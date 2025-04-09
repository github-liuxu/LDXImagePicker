//
//  LDXAlbumTool.m
//  LDXImagePicker
//
//  Created by 刘东旭 on 4/9/25.
//  Copyright © 2025 LDX. All rights reserved.
//

#import "LDXAlbumTool.h"
#import "LDXImagePickerController.h"

@interface LDXAlbumBlock : NSObject <LDXImagePickerControllerDelegate>
@property (nonatomic, copy) void (^selectBlock)(NSArray<PHAsset *> *selectAssets);
@property (nonatomic, copy) void (^cancelBlock)(void);
@end

static NSMutableArray *_albumObjects;
@implementation LDXAlbumTool

+ (NSMutableArray *)albumObjects {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _albumObjects = [NSMutableArray new];
    });
    return _albumObjects;
}

+ (void)showAlbumWithController:(UIViewController *)vc
                   selectBlock:(void (^)(NSArray<PHAsset *> *))selectBlock
                   cancelBlock:(void (^)(void))cancelBlock
{
    LDXAlbumBlock *albumBlock = [LDXAlbumBlock new];
    [[self albumObjects] addObject:albumBlock];
    
    albumBlock.selectBlock = selectBlock;
    albumBlock.cancelBlock = cancelBlock;
    
    LDXImagePickerController *picker = [LDXImagePickerController new];
    picker.delegate = albumBlock;
    picker.mediaType = LDXImagePickerMediaTypeAny;
    picker.allowsMultipleSelection = YES;
    picker.showsNumberOfSelectedAssets = YES;
    picker.numberOfColumnsInPortrait = 3;
    picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    [vc presentViewController:picker animated:YES completion:nil];
}

@end

@implementation LDXAlbumBlock

#pragma mark - LDXImagePickerControllerDelegate
- (void)ldx_imagePickerControllerDidCancel:(LDXImagePickerController *)imagePickerController {
    [imagePickerController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.cancelBlock) self.cancelBlock();
    
    [[LDXAlbumTool albumObjects] removeObject:self];
}

- (void)ldx_imagePickerController:(LDXImagePickerController *)imagePickerController
             didFinishPickingAssets:(NSArray *)assets {
    [imagePickerController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray<PHAsset *> *resultAssets = [NSMutableArray array];
    if ([assets isKindOfClass:[NSArray class]]) {
        for (id item in assets) {
            if ([item isKindOfClass:[PHAsset class]]) {
                [resultAssets addObject:item];
            }
        }
    }
    
    if (self.selectBlock) self.selectBlock(resultAssets);
    [[LDXAlbumTool albumObjects] removeObject:self];
}

@end
