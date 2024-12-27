//
//  LDXImagePickerController.h
//  LDXImagePicker
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@class LDXImagePickerController;

@protocol LDXImagePickerControllerDelegate <NSObject>

@optional
- (void)ldx_imagePickerController:(LDXImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets;
- (void)ldx_imagePickerControllerDidCancel:(LDXImagePickerController *)imagePickerController;

- (BOOL)ldx_imagePickerController:(LDXImagePickerController *)imagePickerController shouldSelectAsset:(PHAsset *)asset;
- (void)ldx_imagePickerController:(LDXImagePickerController *)imagePickerController didSelectAsset:(PHAsset *)asset;
- (void)ldx_imagePickerController:(LDXImagePickerController *)imagePickerController didDeselectAsset:(PHAsset *)asset;

@end

typedef NS_ENUM(NSUInteger, LDXImagePickerMediaType) {
    LDXImagePickerMediaTypeAny = 0,
    LDXImagePickerMediaTypeImage,
    LDXImagePickerMediaTypeVideo
};

@interface LDXImagePickerController : UIViewController

@property (nonatomic, weak) id<LDXImagePickerControllerDelegate> delegate;
@property (nonatomic, assign) LDXImagePickerMediaType mediaType;
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;
@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, assign) BOOL showsNumberOfSelectedAssets;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray *assetCollectionSubtypes;
@property (nonatomic, assign) NSUInteger numberOfColumnsInPortrait;
@property (nonatomic, assign) NSUInteger numberOfColumnsInLandscape;

@end
