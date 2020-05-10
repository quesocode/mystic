//
//  MysticDrawerViewController.m
//  Mystic
//
//  Created by Travis on 10/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticDrawerViewController.h"
#import "MysticGalleryViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MysticMainMenuViewCell.h"
#import "MysticLayerTableViewCell.h"
#import "NSArray+Mystic.h"
#import "MysticBarButton.h"
#import "MysticEffectsManager.h"
#import "MysticActionSheet.h"
#import "AppDelegate.h"
#import "MysticController.h"
#import "UserPotion.h"
#import "MysticDrawerListViewController.h"
#import "MysticDrawerMenuViewController.h"
#import "MysticOptions.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import <CoreText/CoreText.h>
#import "MysticDrawerNavViewController.h"

static CGFloat mainSectionHeight = 0;

@interface MysticDrawerViewController () <UIActionSheetDelegate>
{
    BOOL _hasSetupToolbar;
}

@end

@implementation MysticDrawerViewController

- (void) dealloc;
{
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self commonInit];
    }
    return self;
}


- (void) commonInit;
{
    [super commonInit];

    __unsafe_unretained __block MysticDrawerViewController *weakSelf = self;
    _hasSetupToolbar = NO;
    _shouldHideToolbar = NO;
    self.navigationItem.hidesBackButton = YES;

    
    
    [self updateNavBar];
    
    
    
    

    

}

- (void) viewDidLoad;
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    
    
    NSMutableAttributedString *str = [NSMutableAttributedString attributedStringWithString:[NSLocalizedString(@"Layers", nil) uppercaseString] ];
    [str setCharacterSpacing:2.1];
    [str setFont:[MysticUI gothamBook:MYSTIC_UI_DRAWER_NAV_TEXTSIZE_SMALL]];
    [str setTextColor:[UIColor color:MysticColorTypeDrawerNavBarText]];
    [str setTextAlignment:kCTCenterTextAlignment lineBreakMode:kCTLineBreakByWordWrapping];
    
    OHAttributedLabel *label = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(0, -2, self.view.frame.size.width, 50-5)];
    [label setAttributedText:str];
    label.centerVertically = YES;
    label.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = label;
    [label release];
    
}



- (void) viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    if(self.shouldHideToolbar)
    {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}
- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    if([self.navigationController.viewControllers containsObject:self] && self.hidesBottomBarWhenPushed)
    {
        

        [self setupToolbarAnimated:NO];

    }
    
    
}
- (void)viewDidAppear:(BOOL)animated
{
//

    self.shouldHideToolbar = NO;


    

    [super viewDidAppear:animated];
    _hasSetupToolbar = NO;

}

- (NSArray *) toolbarItems;
{
    NSDictionary *plusIcon = @{@"type": @(MysticToolTypeAdd),
                               @"icon": @(MysticIconTypeToolPlus),
                               @"action": @"addLayerButtonTouched:",
                               @"size": CGSizeMakeValue(60, 60),
                               @"iconSize": CGSizeMakeValue(44, 44),
                               @"color": @(MysticColorTypeDrawerToolbarIcon)};
    
    NSDictionary *cogIcon = @{@"type": @(MysticToolTypeAdd),
                              @"icon": @(MysticIconTypeToolCog),
                              @"action": @"settingsButtonTouched:",
                              @"size": CGSizeMakeValue(60, 60),
                              @"iconSize": CGSizeMakeValue(31, 31),
                              @"color": @(MysticColorTypeDrawerToolbarIcon)};
    
    
    NSDictionary *homeIcon = @{@"type": @(MysticToolTypeCustom),
                               @"icon": @(MysticIconTypeToolHome),
                               @"action": @"homeButtonTouched:",
                               @"size": CGSizeMakeValue(60, 60),
                               @"iconSize": CGSizeMakeValue(29, 29),
                               @"color": @(MysticColorTypeDrawerToolbarIcon)};
    
    MysticBarButtonItem *homeItem = [MysticBarButtonItem itemForType:homeIcon target:self];
    
    MysticBarButtonItem *plusItem = [MysticBarButtonItem itemForType:plusIcon target:self];
    MysticBarButtonItem *cogItem = [MysticBarButtonItem itemForType:cogIcon target:self];
    
    MysticBarButtonItem *flexItem = [MysticBarButtonItem itemForType:@(MysticToolTypeFlexible) target:self];
//    MysticBarButtonItem *noPaddingItem = [MysticBarButtonItem itemForType:@(MysticToolTypeNoPadding) target:self];
    return @[homeItem, flexItem, plusItem, flexItem, cogItem];
}
- (void) setupToolbarAnimated:(BOOL)animated;
{
    [self.navigationController setToolbarHidden:NO animated:NO];
    if(!animated)
    {
        CGPoint pos = self.navigationController.toolbar.layer.position;
        pos.x = self.view.frame.size.width/2;
        self.navigationController.toolbar.layer.position = pos;
        
        CGRect tf = self.navigationController.toolbar.frame;
        tf.origin.x = 0;
        self.navigationController.toolbar.frame = tf;
    }
    [self.navigationController.toolbar setItems:[self toolbarItems] animated:animated];
    _hasSetupToolbar = YES;
}

- (void) addLayerButtonTouched:(id)sender;
{
    
    if ([MysticOptions current].numberOfTextures >= MYSTIC_PROCESS_LAYERS_MAX_ADD) {
        return;
    }

    
    [[MysticController controller] showPackPickerForType:nil option:nil layoutStyle:MysticLayoutStyleListToGrid complete:nil];

    
    
    
    
}

- (void) settingsButtonTouched:(id)sender;
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate openSettingsAnimated:YES complete:nil];
}

- (void) homeButtonTouched:(id)sender;
{
    self.shouldHideToolbar = YES;

    MysticDrawerMenuViewController *controller = [[[MysticDrawerMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [self.navigationController setViewControllers:@[controller, self] animated:NO];
//    [controller release];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void) itemTapped:(id)sender;
{
//    DLog(@"item tapped: %@", sender);
}

- (void) leftNavButtonTouched:(id)sender;
{
    __unsafe_unretained __block MysticDrawerViewController *weakSelf = self;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate newProject];
    
    
}

- (void) rightNavButtonTouched:(id)sender;
{
    [self addLayerButtonTouched:sender];
    
}





- (UIViewController *) loadSection:(NSInteger)section animated:(BOOL)animated;
{
    [self reload];
    if(self.navigationController.viewControllers.count > 1 && self.navigationController.visibleViewController != self)
    {
        [self.navigationController popToViewController:self animated:NO];
    }
//    [self scrollToSection:section animated:animated];
    return self;
}




- (void) updateNavBar;
{
    __unsafe_unretained __block MysticDrawerViewController *weakSelf = self;

    MysticBarButton *leftButton = (MysticBarButton *)[MysticBarButton button:[MysticImage image:@(MysticIconTypeToolX) size:CGSizeMake(30, 30) color:@(MysticColorTypeDrawerNavBarButton)] action:^(MysticBarButton *sender) {
        //        [[MysticController controller] setStateConfirmed:MysticSettingPreferences animated:YES info:nil complete:nil];
        //        [weakSelf inspiration];
        [weakSelf leftNavButtonTouched:sender];
        
        
    }];
    leftButton.contentMode = UIViewContentModeCenter;
    
    [self.navigationItem setLeftBarButtonItem:[MysticBarButtonItem buttonItem:leftButton] animated:NO];
    
    MysticBarButtonItem *empty = [MysticBarButtonItem emptyItem];
    empty.customView.frame = CGRectMake(0, 0, leftButton.frame.size.width, leftButton.frame.size.height);
    [self.navigationItem setRightBarButtonItem:empty animated:NO];

    if ([MysticOptions current].numberOfTextures >= MYSTIC_PROCESS_LAYERS_MAX_ADD) {
        return;

    }

    
}



- (void) initData;
{
    __unsafe_unretained __block   MysticDrawerViewController *weakSelf = self;
    
    self.sections = @[
                      
                    
                      
                      @{
                        @"rows": [self currentLayerRows],
                        },
                     
                      ];
}


- (NSArray *) currentLayerRows;
{
    __unsafe_unretained __block  MysticDrawerViewController *weakSelf = self;
    
    PackPotionOption *option;
//    UIColor *imgBgColor = [UIColor color:MysticColorTypeControlInactive];
    UIColor *titleColor = [UIColor color:MysticColorTypeDrawerText];
    UIColor *iconColor = [UIColor color:MysticColorTypeDrawerIcon];
//    UIColor *indicatorColor = [UIColor color:MysticColorTypeDrawerAccessory];
    NSMutableArray *layerRows = [NSMutableArray array];
    NSValue *iconSize = [NSValue valueWithCGSize:(CGSize){80,80}];
    
    int i = 0;
    for (option in [MysticOptions reversedOptions])
    {
        
        if(!option.showInLayers)
        {
            DLog(@"DRAWER: Wont show option in layers: %@", option.debugDescription);
             continue;
        }
        UIImage *theIcon = nil;
        switch (option.type) {
            case MysticObjectTypeFilter:
                theIcon = (id)@(MysticIconTypeFilter);
                break;
            case MysticObjectTypeSetting:
                theIcon = (id)@(MysticIconTypeSettings);
                break;
                
            default:
                theIcon = option.icon;
                break;
        }
        
        UIViewContentMode cMode = UIViewContentModeScaleAspectFill;
        switch (option.type)
        {
            case MysticObjectTypeText:
            case MysticObjectTypeTexture:
            case MysticObjectTypeLight:
            case MysticObjectTypeFont:
            case MysticObjectTypeFontStyle:
            case MysticObjectTypeFrame:
            {
                cMode = UIViewContentModeScaleAspectFill;
                break;
            }
            case MysticObjectTypeFilter:
            {
                cMode = UIViewContentModeCenter;
                break;
            }
            case MysticObjectTypeSetting:
            {
                cMode = UIViewContentModeCenter;
                break;
            }
            default:
            {
                break;
            }
        }
        
        NSDictionary *rowData = @{@"subtitle": option.layerSubtitle,
                                  @"title": option.layerTitle,
                                  @"image": theIcon ? theIcon : @"",
                                  @"imageContentMode": theIcon ? @(cMode) : @(UIViewContentModeScaleAspectFit),
                                  @"imageSize": iconSize,
                                  @"option": option,
                                  @"titleColor": titleColor,
                                  @"accessory": @(MysticIconTypeToolLayerSettings),
                                  @"accessoryHighlighted": @(MysticIconTypeToolLayerSettingsHighlighted),
                                  @"closeDrawerFirst": @YES,
                                  @"moveable": @(option.canReorder),
                                  @"state": @(option.editState),
                                  @"userInfo": @{@"object": option},
                                  @"type": @(MysticObjectTypeLayer),
                                  @"imageBorder": @NO,
                                  
                                  };
        
        switch (option.type)
        {



            case MysticObjectTypeFilter:
            case MysticObjectTypeSetting:
            {
                NSMutableDictionary *_rowData = [NSMutableDictionary dictionaryWithDictionary:rowData];
                [_rowData setObject:@(MysticColorTypeDrawerIconBackground) forKey:@"imageBackground"];
                [_rowData setObject:[NSValue valueWithCGSize:CGSizeMake(24, 24)] forKey:@"imageSize"];
                [_rowData setObject:@(UIViewContentModeCenter) forKey:@"imageContentMode"];
//                [_rowData setObject:@YES forKey:@"imageBorder"];
                [_rowData setObject:iconColor forKey:@"color"];
                switch (option.type)
                {
                    case MysticObjectTypeFilter:
                    {
//                        [_rowData setObject:@(MysticIconTypeFilter) forKey:@"image"];
                        [_rowData setObject:[NSValue valueWithCGSize:CGSizeMake(24, 24)] forKey:@"imageSize"];

                        [_rowData setObject:iconColor forKey:@"color"];
                        if(option.backgroundColor)
                        {
                            UIColor *newColor = option.backgroundColor;
                            newColor = [newColor blendWithColor:[UIColor colorWithType:MysticColorTypeDrawerIconBackground] alpha:0.6];
                            [_rowData setObject:newColor forKey:@"imageBackground"];
                        }
                        break;
                    }
                    default:
                    {
                        break;
                    }
                }

                rowData = [NSDictionary dictionaryWithDictionary:_rowData];
                
                break;
            }
                
            default: break;
        }
        
        [layerRows addObject:rowData];
        i++;
    }
    
    
    
    
    
    
    [layerRows addObject:@{@"title": @"Photo",
                           @"subtitle": @"Background",
                           @"image": [UserPotion potion].thumbnailPreviewImage,
                           
//                           @"color": iconColor,
                           @"size": iconSize,
                           @"titleColor": titleColor,
                           @"accessory": @(MysticIconTypeToolLayerSettings),
                           @"accessoryHighlighted": @(MysticIconTypeToolLayerSettingsHighlighted),
                           @"state": @(MysticSettingSettings),
                           @"moveable": @NO,
                           @"visible": @YES,
                           @"closeDrawerFirst": @YES,
                           @"type": @(MysticObjectTypeImage),
                           }];
    return layerRows;
}
- (void) reload;
{
    [self updateNavBar];
    self.sections = @[
                      //                      [super.sections objectAtIndex:MysticDrawerSectionMain],
                      @{
                          //                          @"title": [[super.sections objectAtIndex:MysticDrawerSectionLayers] objectForKey:@"title"],
                          @"rows": [self currentLayerRows],
                          },
                      
                      //                      [super.sections objectAtIndex:MysticDrawerSectionAdd],
                      //                      [super.sections objectAtIndex:MysticDrawerSectionAddSpecial]
                      ];
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:MysticDrawerSectionLayers];
//    mainSectionHeight = ([self sectionVisibleRows:indexPath].count-1) * [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
    [self.tableView reloadData];
}

- (void) emptyData;
{
    [super emptyData];
    self.sections = @[];
    [self.tableView reloadData];

    
}




- (void) saveOrder;
{
    NSArray *newRows = [self sectionRows:[NSIndexPath indexPathForRow:0 inSection:MysticDrawerSectionLayers]];
    NSMutableArray *newOptions = [NSMutableArray array];
    for (NSDictionary *row in newRows) {
        if([row objectForKey:@"option"])
        {
            [newOptions addObject:[row objectForKey:@"option"]];
        }
    }
    [[MysticOptions current] reorder:[newOptions reversedArray]];
    [[MysticController controller] reloadImageInBackground:NO settings:MysticRenderOptionsForceProcess];
    
    [[MysticOptions current] saveProject];

}
- (void) reorderSection:(NSInteger)section rows:(NSArray *)newRows;
{
    self.sections = @[
//                      [super.sections objectAtIndex:MysticDrawerSectionMain],
                      @{
//                          @"title": [[super.sections objectAtIndex:MysticDrawerSectionLayers] objectForKey:@"title"],
                          @"rows": newRows,
                          },
                      
//                      [super.sections objectAtIndex:MysticDrawerSectionAdd],
//                      [super.sections objectAtIndex:MysticDrawerSectionAddSpecial]
                      ];
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    self.shouldHideToolbar = NO;
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MysticNavigationViewController *nav = (MysticNavigationViewController *)[(MMDrawerController *)app.window.rootViewController centerViewController];
    if([nav containsViewControllerOfClass:[MysticController class]] && ![nav.visibleViewController isKindOfClass:[MysticController class]])
   {
       [nav popToViewController:[nav viewControllerOfClass:[MysticController class]] animated:NO];
   }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
    self.shouldHideToolbar = YES;
    NSDictionary *sectionRow = [self sectionRow:indexPath];
    if(sectionRow)
    {
        MysticObjectType sectionType = [sectionRow objectForKey:@"type"] ? (MysticObjectType)[[sectionRow objectForKey:@"type"] integerValue] : MysticObjectTypeUnknown;
//        BOOL tappedPhoto = sectionType == MysticObjectTypeImage || indexPath.row == ([self tableView:self.tableView numberOfRowsInSection:indexPath.section] - 1);

        UIColor *titleColor = [UIColor color:MysticColorTypeDrawerText];
        UIColor *iconColor = [UIColor color:MysticColorTypeDrawerIcon];
        NSValue *iconSize = [NSValue valueWithCGSize:(CGSize){24,24}];
        
        MysticDrawerListViewController *listController = [[MysticDrawerListViewController alloc] initWithNibName:@"MysticTableViewController" bundle:nil];
        __unsafe_unretained __block MysticDrawerListViewController *weakController = listController;
        __unsafe_unretained __block MysticDrawerViewController *weakSelf = self;
        PackPotionOption *option = [sectionRow objectForKey:@"option"];
        switch (sectionType)
        {
            case MysticObjectTypeImage:
            {
                listController.navigationItem.title = NSLocalizedString(@"Photo", nil);
                listController.navigationItem.hidesBackButton = YES;
                
                MysticBarButton *leftButton = (MysticBarButton *)[MysticBarButton button:[MysticImage image:@(MysticIconTypeToolLeft) size:CGSizeMake(40, 40) color:@(MysticColorTypeDrawerNavBarButton)] action:^(MysticBarButton *sender) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
                
                listController.navigationItem.leftBarButtonItem = [MysticBarButtonItem item:leftButton];
                
                
                PackPotionOptionSetting *settingsOption = (PackPotionOptionSetting *)[[MysticOptions current] option:MysticObjectTypeSetting];
                NSDictionary *_userInfo = settingsOption ? @{@"object": settingsOption} : @{};
                listController.sections = @[
                     @{


                    @"rows": @[
                            
                            /*
                          @{@"title": @"Retake Photo",
                            @"CellClass": [MysticMainMenuViewCell class],
                            @"image": @(MysticIconTypeCamera),
                            @"color": iconColor,
                            @"titleColor": titleColor,
                            @"target": weakSelf,
                            @"action": @"takePhotoAndReload",
                            @"closeDrawer": @NO,
                            //                          @"imageBorder": @YES,
                            @"imageBorder": @NO,
                            @"imageCornerRadius": @(MYSTIC_UI_DRAWER_CELL_CORNER_RADIUS),
                            @"imageContentMode": @(UIViewContentModeCenter),
                            @"imageSize": iconSize,
                            },
                          
                          
                          @{@"title": @"Swap Photo",
                            @"CellClass": [MysticMainMenuViewCell class],
                            @"image": @(MysticIconTypeSave),
                            @"color": iconColor,
                            @"titleColor": titleColor,
                            @"target": weakSelf,
                            @"action": @"choosePhotoAndReload",
                            @"closeDrawer": @NO,
                            //                          @"imageBorder": @YES,
                            @"imageBorder": @NO,
                            @"imageContentMode": @(UIViewContentModeCenter),
                            @"imageCornerRadius": @(MYSTIC_UI_DRAWER_CELL_CORNER_RADIUS),
                            @"imageSize": iconSize,


                            },
                             
                             */
                          
                          @{@"title": @"Adjust",
                            @"CellClass": [MysticMainMenuViewCell class],
                            @"image": @(MysticIconTypeSettings),
                            @"color": iconColor,
                            @"titleColor": titleColor,
                            @"closeDrawerFirst": @YES,
                            @"state": @(MysticSettingSettings),
                            @"userInfo": _userInfo,
                            //                          @"imageBorder": @YES,
                            @"imageBorder": @NO,
                            @"imageContentMode": @(UIViewContentModeCenter),
                            @"imageCornerRadius": @(MYSTIC_UI_DRAWER_CELL_CORNER_RADIUS),
                            @"imageSize": iconSize,

                            },
                          
                          ],
                }];
                break;
            }
            case MysticObjectTypeLayer:
            default:
            {
                listController.navigationItem.title = NSLocalizedString([sectionRow objectForKey:@"subtitle"], nil);
                listController.navigationItem.hidesBackButton = YES;
                MysticBarButton *leftButton = (MysticBarButton *)[MysticBarButton button:[MysticImage image:@(MysticIconTypeToolLeft) size:CGSizeMake(40, 40) color:@(MysticColorTypeDrawerNavBarButton)] action:^(MysticBarButton *sender) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
                
                listController.navigationItem.leftBarButtonItem = [MysticBarButtonItem item:leftButton];
                listController.sections = @[
                                            
                                            
            @{
                
                
                @"rows": @[
                        
                        
                        
                        @{@"title": @"Adjust",
                          @"CellClass": [MysticMainMenuViewCell class],
                          @"image": @(MysticIconTypeSettings),
                          @"imageContentMode": @(UIViewContentModeCenter),
                          @"color": iconColor,
                          @"titleColor": titleColor,
                          @"closeDrawerFirst": @YES,
                          @"state": @(MysticSettingSettingsLayer),
                          @"userInfo": @{@"object": option},
                          //                          @"imageBorder": @YES,
                          @"imageBorder": @NO,
                          @"imageContentMode": @(UIViewContentModeCenter),
                          @"imageCornerRadius": @(MYSTIC_UI_DRAWER_CELL_CORNER_RADIUS),
                          @"imageSize": iconSize,

                          
                          },
                        
                        @{@"title": @"Remove",
                          @"CellClass": [MysticMainMenuViewCell class],
                          @"image": @(MysticIconTypeToolX),
                          @"color": iconColor,
                          @"titleColor": titleColor,
                          @"confirm": @"Are you sure?",
                          @"confirmMessage": @"Are you sure you want to remove this?",
                          @"confirmCancel": @"No",
                          @"confirmConfirm": @"Yes",
                          @"closeDrawerFirst": @NO,
                          @"target": weakSelf,
                          @"action": @"removeOptionAndGoBack:",
                          @"param": option,
//                          @"imageBorder": @YES,
                          @"imageBorder": @NO,

                          @"imageContentMode": @(UIViewContentModeCenter),
                          @"imageCornerRadius": @(MYSTIC_UI_DRAWER_CELL_CORNER_RADIUS),
                          @"imageSize": iconSize,

                          },
                        
                        ],
                }];
                break;
            }
        }
        
        [self.navigationController pushViewController:listController animated:YES];
        [listController release];
        
        
        return;

    }
}

- (void) actionSheet:(UIActionSheet *)_actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    __unsafe_unretained __block MysticDrawerViewController *weakSelf = self;
    MysticActionSheet *actionSheet = (MysticActionSheet *)_actionSheet;
    NSDictionary *row = [self sectionRow:actionSheet.indexPath];
    PackPotionOption *option = [row objectForKey:@"option"];
    
    if(buttonIndex == actionSheet.cancelButtonIndex) return;
    switch (actionSheet.tag) {
        case MysticViewTypeButton1:
        {
            switch (buttonIndex) {
                    // take photo
                case 0:
                {
                    [weakSelf takePhoto];
                    break;
                }
                    // choose photo
                case 1:
                {
                    [weakSelf choosePhoto];


                    break;
                }
                default: break;
            }
            break;
        }
        case MysticViewTypeButton2:
        {
            switch (buttonIndex) {
                // remove layer
                case 0:
                {
                    [weakSelf removeOption:option];
                    
                    break;
                }
                    
                default: break;
            }
            break;
        }
            
        default: break;
    }
}

- (void) takePhoto;
{
    __unsafe_unretained __block MysticDrawerViewController *weakSelf = self;

    [[MysticController controller] pick:MysticPickerSourceTypeCamera finished:^{
        [weakSelf.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:NO completion:^(BOOL finished) {
            
        }];
    }];
}

- (void) takePhotoAndReload;
{
    __unsafe_unretained __block MysticDrawerViewController *weakSelf = self;
    
    [[MysticController controller] pick:MysticPickerSourceTypeCamera finished:^{
        [[MysticOptions current] setHasChanged:YES];
        [[MysticOptions current] setNeedsRender];
        [MysticOptions enable:MysticRenderOptionsForceProcess];
        
        [weakSelf reload];
        [MysticEffectsManager render];
//        [MysticController setNeedsDisplay];
        [weakSelf.navigationController popToViewController:weakSelf animated:YES];

    }];
}

- (void) choosePhoto;
{
    __unsafe_unretained __block MysticDrawerViewController *weakSelf = self;
    
    [[MysticController controller] pick:MysticPickerSourceTypePhotoLibrary finished:^{
        [weakSelf.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:NO completion:^(BOOL finished) {
            
        }];
    }];
}
- (void) choosePhotoAndReload;
{
    __unsafe_unretained __block MysticDrawerViewController *weakSelf = self;
    
    [[MysticController controller] pick:MysticPickerSourceTypePhotoLibrary finished:^{
        [[MysticOptions current] setHasChanged:YES];
        [[MysticOptions current] setNeedsRender];
        [MysticOptions enable:MysticRenderOptionsForceProcess];
        
        [weakSelf reload];
        [MysticEffectsManager render];
//        [MysticController setNeedsDisplay];
        [weakSelf.navigationController popToViewController:weakSelf animated:YES];
    }];
}
- (void) removeOptionAndGoBack:(PackPotionOption *)option;
{
 
//        [self.navigationController popViewControllerAnimated:YES];
        [self removeOption:option];
   
    
}
- (void) removeOption:(PackPotionOption *)option;
{
    option.ignoreRender = YES;
    [UserPotion removeOption:option];
    [[MysticOptions current] setHasChanged:YES];
    [[MysticOptions current] setNeedsRender];
    [MysticOptions enable:MysticRenderOptionsForceProcess];
    
    [self reload];
    [MysticEffectsManager render];
//    [MysticController setNeedsDisplay];
}




- (void) scrollViewDidScroll:(UIScrollView *)scrollView;
{

    
}





@end
