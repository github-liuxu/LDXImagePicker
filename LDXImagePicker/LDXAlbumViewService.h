//
//  LDXAlbumViewService.h
//  LDXImagePicker
//
//  Created by Mac-Mini on 2022/2/14.
//  Copyright © 2022 LDX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "LDXAlbumFetch.h"
#import "LDXImagePickerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LDXAlbumViewService : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithView:(UITableView *)tableView;
- (NSArray *)fetchAlbum:(id <LDXAlbumFetchDelegate>)albumFetch withMediaType:(LDXImagePickerMediaType)mediaType;

@end

NS_ASSUME_NONNULL_END
