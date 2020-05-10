//
//  MysticLayersViewController.m
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticLayersViewController.h"
#import "MysticAddLayerViewController.h"
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
#import "MysticLayersBottomView.h"
#import "MysticLabel.h"

static CGFloat mainSectionHeight = 0;

@interface MysticLayersViewController () <UIActionSheetDelegate>
{
    BOOL _hasSetupToolbar, _ignoreToggles;
}
@property (nonatomic, assign) PackPotionOption *lastOptionSwitched;
@property (nonatomic, retain) NSMutableDictionary *switchedOptions;
@end

@implementation MysticLayersViewController

- (void) dealloc;
{
    DLog(@"dealloc layers drawer");
    
    _ignoreToggles = YES;
    _lastOptionSwitched = nil;
    [_switchedOptions release], _switchedOptions=nil;
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
    _hasSetupToolbar = NO;
    _shouldHideToolbar = NO;
    self.navigationItem.hidesBackButton = YES;
    _ignoreToggles = NO;
    self.lastOptionSwitched = nil;
    self.switchedOptions = [NSMutableDictionary dictionary];
    [self updateNavBar];
}

- (void) viewDidLoad;
{
    [super viewDidLoad];
    self.tableView.delegate = self;
//
//    
//    CGRect bViewFrame = CGRectAlign((CGRect){0,0,self.view.frame.size.width,MYSTIC_UI_DRAWER_LAYERS_BOTTOMVIEW_HEIGHT}, self.view.bounds, MysticAlignTypeBottom);
//    MysticLayersBottomView *bView = [[[MysticLayersBottomView alloc] initWithFrame:bViewFrame] autorelease];
//    bView.backgroundColor = self.view.backgroundColor;
//    bView.autoresizesSubviews = YES;
//    bView.borderPosition = MysticPositionTop;
//    bView.borderWidth = 1;
//    bView.borderColor = [UIColor color:MysticColorTypeDrawerBackgroundCellBorder];
//
//    bView.borderInsets = UIEdgeInsetsMake(1, 0, 0, 0);
//    bView.showBorder = YES;
//    CGRect btnFrame = bViewFrame;
//    btnFrame = CGRectIntegral(btnFrame);

//    MysticButton *shareButton = [MysticButton buttonWithTitle:@"SAVE  &  SHARE" target:self sel:@selector(shareTouched:)];
//    shareButton.frame = bView.bounds;
//    [shareButton setBackgroundColor:[UIColor hex:@"1a1a19"] forState:UIControlStateNormal];
//    [shareButton setBackgroundColor:@(MysticColorTypePink) forState:UIControlStateHighlighted];
//    shareButton.titleLabel.font = [MysticFont font:13];
//    shareButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [shareButton setTitleColor:[UIColor hex:@"ede6d8"] forState:UIControlStateNormal];
//    [shareButton setTitleColor:[UIColor hex:@"25211e"] forState:UIControlStateHighlighted];
//    
//    CGSize iconSize = CGSizeMake(39, 39);
//    
//    [shareButton setImage:[MysticImage image:@(MysticIconTypeToolLeft) size:iconSize color:[UIColor color:MysticColorTypePink]] forState:UIControlStateNormal];
//    shareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    CGSize size = [shareButton.titleLabel.text sizeWithFont:shareButton.font];
//    CGRect f = CGRectMake(0, 0, MYSTIC_UI_DRAWER_RIGHT_WIDTH, MYSTIC_UI_DRAWER_LAYERS_BOTTOMVIEW_HEIGHT);
//    
//    
//    CGFloat x = ((f.size.width - size.width)/2);
//    
//    x = x - iconSize.width;
//    
//    shareButton.titleEdgeInsets = UIEdgeInsetsMake(0, x+10, 0, 0);
//    shareButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
//    [bView addSubview:shareButton];
    
//    MysticButton *addButton = [MysticButton buttonWithIconType:MysticIconTypePlus color:@(MysticColorTypeDrawerBackgroundCellBorder) target:self action:@selector(addTouched:)];
//    btnFrame.origin.y = 1;
//    btnFrame.size.height -= 1;
//    addButton.frame = btnFrame;
//    addButton.imageEdgeInsets = UIEdgeInsetsMakeFrom(13);
//    addButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [addButton setBackgroundColor:bView.backgroundColor forState:UIControlStateNormal];
//    [addButton setBackgroundColor:@(MysticColorTypeWhite) forState:UIControlStateHighlighted];
////    addButton.titleLabel.font = [MysticFont fontBold:13];
////    [addButton setTitleColor:[UIColor color:MysticColorTypeWhite] forState:UIControlStateNormal];
//    [bView addSubview:addButton];
    
//    self.bottomView = bView;
    
}


- (void) shareTouched:(id)sender;
{
    [self.mm_drawerController
     closeDrawerAnimated:YES
     completion:^(BOOL finished) {
         if(finished)
         {
             [[MysticController controller] setState:MysticSettingShare animated:YES complete:nil];
         }
     }];
}

- (void) addTouched:(id)sender;
{
    
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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor color:MysticColorTypeDrawerBackground];
    self.tableView.backgroundColor = self.view.backgroundColor;
    
}
- (void)viewDidAppear:(BOOL)animated
{
    //
    
    self.shouldHideToolbar = NO;
    

    
    [super viewDidAppear:animated];
    _hasSetupToolbar = NO;
    
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


- (void) itemTapped:(id)sender;
{
    //    DLog(@"item tapped: %@", sender);
}

- (void) leftNavButtonTouched:(id)sender;
{
    __unsafe_unretained __block  MysticLayersViewController *weakSelf = self;
    
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

    
}



- (void) initData;
{
    
    self.sections = @[@{@"rows": [self currentLayerRows],},];
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    return MYSTIC_DRAWER_LAYER_CELL_HEIGHT;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block MysticLayersViewController *weakSelf = self;
    MysticLayerTableViewCell *cell = (id)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell.imageViewControl addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    [cell.imageViewBackground addTarget:self action:@selector(switchBgToggled:) forControlEvents:UIControlEventTouchUpInside];

    NSDictionary *cellInfo = [self sectionRow:indexPath];
    BOOL switchOn = isM(cellInfo[@"switchOn"]) ? [[cellInfo objectForKey:@"switchOn"] boolValue] : YES;
    BOOL ignoreRender = isM(cellInfo[@"ignoreRender"]) ? [[cellInfo objectForKey:@"ignoreRender"] boolValue] : NO;

    cell.imageViewControl.enabled = [cellInfo objectForKey:@"switchEnabled"] && ![[cellInfo objectForKey:@"switchEnabled"] boolValue] ? NO : YES;
    PackPotionOption *option = [cellInfo objectForKey:@"option"];


//    cell.imageViewControl.on = switchOn;
    cell.imageViewBackground.enabled = cell.imageViewControl.enabled;
    cell.imageViewControl.hidden = cell.imageViewControl.enabled ? NO : YES;
    
    if(cell.imageViewBackground.enabled)
    {
        cell.imageViewControl.startSending = YES;
    }
    
    if(option.canReplaceColor && [option hasUserSelectedColorOfOptionType:MysticOptionColorTypeForeground])
    {
        UIColor *fc = [option foregroundColor];
        if(fc)
        {
            [cell setImageViewBorderColor:fc];
        }
  
    }
    
    [self switchToggled:cell.imageViewControl runFinished:NO toggle:cell.imageViewControl.on != switchOn ? YES : NO value:@(ignoreRender)];

    if(isMEmpty([cellInfo objectForKey:@"image"]))
    {
        MysticBlockSetImageView c = option.imageViewBlock;
        if(c)
        {
            cell.imageView.image = [UIImage imageNamed:@"layer_icon_placeholder.png"];
            
            c(cell, ^(UIImage *nimg, BOOL iDone)
            {
      
                if(iDone)
                {
                    [weakSelf reload];

                }
                Block_release(c);
            });
            

        }


    }
    cell.imageView.layer.cornerRadius = MYSTIC_UI_DRAWER_CELL_CORNER_RADIUS;
    cell.imageView.layer.masksToBounds = YES;
//    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;


    return (id)cell;
}
- (void) switchBgToggled:(UIButton *)sender;
{
    MysticLayerTableViewCell* cell = (id)sender;
    
    while (cell.superview) {
        cell = (id)cell.superview;
        if ([cell isKindOfClass:[MysticLayerTableViewCell class]])
        {
            break;
        }
    }
    
    if(!cell || ![cell isKindOfClass:[MysticLayerTableViewCell class]]) return;
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    [self switchToggled:cell.imageViewControl runFinished:YES toggle:YES value:@"-"];
}
- (void) switchToggled:(Switch*)mySwitch;
{
    [self switchToggled:mySwitch runFinished:YES toggle:NO value:@"-"];
}
- (void) switchToggled:(Switch*)mySwitch runFinished:(BOOL)shouldFinish toggle:(BOOL)shouldToggleAfter value:(id)ignoreRenderV;
{
    BOOL isOn = shouldToggleAfter ? !mySwitch.on : mySwitch.on;
    MysticLayerTableViewCell* cell = (id)mySwitch;
    
    while (cell.superview) {
        cell = (id)cell.superview;
        if ([cell isKindOfClass:[MysticLayerTableViewCell class]])
        {
            break;
        }
    }
    
    if(!cell || ![cell isKindOfClass:[MysticLayerTableViewCell class]]) return;
    
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *cellInfo = [self sectionRow:indexPath];
    PackPotionOption *option = [cellInfo objectForKey:@"option"];
    
    BOOL ignoreRender = NO;
    BOOL autoIgnore = NO;
    if(![ignoreRenderV isKindOfClass:[NSString class]])
    {
        ignoreRender = [ignoreRenderV boolValue];
    }
    else if([ignoreRenderV isEqualToString:@"-"])
    {
        ignoreRender = option.ignoreActualRender;
        autoIgnore = YES;
    }

    BOOL setOptionIgnore = option.ignoreActualRender != ignoreRender;
    
    if(autoIgnore && isOn != mySwitch.on)
    {
        setOptionIgnore = YES;
        ignoreRender = !isOn;
    }
    
//    ALLog(@"switch:", @[@"on", isOn ? @"ON" : @"OFF",
//                        @"switch", mySwitch.on ? @"ON" : @"OFF",
//                        @"auto", MBOOL(autoIgnore),
////                        @"animated", MBOOL(shouldFinish),
//                        @"toggle", MBOOL(shouldToggleAfter),
//                        @"hidden", MBOOL(mySwitch.hidden),
//                        @"value", MBOOL(ignoreRender),
//                        @"set", MBOOL(setOptionIgnore),
//                        @"option", !option ? @"---" : [MObj(option.name) stringByAppendingString:MBOOL(option.ignoreActualRender)],
//                        ]);
    
    if(isOn && shouldToggleAfter && !mySwitch.hidden)
    {
        if(_ignoreToggles) return;
        mySwitch.on = isOn;
        return;
    }
    
    
    if(!ignoreRender && setOptionIgnore)
    {
        
        //DLog(@"messed up");
        
        setOptionIgnore = !isOn && !ignoreRender ? NO : setOptionIgnore;
        
    }

    if(cell.imageViewBackground.hidden) return;
    BOOL changedSwitch = NO;
    BOOL changedSwitchValue = NO;
    if(!mySwitch.hidden && setOptionIgnore)
    {
        changedSwitch = YES;
        BOOL originalSwitchValue = option ? option.ignoreActualRender : NO;
        id swv = [self.switchedOptions objectForKey:indexPath];
        if(swv)
        {
            originalSwitchValue = [swv boolValue];
        }
        option.ignoreActualRender = ignoreRender;
        
    
        
        [[MysticController controller] ignoreOption:option];
        
        
        changedSwitchValue = !swv ? YES : option.ignoreActualRender != originalSwitchValue;
        
        if(changedSwitch && changedSwitchValue)
        {
            if(indexPath) [self.switchedOptions setObject:@(originalSwitchValue) forKey:indexPath];
        }
        else if(indexPath)
        {
            [self.switchedOptions removeObjectForKey:indexPath];
        }
    }
    
    
    if(!mySwitch.hidden)
    {
        if(!shouldToggleAfter)
        {
            
            self.shouldRerenderOnClose = self.switchedOptions.count ? YES : NO;;
            self.lastOptionSwitched = option;
            
        }
    }
    
  
    
    UIColor *fc = option.canReplaceColor && [option hasUserSelectedColorOfOptionType:MysticOptionColorTypeForeground] ? [option foregroundColor] : nil;

    
    UIColor *imvbgc = fc ? fc : [[UIColor hex:@"332f2c"] colorWithAlphaComponent:0];
    UIColor *newImvBorderColor = !isOn ? [[UIColor hex:@"332f2c"] colorWithAlphaComponent:imvbgc.alpha] : imvbgc;// ;
    

  
    
    MysticAnimation *anim = [MysticAnimation animationWithDuration:0.2];
    anim.animationOptions = UIViewAnimationCurveEaseInOut;

    
    
    [anim addKeyFrame:isOn ? 0.4 : 0 duration:0.3 animations:^{
        
        cell.imageViewBackground.backgroundColor = isOn ? [cell.imageViewBackground.backgroundColor colorWithAlphaComponent:0] : [cell.imageViewBackground.backgroundColor colorWithAlphaComponent:0.65];
        
        if(newImvBorderColor)
        {
        
            [cell setImageViewBorderColor:newImvBorderColor];
            
        }
        cell.imageView.alpha = isOn ? 1 : 0.5;

    }];
    if(!mySwitch.hidden && (mySwitch.alpha != isOn ? 0 : 1) && ((isOn && !shouldToggleAfter) || (!isOn && shouldToggleAfter)))
    {
        [anim addKeyFrame:isOn ? 0.1 : 0 duration:0.2 animations:^{
            mySwitch.alpha = isOn ? 0 : 1;

        }];
    }
    anim.animated = shouldFinish;
    anim.duration = shouldToggleAfter ? anim.duration + 0.3 : anim.duration;
    [anim animate:!shouldToggleAfter || mySwitch.hidden ? ^(BOOL finished, MysticAnimationBlockObject *obj) {
   
    } : ^(BOOL finished, MysticAnimationBlockObject *obj) {
      
        if(_ignoreToggles || !finished) return;
        mySwitch.enabled = NO;
        mySwitch.on = !mySwitch.on;
        mySwitch.enabled = YES;

    }];
    
//
}
- (void) drawerOpened;
{
    [super drawerOpened];
    self.shouldRerenderOnClose = NO;
    self.lastOptionSwitched = nil;

}
- (void) drawerClosed;
{
    [super drawerClosed];
    self.switchedOptions = [NSMutableDictionary dictionary];
    self.lastOptionSwitched = nil;
    self.shouldRerenderOnClose = NO;

}

- (NSArray *) currentLayerRows;
{
    
    
    __unsafe_unretained __block  MysticLayersViewController *weakSelf = self;
    
    PackPotionOption *option;
    //    UIColor *imgBgColor = [UIColor color:MysticColorTypeControlInactive];
    UIColor *titleColor = [UIColor color:MysticColorTypeDrawerText];
    UIColor *iconColor = [UIColor color:MysticColorTypeDrawerIcon];
    //    UIColor *indicatorColor = [UIColor color:MysticColorTypeDrawerAccessory];
    NSMutableArray *layerRows = [NSMutableArray array];
    NSValue *iconSize = [NSValue valueWithCGSize:[MysticLayerTableViewCell imageViewSize]];
    UIImage *accessBgImg = [UIImage imageNamed:@"layer_num_bg.png"];
    int i = 0;
    MysticOptions *ropts = [MysticOptions reversedOptions];
    for (option in ropts)
    {
        
        if(!option.showInLayers)
        {
            DLog(@"DRAWER: Wont show option in layers: %@", option.debugDescription);
            continue;
        }
        UIImage *theIcon = nil;
        id acc = @(MysticIconTypeAccessoryDrag);
        
        switch (option.type) {
            case MysticObjectTypeSetting:
                theIcon = (id)@(MysticIconTypeTune);
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
            case MysticObjectTypeFilter:
            {
                cMode = UIViewContentModeScaleAspectFill;
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
        
        NSString *idnt = @"normal";
        if(option.canReplaceColor)
        {
            idnt = @"normal-color";
        }
        
        NSDictionary *rowData = @{@"subtitle": option.layerSubtitle,
                                  @"title": option.layerTitle,
                                  @"image": MNull(theIcon),
                                  @"imageContentMode": theIcon ? @(cMode) : @(UIViewContentModeScaleAspectFit),
                                  @"imageSize": iconSize,
                                  @"option": option,
                                  @"titleColor": titleColor,
                                  @"switchOn": option.ignoreActualRender ? @NO : @YES,
                                  @"ignoreRender": @(option.ignoreActualRender),
                                  @"accessory": option.canReorder ? acc : [NSNull null],
                                  @"accessoryHighlighted": @(MysticIconTypeAccessoryDrag),
                                  @"accessorySize": [NSValue valueWithCGSize:(CGSize){13, 6}],

                                  @"closeDrawerFirst": @YES,
                                  @"moveable": @(option.canReorder),
                                  @"state": @(option.editState),
                                  @"userInfo": @{@"object": option},
                                  @"type": @(MysticObjectTypeLayer),
                                  @"imageBorder": @NO,
                                  @"identifier": idnt,
                                  };
        

        switch (option.type)
        {
                
                
                
            case MysticObjectTypeSetting:
            {
                NSMutableDictionary *_rowData = [NSMutableDictionary dictionaryWithDictionary:rowData];
                [_rowData setObject:@(MysticColorTypeDrawerIconBackground) forKey:@"imageBackground"];
                [_rowData setObject:[NSValue valueWithCGSize:CGSizeMake(24, 24)] forKey:@"imageSize"];
                [_rowData setObject:@(UIViewContentModeCenter) forKey:@"imageContentMode"];
                [_rowData setObject:iconColor forKey:@"color"];
                switch (option.type)
                {
                    case MysticObjectTypeFilter:
                    {
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
                           
                           @"size": iconSize,
                           @"titleColor": titleColor,
                           @"switchOn": @YES,
                           @"switchEnabled": @NO,
                           @"accessory": @(MysticIconTypeToolLayerSettings),
                           @"accessoryHighlighted": @(MysticIconTypeToolLayerSettings),
                           @"accessorySize": [NSValue valueWithCGSize:(CGSize){13, 10}],
                           @"state": @(MysticSettingSettings),
                           @"moveable": @NO,
                           @"visible": @YES,
                           @"closeDrawerFirst": @YES,
                           @"type": @(MysticObjectTypeImage),
                           @"identifier": @"bgphoto",

                           }];
    return layerRows;
}
- (void) reload;
{
    [self updateNavBar];
    self.sections = @[
                      @{
                         
                          @"rows": [self currentLayerRows],
                          },
                      
                      ];
    
   
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
    NSArray *n= [[MysticOptions current] optionsOrderedByLevel];

    [[MysticController controller] reloadImageInBackground:NO settings:MysticRenderOptionsForceProcess];
    
    self.shouldRerenderOnClose = NO;

    [[MysticOptions current] saveProject];

}
- (void) reorderSection:(NSInteger)section rows:(NSArray *)newRows;
{
    self.shouldRerenderOnClose = YES;
    self.sections = @[
                      @{
                      
                          @"rows": newRows,
                          },
                      
                      ];
    
  
    
}


- (void) setShouldRerenderOnClose:(BOOL)shouldRerenderOnClose;
{
  
    [super setShouldRerenderOnClose:shouldRerenderOnClose];
    
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
    self.shouldRerenderOnClose = NO;
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
    return [self tableView:tableView didSelectRowAtIndexPath:indexPath];

}

- (void) actionSheet:(UIActionSheet *)_actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    __unsafe_unretained __block MysticLayersViewController *weakSelf = self;
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
    __unsafe_unretained __block MysticLayersViewController *weakSelf = self;
    
    [[MysticController controller] pick:MysticPickerSourceTypeCamera finished:^{
        [weakSelf.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:NO completion:^(BOOL finished) {
            
        }];
    }];
}

- (void) takePhotoAndReload;
{
    __unsafe_unretained __block MysticLayersViewController *weakSelf = self;
    
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
    __unsafe_unretained __block MysticLayersViewController *weakSelf = self;
    
    [[MysticController controller] pick:MysticPickerSourceTypePhotoLibrary finished:^{
        [weakSelf.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:NO completion:^(BOOL finished) {
            
        }];
    }];
}
- (void) choosePhotoAndReload;
{
    __unsafe_unretained __block MysticLayersViewController *weakSelf = self;
    
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
- (void) adjustOptionAndGoBack:(PackPotionOption *)option;
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}
- (void) removeOptionAndGoBack:(PackPotionOption *)option;
{
    
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
    [self.navigationController popViewControllerAnimated:YES];
    //    [MysticController setNeedsDisplay];
}




- (void) scrollViewDidScroll:(UIScrollView *)scrollView;
{
    
    
}



@end
