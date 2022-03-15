//
//  LDXAlbumFetch.m
//  LDXImagePicker
//
//  Created by Mac-Mini on 2022/2/14.
//  Copyright © 2022 LDX. All rights reserved.
//

#import "LDXAlbumFetch.h"

@interface LDXAlbumFetch()<PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) NSArray *fetchResults;
@property (nonatomic, strong) NSMutableArray <PHAssetCollection*>* assetCollections;
@property (nonatomic, strong) void(^albumChange)(void);

@end

@implementation LDXAlbumFetch

- (instancetype)init {
    self = [super init];
    if (self) {
        self.assetCollections = [NSMutableArray array];
    }
    return self;
}

- (void)fetchAlbumAndDidChange:(void(^)(void))block {
    // Fetch user albums and smart albums
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    self.fetchResults = @[smartAlbums, userAlbums];
    self.assetCollections = [self fetchCollections];
    self.albumChange = block;
    
    // Register observer
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (NSMutableArray <PHAssetCollection*>*)fetchCollections {
    // Filter albums
    [self.assetCollections removeAllObjects];
    NSMutableDictionary *smartAlbums = [NSMutableDictionary dictionary];
    NSMutableArray *userAlbums = [NSMutableArray array];
    
    for (PHFetchResult *fetchResult in self.fetchResults) {
        [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
            PHAssetCollectionSubtype subtype = assetCollection.assetCollectionSubtype;
            if (subtype == PHAssetCollectionSubtypeAlbumRegular) {
                [userAlbums addObject:assetCollection];
            } else if ([self.subTypes containsObject:@(subtype)]) {
                if (!smartAlbums[@(subtype)]) {
                    smartAlbums[@(subtype)] = [NSMutableArray array];
                }
                [smartAlbums[@(subtype)] addObject:assetCollection];
            }
        }];
    }
    
    // Fetch smart albums
    NSArray *collections = [smartAlbums allValues];
    [collections enumerateObjectsUsingBlock:^(NSArray *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.assetCollections addObject:assetCollection];
        }];
    }];
    
    // Fetch user albums
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
        [self.assetCollections addObject:assetCollection];
    }];
    
    return self.assetCollections;
}

- (PHFetchResult<PHAsset *> *)fetchAssetsMediaType:(LDXImagePickerMediaType)mediaType inAssetCollection:(PHAssetCollection *)assetCollection {
    PHFetchOptions *options = [PHFetchOptions new];
    switch (mediaType) {
        case PHAssetMediaTypeImage:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            break;
        case PHAssetMediaTypeVideo:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            break;
        default:
            break;
    }
    return [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
}

+ (void)requestAsset:(PHAsset *)asset targetSize:(CGSize)size complate:(void(^)(UIImage *image))block {
    PHImageManager *imageManager = [PHImageManager defaultManager];
    [imageManager requestImageForAsset:asset
                            targetSize:size
                           contentMode:PHImageContentModeAspectFill
                               options:nil
                         resultHandler:^(UIImage *result, NSDictionary *info) {
        block(result);
    }];
}


#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update fetch results
        NSMutableArray *fetchResults = [self.fetchResults mutableCopy];
        [self.fetchResults enumerateObjectsUsingBlock:^(PHFetchResult *fetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:fetchResult];
            if (changeDetails) {
                [fetchResults replaceObjectAtIndex:index withObject:changeDetails.fetchResultAfterChanges];
            }
        }];
        
        if (![self.fetchResults isEqualToArray:fetchResults]) {
            self.fetchResults = fetchResults;
            // Reload albums
            self.assetCollections = [self fetchCollections];
            self.albumChange();
        }
    });
}

- (void)dealloc {
    // Deregister observer
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
 
@end
