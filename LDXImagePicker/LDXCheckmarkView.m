//
//  LDXCheckmarkView.m
//  LDXImagePicker
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "LDXCheckmarkView.h"

@implementation LDXCheckmarkView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.indexNumber = 1;
    // Set default values
    self.borderWidth = 1.0;
    self.checkmarkLineWidth = 1.2;
    
    self.borderColor = [UIColor whiteColor];
    self.bodyColor = [UIColor colorWithRed:(20.0 / 255.0) green:(111.0 / 255.0) blue:(223.0 / 255.0) alpha:1.0];
    self.checkmarkColor = [UIColor whiteColor];
    
    // Set shadow
    self.layer.shadowColor = [[UIColor grayColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowRadius = 2.0;
}

- (void)drawRect:(CGRect)rect
{
    // Border
    [self.borderColor setFill];
    [[UIBezierPath bezierPathWithOvalInRect:self.bounds] fill];
    
    // Body
    [self.bodyColor setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, self.borderWidth, self.borderWidth)] fill];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    [[NSString stringWithFormat:@"%ld",(long)self.indexNumber] drawInRect:CGRectInset(rect, 0, 3) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:paragraphStyle}];
//    // Checkmark
//    UIBezierPath *checkmarkPath = [UIBezierPath bezierPath];
//    checkmarkPath.lineWidth = self.checkmarkLineWidth;
//    [checkmarkPath moveToPoint:CGPointMake(CGRectGetWidth(self.bounds) * (6.0 / 24.0), CGRectGetHeight(self.bounds) * (12.0 / 24.0))];
//    [checkmarkPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) * (10.0 / 24.0), CGRectGetHeight(self.bounds) * (16.0 / 24.0))];
//    [checkmarkPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) * (18.0 / 24.0), CGRectGetHeight(self.bounds) * (8.0 / 24.0))];
    
    [self.checkmarkColor setStroke];
//    [checkmarkPath stroke];
}

@end
