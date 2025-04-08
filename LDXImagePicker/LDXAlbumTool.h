//
//  LDXAlbumTool.h
//  LDXImagePicker
//
//  Created by 刘东旭 on 4/9/25.
//  Copyright © 2025 LDX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDXAlbumTool : NSObject
+ (void)showAlbumWithController:(UIViewController *)vc
                   selectBlock:(void (^)(NSArray<PHAsset *> *))selectBlock
                   cancelBlock:(void (^)(void))cancelBlock;
@end

NS_ASSUME_NONNULL_END
