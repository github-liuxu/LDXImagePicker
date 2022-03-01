//
//  LDXAssetCell.h
//  LDXImagePicker
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDXCheckmarkView.h"
#import "LDXVideoIndicatorView.h"
@import Photos;

@interface LDXAssetCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet LDXVideoIndicatorView *videoIndicatorView;

@property (nonatomic, assign) BOOL showsOverlayViewWhenSelected;
@property (nonatomic, assign) NSUInteger indexNumber;
@property (weak, nonatomic) IBOutlet LDXCheckmarkView *checkmarkView;
@property (nonatomic, strong) PHAsset *asset;

@end
