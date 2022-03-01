//
//  LDXAssetDownloadGetter.m
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/2/17.
//  Copyright © 2022 LDX. All rights reserved.
//

#import "LDXAssetDownloadGetter.h"
#import "FetchResultProtocal.h"

//image option
static PHImageRequestOptionsVersion imageVersion = PHImageRequestOptionsVersionCurrent;
static PHImageRequestOptionsDeliveryMode imageDeliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//video option
static PHVideoRequestOptionsVersion videoVersion = PHVideoRequestOptionsVersionCurrent;
static PHVideoRequestOptionsDeliveryMode videoDeliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;

@interface LDXAssetDownloadGetter ()

@property (nonatomic, assign) PHImageRequestID requestId;

@end

@implementation LDXAssetDownloadGetter

- (BOOL)assetIsInICloud:(PHAsset*)asset {
    if(!asset || asset == nil)
        return NO;
    
    __block BOOL isInICloud = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    @autoreleasepool {
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
            option.version = videoVersion;
            option.deliveryMode = videoDeliveryMode;
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                            options:option
                                                      resultHandler:^(AVAsset * avAsset, AVAudioMix * audioMix, NSDictionary * info) {
                NSLog(@"%d", [[info objectForKey:PHImageResultIsInCloudKey] boolValue]);
                if (avAsset == nil) {
                    isInICloud = YES;
                } else {
                    isInICloud = NO;
                }
                dispatch_semaphore_signal(semaphore);
            }];
        } else {
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.version = imageVersion;
            options.deliveryMode = imageDeliveryMode;
            options.synchronous = YES;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !imageData) {
                    isInICloud = YES;
                }
                dispatch_semaphore_signal(semaphore);
            }];
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    return isInICloud;
    return false;
}

- (void)getResult:(PHAsset*)asset complate:(void(^)(PHAsset* asset,NSDictionary *info))block {
    if ([self assetIsInICloud:asset]) {
        [self.delegate showProgress];
        __weak typeof(self)weakSelf = self;
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc]init];
            option.networkAccessAllowed = YES;
            option.version = videoVersion;
            option.deliveryMode = videoDeliveryMode;
            option.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
                NSLog(@"%f",progress);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.delegate setProgress:progress];
                });
            };
            weakSelf.requestId = [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset * _Nullable asset1, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (asset1) {
                        block(asset,info);
                    } else {
                        if (![info[PHImageCancelledKey] boolValue]) {//如果不是取消
                        }
                        block(nil,info);
                    }
                    [weakSelf.delegate hiddenProgress];
                });
            }];
        } else {
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.version = imageVersion;
            options.deliveryMode = imageDeliveryMode;
            options.networkAccessAllowed = YES;
            options.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
                NSLog(@"%f",progress);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.delegate setProgress:progress];
                });
            };
            weakSelf.requestId = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (imageData) {
                        block(asset,info);
                        [weakSelf.delegate hiddenProgress];
                    } else {
                        if (![info[PHImageCancelledKey] boolValue]) {//如果不是取消
                        }
                        block(nil,info);
                    }
                    [weakSelf.delegate hiddenProgress];
                });
            }];
        }
    } else {
        block(asset,@{});
    }
}

- (void)cancel {
    [[PHImageManager defaultManager] cancelImageRequest:self.requestId];
    [self.delegate hiddenProgress];
}

@end
