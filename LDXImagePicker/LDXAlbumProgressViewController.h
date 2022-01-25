//
//  LDXAlbumProgressViewController.h
//  LDXAlbumProgressViewController
//
//  Created by 刘东旭 on 2019/5/29.
//  Copyright © 2019 刘东旭. All rights reserved.
//

#import <UIKit/UIkit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDXAlbumProgressViewController : UIViewController

@property (nonatomic, assign) float progress;
@property (nonatomic, copy) NSString *titleStr; //显示第几张图片，默认为否
- (void)setCancelBlock:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
