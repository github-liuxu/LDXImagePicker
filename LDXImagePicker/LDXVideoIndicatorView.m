//
//  LDXVideoIndicatorView.m
//  LDXImagePicker
//
//  Created by Liuxu on 2022/04/04.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "LDXVideoIndicatorView.h"

@implementation LDXVideoIndicatorView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Add gradient layer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[
                             (__bridge id)[[UIColor clearColor] CGColor],
                             (__bridge id)[[UIColor blackColor] CGColor]
                             ];
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

@end
