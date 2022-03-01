//
//  LDXAssetPresentProtocal.h
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/2/17.
//  Copyright © 2022 LDX. All rights reserved.
//

#ifndef LDXAssetPresentProtocal_h
#define LDXAssetPresentProtocal_h

#import <UIKit/UIKit.h>
#import "LDXImagePickerController.h"
@import Photos;

@protocol LDXViewProtocal <NSObject>

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) PHAssetCollection *assetCollection;

- (void)selectChanged:(NSUInteger)count;

@end

//@protocol LDXServiceProtocal <NSObject>
//
//- (instancetype)initWithViewDelegate:(id<LDXViewProtocal>)viewDelegate;
//- (NSArray *)getSelectResult;
//@property (nonatomic, weak) id<LDXImagePickerControllerDelegate,LDXImagePickerControllerProtocal> delegate;
//
//@end


#endif /* LDXAssetPresentProtocal_h */
