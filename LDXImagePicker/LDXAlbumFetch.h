//
//  LDXAlbumFetch.h
//  LDXImagePicker
//
//  Created by Mac-Mini on 2022/2/14.
//  Copyright © 2022 LDX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LDXAlbumFetchDelegate <NSObject>
@required
- (instancetype)initWithSubtypes:(NSArray /*<PHAssetCollectionSubtype>*/*)subtypes;
- (NSMutableArray *)getAssetCollections;
- (NSArray *)fetchResults;
@end

@interface LDXAlbumFetch : NSObject <LDXAlbumFetchDelegate>

- (instancetype)initWithSubtypes:(NSArray /*<PHAssetCollectionSubtype>*/*)subtypes;
- (NSMutableArray *)getAssetCollections;
- (NSArray *)fetchResults;

@end

NS_ASSUME_NONNULL_END
