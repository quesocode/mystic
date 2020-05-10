//
//  MysticGalleryViewController.m
//  Mystic
//
//  Created by travis weerts on 9/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticGalleryViewController.h"
#import "MysticInstagramPhoto.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "MysticImageViewGallery.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+WebCache.h"

@interface MysticGalleryViewController  () <MysticImageViewGalleryDelegate>
{
    NSString *tagName;
    BOOL isRefreshing, skipNavBarSetup, stopScrolling;
}
@property (nonatomic, assign) NSInteger lastContentOffset;


@end

@implementation MysticGalleryViewController

- (void) dealloc;
{
    stopScrolling = YES;
    self.contentView.delegate = nil;
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        stopScrolling = NO;
        self.lastContentOffset = 0;
        isRefreshing = NO;
        self.delegate = self;
        if(!skipNavBarSetup) [self setupNavBar];
        
        
    }
    return self;
}
- (id) initWithTag:(NSString *)aTag;
{
    skipNavBarSetup = YES;
    self = [self init];
    if(self)
    {
        tagName = aTag;
        self.images = [NSArray array];
        [self setupNavBar];
    }
    return self;
}

- (void) setupNavBar;
{
    self.navigationItem.title = NSLocalizedString(@"Inspiration", nil);
    self.navigationItem.hidesBackButton = YES;
    
    MysticBarButton *button = [MysticBarButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeToolLeft) size:CGSizeMake(MYSTIC_NAVBAR_TOOLICON_WIDTH, MYSTIC_NAVBAR_TOOLICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIconCancel]] target:self sel:@selector(backButtonTouched:)];
    [button setImage:[MysticImage image:@(MysticIconTypeToolLeft) size:CGSizeMake(MYSTIC_NAVBAR_TOOLICON_WIDTH, MYSTIC_NAVBAR_TOOLICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIconHighlighted]] forState:UIControlStateHighlighted];

    button.frame = CGRectMake(0, 0, MYSTIC_NAVBAR_TOOLICON_WIDTH + 15, MYSTIC_NAVBAR_TOOLICON_HEIGHT);
    button.buttonPosition = MysticPositionLeft;
    self.navigationItem.leftBarButtonItem = [MysticBarButtonItem item:button];
    
    
    
    
    UIView *tview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 50)];
    tview.autoresizesSubviews = YES;
    MysticButton *titleButton = [MysticUI clearButtonWithImage:[MysticImage image:@(MysticIconTypeLogo) size:CGSizeMake(30,30) color:@(MysticColorTypeNavBarIcon)] target:self sel:@selector(refreshTouched:)];
    titleButton.frame = CGRectMake(0, 12, 75, 28);
    titleButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleLeftMargin;
    [tview addSubview:titleButton];
    self.navigationItem.titleView = tview;
    
    if([MysticInstagramAPI hasInstagramApp])
    {
        __block NSString *_tagName = tagName ? tagName : MYSTIC_API_INSTAGRAM_TAG;
        
        
        MysticButton *rightBarButton = [MysticButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeShare) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIcon]] action:^{
           
            
            NSString *userMsg = NSLocalizedString(@"You're about to view a Mystic Gallery in the Instagram app. Do you want to continue?", nil);
            [MysticAlert ask:NSLocalizedString(@"Open in Instagram?", nil)  message:userMsg yes:^(id object, id o2) {
                [MysticInstagramAPI openTagInInstagram:_tagName];

            } no:^(id object, id o2) {
                
            } options:nil];
            

        }];
        rightBarButton.buttonPosition = MysticPositionRight;
        rightBarButton.frame = CGRectMake(0, 0, MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT);

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    }
    else
    {
        __block NSString *_tagName = tagName ? tagName : MYSTIC_API_INSTAGRAM_TAG;

        NSURL *url = [NSURL URLWithString:[@"http://mysti.ch/gallery/" stringByAppendingString:_tagName]];
        
        MysticButton *rightBarButton = [MysticButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeShare) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIcon]] action:^{
    
            NSString *userMsg = NSLocalizedString(@"You're about to view a Mystic Gallery in the Safari app. Do you want to continue?", nil);
            
            [MysticAlert ask:NSLocalizedString(@"Open in Safari?", nil)  message:userMsg yes:^(id object, id o2) {
                [[UIApplication sharedApplication] openURL:url];
                
            } no:^(id object, id o2) {
                
            } options:nil];
            
           
            
        }];
        rightBarButton.frame = CGRectMake(0, 0, MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT);

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    }
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor color:MysticColorTypeNavBar];
    self.contentView.delegate = self;
    self.contentView.showsVerticalScrollIndicator = NO;
    self.contentView.showsHorizontalScrollIndicator = NO;
    self.contentView.directionalLockEnabled = YES;
    [self refreshData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) backButtonTouched:(id)sender;
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) refreshTouched:(id)sender;
{
    [self refreshData];
}


- (void) refreshData;
{
    if(isRefreshing) return;
    __unsafe_unretained MysticGalleryViewController *weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    if(tagName)
    {
        isRefreshing = YES;
        [MysticInstagramAPI photosForTag:tagName finished:^(NSArray *photos, BOOL success) {
            isRefreshing = NO;
            [MBProgressHUD hideAllHUDsForView:weakSelf.navigationController.view animated:YES];

            if(!success) return;
            
            if(photos.count)
            {
                self.photosData = [NSArray arrayWithArray:photos];
                self.numberOfImages = self.photosData.count;
                if(self.numberOfImages > 0) [self placeImages];
            }
        }];
    }
}
- (UIImageView *) galleryViewController:(id)viewController viewForIndex:(NSInteger)index;
{
    MysticInstagramPhoto *photo = [self.photosData objectAtIndex:index];
    MysticImageViewGallery *imageView = [[MysticImageViewGallery alloc] init];
//    imageView.tag = index;
    imageView.delegate = self;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    __block MysticImageViewGallery *_imageView = imageView;
    [imageView cancelCurrentImageLoad];

    [imageView setImageWithURL:photo.previewUrl placeholderImage:photo.placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

        if (image && cacheType == SDImageCacheTypeNone)
        {
            _imageView.alpha = 0.0;
            [MysticUIView animateWithDuration:MYSTIC_UI_GALLERY_IMAGE_DURATION
                             animations:^{
                                 _imageView.alpha = 1.0;
                             }];
        }
    }];
    
    
    return imageView;
}

static BOOL hiddenNav = NO;
static BOOL isScrollDragging = NO;
static CGFloat scrollViewDraggingBuffer = 10.0f;

- (void) scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if(stopScrolling) return;

    MysticScrollDirection scrollDirection = MysticScrollDirectionNone;
    CGFloat scrollViewOffsetDifference = (CGFloat) abs((int)(self.lastContentOffset - scrollView.contentOffset.y));
    if (self.lastContentOffset > scrollView.contentOffset.y && scrollViewOffsetDifference > scrollViewDraggingBuffer)
        scrollDirection = MysticScrollDirectionUp;
    else if (self.lastContentOffset < scrollView.contentOffset.y && scrollViewOffsetDifference > scrollViewDraggingBuffer)
        scrollDirection = MysticScrollDirectionDown;
    
    if(scrollViewOffsetDifference > scrollViewDraggingBuffer)
    {
        self.lastContentOffset = scrollView.contentOffset.y;
    }
    
    
    switch (scrollDirection) {
        case MysticScrollDirectionUp:
            if(isScrollDragging && hiddenNav && self.navigationController.navigationBarHidden)
            {
                hiddenNav = NO;
                isScrollDragging = NO;
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            }
            break;
        case MysticScrollDirectionDown:
            if(isScrollDragging && !hiddenNav && !self.navigationController.navigationBarHidden)
            {
                hiddenNav = YES;
                isScrollDragging = NO;
                [self.navigationController setNavigationBarHidden:YES animated:YES];
            }
            break;
        default: break;
    }
    
    
    
}
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    if(stopScrolling) return;
    isScrollDragging = YES;
}
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if(stopScrolling) return;

    isScrollDragging = NO;
}


#pragma mark - mysticImageView Delegate

- (void) mysticImageView:(MysticImageViewGallery *)imageView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    int index = imageView.tag - MysticViewTypeImage;
    if(index > self.photosData.count) return;
    
    MysticInstagramPhoto *photo = [self.photosData objectAtIndex:index];
    imageView.layer.borderWidth = MYSTIC_UI_GALLERY_IMAGE_BORDER;
    imageView.layer.borderColor = [UIColor color:MysticColorTypePink].CGColor;
    
}





@end
