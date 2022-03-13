//
//  LDXAsset.h
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/3/11.
//  Copyright © 2022 LDX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDXImagePickerControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LDXAsset : NSObject <LDXAssetProtocol>

@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) LDXPathType type;

@end

NS_ASSUME_NONNULL_END
