//
//  LDXImagePickerController.m
//  LDXImagePicker
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "LDXImagePickerController.h"
#import <Photos/Photos.h>

// ViewControllers
#import "LDXAlbumsViewController.h"

@interface LDXImagePickerController ()

@property (nonatomic, strong) UINavigationController *albumsNavigationController;

@end

@implementation LDXImagePickerController

- (instancetype)init {
    if (self = [super init]) {
        // Set default values
        self.assetCollectionSubtypes = @[
                                         @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                         @(PHAssetCollectionSubtypeAlbumMyPhotoStream),
                                         @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                         @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                         @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos)
                                         ].mutableCopy;
        if (@available(iOS 9.0, *)) {
            [self.assetCollectionSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumSelfPortraits)];
            [self.assetCollectionSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumScreenshots)];
        }
        
        if (@available(iOS 10.3, *)) {
            [self.assetCollectionSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumLivePhotos)];
        }
        
        if (@available(iOS 15.0, *)) {
            [self.assetCollectionSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumRAW)];
        }
        
        self.minimumNumberOfSelection = 1;
        self.numberOfColumnsInPortrait = 4;
        self.numberOfColumnsInLandscape = 7;
        
        _selectedAssets = [NSMutableOrderedSet orderedSet];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self setUp];
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied) {
        [self presentPermissions];
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        __weak typeof(self)weakSelf = self;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
                    [weakSelf presentPermissions];
                } else {
                    [weakSelf setUp];
                }
            });
        }];
    }
}

- (void)presentPermissions {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"No access" message:@"Album access not allowed" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *skipAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertVC addAction:skipAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)setUp{
    [self setUpAlbumsViewController];
    
    // Set instance
    LDXAlbumsViewController *albumsViewController = (LDXAlbumsViewController *)self.albumsNavigationController.topViewController;
    albumsViewController.imagePickerController = self;
}

- (void)setUpAlbumsViewController
{
    // Add LDXAlbumsViewController as a child
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LDXImagePicker" bundle:[NSBundle bundleForClass:[self class]]];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"LDXAlbumsNavigationController"];
    
    [self addChildViewController:navigationController];
    
    navigationController.view.frame = self.view.bounds;
    [self.view addSubview:navigationController.view];
    
    [navigationController didMoveToParentViewController:self];
    
    self.albumsNavigationController = navigationController;
}

@end
