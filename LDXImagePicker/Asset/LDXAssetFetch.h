//
//  LDXAssetFetch.h
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/2/17.
//  Copyright © 2022 LDX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FetchResultProtocal.h"

NS_ASSUME_NONNULL_BEGIN

@interface LDXAssetFetch : NSObject <LDXFetchResultProtocal>
@property (nonatomic, assign) PHAssetMediaType mediaType;
- (PHFetchResult<PHAsset *> *)getAssetCollection:(PHAssetCollection *)assetCollection;
@end

NS_ASSUME_NONNULL_END
