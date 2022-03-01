//
//  LDXAssetDownloadGetter.h
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/2/17.
//  Copyright © 2022 LDX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetGetterProtocal.h"

NS_ASSUME_NONNULL_BEGIN

@interface LDXAssetDownloadGetter : NSObject <LDXAssetGetterProtocal>

@property (nonatomic, weak) id<LDXAssetGetterDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
