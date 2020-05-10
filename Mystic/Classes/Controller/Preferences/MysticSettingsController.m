//
//  MysticSettingsController.m
//  Mystic
//
//  Created by Travis A. Weerts on 5/27/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticSettingsController.h"
#import "MysticBarButtonItem.h"
#import "MysticCommon.h"
#import "MysticBlurBackgroundView.h"
#import "MysticUser.h"
#import "ABX.h"
#import "AppDelegate.h"
#import "MysticCache.h"
#import "AHKActionSheet.h"

@implementation MysticSettingsCell


- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    return self;
}
- (void) commonInit;
{
    UIView *selectionView = [[UIView alloc] init];
//    selectionView.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.05 alpha:0.5];
    selectionView.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView = selectionView;
    self.showsReorderControl = NO;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    self.indentationWidth = 0;
    self.preservesSuperviewLayoutMargins = NO;
    self.layoutMargins = UIEdgeInsetsZero;
    self.separatorInset = UIEdgeInsetsZero;
}
- (void) setExtraControl:(UIView *)extraControl;
{
    if(_extraControl) [_extraControl removeFromSuperview];
    _extraControl = extraControl;
    [self addSubview:extraControl];
    [self setNeedsLayout];
}
- (void) layoutSubviews;
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectAddXY(self.textLabel.frame, 2, -3);
    self.detailTextLabel.frame = CGRectAddXY(self.detailTextLabel.frame, 2, 3);
    if(_extraControl) self.extraControl.frame = CGRectXY(self.extraControl.frame, self.frame.size.width - 5 - self.extraControl.frame.size.width, (self.frame.size.height - self.extraControl.frame.size.height)/2);
}
@end
@interface MysticSettingsController ()
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, weak) MysticBlurBackgroundView *background;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation MysticSettingsController
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(!self) return nil;
    return [self commonInit];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(!self) return nil;
    return [self commonInit];
}
- (instancetype) commonInit;
{
    [self reloadData];
    self.cellHeight = 65;
    return self;
}
- (void) reloadData;
{
    int q = [MysticUser geti:@"settings-photo-quality"];
    NSString *qualityStr = @"AUTO";
    switch (q) {
        case 0: qualityStr = @"AUTO"; break;
        case 1: qualityStr = @"HIGH"; break;
        case 2: qualityStr = @"NORMAL"; break;
        case 3: qualityStr = @"LOW"; break;
        default: break;
    }
    NSString *cacheSize = @"0 MB";
    long long fsize = [MysticCache cacheSizeForAllExceptProject];
    long long ffsize = fsize/1000;
    cacheSize = [NSString stringWithFormat:@"%2.2llu %@", ffsize/1000, ffsize > 1000 ? @"MB" : @"KB"];
    cacheSize = [cacheSize stringByReplacingOccurrencesOfString:@"00" withString:@"0"];
    BOOL privacy = [[MysticUser get:@"settings-private"] boolValue];
    BOOL tips = [[MysticUser get:@"settings-showTips"] boolValue];
    
    self.data = @[@{@"title": @"Photo Quality", @"subtitle":@"The image resolution", @"action":@"photoQuality", @"value":qualityStr, @"image":@(MysticIconTypeSettingsPhotoQuality)},
                  @{@"title": @"Empty Cache", @"subtitle":@"The image resolution", @"action":@"emptyCache", @"value":cacheSize, @"image":@(MysticIconTypeSettingsEmptyCache)},
                  @{@"title": @"Show Tips", @"subtitle":@"The image resolution", @"action":@"showTips", @"toggle":@(1111), @"value":@(tips), @"image":@(MysticIconTypeSettingsShowTips)},
                  @{@"title": @"Privacy", @"subtitle":@"Your photos will never be shared", @"action":@"private", @"toggle":@(1112), @"value":@(privacy), @"image":@(MysticIconTypeSettingsKeepPrivate)},
                  @{@"title": @"Accessories...", @"subtitle":@"The image resolution", @"action":@"accessories", @"image":@(MysticIconTypeSettingsAccessories)},
//                  @{@"title": @"About Mystic", @"subtitle":@"The image resolution", @"action":@"aboutMystic", @"image":@(MysticIconTypeSettingsAboutMystic)},
                  @{@"title": @"Submit a Bug", @"subtitle":@"The image resolution", @"action":@"submitBug", @"image":@(MysticIconTypeSettingsSubmitBug)},
                  @{@"title": @"Restore Purchases", @"subtitle":@"The image resolution", @"action":@"restorePurchases", @"image":@(MysticIconTypeSettingsRestorePurchases)},
                  
                  //                  @{@"title": @"Reset Defaults"},
                  
                  
                  ];
}
- (void) photoQuality;
{
    __unsafe_unretained __block MysticSettingsController *weakSelf = self;
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:@"PHOTO QUALITY"];
    [actionSheet setupAppearance:MysticActionSheetStyleYesOrNo];
    actionSheet.cancelButtonHeight = 0;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"AUTO", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender){
        [MysticUser set:@(0) key:@"settings-photo-quality"];
        [weakSelf reloadData];
        [weakSelf.tableView reloadData];
    }];
//    [actionSheet addButtonWithTitle:NSLocalizedString(@"MAX", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender){
//        [MysticUser set:@(1) key:@"settings-photo-quality"];
//
//    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"HIGH", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender){
        [MysticUser set:@(1) key:@"settings-photo-quality"];
        [weakSelf reloadData];
        [weakSelf.tableView reloadData];

    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"NORMAL", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender){
        [MysticUser set:@(2) key:@"settings-photo-quality"];
        [weakSelf reloadData];
        [weakSelf.tableView reloadData];

    }];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"LOW", nil) type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *sender){
        [MysticUser set:@(3) key:@"settings-photo-quality"];
        [weakSelf reloadData];
        [weakSelf.tableView reloadData];

    }];
    [actionSheet show];
}
- (void) emptyCache;
{
    DLogRender(@"emptyCache");
    [MysticCache clearAllSafely];
    [self reloadData];
    [self.tableView reloadData];

}
- (void) showTips;
{
    DLogRender(@"showTips");
    [MysticUser toggle:@"settings-showTips"];
    [self reloadData];
    [self.tableView reloadData];
}
- (void) private;
{
    DLogRender(@"private");
    [MysticUser toggle:@"settings-private"];
    [self reloadData];
    [self.tableView reloadData];

}
- (void) accessories;
{
    DLogRender(@"accessories");
    [self reloadData];
    [self.tableView reloadData];
}
- (void) aboutMystic;
{
    DLogRender(@"aboutMystic");
    NSURL *url = [NSURL URLWithString:@"http://mysti.ch/story"];
    
    if (![[UIApplication sharedApplication] openURL:url])
        DLog(@"%@%@",@"Failed to open url:",[url description]);
}
- (void) submitBug;
{
    DLogRender(@"submitBug");
    UIViewController *pvc = self.presentingViewController;
    [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
        [ABXFeedbackViewController showFromController:pvc placeholder:@"Describe the bug you found here..." email:nil metaData:@{ @"Bug Report" : @YES } image:nil];
    }];
    
    
}
- (void) restorePurchases;
{
    DLogRender(@"restorePurchases");
    if(!kEnableStore && (kEnableStore  && ![Mystic storeEnabled]))
    {
        
        [MysticAlert notice:@"Store Closed" message:@"The Mystic Shop is currently closed. Check our website for more info on when it will be open." action:^(id object, id o2) {
            
        } options:@{@"button":@"OK", @"controller": self}];
        
        return;
    }
    if(self.restoreImageView.hidden || self.restoreImageView.highlighted) return;
    if(_activity) {[_activity removeFromSuperview]; _activity=nil; }
    _activity = [[UIActivityIndicatorView alloc] initWithFrame:self.restoreImageView.frame];
    _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.restoreView addSubview:_activity];
    [_activity startAnimating];
    self.restoreImageView.hidden = YES;
    [NSTimer wait:0.2 block:^{
        [[MysticShop sharedShop] restoreCompletedTransactions:^{
            [NSTimer wait:0.1 block:^{
                [_activity stopAnimating];
                [_activity removeFromSuperview];
                self.restoreImageView.hidden = NO;
                self.restoreImageView.highlighted = YES;
//                [NSTimer wait:0.2 block:^{
//                    [self closeItemAction:nil];
//                }];
            }];
        }];
    }];

}
//- (void) loadView;
//{
//    MysticClearView *view = [[MysticClearView alloc] initWithFrame:CGRectMake(0,0,[MysticUI screen].width, [MysticUI screen].height)];
//    view.autoresizesSubviews = YES;
//    self.view = view;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINavigationItem *item = [[UINavigationItem alloc] init];
//    MysticButton *cancelBtn = [MysticButton button:(id)[[MysticAttrString string:@"RESET" style:MysticStringStyleSettingsNavButtonLeft] attrString] target:self sel:@selector(reset:)];
//    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    MysticButton *acceptBtn = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeToolBarConfirm) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM_SKETCH, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM_SKETCH) color:@(MysticColorTypeMenuIconConfirm)] target:self sel:@selector(accept:)];
    UIBarButtonItem *accept = [[UIBarButtonItem alloc] initWithCustomView:acceptBtn];
//    item.leftBarButtonItem = cancel;
    item.rightBarButtonItem = accept;
    
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){0,0,200,50}];
    label.attributedText = [[MysticAttrString string:@"SETTINGS" style:MysticStringStyleNavigationTitle] attrString];
    item.titleView = label;
    self.navBar.items = @[item];
    
    MysticBlurBackgroundView *bg = [[MysticBlurBackgroundView alloc] initWithFrame:self.view.frame];
    bg.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:bg atIndex:0];
    self.background = bg;
    self.view.backgroundColor = UIColor.clearColor;
    self.tableView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor hex:@"302d29"];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.allowsSelection = NO;
//    self.navBar.frame = CGRectXYH(self.navBar.frame, 0, self.view.frame.size.height-60, 60);
//    self.tableView.frame = CGRectXH(self.tableView.frame, 0, self.view.frame.size.height - 60);
}
- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    self.cellHeight = roundf((self.tableView.frame.size.height- 44)/6);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return self.cellHeight;
}
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingsCell";
    MysticSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[MysticSettingsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [cell commonInit];
    }
    NSDictionary *item = [self.data objectAtIndex:indexPath.item];
    cell.textLabel.attributedText = [[MysticAttrString string:[item objectForKey:@"title"] style:MysticStringStyleSettingsCellTitle] attrString];
    if(item[@"subtitle"]) cell.detailTextLabel.attributedText = [[MysticAttrString string:[item objectForKey:@"subtitle"] style:MysticStringStyleSettingsCellSubtitle] attrString];
    if(item[@"image"])
    {
        cell.imageView.image = [MysticImage image:item[@"image"] size:(CGSize){40,40} color:[UIColor colorWithRed:0.50 green:0.45 blue:0.41 alpha:1.00]];
    }
    if(item[@"toggle"])
    {
        Switcher *switcher = [[Switcher alloc] initWithFrame:(CGRect){0,0,44,24}];
        switcher.delegate = self;
        switcher.status = [item[@"value"] boolValue];
        switcher.selectedColor = [UIColor color:MysticColorTypePink];
        switcher.disabledColor = [UIColor colorWithRed:0.37 green:0.35 blue:0.33 alpha:1.00];
        switcher.tag = [item[@"toggle"] intValue];
        [switcher setupView];
        cell.accessoryView = switcher;
    }
    else if(item[@"value"])
    {
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){0,0,70,50}];
        label.attributedText = [[MysticAttrString string:[item objectForKey:@"value"] style:MysticStringStyleSettingsCellDetail] attrString];
        cell.accessoryView = label;
    }
    
    return cell;
}
- (void) switcherDidChangeValue:(Switcher*)switcher value:(BOOL)value;
{
    switch (switcher.tag) {
        case 1111: [self showTips]; break;
        case 1112: [self private]; break;
        default: break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.data objectAtIndex:indexPath.item];
    MysticSettingsCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    if(cell.extraControl && [cell.extraControl isKindOfClass:[Switcher class]])
        [(Switcher *)cell.extraControl switcherButtonDidTouch:(Switcher *)cell.extraControl];
    else if(item[@"action"] && [self respondsToSelector:NSSelectorFromString(item[@"action"])])
        [self performSelector:NSSelectorFromString(item[@"action"])];
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {    
    return NO;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (void) accept:(id)sender;
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}
- (void) reset:(id)sender;
{
    PrintView(@"settings", self.view.topSuperview);

//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@implementation MysticClearView
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(!self) return nil;
    return [self commonInit];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(!self) return nil;
    return [self commonInit];
}
- (instancetype) commonInit;
{
    [super setBackgroundColor:UIColor.clearColor];
    return self;
}
- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    
}

@end
