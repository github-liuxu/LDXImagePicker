//
//  LDXAlbumCell.h
//  LDXImagePicker
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDXAlbumCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (nonatomic, assign) CGFloat borderWidth;

@end
