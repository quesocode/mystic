//
//  MysticCustomImagePickerController.m
//  Mystic
//
//  Created by Me on 5/2/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "Mystic.h"
#import "MysticCustomImagePickerController.h"
#import "MysticCustomAlbumPickerController.h"
#import "MysticLayerToolbar.h"
#import "MysticView.h"
#import "MysticNavigationViewController.h"
#import "MysticAlbumDataSource.h"
#import "PECropViewController.h"
#import "MysticBackgroundsDataSource.h"
#import "MysticColorBackgroundsDataSource.h"
#import "MysticProgressHUD.h"
#import "MysticImagePreloader.h"
#import "MysticAssetCollectionCell.h"
#import "MysticCollectionViewSectionToolbarHeader.h"


static NSString *backgroundsTitle = @"BACKDROPS";
static NSString *libraryTitle = @"PHOTOS";
static NSString *colorsTitle = @"COLORS";


@interface MysticCustomImagePickerController () <MysticLayerToolbarDelegate, MysticCollectionToolbarDelegate>
{
    NSMutableDictionary *dataSources;
    NSMutableDictionary *lastOffsets;
}
@property (nonatomic, assign) CGPoint lastOffset;
@property (nonatomic, retain) MysticLayerToolbar *toolbar;
@property (nonatomic, retain) MysticImagePreloader *preloader;
@property (nonatomic, retain) MysticProgressHUD *hud;
@end

@implementation MysticCustomImagePickerController


+ (Class) dataSourceClass;
{
    return [MysticAlbumDataSource class];
}
+ (MysticGridSize) gridSize;
{
    return (MysticGridSize){NSNotFound, 3};
}
+ (CGFloat) lineSpacing;
{
    return 4;
}
+ (CGFloat) itemSpacing;
{
    return 4;
}
+ (UIEdgeInsets) gridContentInsets;
{
    return UIEdgeInsetsMake(4, -4, 4, -4);
}



- (void) dealloc;
{
    [super dealloc];
    [_preloader release], _preloader = nil;
    [dataSources release], dataSources = nil;
    [lastOffsets release], lastOffsets = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dataSources = [[NSMutableDictionary alloc] init];
        lastOffsets = [[NSMutableDictionary alloc] init];

        _backgroundType = MysticBackgroundTypePhoto;
        self.navigationItem.hidesBackButton = YES;
        self.lastOffset = CGPointUnknown;
        self.hidesBottomBarWhenPushed = YES;
        self.shouldTrack = NO;
        self.allowsEditing = YES;

        
        
        if(self.navigationController) [(MysticNavigationViewController *)self.navigationController navigationBar].backgroundColorStyle = MysticColorTypeCollectionNavBarBackground;
    }
    return self;
}

- (void)viewDidLoad
{
    

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor color:MysticColorTypeCollectionBackground];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    CGFloat ls = [[self class] lineSpacing];
    CGFloat toolWidth = self.view.frame.size.width/3;
    NSArray *theItems = @[ @{@"toolType": @(MysticToolTypeStatic),
                             @"width":@(-15)},
                           
                           @{@"toolType": @(MysticToolTypeTitle),
                             @"title": backgroundsTitle,
                             @"selected": @(self.backgroundType == MysticBackgroundTypeBackground),
                             
                             @"width": @(toolWidth)},
                           
                           
                           @{@"toolType": @(MysticToolTypeFlexible),
                             },
                           @{@"toolType": @(MysticToolTypeTitle),
                             @"title": libraryTitle,
                             @"selected": @(self.backgroundType == MysticBackgroundTypePhoto),
                             @"width": @(toolWidth)},
                           
                           
                           @{@"toolType": @(MysticToolTypeFlexible),
                             },
                           
                           @{@"toolType": @(MysticToolTypeTitle),
                             @"title": colorsTitle,
                             @"selected": @(self.backgroundType == MysticBackgroundTypeColor),
                             
                             @"width": @(toolWidth)},
                           
                           @{@"toolType": @(MysticToolTypeStatic),
                             @"width":@(-15)},];
    
    MysticLayerToolbar *toolbar = [MysticLayerToolbar toolbarWithItems:theItems delegate:self height:MYSTIC_UI_TOOLBAR_HEIGHT];
    toolbar.userInteractionEnabled = YES;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    CGRect tbFrame = CGRectMake(0, self.view.frame.size.height - toolbar.frame.size.height, toolbar.frame.size.width, toolbar.frame.size.height);
    toolbar.frame = tbFrame;
    
    self.navigationItem.titleView = toolbar;
    
//    CGRect collectionFrame = self.collectionView.frame;
//    collectionFrame.size.height = toolbar.frame.origin.y;
//    self.collectionView.frame = collectionFrame;
}

- (void) viewWillAppear:(BOOL)animated;
{
//    SLog(@"custom image picker will appear", self.collectionView.frame.size);

    
    [super viewWillAppear:animated];
    
    [self updateNavBar];
    
    [(MysticNavigationViewController *)self.navigationController navigationBar].backgroundColorStyle = MysticColorTypeCollectionNavBarBackground;
    //[self.navigationController setToolbarHidden:YES animated:NO];
    
    
    if(!CGPointEqualToPoint(self.lastOffset, CGPointUnknown))
    {
        self.collectionView.contentOffset = self.lastOffset;
        
    }
}

- (void) updateNavBar;
{
    
    
    /*
     BOOL comeFromCam = [self comesFromCamera];

     CGRect tFrame = CGRectMake(0, 0, 150, 60);
     MysticView *tView = [[MysticView alloc] initWithFrame:tFrame];
     tView.stickToPoint = CGPointMake(CGPointUnknown.x, 0);
     MysticBarButton *titleBtn = [MysticBarButton buttonWithTitle:NSLocalizedString(@"CHOOSE", nil) target:self sel:@selector(titleTouched:)];
     titleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
     [titleBtn setTitleColor:[UIColor color:MysticColorTypeCollectionNavBarText] forState:UIControlStateNormal];
     titleBtn.titleLabel.font = [MysticUI gothamBook:14];
     titleBtn.tag = MysticPositionCenter;
     titleBtn.autoresizingMask= UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
     titleBtn.frame = tView.bounds;
     [tView addSubview:titleBtn];
     tView.autoresizesSubviews = YES;
     self.navigationItem.titleView = tView;
     [tView release];
     
     MysticBarButton *rightBarButton = (MysticBarButton *)[MysticBarButton buttonWithTitle:NSLocalizedString(@"ALBUMS", nil) target:self sel:@selector(albumsButtonTouched:)];
     rightBarButton.font = [MysticUI font:11];
     rightBarButton.tag = MysticViewTypeButtonForward;
     rightBarButton.position = MysticPositionRight;
     MysticBarButtonItem *barItem = [[MysticBarButtonItem alloc] initWithCustomView:rightBarButton];
     self.navigationItem.rightBarButtonItem = barItem;
     [barItem release];
     
     
    
    if(comeFromCam)
    {
        CGSize leftBtnIconSize = CGSizeMake(37, 37);
        MysticBarButton *leftBarButton = (MysticBarButton *)[MysticBarButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeToolLeft) size:leftBtnIconSize color:[UIColor color:MysticColorTypeCollectionNavBarIcon]] target:self sel:@selector(backButtonTouched:)];
        leftBarButton.tag = MysticViewTypeButtonBack;
        [leftBarButton setImage:[MysticImage image:@(MysticIconTypeToolLeft) size:leftBtnIconSize color:[UIColor color:MysticColorTypeCollectionNavBarHighlighted]] forState:UIControlStateHighlighted];
        
        leftBarButton.frame = CGRectMake(0, 0, 53, 60);
        leftBarButton.position = MysticPositionLeft;
        leftBarButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
        
        MysticBarButtonItem *barItem = [[MysticBarButtonItem alloc] initWithCustomView:leftBarButton];
        self.navigationItem.leftBarButtonItem = barItem;
        
    }
    else
    {
        CGSize leftBtnIconSize = CGSizeMake(30, 30);
        MysticBarButton *leftBarButton = (MysticBarButton *)[MysticBarButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeToolX) size:leftBtnIconSize color:[UIColor color:MysticColorTypeCollectionNavBarIcon]] target:self sel:@selector(backButtonTouched:)];
        leftBarButton.tag = MysticViewTypeButtonBack;
        [leftBarButton setImage:[MysticImage image:@(MysticIconTypeToolX) size:leftBtnIconSize color:[UIColor color:MysticColorTypeCollectionNavBarHighlighted]] forState:UIControlStateHighlighted];
        
        leftBarButton.frame = CGRectMake(0, 0, 53, 60);
        leftBarButton.position = MysticPositionLeft;
        leftBarButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
        
        MysticBarButtonItem *barItem = [[MysticBarButtonItem alloc] initWithCustomView:leftBarButton];
        self.navigationItem.leftBarButtonItem = barItem;
        [barItem release];
    }
     
     */
}
- (BOOL) comesFromCamera;
{
    for (UIViewController *c in self.navigationController.viewControllers) {
        if([c isKindOfClass:[UIImagePickerController class]])
        {
            UIImagePickerController *cc = (UIImagePickerController *)c;
            if(cc.sourceType == UIImagePickerControllerSourceTypeCamera)
            {
                return YES;
            }
        }
    }
    return NO;
}
- (void) viewDidAppear:(BOOL)animated;
{
    
//    SLog(@"custom image picker did appear", self.collectionView.frame.size);
    [super viewDidAppear:animated];
    
    
//    DLog(@"show custom image picker: %@", MBOOL([self comesFromCamera]));

//    BOOL didBecome = [self becomeFirstResponder];
//    DLog(@"became first: %@", MBOOL(didBecome));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) titleTouched:(id)sender;
{
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}
- (void) backButtonTouched:(id)sender;
{
    [self cancelled];
}

- (void) albumsButtonTouched:(id)sender;
{
    MysticCustomAlbumPickerController *viewController = [[MysticCustomAlbumPickerController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (void) setCollectionView:(UICollectionView *)collectionView;
{
    [super setCollectionView:collectionView];
    collectionView.scrollsToTop = YES;
}

- (id <UICollectionViewDataSource>) dataSource;
{
    NSString *dataSourceKey = [NSString stringWithFormat:@"%d", (int)self.backgroundType];
    id dataSource = [dataSources objectForKey:dataSourceKey];
    if(!dataSource)
    {
        switch (self.backgroundType) {
            case MysticBackgroundTypePhoto:
                dataSource = [[MysticAlbumDataSource alloc] init];

                break;
            case MysticBackgroundTypeBackground:
            {

                dataSource = [[MysticBackgroundsDataSource alloc] init];
                break;
            }
            case MysticBackgroundTypeColor:
            {

                dataSource = [[MysticColorBackgroundsDataSource alloc] init];
                break;
            }
            default:
                break;
        }
        if(dataSource) [dataSources setObject:dataSource forKey:dataSourceKey];
        return [dataSource autorelease];
//        [super setDataSource:[dataSource autorelease]];
        
    }
    return dataSource;
}

- (void) collectionViewDidRefresh:(UICollectionView *)collectionView;
{
    [super collectionViewDidRefresh:collectionView];
    
    CGPoint __lastOffset = self.lastOffset;
    NSString *dataSourceKey = [NSString stringWithFormat:@"%d", (int)self.backgroundType];
    if([lastOffsets objectForKey:dataSourceKey])
    {
        __lastOffset = [[lastOffsets objectForKey:dataSourceKey] CGPointValue];
    }
    
//    PLog(@"collection view did refresh:", __lastOffset);

    
    if(!CGPointEqualToPoint(__lastOffset, CGPointUnknown))
    {
        self.collectionView.contentOffset = __lastOffset;
        
    }
    else
    {
        switch (self.backgroundType) {
            case MysticBackgroundTypePhoto:
            {
                
                int _item = [(MysticCollectionViewDataSource *)self.dataSource numberOfItemsForSection:1];
                
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_item-1 inSection:1] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                break;
            }
                
            default:
                break;
        }
    }
    self.collectionView.hidden = NO;
    
}

- (void) setBackgroundType:(MysticBackgroundType)backgroundType;
{
    MysticBackgroundType lastBackgroundType = _backgroundType;
    BOOL changed = _backgroundType != backgroundType;
    _backgroundType = backgroundType;
    
    switch (_backgroundType) {
        case MysticBackgroundTypeBackground:
        case MysticBackgroundTypeColor:
            self.navigationItem.rightBarButtonItem.customView.hidden = YES;
            break;
        case MysticBackgroundTypePhoto:
            self.navigationItem.rightBarButtonItem.customView.hidden = NO;
            break;
        default:
            
            break;
    }
    if(changed || !self.collectionView.dataSource)
    {
        self.lastOffset = CGPointUnknown;
        if(self.collectionView.dataSource && lastBackgroundType != MysticBackgroundTypeUnknown)
        {
            NSString *dataSourceKey = [NSString stringWithFormat:@"%d", (int)lastBackgroundType];

            [lastOffsets setObject:[NSValue valueWithCGPoint:self.collectionView.contentOffset] forKey:dataSourceKey];
        }
        self.collectionView.hidden = YES;
//        self.collectionView.dataSource = self.dataSource;
        [self initCollectionView:self.collectionView];
        [self refreshCollection];
    }
}

- (void)registerCellsForCollectionView:(UICollectionView *)collectionView
{
    MysticCollectionViewDataSource *dataSource = self.dataSource;
    
    Class dataSourceClass = [dataSource class];
    
    NSString *theId = [dataSourceClass cellIdentifier];

    
    [collectionView registerClass:[dataSourceClass cellClassForIdentifier:theId] forCellWithReuseIdentifier:theId];
}


- (void) registerSupplementaryViewsForCollectionView:(UICollectionView *)collectionView;
{
    [collectionView registerClass:[MysticCollectionViewSectionToolbarHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[MysticCollectionViewSectionToolbarHeader cellIdentifier]];
    
    MysticCollectionViewDataSource *dataSource = self.dataSource;
    Class dataSourceClass = [dataSource class];
    NSString *theId = [dataSourceClass sectionHeaderCellIdentifier];
    [collectionView registerClass:[dataSourceClass cellClassForIdentifier:theId] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:theId];
    
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    MysticAssetCollectionCell *_cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    if(_cell)
    {
        
        [_cell didDeselect:^(MysticAssetCollectionCell *cell, BOOL success) {

        }];
    }
         
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __block MysticCustomImagePickerController *weakSelf = self;
    __block MysticAssetCollectionItem *item = [(MysticCollectionViewDataSource *)collectionView.dataSource itemAtIndexPath:indexPath];
    __block NSDictionary *imageInfo;
    __block UIImage *sourceImage, *returnImage;
    __block BOOL shouldDownload = NO;
    __block NSString *downloadStr = nil;
    __unsafe_unretained __block PECropViewController *cropperController = nil;

    MysticAssetCollectionCell *_cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    if(_cell)
    {
        
        [_cell didSelect:^(MysticAssetCollectionCell *cell, BOOL success) {

    
    
            if(weakSelf.allowsEditing)
            {
                cropperController = [[PECropViewController alloc] init];
                cropperController.delegate = weakSelf;
            }

            switch (weakSelf.backgroundType) {
                case MysticBackgroundTypePhoto:
                {
                    imageInfo = item.assetInfo;
                    sourceImage = [imageInfo objectForKey:UIImagePickerControllerOriginalImage];
                    UIImage *editedImage = [imageInfo objectForKey:UIImagePickerControllerEditedImage];
                    if(weakSelf.allowsEditing)
                    {
                        cropperController.image = editedImage ? editedImage : sourceImage;
                        cropperController.media = imageInfo;
                        [weakSelf.navigationController pushViewController:cropperController animated:YES];
                        [cropperController release];
                    }
                    else
                    {
                        [weakSelf cropViewController:nil didFinishCroppingImage:(editedImage ? editedImage : sourceImage) info:imageInfo];
                    }
                    break;
                }
                case MysticBackgroundTypeBackground:
                case MysticBackgroundTypeColor:
                {
                    if(cropperController)
                    {
                        cropperController.media = @{};
                    }
                    
                    shouldDownload = item.fullResolutionURLString != nil;
        //            downloadStr = item.fullResolutionURLString;
                    
                    if(!shouldDownload)
                    {
                        MysticProgressHUD *mysthud = [[MysticProgressHUD alloc] initWithFrame:weakSelf.navigationController.view.frame];
                        mysthud.dimBackground = YES;
                        mysthud.underlyingView = weakSelf.navigationController.view;
                        mysthud.tag = MysticViewTypeHUD;
                        mysthud.mode = MysticProgressHUDModeIndeterminate;
                        weakSelf.hud = mysthud;
                        [weakSelf.navigationController.view addSubview:mysthud];
                        [mysthud show:YES];
                        [mysthud release];
                        [item fullResolutionImage:^(UIImage *newImage) {
                            if(cropperController)
                            {
                                if(newImage)
                                {
                                    cropperController.image = newImage;
                                    [weakSelf.navigationController pushViewController:cropperController animated:YES];
                                }
                                [cropperController release];
                            }
                            weakSelf.hud.removeFromSuperViewOnHide = YES;
                            [weakSelf.hud hide:NO];
                            if(!weakSelf.allowsEditing && newImage)
                            {
                                [weakSelf cropViewController:nil didFinishCroppingImage:newImage info:nil];
                            }
                        }];
                        return;
                        
                    }
                    
                    
                    
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            if(shouldDownload)
            {
                MysticProgressHUD *mysthud = [[MysticProgressHUD alloc] initWithFrame:weakSelf.navigationController.view.frame];
                mysthud.dimBackground = YES;
                mysthud.underlyingView = weakSelf.navigationController.view;
                mysthud.tag = MysticViewTypeHUD;
                mysthud.mode = MysticProgressHUDModeAnnularDeterminate;
                weakSelf.hud = mysthud;
                [weakSelf.navigationController.view addSubview:mysthud];
                [mysthud show:YES];
                [mysthud release];
                if(weakSelf.preloader) [weakSelf.preloader cancelPrefetching];
                weakSelf.preloader = [[[MysticImagePreloader alloc] init] autorelease];
                [weakSelf.preloader prefetchURLs:@[item.fullResolutionURL] progress:^(NSUInteger receivedSize, long long expectedSize) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(weakSelf.hud)
                        {
                            weakSelf.hud.mode = MysticProgressHUDModeAnnularDeterminate;
                            weakSelf.hud.progress = (float)((float)receivedSize/(float)expectedSize);
                        }
                    });
                    
                    
                } completed:^(NSUInteger finishedCount, NSUInteger totalCount, BOOL finished, UIImage *image, NSURL *url, SDImageCacheType cacheType, NSInteger currentIndex) {
                    if(finished)
                    {
                        weakSelf.hud.removeFromSuperViewOnHide = YES;
                        [weakSelf.hud hide:NO];
                        
                        if(cropperController && weakSelf.allowsEditing)
                        {
                            if(image)
                            {
                                cropperController.image = image;
                                [weakSelf.navigationController pushViewController:cropperController animated:YES];
                            }
                            [cropperController release];
                        }
                        else if(!weakSelf.allowsEditing && image)
                        {
                            [weakSelf cropViewController:nil didFinishCroppingImage:image info:nil];
                        }
                    }
                }];
            }
    
    

    
        }];

    
    
    }
    
    
    
}


- (UIImagePickerControllerSourceType) sourceType;
{
    return UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void) cancelled;
{
    if(self.delegate)
    {
        [self.delegate imagePickerControllerDidCancel:(id)self];
    }
}


#pragma mark - pecropviewcontroller delegate

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
    
//    DLog(@"cropper did cancel: %@", controller);
    controller.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
    [NSTimer wait:0.4 block:^{
        
    
        NSIndexPath *selectedPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        if(selectedPath)
        {
            [self.collectionView deselectItemAtIndexPath:selectedPath animated:YES];
        }
    }];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)image info:(NSDictionary *)info;
{
    
    NSAssert(image != nil, @"Picker Cropper didFinishCroppingImage: nil image");
    
    if(!image) return;
    self.lastOffset = self.collectionView.contentOffset;
    if(self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)])
    {
        
        CGRect crop = CGRectZero;
        crop.size = image.size;
        
        info = info ? info : [NSDictionary dictionary];
        NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] initWithDictionary:info];
        [workingDictionary setObject:ALAssetTypePhoto forKey:UIImagePickerControllerMediaType];
        if(image) [workingDictionary setObject:image forKey:UIImagePickerControllerEditedImage];
        if(image && ![workingDictionary objectForKey:UIImagePickerControllerOriginalImage]) [workingDictionary setObject:image forKey:UIImagePickerControllerOriginalImage];
        [workingDictionary setObject:[NSValue valueWithCGRect:crop] forKey:UIImagePickerControllerCropRect];
        
        
        
        
        [self.delegate performSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:@[workingDictionary]];
        [workingDictionary release];

        if(controller) controller.delegate = nil;
        
    }
    
    
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.frame.size.width, section <= 1 ? 50 : 50 + [(MysticCollectionViewLayout *) collectionViewLayout sectionHeaderTopBorderWidth]);
}


- (BOOL)shouldHeaderDragInSection:(NSUInteger)section;
{
    return section != 0;
}
- (BOOL)shouldStickHeaderToTopInSection:(NSUInteger)section;
{
    return section != 0;
}


#pragma mark - Toolbar delegate

- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;
{
    self.lastOffset = CGPointUnknown;
    [toolbar selectItem:sender];
    NSString *title = [[sender titleForState:UIControlStateNormal] uppercaseString];
    if([title isEqualToString:libraryTitle])
    {
        self.backgroundType = MysticBackgroundTypePhoto;
    }
    else if([title isEqualToString:backgroundsTitle])
    {
        self.backgroundType = MysticBackgroundTypeBackground;

    }
    else if([title isEqualToString:colorsTitle])
    {
        self.backgroundType = MysticBackgroundTypeColor;

    }
}


@end
