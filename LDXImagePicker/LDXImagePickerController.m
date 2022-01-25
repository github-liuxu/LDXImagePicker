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

@property (nonatomic, strong) NSBundle *assetBundle;

@end

@implementation LDXImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set default values
    self.assetCollectionSubtypes = @[
                                     @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                     @(PHAssetCollectionSubtypeAlbumMyPhotoStream),
                                     @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                     @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                     @(PHAssetCollectionSubtypeSmartAlbumBursts)
                                     ];
    self.minimumNumberOfSelection = 1;
    self.numberOfColumnsInPortrait = 4;
    self.numberOfColumnsInLandscape = 7;
    
    _selectedAssets = [NSMutableOrderedSet orderedSet];
    
    // Get asset bundle
    self.assetBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [self.assetBundle pathForResource:@"LDXImagePicker" ofType:@"bundle"];
    if (bundlePath) {
        self.assetBundle = [NSBundle bundleWithPath:bundlePath];
    }
    
    [self setUpAlbumsViewController];
    
    // Set instance
    LDXAlbumsViewController *albumsViewController = (LDXAlbumsViewController *)self.albumsNavigationController.topViewController;
    albumsViewController.imagePickerController = self;
}

- (void)setUpAlbumsViewController
{
    // Add LDXAlbumsViewController as a child
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LDXImagePicker" bundle:self.assetBundle];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"LDXAlbumsNavigationController"];
    
    [self addChildViewController:navigationController];
    
    navigationController.view.frame = self.view.bounds;
    [self.view addSubview:navigationController.view];
    
    [navigationController didMoveToParentViewController:self];
    
    self.albumsNavigationController = navigationController;
}

@end
