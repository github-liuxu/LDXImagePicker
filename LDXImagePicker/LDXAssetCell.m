//
//  LDXAssetCell.m
//  LDXImagePicker
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "LDXAssetCell.h"

@interface LDXAssetCell ()

@property (weak, nonatomic) IBOutlet UIView *overlayView;

@end

@implementation LDXAssetCell

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    // Show/hide overlay view
    self.overlayView.hidden = !(selected && self.showsOverlayViewWhenSelected);
}

- (void)setIndexNumber:(NSUInteger)indexNumber {
    _indexNumber = indexNumber;
    self.checkmarkView.indexNumber = indexNumber;
    [self.checkmarkView setNeedsDisplay];
}

@end
