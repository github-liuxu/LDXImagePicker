//
//  LDXImagePickerControllerProtocol.h
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/3/11.
//  Copyright © 2022 LDX. All rights reserved.
//

#ifndef LDXImagePickerControllerProtocol_h
#define LDXImagePickerControllerProtocol_h
@import Photos;

@class LDXImagePickerController;

typedef enum : NSUInteger {
    LDXLocalIdentify,
    LDXLocalPath,
} LDXPathType;

@protocol LDXAssetProtocol <NSObject>

@required
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) LDXPathType type;

@end

@protocol LDXImagePickerControllerDelegate <NSObject>

@optional
- (void)ldx_imagePickerController:(LDXImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets;
- (void)ldx_imagePickerControllerDidCancel:(LDXImagePickerController *)imagePickerController;

- (BOOL)ldx_imagePickerController:(LDXImagePickerController *)imagePickerController shouldSelectAsset:(PHAsset *)asset;
- (void)ldx_imagePickerController:(LDXImagePickerController *)imagePickerController didSelectAsset:(PHAsset *)asset;
- (void)ldx_imagePickerController:(LDXImagePickerController *)imagePickerController didDeselectAsset:(PHAsset *)asset;

@end


#endif /* LDXImagePickerControllerProtocol_h */
