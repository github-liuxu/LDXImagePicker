//
//  LDXAlbumFetch.m
//  LDXImagePicker
//
//  Created by Mac-Mini on 2022/2/14.
//  Copyright © 2022 LDX. All rights reserved.
//

#import "LDXAlbumFetch.h"
#import <Photos/Photos.h>

@interface LDXAlbumFetch()

@property (nonatomic, copy) NSArray *fetchResults;
@property (nonatomic, copy) NSArray *subtypes;

@end

@implementation LDXAlbumFetch


- (instancetype)initWithSubtypes:(NSArray *)subtypes
{
    self = [super init];
    if (self) {
        // Fetch user albums and smart albums
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        self.fetchResults = @[smartAlbums, userAlbums];
        self.subtypes = [NSArray arrayWithArray:subtypes];
    }
    return self;
}

#pragma mark - Fetching Asset Collections
- (NSMutableArray *)getAssetCollections
{
    // Filter albums
    NSMutableDictionary *smartAlbums = [NSMutableDictionary dictionaryWithCapacity:self.subtypes.count];
    NSMutableArray *userAlbums = [NSMutableArray array];
    
    for (PHFetchResult *fetchResult in self.fetchResults) {
        [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
            PHAssetCollectionSubtype subtype = assetCollection.assetCollectionSubtype;
            
            if (subtype == PHAssetCollectionSubtypeAlbumRegular) {
                [userAlbums addObject:assetCollection];
            } else if ([self.subtypes containsObject:@(subtype)]) {
                if (!smartAlbums[@(subtype)]) {
                    smartAlbums[@(subtype)] = [NSMutableArray array];
                }
                [smartAlbums[@(subtype)] addObject:assetCollection];
            }
        }];
    }
    
    NSMutableArray *assetCollections = [NSMutableArray array];

    // Fetch smart albums
    for (NSNumber *assetCollectionSubtype in self.subtypes) {
        NSArray *collections = smartAlbums[assetCollectionSubtype];
        
        if (collections) {
            [assetCollections addObjectsFromArray:collections];
        }
    }
    
    // Fetch user albums
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
        [assetCollections addObject:assetCollection];
    }];
    
    return assetCollections;
}

- (NSArray *)fetchResults {
    return _fetchResults;
}

@end
