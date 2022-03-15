//
//  LDXAssetDownload.h
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/2/17.
//  Copyright © 2022 LDX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LDXAssetGetterDelegate <NSObject>

- (void)showProgress;
- (void)hiddenProgress;
- (void)setProgress:(float)progress;

@end

@interface LDXAssetDownload : NSObject

@property (nonatomic, weak) id<LDXAssetGetterDelegate> delegate;
- (void)getResult:(PHAsset*)asset complate:(void(^)(PHAsset* asset,NSDictionary *info))block;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
