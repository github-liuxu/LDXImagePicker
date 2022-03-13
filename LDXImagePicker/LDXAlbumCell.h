//
//  LDXAlbumCell.h
//  LDXImagePicker
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ImageBlock)(UIImage *image);

@interface LDXAlbumCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (copy, nonatomic) ImageBlock image1;
@property (copy, nonatomic) ImageBlock image2;
@property (copy, nonatomic) ImageBlock image3;

@property (nonatomic, assign) CGFloat borderWidth;

- (void)setTitle:(NSString *)title assetCount:(NSUInteger)assetCount;

@end
