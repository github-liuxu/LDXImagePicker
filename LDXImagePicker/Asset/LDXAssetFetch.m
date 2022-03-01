//
//  LDXAssetFetch.m
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/2/17.
//  Copyright © 2022 LDX. All rights reserved.
//

#import "LDXAssetFetch.h"

@implementation LDXAssetFetch

- (PHFetchResult<PHAsset *> *)getAssetCollection:(PHAssetCollection *)assetCollection {
    PHFetchOptions *options = [PHFetchOptions new];
    switch (self.mediaType) {
        case PHAssetMediaTypeImage:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            break;
        case PHAssetMediaTypeVideo:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            break;
        default:
            break;
    }
    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    return fetchResult;
}

@end
