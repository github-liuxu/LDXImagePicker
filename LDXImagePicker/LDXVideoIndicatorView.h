//
//  LDXVideoIndicatorView.h
//  LDXImagePicker
//
//  Created by Liuxu on 2022/04/04.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LDXVideoIconView.h"
#import "LDXSlomoIconView.h"

@interface LDXVideoIndicatorView : UIView

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet LDXVideoIconView *videoIcon;
@property (nonatomic, weak) IBOutlet LDXSlomoIconView *slomoIcon;


@end
