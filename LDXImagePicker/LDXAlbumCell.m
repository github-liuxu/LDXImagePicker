//
//  LDXAlbumCell.m
//  LDXImagePicker
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "LDXAlbumCell.h"
#import "LDXImageUtils.h"

@implementation LDXAlbumCell

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    
    self.imageView1.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.imageView1.layer.borderWidth = borderWidth;
    
    self.imageView2.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.imageView2.layer.borderWidth = borderWidth;
    
    self.imageView3.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.imageView3.layer.borderWidth = borderWidth;
}

- (ImageBlock)image1 {
    __weak typeof(self)weakSelf = self;
    return ^(UIImage *image){
        weakSelf.imageView1.hidden = NO;
        weakSelf.imageView1.image = image;
    };
}

- (ImageBlock)image2 {
    __weak typeof(self)weakSelf = self;
    return ^(UIImage *image){
        weakSelf.imageView2.hidden = NO;
        weakSelf.imageView2.image = image;
    };
}

- (ImageBlock)image3 {
    __weak typeof(self)weakSelf = self;
    return ^(UIImage *image){
        weakSelf.imageView3.hidden = NO;
        weakSelf.imageView3.image = image;
    };
}

- (void)setTitle:(NSString *)title assetCount:(NSUInteger)assetCount {
    self.imageView3.hidden = YES;
    self.imageView2.hidden = YES;
    self.imageView1.hidden = NO;
    
    if (assetCount == 0) {
        // Set placeholder image
        UIImage *placeholderImage = [LDXImageUtils placeholderImageWithSize:self.imageView1.frame.size];
        self.imageView1.image = placeholderImage;
    }
    
    // Album title
    self.titleLabel.text = title;
    
    // Number of photos
    self.countLabel.text = [NSString stringWithFormat:@"%lu", assetCount];
}

@end
