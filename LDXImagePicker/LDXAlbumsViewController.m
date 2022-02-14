//
//  LDXAlbumsViewController.m
//  LDXImagePicker
//
//  Created by Liuxu on 2022/01/21.
//  Copyright (c) 2022 Liuxu. All rights reserved.
//

#import "LDXAlbumsViewController.h"

// ViewControllers
#import "LDXImagePickerController.h"
#import "LDXAssetsViewController.h"
#import "LDXAlbumViewService.h"

@interface LDXImagePickerController (Private)
@property (nonatomic, strong) NSBundle *assetBundle;
@end

@interface LDXAlbumsViewController ()

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, copy) NSArray *assetCollections;
@property (nonatomic, strong) LDXAlbumViewService *albumService;

@end

@implementation LDXAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.albumService = [[LDXAlbumViewService alloc] initWithView:self.tableView];
    LDXAlbumFetch *albumFetch = [[LDXAlbumFetch alloc] initWithSubtypes:self.imagePickerController.assetCollectionSubtypes];
    self.assetCollections = [self.albumService fetchAlbum:albumFetch withMediaType:self.imagePickerController.mediaType];
    self.tableView.dataSource = self.albumService;
    self.tableView.delegate = self.albumService;
    [self setUpToolbarItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure navigation item
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"albums.title", @"LDXImagePicker", self.imagePickerController.assetBundle, nil);
    self.navigationItem.prompt = self.imagePickerController.prompt;
    
    // Show/hide 'Done' button
    if (self.imagePickerController.allowsMultipleSelection) {
        [self.navigationItem setRightBarButtonItem:self.doneButton animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
    
    [self updateControlState];
    [self updateSelectionInfo];
}

#pragma mark - Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LDXAssetsViewController *assetsViewController = segue.destinationViewController;
    assetsViewController.imagePickerController = self.imagePickerController;
    assetsViewController.assetCollection = self.assetCollections[self.tableView.indexPathForSelectedRow.row];
}

#pragma mark - Actions
- (IBAction)cancel:(id)sender {
    if ([self.imagePickerController.delegate respondsToSelector:@selector(ldx_imagePickerControllerDidCancel:)]) {
        [self.imagePickerController.delegate ldx_imagePickerControllerDidCancel:self.imagePickerController];
    }
}

- (IBAction)done:(id)sender {
    if ([self.imagePickerController.delegate respondsToSelector:@selector(ldx_imagePickerController:didFinishPickingAssets:)]) {
        [self.imagePickerController.delegate ldx_imagePickerController:self.imagePickerController
                                               didFinishPickingAssets:self.imagePickerController.selectedAssets.array];
    }
}

#pragma mark - Toolbar
- (void)setUpToolbarItems {
    // Space
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    // Info label
    NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    UIBarButtonItem *infoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    infoButtonItem.enabled = NO;
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    self.toolbarItems = @[leftSpace, infoButtonItem, rightSpace];
}

- (void)updateSelectionInfo {
    NSMutableOrderedSet *selectedAssets = self.imagePickerController.selectedAssets;
    if (selectedAssets.count > 0) {
        NSBundle *bundle = self.imagePickerController.assetBundle;
        NSString *format;
        if (selectedAssets.count > 1) {
            format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.items-selected", @"LDXImagePicker", bundle, nil);
        } else {
            format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.item-selected", @"LDXImagePicker", bundle, nil);
        }
        
        NSString *title = [NSString stringWithFormat:format, selectedAssets.count];
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:title];
    } else {
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:@""];
    }
}

#pragma mark - Checking for Selection Limit
- (BOOL)isMinimumSelectionLimitFulfilled {
    return (self.imagePickerController.minimumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
}

- (BOOL)isMaximumSelectionLimitReached {
    NSUInteger minimumNumberOfSelection = MAX(1, self.imagePickerController.minimumNumberOfSelection);
    if (minimumNumberOfSelection <= self.imagePickerController.maximumNumberOfSelection) {
        return (self.imagePickerController.maximumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
    }
    
    return NO;
}

- (void)updateControlState {
    self.doneButton.enabled = [self isMinimumSelectionLimitFulfilled];
}

@end
