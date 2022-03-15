//
//  LDXAlbumService.m
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/3/12.
//  Copyright © 2022 LDX. All rights reserved.
//

#import "LDXAlbumService.h"
#import "LDXAlbumFetch.h"

@interface LDXAlbumService()

@property (nonatomic, strong) LDXAlbumFetch *albumFetch;

@end

@implementation LDXAlbumService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.albumFetch = [[LDXAlbumFetch alloc] init];
    }
    return self;
}

- (void)fetchCollectionSubtypes:(NSArray *)subType {
    __weak typeof(self)weakSelf = self;
    self.albumFetch.subTypes = subType;
    [self.albumFetch fetchAlbumAndDidChange:^{
        if ([weakSelf.delegate respondsToSelector:@selector(updateView)]) {
            [weakSelf.delegate updateView];
        }
    }];
}

- (NSUInteger)collectionCount {
    return self.albumFetch.assetCollections.count;
}

- (void)requestCollectionThumbnail:(NSUInteger)index targetSizes:(NSArray *)sizes info:(void(^)(NSString *title, NSUInteger assetCount))block imageBlock1:(ImageBlock)image1 imageBlock2:(ImageBlock)image2 imageBlock3:(ImageBlock)image3 {
    PHAssetCollection* assetCollection = [[self.albumFetch assetCollections] objectAtIndex:index];
    PHFetchResult<PHAsset *> *fetchResult = [self.albumFetch fetchAssetsMediaType:LDXImagePickerMediaTypeAny  inAssetCollection:assetCollection];
    NSString *title = assetCollection.localizedTitle;
    NSUInteger count = fetchResult.count;
    block(title, count);
    if (count >= 3) {
        PHAsset *asset = fetchResult.lastObject;
        NSValue *value = sizes.lastObject;
        [LDXAlbumFetch requestAsset:asset targetSize:value.CGSizeValue complate:^(UIImage * _Nonnull image) {
            image3(image);
        }];
    }
    
    if (count >= 2) {
        PHAsset *asset = [fetchResult objectAtIndex:count - 2];
        NSValue *value = sizes[1];
        [LDXAlbumFetch requestAsset:asset targetSize:value.CGSizeValue complate:^(UIImage * _Nonnull image) {
            image2(image);
        }];
    }
    
    if (count >= 1) {
        PHAsset *asset = fetchResult.firstObject;
        NSValue *value = sizes.firstObject;
        [LDXAlbumFetch requestAsset:asset targetSize:value.CGSizeValue complate:^(UIImage * _Nonnull image) {
            image1(image);
        }];
    }
}

@end
