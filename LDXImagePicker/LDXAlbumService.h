//
//  LDXAlbumService.h
//  LDXImagePicker
//
//  Created by 刘东旭 on 2022/3/12.
//  Copyright © 2022 LDX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDXImagePickerController.h"
#import "LDXAlbumFetch.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LDXViewUpdateProtocol <NSObject>

- (void)updateView;

@end

@interface LDXAlbumService : NSObject

typedef void(^ImageBlock)(UIImage *image);

@property (nonatomic, assign) LDXImagePickerMediaType mediaType;
@property (nonatomic, weak) id<LDXViewUpdateProtocol> delegate;
@property (nonatomic, strong, readonly) LDXAlbumFetch *albumFetch;
- (void)fetchCollectionSubtypes:(NSArray *)subType;

- (NSUInteger)collectionCount;
- (void)requestCollectionThumbnail:(NSUInteger)index targetSizes:(NSArray *)sizes info:(void(^)(NSString *title, NSUInteger assetCount))block imageBlock1:(ImageBlock)image1 imageBlock2:(ImageBlock)image2 imageBlock3:(ImageBlock)image3;

@end

NS_ASSUME_NONNULL_END
