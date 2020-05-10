//
//  MysticTabBar.m
//  Mystic
//
//  Created by Travis on 10/9/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticTabBar.h"
#import "MysticController.h"
#import "UserPotion.h"
#import "MysticLabelsView.h"
#import "MysticLayersView.h"

@implementation MysticTabBar

@synthesize tabBarDelegate, options, tabs, selectedButton, tabStyle=_tabStyle, insets=_insets, tabLayoutStyle=_tabLayoutStyle, buttonPadding=_buttonPadding, preventsScrollOnHide=_preventsScrollOnHide, numberOfVisibleTabs=_numberOfVisibleTabs;

- (void) dealloc;
{
    self.tabBarDelegate = nil;
}
- (Class) tabButtonClass;
{
    return [MysticTabButton class];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setDefaults];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layoutRect = CGRectSize(frame.size);

        [self setDefaults];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame options:(NSArray *)theoptions;
{
    return [self initWithFrame:frame options:theoptions layout:MysticLayoutStyleDefault rect:CGRectSize(frame.size)];
}
- (id) initWithFrame:(CGRect)frame options:(NSArray *)theoptions layout:(MysticLayoutStyle)layoutType;
{
    return [self initWithFrame:frame options:theoptions layout:layoutType rect:CGRectSize(frame.size)];

}
- (id) initWithFrame:(CGRect)frame options:(NSArray *)theoptions layout:(MysticLayoutStyle)layoutType rect:(CGRect)layoutRect;
{
    self = [self initWithFrame:frame];
    if(self)
    {
        self.layoutRect = layoutRect;
        self.tabLayoutStyle = layoutType;
        self.options = theoptions;
        self.layoutOrigin = (CGPoint){MAX(self.layoutOrigin.x, layoutRect.origin.x), self.layoutOrigin.y};
    }
    return self;
}

- (void) setDefaults;
{
    _autoSelection = YES;
    _unSelectAllOnDisplay = NO;
    _lookForActiveOptions = YES;
    _preventsScrollOnHide = YES;
    _numberOfVisibleTabs = NAN;
    _showActiveTypes = YES;
    _scrollToItemBeforeEvent = NO;
    _revealStyle = MysticScrollViewRevealStyleDefault;
    self.tabLayoutStyle = MysticLayoutStyleDefault;
    self.insets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.buttonPadding = UIEdgeInsetsMake(0, 10, 0, 10);
    self.layoutOrigin = CGPointMake(self.insets.left, self.insets.top);
    self.tabStyle = MysticTabStyleDefault;
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.directionalLockEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    
    self.opaque = NO;
    self.clipsToBounds = NO;
//    self.debug = YES;

    [self loadView];
}

- (void) loadView;
{

}

- (CGFloat) numberOfVisibleTabs;
{
    return [self numberOfVisibleTabs:NO];
}
- (CGFloat) numberOfVisibleTabs:(BOOL)defaultNum;
{
    CGFloat _n = _numberOfVisibleTabs;
    if(defaultNum || isnan(_numberOfVisibleTabs) || !_numberOfVisibleTabs)
    {
        _n = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? MYSTIC_UI_SUB_BTN_COUNT_IPHONE : MYSTIC_UI_SUB_BTN_COUNT_IPAD;
        if(!defaultNum && isnan(_numberOfVisibleTabs))
        {
            _numberOfVisibleTabs = _n;
        }
    }
    
    return _n;
}

- (BOOL) showTitles;
{
    return MYSTIC_UI_TABBAR_SHOW_TITLES > 0 ? YES : NO;
}
- (UIEdgeInsets) buttonImageInsets;
{
    return UIEdgeInsetsZero;
    return UIEdgeInsetsMake(MYSTIC_UI_SUB_BTN_ICON_OFFSET_TOP, MYSTIC_UI_SUB_BTN_ICON_OFFSET_LEFT, MYSTIC_UI_SUB_BTN_ICON_OFFSET_BOTTOM, MYSTIC_UI_SUB_BTN_ICON_OFFSET_RIGHT);
}
- (void) setOptions:(NSArray *)theoptions;
{
    @autoreleasepool
    {
        _numberOfVisibleTabs = NAN;
        [self removeAllSubviews];
        
        BOOL addedFirst = NO;
        MysticTabButton *subButton;
        MysticObjectType buttonType;
        MysticButtonType buttonTag = kMysticTag;
        MysticObjectType nextSetting;
        MysticColorType iconColorType = MysticColorTypeTabIconInactive;
        MysticColorType iconColorTypeSelected = MysticColorTypeControlIconSelected;
        MysticColorType iconColorTypeHighlighted = MysticColorTypeControlIconHighlighted;
        MysticColorType iconColorTypeDisabled = MysticColorTypeUndefined;


        UIImage *subiconImg = nil;
        UIImage *subiconHighlighted = nil;
        UIImage *subiconDisabled = nil;

        UIImage *subiconImgSelected = nil;
        CGFloat contentWidth = 0;
        CGFloat controlWidth = 0;
        UIEdgeInsets buttonInsets;
        self.numberOfVisibleTabs = theoptions.count < self.numberOfVisibleTabs ? theoptions.count : self.numberOfVisibleTabs;
        CGFloat x = self.insets.left;
        CGFloat startX = self.layoutOrigin.x;
        CGFloat paddingX = self.insets.right;

        self.margin = paddingX;
        CGRect tabBarFrame = self.frame;
        tabBarFrame.size.width = (CGRectGetWidth(self.layoutRect) - self.insets.left*2);
        CGRect controlFrame;
        CGFloat w = ((CGRectGetWidth(self.layoutRect) - self.insets.left*2) - (paddingX*(self.numberOfVisibleTabs-1)))/self.numberOfVisibleTabs;
        controlFrame = CGRectMake(x, self.insets.top, w, CGRectGetHeight(self.layoutRect) - self.insets.top - self.insets.bottom);
        controlFrame.origin.x = startX;
        controlFrame.size.width = w;
        controlFrame = CGRectIntegral(controlFrame);
        
        self.tileSize = controlFrame.size;
        controlWidth = controlFrame.size.width;
        
        CGRect fixedControlFrame = controlFrame;
        int i = 0;
        BOOL hideButtonTitle = NO;
        for (NSDictionary *option in theoptions) {
            i++;
            NSString *selectedTitle = nil;
            iconColorType = MysticColorTypeTabIconInactive;
            iconColorTypeSelected = MysticColorTypeControlIconSelected;
            iconColorTypeHighlighted = MysticColorTypeControlIconHighlighted;
            iconColorTypeDisabled = MysticColorTypeUndefined;

            subiconHighlighted = subiconImgSelected = subiconImg = subiconDisabled = nil;
            hideButtonTitle = NO;
            controlFrame.size = fixedControlFrame.size;
            buttonInsets = self.buttonImageInsets;
            if(option[@"imageInsets"]) buttonInsets = UIEdgeInsetsFromString(option[@"imageInsets"]);
            
            buttonType = [[option objectForKey:@"type"] integerValue];
            CGFloat uniqueControlWidth = option[@"width"] ? [[option objectForKey:@"width"] floatValue] : MYSTIC_FLOAT_UNKNOWN;
            CGFloat uniquePaddingX = option[@"margin"] ? [option[@"margin"] floatValue] : paddingX;
            
            MysticObjectType objectType = buttonType < MysticObjectTypeLastOfObjects ? MysticTypeForSetting(buttonType, nil) : buttonType;
            
            
            MysticIconType iconType = [option objectForKey:@"iconType"] ? [[option objectForKey:@"iconType"] integerValue] : ([option objectForKey:@"icon"] ? [[option objectForKey:@"icon"] integerValue] : [MysticIcon iconTypeForObjectType:objectType]);
            
            MysticIconType selectedIconType = [option objectForKey:@"iconSelected"] ? [[option objectForKey:@"iconSelected"] integerValue] : iconType;

            
            
            CGSize iconSize = option[@"iconSize"] ? [option[@"iconSize"] CGSizeValue] : CGRectInset(controlFrame, 5, 5).size;
            NSString *iconName = option[@"iconName"] ? option[@"iconName"] : [MysticIcon name:iconType];
            NSString *iconNameSelected = option[@"states"] ? nil : option[@"iconNameSelected"] ? option[@"iconNameSelected"] : [MysticIcon name:selectedIconType state:UIControlStateSelected];
            NSString *iconNameHighlighted = option[@"states"] ? nil : option[@"iconNameHighlighted"] ? option[@"iconNameHighlighted"] : [MysticIcon name:iconType state:UIControlStateHighlighted];
            NSString *iconNameDisabled = option[@"states"] ? nil : option[@"iconNameDisabled"] ? option[@"iconNameDisabled"] : [MysticIcon name:iconType state:UIControlStateDisabled];
            selectedTitle = option[@"selectedTitle"] ? option[@"selectedTitle"] : nil;
            
            if([iconName hasSuffix:@"-color"] )
            {
                iconColorType = MysticColorTypeUnknown;
                iconColorTypeSelected = MysticColorTypeUnknown;
            }
            if(iconNameSelected && [iconNameSelected hasSuffix:@"-color"] ) iconColorTypeSelected = MysticColorTypeUnknown;
            if(iconNameHighlighted && [iconNameHighlighted hasSuffix:@"-color"] ) iconColorTypeHighlighted = MysticColorTypeUnknown;
            
            iconColorType = [option objectForKey:@"color"] ? [[option objectForKey:@"color"] integerValue] : iconColorType;
            iconColorTypeSelected = [option objectForKey:@"colorSelected"] ? [[option objectForKey:@"colorSelected"] integerValue] : iconColorTypeSelected;
            iconColorTypeHighlighted = [option objectForKey:@"colorHighlighted"] ? [[option objectForKey:@"colorHighlighted"] integerValue] : iconColorTypeHighlighted;
            iconColorTypeDisabled = [option objectForKey:@"colorDisabled"] ? [[option objectForKey:@"colorDisabled"] integerValue] : iconColorTypeDisabled;


            
//            UIImage *subImg = [UIImage imageNamed:iconName];
            subiconImg = subiconImg ? subiconImg : [MysticImageIcon image:iconName size:CGSizeMakeUnknownWidth(CGSizeSquareSmall(iconSize)) color:@(iconColorType)];
            BOOL isSubIconSelected = subiconImgSelected || (iconNameSelected && [UIImage imageNamed:iconNameSelected] != nil) ? YES : NO;
            
            
            if(isSubIconSelected) subiconImgSelected = subiconImgSelected ? subiconImgSelected : [MysticImageIcon image:iconNameSelected size:CGSizeMakeUnknownWidth(CGSizeSquareSmall(iconSize)) color:@(iconColorTypeSelected)];
            else if(option[@"states"] == nil) subiconImgSelected = [MysticImageIcon image:iconName size:CGSizeMakeUnknownWidth(CGSizeSquareSmall(iconSize)) color:@(MysticColorTypeControlIconSelected)];
         
            
            BOOL isSubIconHighlighted = subiconHighlighted || (iconNameHighlighted && [UIImage imageNamed:iconNameHighlighted] != nil) ? YES : NO;
            if(isSubIconHighlighted) subiconHighlighted = subiconHighlighted ? subiconHighlighted : [MysticImageIcon image:iconNameHighlighted size:CGSizeMakeUnknownWidth(CGSizeSquareSmall(iconSize)) color:@(iconColorTypeHighlighted)];
            else if(option[@"states"] == nil) subiconHighlighted = [MysticImageIcon image:iconName size:CGSizeMakeUnknownWidth(CGSizeSquareSmall(iconSize)) color:@(MysticColorTypeControlIconHighlighted)];
            
            if(iconColorTypeDisabled != MysticColorTypeUndefined)
            {
                BOOL isSubIconDisabled = subiconDisabled || [UIImage imageNamed:iconNameDisabled] != nil ? YES : NO;
                subiconDisabled = subiconDisabled ? subiconDisabled : [MysticImageIcon image:isSubIconDisabled ? iconNameDisabled : iconName size:CGSizeMakeUnknownWidth(CGSizeSquareSmall(iconSize)) color:@(iconColorTypeDisabled)];
            }

            if(subiconImg && self.tabLayoutStyle == MysticLayoutStyleFlexible) controlFrame.size.width = subiconImg.size.width + self.buttonPadding.left + self.buttonPadding.right;
            
            if(self.showTitles)
            {
                if(self.tabLayoutStyle == MysticLayoutStyleFlexible)
                {
                    NSString *btnTitle = MysticObjectTypeTitleParent(objectType, NULL);
                    CGSize titleSize = [btnTitle sizeWithFont:[(id)[self tabButtonClass] labelFont]];
                    CGSize imgSize = subiconImg.size;
                    
                    if(option[@"iconSize"]) imgSize = [option[@"iconSize"] CGSizeValue];
                    else
                    {
                        CGFloat maxImageHeight = [(SubBarButton *)[self tabButtonClass] maxImageHeight];
                        if(maxImageHeight != MYSTIC_FLOAT_UNKNOWN)
                        {
                            imgSize.height = maxImageHeight;
                            imgSize.width = ceilf((subiconImg.size.width*maxImageHeight)/subiconImg.size.height);
                        }
                    }
                    
                    UIEdgeInsets bci = [(SubBarButton *)[self tabButtonClass] contentInsets];
                    controlFrame.size.width = MAX(imgSize.width+ self.buttonPadding.left + self.buttonPadding.right, titleSize.width + self.buttonPadding.left + self.buttonPadding.right + ((bci.left + bci.right)*1.1));
                }
            }
            
            
            if(self.tabLayoutStyle != MysticLayoutStyleFixed)
            {
                UIEdgeInsets btnInsets = [(MysticTabButton *)[self tabButtonClass] contentInsets];
                controlFrame.size.width += btnInsets.left + btnInsets.right;
            }
            
            if(uniqueControlWidth != MYSTIC_FLOAT_UNKNOWN) controlFrame.size.width = uniqueControlWidth;
            controlFrame = CGRectNoNaN(controlFrame);
            
            subButton = [[self tabButtonClass] buttonWithType:UIButtonTypeCustom frame:controlFrame showTitle:self.showTitles];
            subButton.iconColorType = iconColorType;
            if(option[@"iconSize"])
            {
                subButton.maxImageHeight = [option[@"iconSize"] CGSizeValue].height;
                [subButton setNeedsLayout];
            }
            
            subButton.userInfo = option;
            subButton.selectedColorType = iconColorTypeSelected;
            subButton.tabIndex = i -1;
            subButton.isFirst = addedFirst ? NO : YES;
            if(i == theoptions.count) subButton.isLast = YES;
            subButton.tag = [self tagForType:buttonType];
            subButton.type = buttonType;
            [subButton addTarget:self action:@selector(tabBarButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            
            UIViewContentMode contentMode = option[@"iconSize"] ? UIViewContentModeCenter : subButton.imageView.contentMode;
            contentMode = option[@"mode"] ? [option[@"mode"] integerValue] : contentMode;
            subButton.imageView.contentMode = contentMode;

            if(self.showTitles && !hideButtonTitle)
            {
                [subButton setTitle:[MysticObjectTypeTitleParent(objectType, NULL) uppercaseString] forState:UIControlStateNormal];
                if(selectedTitle && selectedTitle.length > 0) [subButton setTitle:selectedTitle forState:UIControlStateSelected];
                if(iconColorTypeDisabled != MysticColorTypeUndefined) [subButton setTitleColor:[UIColor color:iconColorTypeDisabled] forState:UIControlStateDisabled];
            }
            if(option[@"selected"]) subButton.selected = [option[@"selected"] boolValue];
            if(option[@"canUnselect"]) subButton.canUnselect = [option[@"canUnselect"] boolValue];
            if(option[@"toggleSelected"]) subButton.toggleSelected = [option[@"toggleSelected"] boolValue];
            
            if(subiconImg && !option[@"states"]) [subButton setImage:subiconImg forState:UIControlStateNormal];
            if(subiconDisabled && !option[@"states"]) [subButton setImage:subiconDisabled forState:UIControlStateDisabled];
            if(subButton.allowSelect && subiconImgSelected && !option[@"states"]) [subButton setImage:subiconImgSelected forState:UIControlStateSelected];
            if(option[@"states"])
            {
                subButton.controlStateNormal = [[option[@"states"] firstObject] intValue];
                subButton.controlStates = option[@"states"];
                for (NSNumber *state in option[@"states"]) {
                    UIImage *img = [MysticImageIcon image:[MysticIcon name:[MysticIcon iconTypeForObjectType:[state intValue]]] size:CGSizeMakeUnknownWidth(CGSizeSquareSmall(iconSize)) color:@(iconColorType)];
                    if(img) [subButton setImage:img forState:(UIControlState)([state intValue]+1000)];
                }
                subButton.controlState = UIControlStateNormal;
            }
            subButton.imageEdgeInsets = buttonInsets;
            subButton.debug = self.debug;
            [self addSubview:[self customizeTab:subButton info:option]];
            controlFrame.origin.x += controlFrame.size.width + uniquePaddingX;
            addedFirst = YES;
        }
        
        [self setContentSize:CGSizeMake(controlFrame.origin.x, CGRectGetHeight(self.frame))];
        
        
        
        
        for (UIView *subbtn in self.subviews) {
            if([subbtn isKindOfClass:[self tabButtonClass]]) contentWidth = MAX(contentWidth, (subbtn.frame.origin.x + subbtn.frame.size.width + paddingX) - startX);
        }
        
        contentWidth -= paddingX;
        
        
        
        
        if(contentWidth <= CGRectGetWidth(self.frame))
        {
            
            x = ((CGRectGetWidth(self.frame) - contentWidth)/2);
            for (UIView *subbtn in self.subviews) {
                
                if([subbtn isKindOfClass:[self tabButtonClass]])
                {
                    controlFrame = subbtn.frame;
                    controlFrame.origin.x = x;
                    subbtn.frame = controlFrame;
                    x += controlFrame.size.width + paddingX;
                }
            }
            int x = 0;
        }
    }
    if(self.debug) [self setDebug:YES];
}
- (id) customizeTab:(MysticTabButton *)tab info:(NSDictionary *)info;
{
    return tab;
}
- (void) setDebug:(BOOL)debug;
{
//    if(debug)
//    {
//        MBorder(self, [[UIColor hex:@"cccccc"] colorWithAlphaComponent:0.5], 1);
//    }
//    else if(_debug)
//    {
//        self.layer.borderWidth = 0;
//        self.layer.borderColor = nil;
//    }
    _debug = debug;
    for (MysticTabButton *subBarButton in self.subviews) {
        if([subBarButton isKindOfClass:[MysticTabButton class]])
        {
            subBarButton.debug = _debug;
        }
    }
    

}
- (void) removeAllSubviews;
{
    for (MysticTabButton *subBarButton in self.subviews) {
        if([subBarButton isKindOfClass:[MysticTabButton class]])
        {
            [subBarButton clear];
            [subBarButton removeFromSuperview];
        }
    }
    
}

- (MysticButtonType) tagForType:(MysticObjectType)buttonType;
{
    MysticButtonType buttonTag = MysticButtonTypeUnknown;
    MysticObjectType objectType = buttonType < MysticObjectTypeLastOfObjects ? MysticTypeForSetting(buttonType, nil) : buttonType;


    switch (objectType) {
        case MysticSettingAddLayer:
        {
            buttonTag = MysticButtonTypeAddLayer;
            break;
        }
        case MysticObjectTypePotion:
        {
            buttonTag = MysticButtonTypePotions;
            break;
        }
        case MysticSettingLayers:
        {
            buttonTag = MysticButtonTypeManageLayers;
            break;
        }
  
        case MysticObjectTypeDesign:
        case MysticObjectTypeText:
        {
            buttonTag = MysticButtonTypeText;
            break;
        }
        case MysticObjectTypeSetting:
        {
            buttonTag = MysticButtonTypeSettings;
            break;
        }
        case MysticObjectTypeFont:
        {
            buttonTag = MysticButtonTypeText;
            break;
        }
        case MysticObjectTypeFilter:
        {
            buttonTag = MysticButtonTypeFilter;
            break;
        }
        case MysticObjectTypeFrame:
        {
            buttonTag = MysticButtonTypeFrame;
            break;
        }
        case MysticObjectTypeTexture:
        {
            buttonTag = MysticButtonTypeTexture;
            break;
        }
        case MysticSettingMixtures:
        {
            buttonTag = MysticButtonTypeMixtures;
            break;
        }
        case MysticObjectTypeLight:
        {
            buttonTag = MysticButtonTypeLight;
            break;
        }
        case MysticObjectTypeBadge:
        {
            buttonTag = MysticButtonTypeBadge;
            break;
        }
        case MysticObjectTypeShape:
        {
            buttonTag = MysticButtonTypeShape;
            break;
        }
        default: break;
    }
    return buttonTag;
}

- (void) tabBarButtonTouched:(MysticTabButton *)button;
{
    [self tabBarButtonTouched:button animated:YES];
}
- (void) tabBarButtonTouched:(MysticTabButton *)button animated:(BOOL)animated;
{
    MysticObjectType buttonType = button.type;
    MysticObjectType objectType = button.objectType;
    NSDictionary *userInfo = nil;
    
    if(self.autoSelection) button.selected = button.toggleSelected ? !button.selected : YES;
    if(userInfo == nil)
    {
        PackPotionOption * lastOption = [[MysticOptions current] selectableOption:buttonType];
        if(lastOption && lastOption.type == buttonType) userInfo = @{@"object": lastOption};
    }
    __unsafe_unretained __block MysticTabBar *weakSelf = self;
    MysticBlockObject f = ^(id obj)
    {
        if(weakSelf.tabBarDelegate)
        {
            if(weakSelf.tabSelectedAction && [weakSelf.tabBarDelegate respondsToSelector:weakSelf.tabSelectedAction])
            {
                [weakSelf.tabBarDelegate performSelector:weakSelf.tabSelectedAction withObject:weakSelf withObject:button];
            }
            else if([weakSelf.tabBarDelegate respondsToSelector:@selector(mysticTabBar:didSelectItem:info:)])
            {
                [weakSelf.tabBarDelegate mysticTabBar:weakSelf didSelectItem:button info:userInfo];
            }
            else if([weakSelf.tabBarDelegate isKindOfClass:[MysticController class]])
            {
                [(MysticController *)weakSelf.tabBarDelegate setStateConfirmed:MysticSettingForObjectType(objectType) animated:YES info:userInfo complete:nil];
            }
        }
    };

    
    if(!self.preventsScrollOnHide || ([self itemNeedsReveal:button] && !self.preventsScrollOnHide))
    {
        
        switch (self.revealStyle) {
            case MysticScrollViewRevealStyleCenter:
            {
                if(self.scrollToItemBeforeEvent)
                {
                    __unsafe_unretained __block MysticBlockObject _f = f ? f : nil;
                    [self centerOnView:button animate:animated complete:^{
                        if(_f) _f(nil);
                    }];
                }
                else
                {
                    [self centerOnView:button animate:animated complete:nil];
                    f(nil);
                }
                break;
            }
                
            default:
            {
                if(self.scrollToItemBeforeEvent)
                    [self revealItem:button animated:animated complete:f];
                else
                {
                    [self revealItem:button animated:animated complete:nil];
                    f(nil);
                }
                break;
            }
        }
    
    }
    else f(nil);
}
- (BOOL) containsButtonOfType:(MysticObjectType)type;
{
    for (MysticTabButton *tab in self.tabs) {
        if(MysticTypeEqualsType(tab.type, type)) return YES;
    }
    return NO;
}
- (MysticTabButton *) tabForType:(MysticObjectType)type;
{
    for (MysticTabButton *tab in self.tabs) {
        if(MysticTypeEqualsType(tab.type, type)) return tab;
    }
    return nil;
}
- (NSArray *) tabs;
{
    NSMutableArray *__tabs = [NSMutableArray array];
    
    for (UIView *subview in self.subviews) {
        if([subview.class isSubclassOfClass:[SubBarButton class]] || [subview isKindOfClass:[self tabButtonClass]])
        {
            [__tabs addObject:subview];
        }
    }
    return __tabs;
}
- (BOOL) isTabOfTypeSelected:(MysticObjectType)type;
{
    for (MysticTabButton *tab in self.tabs) {
        if(tab.type == type && tab.selected) return YES;
    }
    return NO;
}
- (void) updateDisplayForTab:(id)tab animated:(BOOL)animated;
{
    
}
- (void) setNeedsDisplay;
{
      [self setNeedsDisplay:YES ignore:NO];
        
}
- (void) setNeedsDisplay:(BOOL)animated;
{
    [self setNeedsDisplay:animated ignore:NO];
}
- (void) setNeedsDisplay:(BOOL)animated ignore:(BOOL)ignore;
{
    if(ignore)
    {
        [super setNeedsDisplay];
        return;
    }
    
    
    BOOL skipLookForCount = NO;
    for (MysticTabButton *btn in self.tabs) {
        BOOL activate = NO;

        switch (btn.type) {
            case MysticSettingMixtures:
            case MysticObjectTypeMixture:
                activate = [UserPotion confirmedOptionForType:MysticObjectTypeMixture] != nil;
                break;
            case MysticObjectTypeLight:
                activate = [UserPotion confirmedOptionForType:MysticObjectTypeLight] != nil;
                break;
            case MysticObjectTypeCamLayer:
                activate = [UserPotion confirmedOptionForType:MysticObjectTypeCamLayer] != nil;
                break;
            case MysticObjectTypeFrame:
                activate = [UserPotion confirmedOptionForType:MysticObjectTypeFrame] != nil;
                break;
            case MysticObjectTypeDesign:
            case MysticObjectTypeText:
                activate = [UserPotion confirmedOptionForType:MysticObjectTypeText] != nil;
                break;
            case MysticObjectTypeFont:
            {
                activate = [UserPotion confirmedOptionForType:MysticObjectTypeFont] != nil;
                if(!activate) activate = [MysticController controller].fontStylesController.hasLayers;

                break;
            }
            case MysticObjectTypeTexture:
                activate = [UserPotion confirmedOptionForType:MysticObjectTypeTexture] != nil;
                break;
            case MysticObjectTypeColorOverlay:
                activate = [UserPotion confirmedOptionForType:MysticObjectTypeColorOverlay] != nil;
                break;
            case MysticObjectTypeBadge:
                activate = [UserPotion confirmedOptionForType:MysticObjectTypeBadge] != nil;
                break;
            case MysticObjectTypeShape:
                activate = [UserPotion confirmedOptionForType:MysticObjectTypeShape] != nil;
                break;
            case MysticObjectTypeFilter:
                activate = [UserPotion confirmedOptionForType:MysticObjectTypeFilter] != nil;
                break;
            
            case MysticSettingSettings:
            case MysticObjectTypeSetting:
            {
//                activate = [[UserPotion potion] hasSettingsAppliedOrFilter:![self containsButtonOfType:MysticObjectTypeFilter]];
                
                PackPotionOption *setObj = [UserPotion confirmedOptionForType:MysticObjectTypeSetting];
                
                NSDictionary *adjustments = setObj ? setObj.adjustments : nil;
                activate = adjustments != nil && adjustments.allKeys.count > 1;
                if(adjustments)
                {
                    NSMutableDictionary *d = [NSMutableDictionary dictionary];
                    for (id key in adjustments.allKeys) {
                        if([key isEqualToString:@"keys"]) continue;
                        MysticObjectType theKeyType = [key integerValue];
                        id newKey = MysticString(theKeyType);
                        if(theKeyType == MysticObjectTypeUnknown)
                        {
                            newKey = [@"unknown-" stringByAppendingString:[NSString stringWithFormat:@"%@", key]];
                        }
                        [d setObject:[adjustments objectForKey:key] forKey:newKey];
                    }
                    adjustments = d;
                }
//                if(!activate && ![self containsButtonOfType:MysticObjectTypeFilter])
//                {
//                    activate = [UserPotion confirmedOptionForType:MysticObjectTypeFilter] != nil;
//                }
                break;
            }
            case MysticSettingRecipe:
                break;
            case MysticSettingLayers:
            {
                activate = [MysticOptions current].confirmedOptions.count > 0;
         
                break;
            }
            default:
                activate = NO;
                skipLookForCount = YES;
                break;
        }
        if(!skipLookForCount && !activate && self.lookForActiveOptions)
        {
            NSInteger numberOfOptions = 0;
            numberOfOptions = MAX([[MysticOptions current] numberOfOptions:btn.types forState:MysticOptionStateConfirmed], numberOfOptions);
            activate = numberOfOptions > 0;
        }
        
        
        if(self.unSelectAllOnDisplay)
        {
            if(self.autoSelection)  btn.selected = NO;
        }
        else if(btn.selected && (self.selectedIndex!=NSNotFound && self.selectedIndex!=btn.tabIndex))
        {
            if(self.autoSelection) btn.selected = NO;
        }
        if(self.showActiveTypes || btn.type > MysticObjectTypeLastOfObjects)
        {
            
            [btn setActive:activate animated:animated];
        }
        [btn setNeedsDisplay];
        [btn setNeedsLayout];

        
    }
    [self scrollViewDidScroll:self];
    [super setNeedsDisplay];
}


- (void) setButtonType:(MysticObjectType)type active:(BOOL)activated;
{
    for (MysticTabButton *btn in self.tabs) {
        if(btn.type == type)
        {
            btn.active = activated;
        }
    }
}
- (MysticTabButton *) selectedButton;
{
    for (MysticTabButton *subButton in self.tabs) {
        if(subButton.selected)
        {
            return subButton;
        }
    }
    return nil;
}

- (MysticTabButton *) tabAtIndex:(NSInteger)index;
{
    for (MysticTabButton *subButton in self.tabs) {
        if(subButton.tabIndex == index)
        {
            return subButton;
        }
    }
    return nil;
}

- (NSInteger) selectedIndex;
{
    for (MysticTabButton *subButton in self.tabs) {
        if(subButton.selected)
        {
            return subButton.tabIndex;
        }
    }
    return NSNotFound;
}
- (void) resetAll;
{
    
    for (MysticTabButton *s in self.tabs) {
        s.selected = NO;
    }
    [self scrollViewDidScroll:self];
}

- (void) deactivateAll;
{
    for (MysticTabButton *s in self.tabs) {
        s.active = NO;
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if(self.tabBarDelegate)
    {
        [self.tabBarDelegate tabBarDidScroll:self];
    }
}
- (void) setSelected:(MysticObjectType)selectType;
{
    [self setSelected:selectType selected:YES];
}
- (void) setSelected:(MysticObjectType)selectType selected:(BOOL)isSelected;
{
    int tag = [self tagForType:selectType];
    MysticTabButton *button = (MysticTabButton *)[self viewWithTag:tag];
    if(!button) return;
    button.selected = !button.toggleSelected ? isSelected : !button.selected;
    if(isSelected) [self itemTapped:button];
}

- (void) setSelectedIndex:(NSInteger)selectedIndex;
{
    [self setSelectedIndex:selectedIndex callEvent:YES];
}
- (void) setSelectedIndex:(NSInteger)selectedIndex callEvent:(BOOL)callEvent;
{
    [self setSelectedIndex:selectedIndex callEvent:callEvent animated:YES];
}
- (void) setSelectedIndex:(NSInteger)selectedIndex callEvent:(BOOL)callEvent animated:(BOOL)animated;
{

    if(selectedIndex == NSNotFound)
    {
        for (MysticTabButton *tab in self.tabs) {
            tab.selected = NO;
        }
        if(self.tabBarDelegate)
        {
            if(self.tabSelectedAction && [self.tabBarDelegate respondsToSelector:self.tabSelectedAction])
            {
                [self.tabBarDelegate performSelector:self.tabSelectedAction withObject:self withObject:nil];
            }
            else if([self.tabBarDelegate respondsToSelector:@selector(mysticTabBar:didSelectItem:info:)])
            {
                [self.tabBarDelegate mysticTabBar:self didSelectItem:nil info:nil];
            }
        }
        return;
    }
    for (MysticTabButton *tab in self.tabs) {
        if(tab.tabIndex == selectedIndex)
        {
            tab.selected = YES;
            if(callEvent)
            {
                
                [self tabBarButtonTouched:tab animated:animated];
            }
            else
            {
                [self revealTouchSpaceAround:tab];

            }
            return;
        }
    }
}

@end
