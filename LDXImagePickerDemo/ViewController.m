//
//  ViewController.m
//  LDXImagePickerDemo
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "ViewController.h"
#import <LDXImagePicker/PhotoPickerController.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)openImagePicker:(id)sender {
    PhotoPickerController *picker = [[PhotoPickerController alloc] init];
    picker.selectionMode = SelectionModeMultiple;
    picker.maxSelectionCount = 999;
    
    PhotoPickerCompletionHandler *handler = [[PhotoPickerCompletionHandler alloc] init];
    __weak typeof(self)weakSelf = self;
    handler.didFinishPicking = ^(NSArray<PHAsset *> *assets) {
        // 处理选中的照片
        NSLog(@"选中的照片数量: %lu", (unsigned long)assets.count);
        [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"asset: %@", obj.localIdentifier);
        }];
    };
    handler.didCancel = ^{
        NSLog(@"用户取消了选择");
    };
    
    picker.completionHandler = handler;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
