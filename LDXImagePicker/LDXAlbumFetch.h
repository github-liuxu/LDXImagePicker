//
//  LDXAlbumFetch.h
//  LDXImagePicker
//
//  Created by Mac-Mini on 2022/2/14.
//  Copyright © 2022 LDX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDXImagePickerController.h"
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDXAlbumFetch : NSObject

- (void)fetchAlbumAndDidChange:(void(^)(void))block;
@property (nonatomic, strong) NSArray *subTypes;
@property (nonatomic, strong, readonly) NSMutableArray <PHAssetCollection*>* assetCollections;
- (PHFetchResult<PHAsset *> *)fetchAssetsMediaType:(LDXImagePickerMediaType)mediaType inAssetCollection:(PHAssetCollection *)assetCollection;
+ (void)requestAsset:(PHAsset *)asset targetSize:(CGSize)size complate:(void(^)(UIImage *image))block;

@end

NS_ASSUME_NONNULL_END
