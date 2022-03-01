//
//  LDXAssetsViewController.m
//  LDXImagePicker
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "LDXAssetsViewController.h"
#import <Photos/Photos.h>

// Views
#import "LDXImagePickerController.h"
#import "LDXAssetCell.h"
#import "LDXVideoIndicatorView.h"
#import "LDXAlbumProgressViewController.h"
#import "LDXAlbumToast.h"
#import "LDXUtils.h"
#import "LDXAssetService.h"
#import "LDXAssetDownloadGetter.h"

@interface LDXAssetsViewController () <LDXViewProtocal, LDXAssetGetterDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) PHFetchResult *fetchResult;

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, assign) CGRect previousPreheatRect;

@property (nonatomic, assign) BOOL disableScrollToBottom;
@property (nonatomic, strong) NSIndexPath *lastSelectedItemIndexPath;

@property (nonatomic, weak) LDXAlbumProgressViewController *progressVC;
@property (nonatomic, strong) LDXAssetService *assetService;

@property (nonatomic, strong) LDXAssetDownloadGetter *assetGetter;

@end

@implementation LDXAssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpToolbarItems];
    self.assetService = [[LDXAssetService alloc] initWithViewDelegate:self];
    self.assetService.imagePickerController = self.imagePickerController;
    self.assetGetter = [[LDXAssetDownloadGetter alloc] init];
    self.assetGetter.delegate = self;
    self.assetService.assetGetter = self.assetGetter;

    [self.assetService resetCachedAssets];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Configure navigation item
    self.navigationItem.title = self.assetCollection.localizedTitle;
    self.navigationItem.prompt = self.imagePickerController.prompt;
    // Configure collection view
    self.collectionView.allowsMultipleSelection = self.imagePickerController.allowsMultipleSelection;
    // Show/hide 'Done' button
    if (self.imagePickerController.allowsMultipleSelection) {
        [self.navigationItem setRightBarButtonItem:self.doneButton animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
    
    [self.assetService fetchAsset];
    [self updateDoneButtonState];
    [self updateSelectionInfo];
    [self.collectionView reloadData];
    
    // Scroll to bottom
    [self.assetService scrollLastSelect];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.disableScrollToBottom = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.disableScrollToBottom = NO;
    [self.assetService updateCachedAssets];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // Save indexPath for the last item
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    
    // Update layout
    [self.collectionViewLayout invalidateLayout];
    
    // Restore scroll position
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }];
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    if ([self.imagePickerController.delegate respondsToSelector:@selector(ldx_imagePickerController:didFinishPickingAssets:)]) {
        [self.imagePickerController.delegate ldx_imagePickerController:self.imagePickerController
                                                didFinishPickingAssets:[self.assetService getSelectResult].array];
    }
}

#pragma mark - Toolbar

- (void)setUpToolbarItems {
    // Space
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    // Info label
    NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    UIBarButtonItem *infoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    infoButtonItem.enabled = NO;
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    
    self.toolbarItems = @[leftSpace, infoButtonItem, rightSpace];
}

- (void)updateSelectionInfo {
    NSMutableOrderedSet *selectedAssets = self.imagePickerController.selectedAssets;
    if (selectedAssets.count > 0) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *format;
        if (selectedAssets.count > 1) {
            format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.items-selected", @"LDXImagePicker", bundle, nil);
        } else {
            format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.item-selected", @"LDXImagePicker", bundle, nil);
        }
        
        NSString *title = [NSString stringWithFormat:format, selectedAssets.count];
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:title];
    } else {
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:@""];
    }
}

#pragma mark - PresenterDelegate
- (void)hiddenProgress {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)selectChanged:(NSUInteger)count {
    [self updateSelectionInfo];
    [self updateDoneButtonState];
}

- (void)setProgress:(float)progress {
    self.progressVC.progress = progress;
}

- (void)showProgress {
    //资源在iCloud上
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Asset in iCloud"
                                                                             message:@"Download?"
                                                                      preferredStyle:UIAlertControllerStyleAlert ];
    //添加取消到UIAlertController中
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^ (UIAlertAction *action){

    }];
    [alertController addAction:cancelAction];
    //添加确定到UIAlertController中
    __weak typeof(self)weakSelf = self;
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleDefault handler:^ (UIAlertAction *action){
        LDXAlbumProgressViewController *progressVC = [LDXAlbumProgressViewController new];
        weakSelf.progressVC = progressVC;
        [weakSelf.progressVC setCancelBlock:^{
            [weakSelf.assetGetter cancel];
        }];
        
        weakSelf.definesPresentationContext = YES;
        weakSelf.progressVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [weakSelf.navigationController presentViewController:progressVC animated:YES completion:NULL];
    }];
    
    [alertController addAction:OKAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Checking for Selection Limit
- (void)updateDoneButtonState {
    self.doneButton.enabled = [self isMinimumSelectionLimitFulfilled];
}

- (BOOL)isMinimumSelectionLimitFulfilled {
    return (self.imagePickerController.minimumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
}


- (void)reloadVisibleIndex {

}

- (BOOL)isAutoDeselectEnabled {
    return (self.imagePickerController.maximumNumberOfSelection == 1
            && self.imagePickerController.maximumNumberOfSelection >= self.imagePickerController.minimumNumberOfSelection);
}

- (void)SelectItemAtIndex:(LDXImagePickerController *)imagePickerController selectedAssets:(NSMutableOrderedSet *)selectedAssets asset:(PHAsset *)asset indexPath:(NSIndexPath *)indexPath {
    if (imagePickerController.allowsMultipleSelection) {
        if ([self isAutoDeselectEnabled] && selectedAssets.count > 0) {
            // Remove previous selected asset from set
            [selectedAssets removeObjectAtIndex:0];
            [self reloadVisibleIndex];
            // Deselect previous selected asset
            if (self.lastSelectedItemIndexPath) {
                [self.collectionView deselectItemAtIndexPath:self.lastSelectedItemIndexPath animated:NO];
            }
        }
        
        // Add asset to set
        [selectedAssets addObject:asset];
        [self reloadVisibleIndex];
        self.lastSelectedItemIndexPath = indexPath;
        
        [self updateDoneButtonState];
        
        if (imagePickerController.showsNumberOfSelectedAssets) {
            [self updateSelectionInfo];
            
            if (selectedAssets.count == 1) {
                // Show toolbar
                [self.navigationController setToolbarHidden:NO animated:YES];
            }
        }
    } else {
        if ([imagePickerController.delegate respondsToSelector:@selector(ldx_imagePickerController:didFinishPickingAssets:)]) {
            [imagePickerController.delegate ldx_imagePickerController:imagePickerController didFinishPickingAssets:@[asset]];
        }
    }
    
    if ([imagePickerController.delegate respondsToSelector:@selector(ldx_imagePickerController:didSelectAsset:)]) {
        [imagePickerController.delegate ldx_imagePickerController:imagePickerController didSelectAsset:asset];
    }
}

@end
