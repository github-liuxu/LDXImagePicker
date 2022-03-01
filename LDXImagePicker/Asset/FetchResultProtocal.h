//
//  FetchResultProtocal.h
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/2/17.
//  Copyright © 2022 LDX. All rights reserved.
//

#ifndef FetchResultProtocal_h
#define FetchResultProtocal_h
@import Photos;

@protocol LDXFetchResultProtocal <NSObject>

@property (nonatomic, assign) PHAssetMediaType mediaType;
- (PHFetchResult<PHAsset *> *)getAssetCollection:(PHAssetCollection *)assetCollection;
@end


#endif /* FetchResultProtocal_h */
