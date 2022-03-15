//
//  LDXAssetsViewController.h
//  LDXImagePicker
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDXAlbumFetch.h"

@class LDXImagePickerController;
@class PHAssetCollection;

@interface LDXAssetsViewController : UICollectionViewController

@property (nonatomic, weak) LDXImagePickerController *imagePickerController;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end
