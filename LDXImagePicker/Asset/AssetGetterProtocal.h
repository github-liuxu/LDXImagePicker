//
//  AssetGetterProtocal.h
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/2/17.
//  Copyright © 2022 LDX. All rights reserved.
//

#ifndef AssetGetterProtocal_h
#define AssetGetterProtocal_h

#import "AssetGetterProtocal.h"
#import "FetchResultProtocal.h"

@protocol LDXAssetGetterDelegate <NSObject>

- (void)showProgress;
- (void)hiddenProgress;
- (void)setProgress:(float)progress;

@end

@protocol LDXAssetGetterProtocal <NSObject>

- (void)getResult:(PHAsset*)asset complate:(void(^)(PHAsset* asset,NSDictionary *info))block;
- (void)cancel;

@end

#endif /* AssetGetterProtocal_h */
