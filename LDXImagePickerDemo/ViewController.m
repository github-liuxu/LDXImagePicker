//
//  ViewController.m
//  LDXImagePickerDemo
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "ViewController.h"
#import <LDXImagePicker/LDXImagePicker.h>

@interface ViewController () <LDXImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LDXImagePickerController *imagePickerController = [LDXImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.mediaType = LDXImagePickerMediaTypeAny;
    imagePickerController.allowsMultipleSelection = (indexPath.section == 1);
    imagePickerController.showsNumberOfSelectedAssets = YES;
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 1:
                imagePickerController.minimumNumberOfSelection = 3;
                break;
                
            case 2:
                imagePickerController.maximumNumberOfSelection = 6;
                break;
                
            case 3:
                imagePickerController.minimumNumberOfSelection = 3;
                imagePickerController.maximumNumberOfSelection = 6;
                break;

            case 4:
                imagePickerController.maximumNumberOfSelection = 2;
                [imagePickerController.selectedAssets addObject:[PHAsset fetchAssetsWithOptions:nil].lastObject];
                break;
                
            default:
                break;
        }
    }
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}


#pragma mark - LDXImagePickerControllerDelegate

- (void)ldx_imagePickerController:(LDXImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"Selected assets:");
    NSLog(@"%@", assets);
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)ldx_imagePickerControllerDidCancel:(LDXImagePickerController *)imagePickerController
{
    NSLog(@"Canceled.");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
