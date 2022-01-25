//
//  LDXAlbumCircleView.m
//  HWProgress
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "LDXAlbumCircleView.h"

@interface LDXAlbumCircleView () {
    float circleLineWidth;
    UIFont *circleFont;
    UIColor *circleColor;
}

@property (nonatomic, weak) UILabel *cLabel;

@end

@implementation LDXAlbumCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        circleLineWidth = 2.0f;
        circleFont = [UIFont boldSystemFontOfSize:15.0f];
        circleColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        //百分比标签
        UILabel *cLabel = [[UILabel alloc] initWithFrame:self.bounds];
        cLabel.font = circleFont;
        cLabel.textColor = circleColor;
        cLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:cLabel];
        self.cLabel = cLabel;
    }
    
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    _cLabel.text = [NSString stringWithFormat:@"%d%%", (int)floor(progress * 100)];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    //路径
    UIBezierPath *path = [[UIBezierPath alloc] init];
    //线宽
    path.lineWidth = circleLineWidth;
    //颜色
    [circleColor set];
    //拐角
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    //半径
    CGFloat radius = (MIN(rect.size.width, rect.size.height) - circleLineWidth) * 0.5;
    //画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
    [path addArcWithCenter:(CGPoint){rect.size.width * 0.5, rect.size.height * 0.5} radius:radius startAngle:M_PI * 1.5 endAngle:M_PI * 1.5 + M_PI * 2 * _progress clockwise:YES];
    //连线
    [path stroke];
}

@end

