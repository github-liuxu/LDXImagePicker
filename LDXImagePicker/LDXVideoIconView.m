//
//  LDXVideoIconView.m
//  LDXImagePicker
//
//  Created by Liuxu on 2022/04/04.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "LDXVideoIconView.h"

@implementation LDXVideoIconView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Set default values
    self.iconColor = [UIColor whiteColor];
}

- (void)drawRect:(CGRect)rect
{
    [self.iconColor setFill];
    
    // Draw triangle
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds))];
    [trianglePath addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds))];
    [trianglePath addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds) - CGRectGetMidY(self.bounds), CGRectGetMidY(self.bounds))];
    [trianglePath closePath];
    [trianglePath fill];
    
    // Draw rounded square
    UIBezierPath *squarePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds) - CGRectGetMidY(self.bounds) - 1.0, CGRectGetHeight(self.bounds)) cornerRadius:2.0];
    [squarePath fill];
}

@end
