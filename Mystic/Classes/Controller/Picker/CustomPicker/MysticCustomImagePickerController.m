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
#import "MysticPreloaderImage.h"
#import "MysticAssetCollectionCell.h"
#import "MysticCollectionViewSectionToolbarHeader.h"
#import "MysticTipView.h"


static NSString *backgroundsTitle = @"ALBUMS";
static NSString *libraryTitle = @"PHOTOS";
static NSString *colorsTitle = @"COLORS";
#define MYSTIC_PHOTOS_TAG 3348
#define MYSTIC_BACKGROUNDS_TAG 3349
#define MYSTIC_ALBUMS_TAG 3350

@interface MysticCustomImagePickerController () <MysticLayerToolbarDelegate, MysticCollectionToolbarDelegate>
{
    NSMutableDictionary *dataSources;
    NSMutableDictionary *lastOffsets;
    BOOL stickingHeader, oktostick, forcestick, comingBack, shouldIgnoreDrag, isShowingHeader;
}
@property (nonatomic, assign) UIView *accessView;
@property (nonatomic, assign) MysticScrollDirection scrollDirectionOnBeginDrag, scrollDirectionOnEndDrag;
@property (nonatomic, assign) CGPoint lastOffset;
@property (nonatomic, retain) MysticLayerToolbar *toolbar;
@property (nonatomic, retain) MysticPreloaderImage *preloader;
@property (nonatomic, retain) MysticProgressHUD *hud;
@property (nonatomic, retain) MysticLayerToolbar *layerToolbar;
@property (nonatomic, retain) MysticCollectionSectionUnderHeader *headerRef;
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
    return 7;
}
+ (CGFloat) itemSpacing;
{
    return 7;
}
+ (UIEdgeInsets) gridContentInsets;
{
    return UIEdgeInsetsMake(0, 0, 7, 0);
}



- (void) dealloc;
{

    [_preloader release], _preloader = nil;
    [dataSources release], dataSources = nil;
    [lastOffsets release], lastOffsets = nil;
    if(self.layerToolbar ) { [_layerToolbar release], _layerToolbar = nil;  }
    [_headerRef release], _headerRef=nil;
    [_album release], _album = nil;
    [super dealloc];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dataSources = [[NSMutableDictionary alloc] init];
        lastOffsets = [[NSMutableDictionary alloc] init];
        stickingHeader = NO;
        oktostick = NO;
        comingBack = NO;
        _scrollDirectionOnBeginDrag = MysticScrollDirectionNone;
        _scrollDirectionOnEndDrag = MysticScrollDirectionNone;
        self.scrollDirection = MysticScrollDirectionNone;
        _backgroundType = MysticBackgroundTypePhoto;
        self.navigationItem.hidesBackButton = YES;
        self.lastOffset = CGPointUnknown;
        self.hidesBottomBarWhenPushed = YES;
        self.shouldTrack = NO;
        self.allowsEditing = YES;
        self.ignoreScroll = YES;
        CGRect hf = CGRectSize((CGSize){[MysticUI screen].width, 52});
        self.headerRef = [[[MysticCollectionSectionUnderHeader alloc] initWithFrame:hf] autorelease];
        [self.headerRef.button addTarget:self action:@selector(albumsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerRef setTitle:@"ALBUMS"];
        self.headerRef.backgroundColor = [UIColor hex:@"151515"];
        if(self.navigationController) [(MysticNavigationViewController *)self.navigationController navigationBar].backgroundColorStyle = MysticColorTypeCollectionNavBarBackground;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor color:MysticColorTypeCollectionBackground];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    CGSize leftBtnIconSize = CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CANCEL, MYSTIC_NAVBAR_ICON_HEIGHT_CANCEL);
    MysticToolbarTitleButton *leftBarButton = [[[MysticToolbarTitleButton alloc] initWithFrame:CGRectMake(0, 0, 56, 60)] autorelease];
    [leftBarButton.button setImage:[MysticImage image:@(MysticIconTypeToolX) size:leftBtnIconSize color:[UIColor color:MysticColorTypeCollectionNavBarIcon]] forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    leftBarButton.tag = MysticViewTypeButtonBack;
    [leftBarButton.button setImage:[MysticImage image:@(MysticIconTypeToolX) size:leftBtnIconSize color:[UIColor color:MysticColorTypeCollectionNavBarHighlighted]] forState:UIControlStateHighlighted];
    leftBarButton.buttonPosition = MysticPositionLeft;
    leftBarButton.button.imageEdgeInsets = UIEdgeInsetsMake(-1, 9, 1, 0);
    leftBarButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    leftBarButton.frame = CGRectMake(0, 0, 56, 60);

    int numOfTools = 2;
    CGFloat ls = [[self class] lineSpacing];
    CGFloat x = 5;
    CGFloat toolWidth = ((self.view.frame.size.width)/numOfTools) - (20 * (numOfTools)) - x;
    toolWidth = 120;

    MysticBarButton *rightButton = [[[MysticBarButton alloc] initWithFrame:(CGRect){0,0,40,60}] autorelease];
    [rightButton addTarget:self action:@selector(rightButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

    NSArray *theItems = @[
  
                          

//                          
                          @{@"toolType": @(MysticToolTypeStatic),
                             @"width":@(-15)},
                          
                          @{@"toolType": @(MysticToolTypeCancel),
                            @"view": leftBarButton,
                            @"width": @(leftBarButton.frame.size.width),
                            @"eventAdded": @YES,

                            },
                          
                          
                          
                          @{@"toolType": @(MysticToolTypeFlexible),
                            },
                          
                          
                          
                           @{@"toolType": @(MysticToolTypeTitle),
                             @"title": libraryTitle,
                             @"selected": @(self.backgroundType == MysticBackgroundTypePhoto),
                             @"width": @(100),
                             @"tag": @(MYSTIC_PHOTOS_TAG),

                             },
                          
                           
                           @{@"toolType": @(MysticToolTypeFlexible)},


                          
                           @{@"toolType": @(MysticToolTypeTitle),
                             @"title": backgroundsTitle,
                             @"tag": @(MYSTIC_BACKGROUNDS_TAG),
                             @"selected": @(self.backgroundType == MysticBackgroundTypeBackground),
                             @"width": @(115)
                             },
                          

                          @{@"toolType": @(MysticToolTypeBack),
                            @"view": rightButton,
                            @"width": @(40),
                            @"eventAdded": @YES,
                            },
                          
                          
                          
                          @{@"toolType": @(MysticToolTypeFlexible),
                            },
                          
                           @{@"toolType": @(MysticToolTypeStatic),
                             @"width":@(-15)},
                           

                           ];
    
    MysticLayerToolbar *toolbar = [MysticLayerToolbar toolbarWithItems:theItems delegate:self height:self.navigationController.navigationBar.frame.size.height];
    toolbar.barTintColor = [UIColor colorWithType:MysticColorTypeTabBarBackground];
    toolbar.margin = 0;
    toolbar.userInteractionEnabled = YES;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    toolbar.frame = CGRectMake(0, self.view.frame.size.height - toolbar.frame.size.height, self.view.frame.size.width, toolbar.frame.size.height);;
    [self.view addSubview:toolbar];
    self.layerToolbar = toolbar;
    CGRect hf = self.headerRef.frame;
    hf.origin.y = -1*self.headerRef.frame.size.height;
    self.headerRef.frame = hf;
    [self.view addSubview:self.headerRef];
//    
//    BOOL hasDenied = NO;
//    BOOL isRestricted = NO;
//    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//    switch (status)
//    {
//        case PHAuthorizationStatusDenied: hasDenied = YES; break;
//        case PHAuthorizationStatusRestricted: isRestricted = YES; break;
//        case PHAuthorizationStatusAuthorized:
//        case PHAuthorizationStatusNotDetermined:
//        default: break;
//    }
//    
//    if(hasDenied || isRestricted)
//    {
//        DLog(@"photo library is  %@", hasDenied ? @"DENIED" : @"RESTRICTED");
//    }
}
- (UICollectionView *) createCollectionView;
{
    UICollectionView *c = [super createCollectionView];
    CGRect cFrame = c.frame;
    cFrame.size.height -= self.navigationController.navigationBar.frame.size.height;
    c.frame = cFrame;
    return c;
}
- (void) viewWillAppear:(BOOL)animated;
{
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    comingBack = NO;
    [super viewWillAppear:animated];
    self.ignoreScroll = YES;
    CGRect hf = self.headerRef.frame;
    hf.origin.y = -52;
    self.headerRef.frame = hf;
    self.collectionView.contentInset = [[self class] gridContentInsets];
}


- (BOOL) comesFromCamera;
{
    for (UIViewController *c in self.navigationController.viewControllers) {
        if([c isKindOfClass:[UIImagePickerController class]] && ((UIImagePickerController *)c).sourceType == UIImagePickerControllerSourceTypeCamera)
            return YES;
    }
    return NO;
}

- (void) setAlbum:(ALAssetsGroup *)album;
{
    if(_album) { [_album release], _album=nil; }
    _album = album ? [album retain] : nil;
}
- (void) titleTouched:(id)sender;
{
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}
- (void) rightButtonTouched:(id)sender;
{
    if(self.backgroundType == MysticBackgroundTypeBackground) return;
    self.lastOffset = CGPointUnknown;
    MysticBarButtonItem *b = [self.layerToolbar itemWithTag:MYSTIC_BACKGROUNDS_TAG];
    if(b && [b isKindOfClass:[MysticBarButtonItem class]])
    {
        [self toolbar:self.layerToolbar itemTouched:(id)b.customView toolType:b.toolType event:UIControlEventTouchUpInside];
    }
    else if(b && [b isKindOfClass:[MysticToolbarTitleButton class]])
    {
        [self toolbar:self.layerToolbar itemTouched:(id)b toolType:b.toolType event:UIControlEventTouchUpInside];
        [(MysticToolbarTitleButton *)b updateState];
    }
}
- (void) backButtonTouched:(id)sender; { [self cancelled]; }

- (void) albumsButtonTouched:(id)sender;
{
    MysticCustomAlbumPickerController *viewController = [[MysticCustomAlbumPickerController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self.delegate;
    NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [vcs insertObject:viewController atIndex:[vcs indexOfObject:self]];
    self.navigationController.viewControllers = vcs;
    [self.navigationController popToViewController:viewController animated:YES];
    [viewController release];
}

- (void) setCollectionView:(UICollectionView *)collectionView;
{
    collectionView.scrollsToTop = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
    [super setCollectionView:collectionView];
}
- (void) setDelegate:(id<UIImagePickerControllerDelegate>)delegate; { _delegate = delegate; }
- (id <UICollectionViewDataSource>) dataSource;
{
    NSString *dataSourceKey = [NSString stringWithFormat:@"%d", (int)self.backgroundType];
    id dataSource = [dataSources objectForKey:dataSourceKey];
    if(dataSource) return dataSource;
    switch (self.backgroundType) {
        case MysticBackgroundTypePhoto:
            dataSource = [[MysticAlbumDataSource alloc] init];
            if(self.album) [(MysticAlbumDataSource *)dataSource setAlbum:self.album];
            break;
        case MysticBackgroundTypeBackground: dataSource = [[MysticBackgroundsDataSource alloc] init]; break;
        case MysticBackgroundTypeColor: dataSource = [[MysticColorBackgroundsDataSource alloc] init]; break;
        default: break;
    }
    if(dataSource) [dataSources setObject:dataSource forKey:dataSourceKey];
    return [dataSource autorelease];
}
- (void)loadCollectionView:(UICollectionView *)collectionView start:(MysticBlockObjBOOL)onStart finish:(MysticBlockObjObjBOOL)onFinish;
{
    if (!collectionView) return;
        
    __unsafe_unretained __block MysticBlockObjBOOL __onStart = onStart ? Block_copy(onStart) : nil;
    __unsafe_unretained __block MysticBlockObjObjBOOL __onFinish = onFinish ? Block_copy(onFinish) : nil;
    __unsafe_unretained __block MysticCustomImagePickerController *weakSelf = self;
    __unsafe_unretained __block UICollectionView *__collectionView = [collectionView retain];
    [self initCollectionView:collectionView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [weakSelf refreshCollectionView:__collectionView start:nil finish:^(id obj, id obj2, BOOL success) {
            
            BOOL wasDenied = NO;
            BOOL wasRestricted = NO;
            if(obj2)
                switch ([obj2 intValue]) {
                    case ALAuthorizationStatusDenied: wasDenied = YES; break;
                    case ALAuthorizationStatusRestricted: wasRestricted = YES; break;
                    case ALAuthorizationStatusNotDetermined:
                    case ALAuthorizationStatusAuthorized:
                    default: break; }
                        
            if(wasDenied || wasRestricted)
            {
                CGFloat spacing = 20;
                UIView *access = [[UIView alloc] initWithFrame:CGRectWH(self.view.bounds, self.view.bounds.size.width, self.view.bounds.size.height - self.toolbar.frame.size.height)];
                
                UIImageView *iconView = [[[UIImageView alloc] initWithFrame:(CGRect){0,0,70,70}] autorelease];
                iconView.image = [MysticImage image:@(MysticIconTypeAlert) size:(CGSize){60,60} color:[UIColor colorWithRed:0.87 green:0.56 blue:0.22 alpha:1.00]];
                iconView.contentMode = UIViewContentModeCenter;
                UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 60)] autorelease];
                UILabel *msgLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 60, 200)] autorelease];
                msgLabel.numberOfLines = 0;
                MysticButton *btn = [MysticButton button:[[MysticAttrString string:@"OPEN SETTINGS" style:MysticStringStyleAccessButton] attrString] action:^(id sender) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                NSString *title = wasDenied ? @"PHOTOS ACCESS DENIED" : @"PHOTOS ARE RESTRICTED";
                NSString *descrpition = wasDenied ? @"Bummer...\n\nYou need to allow Mystic access\nto your photos before you can\nchoose one to edit. \n\nTap OPEN SETTINGS below\nand turn Photos on." : @"Hmm... for some weird reason access to your photo library is restricted?\n\nTap OPEN SETTINGS below\nand turn Photos on.";
                titleLabel.attributedText = [[MysticAttrString string:title style:MysticStringStyleAccessTitle] attrString];
                msgLabel.attributedText = [[MysticAttrString string:descrpition style:MysticStringStyleAccessDescription] attrString];
                [titleLabel sizeToFit];
                [msgLabel sizeToFit];
                [btn sizeToFit];
                [access addSubview:iconView];
                [access addSubview:titleLabel];
                [access addSubview:msgLabel];
                [access addSubview:btn];
                CGSize accessSize = titleLabel.frame.size;
                accessSize.width = MAX(MAX(CGRectGetWidth(titleLabel.frame), CGRectGetWidth(msgLabel.frame)), CGRectGetWidth(btn.frame));
                accessSize.height += (spacing*access.subviews.count) + CGRectGetHeight(iconView.frame) + CGRectGetHeight(titleLabel.frame) + CGRectGetHeight(msgLabel.frame) + CGRectGetHeight(btn.frame);
                iconView.center = CGPointAddY(MCenterOfRect(access.bounds), -accessSize.height/2);
                titleLabel.frame = CGRectOffset(titleLabel.frame, 0,CGRectGetMaxY(iconView.frame) + spacing*1.5);
                CGRect messageFrame = CGRectOffset(msgLabel.frame, 0,CGRectGetMaxY(titleLabel.frame) + spacing);
                msgLabel.frame = CGRectWH(messageFrame, MIN(CGRectGetWidth(messageFrame), CGRectInset(access.bounds, spacing*2, 0).size.width), CGRectGetHeight(messageFrame));
                btn.frame = CGRectOffset(CGRectInset(btn.frame, -spacing/1.5,-spacing/3), 0, CGRectGetMaxY(msgLabel.frame) + spacing*3);
                MBorder(btn, [UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00], 1.5);
                btn.layer.cornerRadius = CGRectGetHeight(btn.frame)/2;
                titleLabel.center = CGPointX(titleLabel.center, iconView.center.x);
                msgLabel.center = CGPointX(msgLabel.center, iconView.center.x);
                btn.center = CGPointX(btn.center, iconView.center.x);
                [self.view insertSubview:access belowSubview:self.layerToolbar];
                self.accessView = [access autorelease];
            }
            if(__onFinish) { __onFinish(obj, obj2, success); Block_release(__onFinish); }
        }];
        
        if(__onStart) Block_release(__onStart);
        [__collectionView release];
    });
}
- (void) collectionViewDidRefresh:(UICollectionView *)collectionView;
{
    self.ignoreScroll = YES;
    self.scrollDirectionThresholdChange = 0;
    [super collectionViewDidRefresh:collectionView];
    CGFloat offsetY = [self collectionView:collectionView layout:collectionView.collectionViewLayout referenceSizeForHeaderInSection:0].height;
    CGPoint __lastOffset = self.lastOffset;
    NSString *dataSourceKey = [NSString stringWithFormat:@"%d", (int)self.backgroundType];
    if([lastOffsets objectForKey:dataSourceKey]) __lastOffset = [[lastOffsets objectForKey:dataSourceKey] CGPointValue];
    if(!CGPointEqualToPoint(__lastOffset, CGPointUnknown))
    {
        switch (self.backgroundType)
        {
            case MysticBackgroundTypeBackground:
            case MysticBackgroundTypePhoto: if(__lastOffset.y < offsetY) __lastOffset.y = offsetY; break;
            default: break;
        }
        self.collectionView.contentOffset = __lastOffset;
    }
    else if (self.backgroundType == MysticBackgroundTypePhoto)
    {
        if(collectionView.frame.size.height < collectionView.collectionViewLayout.collectionViewContentSize.height)
        {
            int _item = [(MysticCollectionViewDataSource *)self.dataSource numberOfItemsForSection:0];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_item-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        }
        else self.collectionView.contentOffset = CGPointMake(0, offsetY);
    }
    self.collectionView.hidden = NO;
}

- (void) setBackgroundType:(MysticBackgroundType)backgroundType;
{
    MysticBackgroundType lastBackgroundType = _backgroundType;
    BOOL changed = _backgroundType != backgroundType;
    _backgroundType = backgroundType;
    if(!(changed || !self.collectionView.dataSource)) return;
    self.lastOffset = CGPointUnknown;
    if(self.collectionView.dataSource && lastBackgroundType != MysticBackgroundTypeUnknown)
        [lastOffsets setObject:[NSValue valueWithCGPoint:self.collectionView.contentOffset] forKey:[NSString stringWithFormat:@"%d", (int)lastBackgroundType]];
    self.collectionView.hidden = YES;
    [self initCollectionView:self.collectionView];
    [self refreshCollection];
}

- (void)registerCellsForCollectionView:(UICollectionView *)collectionView
{
    MysticCollectionViewDataSource *dataSource = self.dataSource;
    NSString *theId = [[dataSource class] cellIdentifier];
    [collectionView registerClass:[[dataSource class] cellClassForIdentifier:theId] forCellWithReuseIdentifier:theId];
}


- (void) registerSupplementaryViewsForCollectionView:(UICollectionView *)collectionView;
{
    [collectionView registerClass:[MysticCollectionViewSectionToolbarHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[MysticCollectionViewSectionToolbarHeader cellIdentifier]];
    MysticCollectionViewDataSource *dataSource = self.dataSource;
    NSString *theId = [[dataSource class] sectionHeaderCellIdentifier];
    [collectionView registerClass:[[dataSource class] cellClassForIdentifier:theId] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:theId];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    MysticAssetCollectionCell *_cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    if(!_cell) return;
    [MysticTipViewManager hideAll];
    [_cell didDeselect:nil];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [MysticTipViewManager hideAll];
    __block MysticCustomImagePickerController *weakSelf = self;
    __block MysticAssetCollectionItem *item = [(MysticCollectionViewDataSource *)collectionView.dataSource itemAtIndexPath:indexPath];
    __block NSDictionary *imageInfo;
    __block UIImage *sourceImage, *returnImage;
    __block BOOL shouldDownload = NO;
    __block NSString *downloadStr = nil;
    __unsafe_unretained __block PECropViewController *cropperController = nil;
    MysticAssetCollectionCell *_cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    if(!_cell) return;
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
                else [weakSelf cropViewController:nil didFinishCroppingImage:(editedImage ? editedImage : sourceImage) info:imageInfo];
                break;
            }
            case MysticBackgroundTypeBackground:
            case MysticBackgroundTypeColor:
            {
                if(cropperController) cropperController.media = @{};
                shouldDownload = item.fullResolutionURLString != nil;
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
                        if(!weakSelf.allowsEditing && newImage) [weakSelf cropViewController:nil didFinishCroppingImage:newImage info:nil];
                    }];
                    return;
                }
                break;
            }
            default: break;
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
            weakSelf.preloader = [[[MysticPreloaderImage alloc] init] autorelease];
            [weakSelf.preloader prefetchURLs:@[item.fullResolutionURL] progress:^(NSUInteger receivedSize, NSUInteger expectedSize) {
                if(!weakSelf.hud) return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.hud.mode = MysticProgressHUDModeAnnularDeterminate;
                    weakSelf.hud.progress = (float)((float)receivedSize/(float)expectedSize);
                });
            } completed:^(NSUInteger finishedCount, NSUInteger totalCount, BOOL finished, UIImage *image, NSURL *url, SDImageCacheType cacheType, NSInteger currentIndex) {
                if(!finished) return;
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
                else if(!weakSelf.allowsEditing && image) [weakSelf cropViewController:nil didFinishCroppingImage:image info:nil];
            }];
        }
    }];
}

- (void) collectionViewDidSelectHeader:(UIView *)header sender:(id)sender atIndexPath:(NSIndexPath *)indexPath;
{
    [self albumsButtonTouched:header];
}
- (UIImagePickerControllerSourceType) sourceType;
{
    return UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void) cancelled;
{
    [self.delegate imagePickerControllerDidCancel:(id)self];
}


#pragma mark - pecropviewcontroller delegate

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
    
    comingBack = YES;
    controller.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
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
    return CGSizeMake(collectionView.frame.size.width, section <= 1 ? 52 : 52 + [(MysticCollectionViewLayout *) collectionViewLayout sectionHeaderTopBorderWidth]);
}

- (void)collectionView:(UICollectionView *)collectionView
willDisplaySupplementaryView:(UICollectionReusableView *)view
        forElementKind:(NSString *)elementKind
           atIndexPath:(NSIndexPath *)indexPath;
{
    stickingHeader = YES;
}

- (void)collectionView:(UICollectionView *)collectionView
didEndDisplayingSupplementaryView:(UICollectionReusableView *)view
      forElementOfKind:(NSString *)elementKind
           atIndexPath:(NSIndexPath *)indexPath;
{
    stickingHeader = NO;
}

- (void) hideHeaderRef;
{
    self.headerRef.frame = CGRectz(self.headerRef.frame);
    oktostick = NO;
    isShowingHeader = NO;
    [MysticUIView animateWithDuration:0.25 animations:^{
        self.headerRef.frame = CGRectXY(self.headerRef.frame,0,-self.headerRef.frame.size.height);
    } completion:nil];
}

//#define DEBUG_PICKER 1

- (void) scrollViewDidScroll:(UIScrollView *)scrollView;
{
#ifdef DEBUG_PICKER
    int method = 0; CGFloat ny = NAN; MysticScrollDirection beforeDirection = self.scrollDirection;
#endif
    if(self.ignoreScroll) return;
    BOOL hasStarted = self.scrollDirection == MysticScrollDirectionNone;
    if (self.lastContentOffset.y > scrollView.contentOffset.y)
    {
        if(self.lastDirection != MysticScrollDirectionUp) self.scrollDirectionThresholdChange = 0;
        self.scrollDirection = MysticScrollDirectionUp;
    }
    else if (self.lastContentOffset.y < scrollView.contentOffset.y)
    {
        if(self.lastDirection != MysticScrollDirectionDown) self.scrollDirectionThresholdChange = 0;
        self.scrollDirection = MysticScrollDirectionDown;
    }
    self.lastDirection = self.scrollDirection;
    self.scrollDirectionThresholdChange += fabsf((float)(self.lastContentOffset.y - scrollView.contentOffset.y));
    self.lastContentOffset = scrollView.contentOffset;
    if(hasStarted)
    {
        shouldIgnoreDrag = self.scrollDirectionOnBeginDrag != MysticScrollDirectionNone && self.scrollDirectionOnBeginDrag == self.scrollDirection;
        self.scrollDirectionOnBeginDrag = self.scrollDirection;
    }

    if(self.scrollDirection==MysticScrollDirectionUp)
    {
#ifdef DEBUG_PICKER
        method = 1;
#endif
        if(scrollView.contentOffset.y <= 0)
        {
            isShowingHeader = NO;
            self.headerRef.frame = CGRectXY(self.headerRef.frame,0,-self.headerRef.frame.size.height);
#ifdef DEBUG_PICKER
            method = 2; ny = self.headerRef.frame.origin.y;
#endif
        }
        else if(!shouldIgnoreDrag || !isShowingHeader)
        {
            if((!stickingHeader && self.headerRef.frame.origin.y < 0 && self.scrollThresholdMet) && self.scrollDirectionOnEndDrag != MysticScrollDirectionDown)
            {
                oktostick = NO; isShowingHeader = YES;
                [MysticUIView animateWithDuration:0.3 delay:0 options:0 animations:^{
                    self.headerRef.frame = CGRectz(self.headerRef.frame);
                } completion:^(BOOL f) { oktostick = YES; forcestick = YES; }];
#ifdef DEBUG_PICKER
                method = 4; ny = 0;
#endif
            }
        }
    }
    else if(!stickingHeader && oktostick && self.headerRef.frame.origin.y == 0 ) {
        isShowingHeader = NO;
        [self hideHeaderRef];
#ifdef DEBUG_PICKER
        method = 3; ny = -self.headerRef.frame.size.height;
#endif
    }
#ifdef DEBUG_PICKER
    if(method>1) { DLog(@" ");DLog(@" ");DLog(@" ");DLog(@" "); }
    DLog(@"%@ -> %@    | %@ | %@ -> %@ |  %@  | %@ %@    %@  ignore: %@    showing: %@      header: %@ -> %@       drag: %@ -> %@",
         [[NSString stringWithFormat:@"%2.1f", scrollView.contentOffset.y] pad:7],
         [[NSString stringWithFormat:@"%2.1f", scrollView.contentSize.height] pad:7],
         self.headerRef.frame.origin.y < 0 ? @"--" : @"++",
         MysticScrollDirectionStr(beforeDirection),
         MysticScrollDirectionStr(self.scrollDirection),
         b(self.scrollThresholdMet),
         oktostick ? @"." : @" ",
         stickingHeader ? @" - " : @"   ",
         method <= 1 ? @"      " : ColorWrap(method==4?@"SHOW  ":method==2?@"HIDE  ":@"HIDE 2", method==4?COLOR_BLUE:COLOR_RED),
         b(shouldIgnoreDrag),
         b(isShowingHeader),
         [[NSString stringWithFormat:@"%2.1f", self.headerRef.frame.origin.y] pad:6],
         isnan(ny)?@"      ": ColorWrap([[NSString stringWithFormat:@"%2.2f",ny] pad:6], ny<0?COLOR_RED:COLOR_BLUE),
         ColorWrap(MysticScrollDirectionStr(self.scrollDirectionOnBeginDrag), self.scrollDirectionOnBeginDrag == MysticScrollDirectionNone ? COLOR_DOTS : COLOR_GREEN),
         ColorWrap(MysticScrollDirectionStr(self.scrollDirectionOnEndDrag), self.scrollDirectionOnEndDrag == MysticScrollDirectionNone ? COLOR_DOTS : COLOR_RED)
         );
    if(method>1) { DLog(@" ");DLog(@" ");DLog(@" ");DLog(@" "); }
#endif

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
{
    self.scrollDirectionOnEndDrag = self.scrollDirection;
}
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    forcestick = NO;
    self.scrollDirection = MysticScrollDirectionNone;
    self.scrollDirectionOnEndDrag = MysticScrollDirectionNone;
    shouldIgnoreDrag = NO;
    [super scrollViewWillBeginDragging:scrollView];
}
- (BOOL)shouldHeaderDragInSection:(NSUInteger)section; { return YES; }
- (BOOL)shouldStickHeaderToTopInSection:(NSUInteger)section;
{
    if(self.scrollDirectionOnEndDrag == MysticScrollDirectionDown) return NO;
    if(!forcestick && (!oktostick || self.scrollDirection == MysticScrollDirectionDown || self.ignoreScroll )) return NO;
    BOOL f = forcestick;
    forcestick = NO;
    return f ? YES : (self.collectionView.contentOffset.y < 52 || self.scrollThresholdMet);
}
- (BOOL)shouldShowFooterOnStart:(NSUInteger)section; { return YES; }
- (BOOL)shouldHideFooterOnScroll:(NSUInteger)section; { return YES; }
- (BOOL)shouldHideHeaderOnScroll:(NSUInteger)section; { return self.scrollDirection == MysticScrollDirectionDown; }
- (BOOL)shouldShowHeaderOnStart:(NSUInteger)section; { return NO; }

#pragma mark - Toolbar delegate

- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;
{
    self.lastOffset = CGPointUnknown;
    [toolbar selectItem:sender];
    NSString *title = [[sender titleForState:UIControlStateNormal] uppercaseString];
    if([title isEqualToString:libraryTitle]) self.backgroundType = MysticBackgroundTypePhoto;
    else if([title isEqualToString:backgroundsTitle])
    {
        //self.backgroundType = MysticBackgroundTypeBackground;
        
        [self albumsButtonTouched:nil];
    }
    else if([title isEqualToString:colorsTitle]) self.backgroundType = MysticBackgroundTypeColor;
}

- (BOOL) canBecomeFirstResponder; { return YES; }


@end
