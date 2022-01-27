//
//  EMPToast.m
//  MintLive
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "LDXAlbumToast.h"

@implementation LDXAlbumToast

+ (void)showInfoWithMessage:(NSString *)message inView:(UIView *)view {
    UILabel *lable = [[UILabel alloc] init];
    lable.backgroundColor = UIColor.blackColor;
    lable.text = message;
    lable.textColor = UIColor.whiteColor;
    lable.numberOfLines = 0;
    lable.lineBreakMode = NSLineBreakByTruncatingTail;
    lable.textAlignment = NSTextAlignmentCenter;
    CGSize size = [lable sizeThatFits:CGSizeMake(300, 300)];
    size = CGSizeMake(size.width + 30, size.height + 20);
    lable.frame = CGRectMake((view.frame.size.width - size.width)/2, (view.frame.size.height - size.height)/2, size.width, size.height);
    [view addSubview:lable];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [lable removeFromSuperview];
    });
}

@end
