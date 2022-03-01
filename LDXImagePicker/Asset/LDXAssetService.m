//
//  LDXAssetService.m
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/2/17.
//  Copyright © 2022 LDX. All rights reserved.
//

#import "LDXAssetService.h"
#import "LDXAssetFetch.h"
#import "AssetGetterProtocal.h"
#import "LDXAssetDownloadGetter.h"
#import "FetchResultProtocal.h"
#import "LDXAssetCell.h"
#import <UIKit/UIKit.h>
#import "LDXUtils.h"
#import "LDXAlbumToast.h"

@implementation NSIndexSet (Convenience)

- (NSArray *)ldx_indexPathsFromIndexesWithSection:(NSUInteger)section
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}

@end

@implementation UICollectionView (Convenience)

- (NSArray *)ldx_indexPathsForElementsInRect:(CGRect)rect
{
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

@end

@interface LDXAssetService () <UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) id<LDXFetchResultProtocal> assetFetch;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *fetchResult;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, weak) UIViewController<LDXViewProtocal> *viewDelegate;
@property (nonatomic, assign) CGRect previousPreheatRect;
@end

@implementation LDXAssetService

- (instancetype)initWithViewDelegate:(UIViewController<LDXViewProtocal>*)viewDelegate; {
    self = [super init];
    if (self) {
        self.viewDelegate = viewDelegate;
        self.viewDelegate.collectionView.delegate = self;
        self.viewDelegate.collectionView.dataSource = self;
        self.imageManager = [PHCachingImageManager new];
        self.assetFetch = [[LDXAssetFetch alloc] init];
        
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}

- (void)fetchAsset {
    __weak typeof(self)weakSelf = self;
    self.fetchResult = [self.assetFetch getAssetCollection:self.viewDelegate.assetCollection];
    [weakSelf.viewDelegate.collectionView reloadData];
}

- (NSMutableOrderedSet *)getSelectResult {
    return self.imagePickerController.selectedAssets;
}

- (void)scrollLastSelect {
    // Scroll to bottom
    if (self.imagePickerController.selectedAssets.count > 0) {
        // when presenting as a .FormSheet on iPad, the frame is not correct until just after viewWillAppear:
        // dispatching to the main thread waits one run loop until the frame is update and the layout is complete
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger index = [self.fetchResult indexOfObject:self.imagePickerController.selectedAssets.lastObject];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [self.viewDelegate.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.fetchResult.count - 1) inSection:0];
            [self.viewDelegate.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        });
    }
}

#pragma mark - Asset Caching
- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self.viewDelegate isViewLoaded] && self.viewDelegate.view.window != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.viewDelegate.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    
    if (delta > CGRectGetHeight(self.viewDelegate.collectionView.bounds) / 3.0) {
        // Compute the assets to start caching and to stop caching
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.viewDelegate.collectionView ldx_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        } removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.viewDelegate.collectionView ldx_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        CGSize itemSize = [(UICollectionViewFlowLayout *)self.viewDelegate.collectionView.collectionViewLayout itemSize];
        CGSize targetSize = CGSizeScale(itemSize, [[UIScreen mainScreen] scale]);
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:targetSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:targetSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect addedHandler:(void (^)(CGRect addedRect))addedHandler removedHandler:(void (^)(CGRect removedRect))removedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.item < self.fetchResult.count) {
            PHAsset *asset = self.fetchResult[indexPath.item];
            [assets addObject:asset];
        }
    }
    return assets;
}

- (void)reloadVisibleIndex {
    NSMutableArray <LDXAssetCell *>*visibleCell = [NSMutableArray arrayWithArray:[self.viewDelegate.collectionView visibleCells]];
    [self.imagePickerController.selectedAssets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idxNum, BOOL * _Nonnull stop) {
        [visibleCell enumerateObjectsUsingBlock:^(LDXAssetCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stopCell) {
            if (obj.asset == asset) {
                [obj setSelected:YES];
                [obj setIndexNumber:idxNum + 1];
                [obj.checkmarkView setNeedsDisplay];
                [visibleCell removeObject:obj];
                *stopCell = true;
            }
        }];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCachedAssets];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LDXAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    cell.tag = indexPath.item;
    cell.showsOverlayViewWhenSelected = self.imagePickerController.allowsMultipleSelection;
    
    // Image
    PHAsset *asset = self.fetchResult[indexPath.item];
    CGSize itemSize = [(UICollectionViewFlowLayout *)collectionView.collectionViewLayout itemSize];
    CGSize targetSize = CGSizeScale(itemSize, [[UIScreen mainScreen] scale]);
    cell.asset = asset;
    [self.imageManager requestImageForAsset:asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
        if (cell.tag == indexPath.item) {
            cell.imageView.image = result;
        }
    }];
    
    // Video indicator
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.videoIndicatorView.hidden = NO;
        
        NSInteger minutes = (NSInteger)(asset.duration / 60.0);
        NSInteger seconds = (NSInteger)ceil(asset.duration - 60.0 * (double)minutes);
        cell.videoIndicatorView.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
        
        if (asset.mediaSubtypes & PHAssetMediaSubtypeVideoHighFrameRate) {
            cell.videoIndicatorView.videoIcon.hidden = YES;
            cell.videoIndicatorView.slomoIcon.hidden = NO;
        }
        else {
            cell.videoIndicatorView.videoIcon.hidden = NO;
            cell.videoIndicatorView.slomoIcon.hidden = YES;
        }
    } else {
        cell.videoIndicatorView.hidden = YES;
    }
    
    // Selection state
    if ([self.imagePickerController.selectedAssets containsObject:asset]) {
        [cell setSelected:YES];
        NSUInteger indexNumber = [self.imagePickerController.selectedAssets indexOfObject:asset];
        cell.indexNumber = indexNumber + 1;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.fetchResult[indexPath.item];
    if ([self.imagePickerController.delegate respondsToSelector:@selector(ldx_imagePickerController:shouldSelectAsset:)]) {
        return [self.imagePickerController.delegate ldx_imagePickerController:self.imagePickerController shouldSelectAsset:asset];
    }
    
    if ([self isAutoDeselectEnabled]) {
        return YES;
    }
    
    return ![self isMaximumSelectionLimitReached];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.fetchResult[indexPath.row];
    __weak typeof(self)weakSelf = self;
    [self.assetGetter getResult:asset complate:^(PHAsset *asset, NSDictionary *info) {
        if (asset) {
            if (weakSelf.imagePickerController.allowsMultipleSelection) {
                [weakSelf.imagePickerController.selectedAssets addObject:weakSelf.fetchResult[indexPath.row]];
                [weakSelf.viewDelegate selectChanged:weakSelf.imagePickerController.selectedAssets.count];
                [weakSelf reloadVisibleIndex];
            } else {
                if ([weakSelf.imagePickerController.delegate respondsToSelector:@selector(ldx_imagePickerController:didFinishPickingAssets:)]) {
                    [weakSelf.imagePickerController.delegate ldx_imagePickerController:weakSelf.imagePickerController didFinishPickingAssets:@[asset]];
                }
            }
            if ([weakSelf.imagePickerController.delegate respondsToSelector:@selector(ldx_imagePickerController:didSelectAsset:)]) {
                [weakSelf.imagePickerController.delegate ldx_imagePickerController:weakSelf.imagePickerController didSelectAsset:asset];
            }
        } else {
            if (![info[PHImageCancelledKey] boolValue]) {//如果不是取消
                [LDXAlbumToast showInfoWithMessage:@"下载失败" inView:weakSelf.viewDelegate.collectionView];
            } else {
                [LDXAlbumToast showInfoWithMessage:@"下载取消" inView:weakSelf.viewDelegate.collectionView];
            }
        }
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [self.imagePickerController.selectedAssets indexOfObject:self.fetchResult[indexPath.row]];
    if ([self.imagePickerController.selectedAssets containsObject:self.fetchResult[indexPath.row]]) {
        [self.imagePickerController.selectedAssets removeObjectAtIndex:index];
    }
    [self.viewDelegate selectChanged:self.imagePickerController.selectedAssets.count];
    [self reloadVisibleIndex];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                  withReuseIdentifier:@"FooterView"
                                                                                         forIndexPath:indexPath];
        
        // Number of assets
        UILabel *label = (UILabel *)[footerView viewWithTag:1];
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSUInteger numberOfPhotos = [self.fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        NSUInteger numberOfVideos = [self.fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
        
        switch (self.imagePickerController.mediaType) {
            case LDXImagePickerMediaTypeAny:
            {
                NSString *format;
                if (numberOfPhotos == 1) {
                    if (numberOfVideos == 1) {
                        format = NSLocalizedStringFromTableInBundle(@"assets.footer.photo-and-video", @"LDXImagePicker", bundle, nil);
                    } else {
                        format = NSLocalizedStringFromTableInBundle(@"assets.footer.photo-and-videos", @"LDXImagePicker", bundle, nil);
                    }
                } else if (numberOfVideos == 1) {
                    format = NSLocalizedStringFromTableInBundle(@"assets.footer.photos-and-video", @"LDXImagePicker", bundle, nil);
                } else {
                    format = NSLocalizedStringFromTableInBundle(@"assets.footer.photos-and-videos", @"LDXImagePicker", bundle, nil);
                }
                
                label.text = [NSString stringWithFormat:format, numberOfPhotos, numberOfVideos];
            }
                break;
                
            case LDXImagePickerMediaTypeImage:
            {
                NSString *key = (numberOfPhotos == 1) ? @"assets.footer.photo" : @"assets.footer.photos";
                NSString *format = NSLocalizedStringFromTableInBundle(key, @"LDXImagePicker", bundle, nil);
                
                label.text = [NSString stringWithFormat:format, numberOfPhotos];
            }
                break;
                
            case LDXImagePickerMediaTypeVideo:
            {
                NSString *key = (numberOfVideos == 1) ? @"assets.footer.video" : @"assets.footer.videos";
                NSString *format = NSLocalizedStringFromTableInBundle(key, @"LDXImagePicker", bundle, nil);
                
                label.text = [NSString stringWithFormat:format, numberOfVideos];
            }
                break;
        }
        
        return footerView;
    }
    
    return nil;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfColumns;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        numberOfColumns = self.imagePickerController.numberOfColumnsInPortrait;
    } else {
        numberOfColumns = self.imagePickerController.numberOfColumnsInLandscape;
    }
    
    CGFloat width = (CGRectGetWidth(self.viewDelegate.collectionView.frame) - 2.0 * (numberOfColumns - 1)) / numberOfColumns;
    return CGSizeMake(width, width);
}

- (BOOL)isAutoDeselectEnabled {
    return (self.imagePickerController.maximumNumberOfSelection == 1
            && self.imagePickerController.maximumNumberOfSelection >= self.imagePickerController.minimumNumberOfSelection);
}

- (BOOL)isMinimumSelectionLimitFulfilled {
    return (self.imagePickerController.minimumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
}

- (BOOL)isMaximumSelectionLimitReached {
    NSUInteger minimumNumberOfSelection = MAX(1, self.imagePickerController.minimumNumberOfSelection);
    
    if (minimumNumberOfSelection <= self.imagePickerController.maximumNumberOfSelection) {
        return (self.imagePickerController.maximumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
    }
    
    return NO;
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.fetchResult];
        if (collectionChanges) {
            // Get the new fetch result
            self.fetchResult = [collectionChanges fetchResultAfterChanges];
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                // We need to reload all if the incremental diffs are not available
                [self.viewDelegate.collectionView reloadData];
            } else {
                // If we have incremental diffs, tell the collection view to animate insertions and deletions
                [self.viewDelegate.collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count]) {
                        [self.viewDelegate.collectionView deleteItemsAtIndexPaths:[removedIndexes ldx_indexPathsFromIndexesWithSection:0]];
                    }
                    
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count]) {
                        [self.viewDelegate.collectionView insertItemsAtIndexPaths:[insertedIndexes ldx_indexPathsFromIndexesWithSection:0]];
                    }
                    
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count]) {
                        [self.viewDelegate.collectionView reloadItemsAtIndexPaths:[changedIndexes ldx_indexPathsFromIndexesWithSection:0]];
                    }
                } completion:NULL];
            }
            [self resetCachedAssets];
        }
    });
}

- (void)dealloc {
    // Deregister observer
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
@end
