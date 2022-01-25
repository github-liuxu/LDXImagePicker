//
//  EMPToast.h
//  MintLive
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EMPToastProgressBlock)(CGFloat progress);

@interface LDXAlbumToast : NSObject
//hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//hud.bezelView.backgroundColor = [UIColor clearColor];
//以下方法会拦截用户交互
+ (void)showLoading;
+ (void)showLoadingWithMessage:(NSString *)message;
+ (void)showLoadingInView:(UIView *)view;
+ (void)showLoadingInView:(UIView *)view message:(NSString *)message interaction:(BOOL)interaction;
+ (void)dismiss;
+ (void)dismissInView:(UIView *)view;
+ (void)dismissAniamted:(BOOL)aniamted;
+ (void)dismissInView:(UIView *)view animated:(BOOL)animated;
+ (void)showCompileWithMessage:(NSString *)message;
+ (EMPToastProgressBlock)showProgressWithMessage:(NSString *)message;
+ (void)showHorizontalProgressWithMessage:(NSString *)message progress:(CGFloat)progress;
//以下方法不拦截交互
+ (void)showInfoWithMessage:(NSString *)message;
+ (void)showSuccessWithMessage:(NSString *)message;
+ (void)showErrorWithMessage:(NSString *)message;

+ (void)showInfoWithMessage:(NSString *)message inView:(UIView *)view;
+ (void)dismissAniamted:(BOOL)aniamted inView:(UIView *)view;

@end
