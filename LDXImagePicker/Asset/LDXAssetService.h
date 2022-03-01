//
//  LDXAssetService.h
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/2/17.
//  Copyright © 2022 LDX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDXAssetPresentProtocal.h"
#import "LDXImagePickerController.h"
#import "AssetGetterProtocal.h"
@import Photos;

NS_ASSUME_NONNULL_BEGIN

@interface LDXAssetService : NSObject

- (instancetype)initWithViewDelegate:(UIViewController<LDXViewProtocal>*)viewDelegate;
- (NSMutableOrderedSet *)getSelectResult;
@property (nonatomic, weak) LDXImagePickerController *imagePickerController;
@property (nonatomic, weak) id<LDXAssetGetterProtocal> assetGetter;
- (void)fetchAsset;
- (void)resetCachedAssets;
- (void)updateCachedAssets;
- (void)scrollLastSelect;
@end

NS_ASSUME_NONNULL_END
