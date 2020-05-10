//
//  MysticBarButtonItem.m
//  Mystic
//
//  Created by Travis on 10/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticBarButtonItem.h"
#import "MysticBarButton.h"
#import "MysticToggleButton.h"
#import "MysticLayerToolbar.h"
#import "MysticFontTools.h"
#import "MysticBorderView.h"
#import "MysticToolbarTitleButton.h"

@implementation MysticBarButtonItem

@dynamic customView;

@synthesize delegate=_delegate,
action,
toolType=_toolType,
objectType=_objectType;


+ (MysticIconType) iconColor:(MysticIconType)iconType;
{
    return MysticColorTypeBarButtonIconInactive;
}
+ (MysticIconType) iconColorHighlighted:(MysticIconType)iconType;
{
    return MysticColorTypeUnknown;
}
+ (MysticIconType) iconColorSelected:(MysticIconType)iconType;
{
    return MysticColorTypeUnknown;
}
+ (MysticBarButtonItem *) item:(id)customView;
{
    return [[self class] buttonItem:customView];
}
+ (MysticBarButtonItem *) buttonItem:(id)customView;
{
    return !customView ? nil : [[[MysticBarButtonItem alloc] initWithCustomView:customView] autorelease];
}
+ (MysticBarButtonItem *) buttonItemWithIconType:(MysticIconType)iconType color:(id)color action:(MysticBlockSender) action;
{
    MysticBarButton *button = [MysticBarButton buttonWithIconType:iconType color:color action:action];
    return [[self class] buttonItem:button];
}
+ (MysticBarButtonItem *) itemForType:(id)toolTypeOrOptions target:(id)target;
{
    __unsafe_unretained __block  MysticLayerToolbar*_toolbar = target;
    MysticToolType toolType = MysticToolTypeUnknown;
    MysticBarButtonItem *item = nil;
    MysticBarButton *button = nil;
    MysticIconType iconType = MysticIconTypeUnknown;
    MysticObjectType objectType = MysticObjectTypeUnknown;
    UIColor *bgColor = nil;
    CGSize iconSize = CGSizeZero;
    CGSize itemSize = MysticSizeUnknown;
    id targetDelegate = target;
    SEL action = @selector(itemTapped:);
    SEL actionDown = @selector(itemTouchDown:);
    SEL delegateAction = action;
//    SEL actionDownRepeat = @selector(itemTouchDownRepeat:);
    MysticColorType iconColor = [[self class] iconColor:toolType];
    MysticColorType iconColorHighlighted = MysticColorTypeUnknown;
    MysticColorType iconColorSelected = MysticColorTypeUnknown;
    MysticColorType iconColorDisabled = MysticColorTypeUnknown;

    
    CGSize insetsSize;
    UIColor *iconUIColor = nil;
    CGFloat width = MYSTIC_FLOAT_UNKNOWN;
    CGFloat height = MYSTIC_FLOAT_UNKNOWN;
    UIEdgeInsets insets = UIEdgeInsetsZero;
    UIViewContentMode iconContentMode = UIViewContentModeCenter;
    NSInteger viewTag = NSNotFound;
    BOOL flex = YES;
    BOOL eventAdded = NO;
    BOOL enabled = YES;
    BOOL ignore = NO;
    BOOL selected = NO;
    BOOL canSelect = YES;
    BOOL continuous = NO;
    BOOL customIconColor = NO;
    BOOL debug = NO;
    BOOL customFlex = NO;
    BOOL hidden = NO;
    BOOL useDelegate = NO;
    BOOL usesCustomAction = NO;
    NSTimeInterval continuousTime = -1;
    NSInteger toggleState = NSNotFound;
    if([toolTypeOrOptions isKindOfClass:[NSNumber class]])
    {
        toolType = [toolTypeOrOptions integerValue];
    }
    else if([toolTypeOrOptions isKindOfClass:[UIView class]])
    {
        toolType = MysticToolTypeCustom;
        button = toolTypeOrOptions;
        width = button.frame.size.width;
    }
    else if([toolTypeOrOptions isKindOfClass:[NSDictionary class]])
    {
        iconType = [toolTypeOrOptions objectForKey:@"iconType"] ? [[toolTypeOrOptions objectForKey:@"iconType"] integerValue] : iconType;
        iconType = [toolTypeOrOptions objectForKey:@"icon"] ? [[toolTypeOrOptions objectForKey:@"icon"] integerValue] : iconType;
        iconColor = [toolTypeOrOptions objectForKey:@"color"] ? [[toolTypeOrOptions objectForKey:@"color"] integerValue] : iconColor;
        customIconColor = [toolTypeOrOptions objectForKey:@"color"] != nil;
        iconColorHighlighted = [toolTypeOrOptions objectForKey:@"colorHighlighted"] ? [[toolTypeOrOptions objectForKey:@"colorHighlighted"] integerValue] : iconColorHighlighted;
        iconColorDisabled = [toolTypeOrOptions objectForKey:@"colorDisabled"] ? [[toolTypeOrOptions objectForKey:@"colorDisabled"] integerValue] : iconColorDisabled;
        iconColorSelected = [toolTypeOrOptions objectForKey:@"colorSelected"] ? [[toolTypeOrOptions objectForKey:@"colorSelected"] integerValue] : iconColorSelected;
        iconContentMode = [toolTypeOrOptions objectForKey:@"iconContentMode"] ? [[toolTypeOrOptions objectForKey:@"iconContentMode"] integerValue] : iconContentMode;
        toolType = [toolTypeOrOptions objectForKey:@"toolType"] ? [[toolTypeOrOptions objectForKey:@"toolType"] integerValue] : toolType;
        toolType = [toolTypeOrOptions objectForKey:@"tool"] ? [[toolTypeOrOptions objectForKey:@"tool"] integerValue] : toolType;
        toolType = [toolTypeOrOptions objectForKey:@"type"] ? [[toolTypeOrOptions objectForKey:@"type"] integerValue] : toolType;
        itemSize = [toolTypeOrOptions objectForKey:@"size"] ? [[toolTypeOrOptions objectForKey:@"size"] CGSizeValue] : itemSize;
        iconSize = [toolTypeOrOptions objectForKey:@"iconSize"] ? [[toolTypeOrOptions objectForKey:@"iconSize"] CGSizeValue] : iconSize;
        
        insetsSize = [toolTypeOrOptions objectForKey:@"insets"] ? [[toolTypeOrOptions objectForKey:@"insets"] CGSizeValue] : CGSizeZero;
        insets = UIEdgeInsetsMake(insetsSize.height, insetsSize.width, insetsSize.height, insetsSize.width);
        viewTag = [toolTypeOrOptions objectForKey:@"tag"] ? [[toolTypeOrOptions objectForKey:@"tag"] integerValue] : viewTag;
        objectType = [toolTypeOrOptions objectForKey:@"objectType"] ? [[toolTypeOrOptions objectForKey:@"objectType"] integerValue] : objectType;
        toggleState = [toolTypeOrOptions objectForKey:@"toggleState"] ? [[toolTypeOrOptions objectForKey:@"toggleState"] integerValue] : toggleState;
        bgColor = [toolTypeOrOptions objectForKey:@"backgroundColor"] ? [MysticColor color:[toolTypeOrOptions objectForKey:@"backgroundColor"]] : nil;
        canSelect = [toolTypeOrOptions objectForKey:@"canSelect"] ? [[toolTypeOrOptions objectForKey:@"canSelect"] boolValue] : canSelect;
        enabled = [toolTypeOrOptions objectForKey:@"enabled"] ? [[toolTypeOrOptions objectForKey:@"enabled"] boolValue] : enabled;
        ignore = [toolTypeOrOptions objectForKey:@"ignore"] ? [[toolTypeOrOptions objectForKey:@"ignore"] boolValue] : ignore;
        debug = [toolTypeOrOptions objectForKey:@"debug"] ? [[toolTypeOrOptions objectForKey:@"debug"] boolValue] : ignore;
        hidden = [toolTypeOrOptions objectForKey:@"hidden"] ? [[toolTypeOrOptions objectForKey:@"hidden"] boolValue] : ignore;
        selected = [toolTypeOrOptions objectForKey:@"selected"] ? [[toolTypeOrOptions objectForKey:@"selected"] boolValue] : selected;
        eventAdded = [toolTypeOrOptions objectForKey:@"eventAdded"] ? [[toolTypeOrOptions objectForKey:@"eventAdded"] boolValue] : eventAdded;
        useDelegate = [toolTypeOrOptions objectForKey:@"useDelegate"] ? [[toolTypeOrOptions objectForKey:@"useDelegate"] boolValue] : useDelegate;
        flex = [toolTypeOrOptions objectForKey:@"flex"] ? [[toolTypeOrOptions objectForKey:@"flex"] boolValue] : flex;
        customFlex = [toolTypeOrOptions objectForKey:@"flex"] != nil;
        
        if([toolTypeOrOptions objectForKey:@"continueInterval"] && [[toolTypeOrOptions objectForKey:@"continueInterval"] isKindOfClass:[NSNumber class]])
        {
            continuousTime = [[toolTypeOrOptions objectForKey:@"continueInterval"] floatValue];
        }
        
        continuous = [toolTypeOrOptions objectForKey:@"continueOnHold"] ? [[toolTypeOrOptions objectForKey:@"continueOnHold"] boolValue] : continuous;


        button = [toolTypeOrOptions objectForKey:@"view"];
        if(button && ![toolTypeOrOptions objectForKey:@"canSelect"] && [button respondsToSelector:@selector(canSelect)])
        {
            canSelect = [(MysticBarButton *)button canSelect];
        }
        width = [toolTypeOrOptions objectForKey:@"width"] ? [[toolTypeOrOptions objectForKey:@"width"] floatValue] : (button ? button.frame.size.width : width);
        flex = [toolTypeOrOptions objectForKey:@"width"] == nil;
        height = [toolTypeOrOptions objectForKey:@"height"] ? [[toolTypeOrOptions objectForKey:@"height"] floatValue] : (button ? button.frame.size.height : height);

        if([toolTypeOrOptions objectForKey:@"target"])
        {
            target = [toolTypeOrOptions objectForKey:@"target"];
            
            target = isM(target) ? target : nil;
        }
        if([toolTypeOrOptions objectForKey:@"action"])
        {
            action = isMNull(toolTypeOrOptions[@"action"]) ? nil : NSSelectorFromString([toolTypeOrOptions objectForKey:@"action"]);
            if(action != nil)
            {
                usesCustomAction = YES;
            }
        }
        if([toolTypeOrOptions objectForKey:@"actionDown"])
        {
            actionDown = isMNull(toolTypeOrOptions[@"actionDown"]) ? nil : NSSelectorFromString([toolTypeOrOptions objectForKey:@"actionDown"]);
        }
        
        if(!target)
        {
            action = nil;
            actionDown = nil;
        }
        
        
    }
    if(CGSizeEqualToSize(MysticSizeUnknown, itemSize))
    {
        if([_toolbar isKindOfClass:[UIView class]])
        {
            itemSize = (CGSize){_toolbar.frame.size.height, _toolbar.frame.size.height};
        }
    }

    if(CGSizeEqualToSize(CGSizeZero, iconSize)) iconSize = itemSize;
    
    if(ignore) return nil;
    
    
    CGRect viewFrame = CGRectMake(0, 0, width == MYSTIC_FLOAT_UNKNOWN ? MYSTIC_UI_TOOLBAR_HEIGHT : width, height == MYSTIC_FLOAT_UNKNOWN ? MYSTIC_UI_TOOLBAR_HEIGHT : height);
    
    if([toolTypeOrOptions isKindOfClass:[NSDictionary class]] && [toolTypeOrOptions objectForKey:@"size"])
    {
        viewFrame.size = [[toolTypeOrOptions objectForKey:@"size"] CGSizeValue];
    }
    
    if(height != MYSTIC_FLOAT_UNKNOWN) viewFrame.size.height = height;
    if(width != MYSTIC_FLOAT_UNKNOWN) viewFrame.size.width = width;

    if(!button)
    {
        switch (toolType) {
            case MysticToolTypeStaticHeader:
            {
                width = -10;
                break;
            }
            case MysticToolTypeStaticFooter:
            {
                width = -17;
                break;
            }
            case MysticToolTypeTitle:
            {
                NSString *labelTitle = toolTypeOrOptions && [toolTypeOrOptions objectForKey:@"title"] ? [toolTypeOrOptions objectForKey:@"title"] : @"Title";
                
                MysticToolbarTitleButton *packLabel = (MysticToolbarTitleButton *)[MysticToolbarTitleButton button:labelTitle action:nil];
                packLabel.textColor = [UIColor color:MysticColorTypeMenuText];
                [packLabel setTitleColor:[UIColor color:MysticColorTypeMenuTextUnselected] forState:UIControlStateNormal];
                [packLabel setTitleColor:[UIColor color:MysticColorTypeMenuTextSelected] forState:UIControlStateSelected];
                [packLabel setTitleColor:[UIColor color:MysticColorTypeMenuTextHighlighted] forState:UIControlStateHighlighted];
                packLabel.useAttrText = NO;

                packLabel.ready = YES;
                packLabel.backgroundColor = [UIColor clearColor];
                packLabel.tag = MysticUITypeLabel;
                packLabel.font = [MysticUI font:12];
                packLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                packLabel.textAlignment = NSTextAlignmentCenter;
                packLabel.toolType = MysticToolTypeBrowsePacks;
                packLabel.objectType = objectType;
                packLabel.canSelect = canSelect;
                
                button = (id)packLabel;
                break;
            }
            case MysticToolTypeVariant:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeEffectNone;
                
                MysticToggleButton *_button = [[[MysticToggleButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)] autorelease];
                _button.iconStyle = MysticIconTypeImage;
                _button.iconColorType = MysticColorTypeBarButtonIconInactive;
                _button.minToggleState = MysticLayerEffectNone;
                canSelect = NO;
                [_button setImage:[MysticImage image:@(MysticIconTypeEffect0) color:@(iconColor)] forState:MysticLayerEffectNone];
                [_button setImage:[MysticImage image:@(MysticIconTypeEffect1) color:@(iconColor)] forState:MysticLayerEffectInverted];
                [_button setImage:[MysticImage image:@(MysticIconTypeEffect2) color:@(iconColor)] forState:MysticLayerEffectDesaturate];
                [_button setImage:[MysticImage image:@(MysticIconTypeEffect3) color:@(iconColor)] forState:MysticLayerEffectOne];
                [_button setImage:[MysticImage image:@(MysticIconTypeEffect4) color:@(iconColor)] forState:MysticLayerEffectTwo];
                [_button setImage:[MysticImage image:@(MysticIconTypeEffect5) color:@(iconColor)] forState:MysticLayerEffectThree];
                [_button setImage:[MysticImage image:@(MysticIconTypeEffect0) color:@(iconColor)] forState:MysticLayerEffectFour];
                _button.maxToggleState = MysticLayerEffectRandom;
                [_button setImage:[MysticImage image:@(MysticIconTypeEffect7) color:@(iconColor)] forState:MysticLayerEffectRandom];
                _button.otherState = MysticLayerEffectRandom;
                _button.toggleState = toggleState != NSNotFound ? toggleState : MysticLayerEffectNone;
                //            layerEffectBtn.toggleState = option ? option.layerEffect : layerEffectBtn.minToggleState;
                
                _button.onToggle = ^(MysticToggleButton *toggleSender)
                {
                    [_toolbar itemTapped:toggleSender];
                };
                
                [_button handleDoubleTapEvent:^(MysticToggleButton *toggleSender) {
                    toggleSender.toggleState = MysticLayerEffectRandom;
                    [_toolbar itemDoubleTapped:toggleSender];
                    
                }];
                _button.selectedColorType = MysticColorTypeBarButtonIconSelectedToggle;
                item = [MysticBarButtonItem buttonItem:_button];
                button = _button;
                eventAdded = YES;
                break;
            }
            case MysticToolTypeEditLayer:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeEditLayer;
                break;
            }
            case MysticToolTypeLogo:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeLogo;
                break;
            }
            case MysticToolTypeAdd:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeAdd;
                break;
            }
            case MysticToolTypeColorAndIntensity:
            case MysticToolTypeColor:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeColors;
    
                break;
            }
            case MysticToolTypeIntensity:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeIntensity;
                break;
            }
            case MysticToolTypeBlend:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeBlend;
                break;
            }
            case MysticToolTypeLayerHSB:
            case MysticToolTypeLayerSettings:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeSettings;
                break;
            }
            case MysticToolTypeSettings:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeSettings;
                break;
            }
            case MysticToolTypeBrowsePacks:
            case MysticToolTypeBrowse:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeBrowse;
                break;
            }
            case MysticToolTypeMoveAndSize:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeMoveAndSize;
                break;
            }
            case MysticToolTypeSize:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeSize;
                break;
            }
            case MysticToolTypeRotateAndFlip:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeRotate;
                break;
            }
            case MysticToolTypeMove:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeMove;
                break;
            }
            case MysticToolTypeMoveUp:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeMoveUp;
                break;
            }
            case MysticToolTypeMoveDown:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeMoveDown;
                break;
            }
            case MysticToolTypeGrid:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeGrid;
                break;
            }
            
            
            case MysticToolTypeReset:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeReset;
                break;
            }
            case MysticToolTypeFont:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeFont;
                break;
            }
            case MysticToolTypeFonts:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeFonts;
                break;
            }
            case MysticToolTypePanUp:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeToolUpCenter;
                break;
            }
            case MysticToolTypePanDown:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeToolDownCenter;
                break;
            }
            case MysticToolTypePanLeft:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeToolLeftCenter;
                break;
            }
            case MysticToolTypePanRight:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeToolRightCenter;
                break;
            }
            case MysticToolTypeSizeSmaller:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeToolMinus;
                break;
            }
            case MysticToolTypeSizeBigger:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeToolPlus;
                break;
            }
            case MysticToolTypeRotateLeft:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeToolRotateLeft;
                break;
            }
            case MysticToolTypeRotateRight:
            {
                iconType = iconType != MysticIconTypeUnknown ? iconType : MysticIconTypeToolRotateRight;
                break;
            }
            case MysticToolTypeFlexible:
            {
                item = [[[[self class] alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
                break;
            }
            case MysticToolTypeStatic:
            {
                item = [[[[self class] alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
                break;
            }
            case MysticToolTypeSeparator:
            {
                MysticBorderView *borderView = [[MysticBorderView alloc] initWithFrame:CGRectMake(0, 0, 5, height == MYSTIC_FLOAT_UNKNOWN ? MYSTIC_UI_TOOLBAR_HEIGHT : height)];
                width = borderView.frame.size.width;
                flex = !customFlex ? NO : flex;
                borderView.borderInsets= insets;
                borderView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                
                borderView.borderPosition = MysticPositionCenterVertical;
                borderView.borderWidth = 1;
                borderView.borderColor = customIconColor ? [MysticColor color:@(iconColor)] : [MysticColor color:@(MysticColorTypeToolbarSeparator)];
                item = [[self class] item:borderView];
                item.width = width;
                [borderView release];
                eventAdded = YES;

                break;
            }
            case MysticToolTypeNoSpace:
            {
                item = [[[[self class] alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
                width = width == MYSTIC_FLOAT_UNKNOWN ? MYSTIC_UI_TOOLBAR_MARGIN * -1 : width;
                flex = !customFlex ? NO : flex;
                break;
                
                
            }
            case MysticToolTypeNoPadding:
            {
                item = [[[[self class] alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
                width = width == MYSTIC_FLOAT_UNKNOWN ? MYSTIC_UI_TOOLBAR_NOMARGIN : width;
                flex = !customFlex ? NO : flex;
                break;
            }
            case MysticToolTypeNoMarginLeft:
            {
                item = [[[[self class] alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
                width = width == MYSTIC_FLOAT_UNKNOWN ? MYSTIC_UI_TOOLBAR_NOMARGIN_LEFT : width;
                flex = !customFlex ? NO : flex;
                break;
            }
            case MysticToolTypeNoMarginRight:
            {
                item = [[[[self class] alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
                width = width == MYSTIC_FLOAT_UNKNOWN ? MYSTIC_UI_TOOLBAR_NOMARGIN_RIGHT : width;
                flex = !customFlex ? NO : flex;
                break;
            }
            case MysticToolTypeFontVariant:
            {
                MysticFontVariantButton *tool = [[MysticFontVariantButton alloc] initWithFrame:viewFrame];
                tool.onToggle = ^(MysticFontVariantButton *toggleSender)
                {
                    [_toolbar itemTapped:toggleSender];
                    
                };
                if(flex) tool.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
                
                if(toggleState != NSNotFound) tool.toggleState = toggleState;
                
                item = [MysticBarButtonItem buttonItem:tool];
                [tool release];
                eventAdded = YES;
                break;
            }
            case MysticToolTypeAlign:
            {
                MysticAlignButton *tool = [[MysticAlignButton alloc] initWithFrame:viewFrame];
                tool.iconColor = [UIColor color:iconColor];
                tool.iconSize = iconSize;
                
                if(usesCustomAction)
                {
                    tool.onToggleTarget = target;
                    tool.onToggleAction = action;
                    
                }
                else
                {
                    tool.onToggle = ^(MysticFontAlignButton *toggleSender)
                    {
                        [_toolbar itemTapped:toggleSender];
                        
                    };
                }
                
                if(toggleState != NSNotFound) { /*DLog(@"setting tool align toggle state: %ld", (long)toggleState);*/ tool.toggleState = toggleState; }
                if(flex) tool.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
                tool.enabled = enabled;

                [tool updateIconImage];
                
                item = [MysticBarButtonItem buttonItem:tool];
                button = (id)item.customView;
                [tool release];
                eventAdded = YES;
                break;
            }
            case MysticToolTypeTextAlign:
            {
                MysticFontAlignButton *tool = [[MysticFontAlignButton alloc] initWithFrame:viewFrame];
                if(usesCustomAction)
                {
                    tool.onToggleTarget = target;
                    tool.onToggleAction = action;
                    
                }
                tool.onToggle = ^(MysticFontAlignButton *toggleSender)
                {
                    if(toggleSender.onToggleTarget && toggleSender.onToggleAction && [toggleSender.onToggleTarget respondsToSelector:toggleSender.onToggleAction])
                        [toggleSender.onToggleTarget performSelector:toggleSender.onToggleAction withObject:toggleSender];
                    else [_toolbar itemTapped:toggleSender];
                };
                tool.iconColor = [UIColor color:iconColor];
                tool.iconColorSelected = [UIColor color:iconColorSelected];
                tool.iconColorHighlighted = [UIColor color:iconColorHighlighted];
                if(iconColorDisabled != MysticColorTypeUnknown) tool.iconColorDisabled = [UIColor color:iconColorDisabled];
                tool.enabled = enabled;
                tool.iconSize = iconSize;
                if(toggleState != NSNotFound) tool.toggleState = toggleState;
                if(flex) tool.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
                [tool updateIconImage];

                item = [MysticBarButtonItem buttonItem:tool];
                button = item.customView;
                [tool release];
                eventAdded = YES;
                break;
            }

            default: break;
        }
    }
    BOOL addedDefaultAction = NO;
    if(!item && !button && iconType != MysticIconTypeUnknown && iconColor != MysticColorTypeUnknown)
    {

        button = [MysticBarButton clearButtonWithImage:[MysticImage image:@(iconType) size:iconSize color:@(iconColor)] target:target sel:action];
        addedDefaultAction = YES;
        button.ignoreUserActions = YES;
        button.contentMode = iconContentMode;
        if(!CGSizeEqualToSize(itemSize, MysticSizeUnknown))
        {
            button.frame = CGRectSize(itemSize);
            width = width == MYSTIC_FLOAT_UNKNOWN ? itemSize.width : width;
            
            
        }
        
        if(flex) button.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

        
        if(iconColorHighlighted != MysticColorTypeUnknown)
        {
            [button setImage:[MysticImage image:@(iconType) size:iconSize color:@(iconColorHighlighted)] forState:UIControlStateHighlighted];
        }
        if(iconColorSelected != MysticColorTypeUnknown)
        {
            [button setImage:[MysticImage image:@(iconType) size:iconSize color:@(iconColorSelected)] forState:UIControlStateSelected];
        }
        if(iconColorDisabled != MysticColorTypeUnknown)
        {
            [button setImage:[MysticImage image:@(iconType) size:iconSize color:@(iconColorDisabled)] forState:UIControlStateDisabled];
        }
        if([button respondsToSelector:@selector(setToolType:)]) button.toolType = toolType;
        button.continueOnHold = continuous;
        if(continuousTime > -1)
        {
            button.holdingInterval = continuousTime;
        }

    }
    if(!item && button)
    {
        
        if(flex) button.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        item = [MysticBarButtonItem item:button];
        if(!eventAdded && [button respondsToSelector:@selector(addTarget:action:forControlEvents:)] && target)
        {
            if(action && [target respondsToSelector:action] && !addedDefaultAction) [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
            if(actionDown && [target respondsToSelector:actionDown]) [button addTarget:target action:actionDown forControlEvents:UIControlEventTouchDown];
        }
        if(useDelegate)
        {
            if(targetDelegate && delegateAction && [targetDelegate respondsToSelector:delegateAction]) [button addTarget:targetDelegate action:delegateAction forControlEvents:UIControlEventTouchUpInside];
        }
    }
    if(item && !button)
    {
        if(bgColor && item.customView) item.customView.backgroundColor = bgColor;

    }
    if(button)
    {
        if(bgColor) button.backgroundColor = bgColor;
        if([button respondsToSelector:@selector(setCanSelect:)]) button.canSelect = canSelect;
        if([button respondsToSelector:@selector(setEnabled:)]) button.enabled = enabled;
        if(canSelect && [button respondsToSelector:@selector(setSelected:)]) button.selected = selected;
        if(viewTag != NSNotFound) button.tag = viewTag;
        if([button respondsToSelector:@selector(setObjectType:)]) button.objectType = objectType;
    }
    
    
    if(item)
    {
        if(hidden && item.customView)
        {
            item.customView.hidden = hidden;
        }
        item.toolType = toolType;
        item.objectType = objectType;
        if(width != MYSTIC_FLOAT_UNKNOWN && !flex) {
            item.width=width;
            if(debug)
            {
                DLog(@"item set width: %2.2f --> %@", width, item.customView ? item.customView : item);
            }
        }
    }
    if([toolTypeOrOptions isKindOfClass:[NSDictionary class]])
    {
        id bBlock = [toolTypeOrOptions objectForKey:@"block"];
        
        
        if(bBlock)
        {
            
            
            button = (id)((MysticBlockButtonItem)bBlock)(button, item);
            //        MysticBlockButtonItem b = [toolTypeOrOptions objectForKey:@"block"];
            //        button = (id)b(button, item);
        }
        
    }
  
//    if(debug)
//    {
//        ALLog(@"item debug", @[@"width", @(width), @"item",  item.customView ? item.customView : item, @"flex", MBOOL(flex), @"item width", @(item.width)]);
//    }

    return item;
}


- (void) dealloc;
{
    _delegate = nil;
    action=nil;
    [super dealloc];
}

- (CGFloat) frameWidth;
{
    UIView *view = [self valueForKey:@"view"];
    CGFloat w = view? [view frame].size.width : (CGFloat)self.width;
    return w;
}

- (BOOL) flexible;
{
    switch (self.toolType) {
        case MysticToolTypeCustom:
        {
            if(self.customView.autoresizingMask & UIViewAutoresizingFlexibleWidth)
            {
                return YES;
            }
            break;
        }
        case MysticToolTypeFlexible:
        case MysticToolTypeUnknown:
            return YES;
            break;
            
        default: break;
    }
    return NO;
}
- (void) setObjectType:(MysticObjectType)objectType;
{
    _objectType = objectType;
    if([self.button respondsToSelector:@selector(setObjectType:)])
    {
        self.button.objectType = objectType;
    }
}
- (void) setToolType:(MysticToolType)toolType;
{
    _toolType = toolType;
    if([self.button respondsToSelector:@selector(setToolType:)])
    {
        self.button.toolType = toolType;
    }
}
- (CGFloat) width;
{
    switch (self.toolType) {
        case MysticToolTypeStatic:
            return super.width;
            break;
            
        default: break;
    }
    return super.width;
}
- (void) setWidth:(CGFloat)value;
{
    if(self.customView)
    {
        CGRect newFrame = self.customView.frame;
        newFrame.size.width = value;
        self.customView.frame = newFrame;
    }
    super.width = value;
}
- (CGSize) size;
{
    if(self.customView)
    {
        return self.customView.frame.size;
    }
    return CGSizeMake(self.width, 0.0f);
}
- (BOOL) selected;
{
    return self.button.selected;
}
- (void) setSelected:(BOOL)selected;
{
    self.button.selected = selected;
}
- (MysticBarButton *) button;
{
    return (MysticBarButton *)self.customView;
}
+ (MysticBarButtonItem *) barButtonItemWithImage:(UIImage *)image action:(ActionBlock) action;
{
    MysticBarButton *btn = (MysticBarButton *)[MysticBarButton buttonWithImage:image action:action];
    [btn setImageEdgeInsets:UIEdgeInsetsZero];
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:btn];
    return [buttonItem autorelease];
}
+ (MysticBarButtonItem *) confirmButtonItem:(MysticBlockSender) action;
{
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:(MysticBarButton *)[MysticBarButton confirmButton:action]];
    return [buttonItem autorelease];
}

+ (MysticBarButtonItem *) confirmButtonItemWithTarget:(id)target sel:(SEL)action;
{
    MysticImage *img = [MysticImage image:@(MysticIconTypeConfirm) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIconConfirm]];
    
    MysticImage *imgHighlighted = [MysticImage image:@(MysticIconTypeConfirm) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIconConfirmHighlighted]];

    
    MysticBarButton *btn = (MysticBarButton *)[MysticBarButton clearButtonWithImage:img target:target sel:action];
    [btn setImage:imgHighlighted forState:UIControlStateHighlighted];
    CGRect f = btn.frame;
    f.size.width = 41.0f;
    btn.frame = f;
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:btn];
    return [buttonItem autorelease];
}

+ (MysticBarButtonItem *) cancelButtonItemWithTarget:(id)target sel:(SEL)action;
{
    MysticBarButton *btn = (MysticBarButton *)[MysticBarButton buttonWithImage:[UIImage imageNamed:@"cancel-button.png"] target:target sel:action];
    CGRect f = btn.frame;
    f.size.width = 48.0f;
    btn.frame = f;
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:btn];
    return [buttonItem autorelease];
}

+ (MysticBarButtonItem *) cancelButtonItem:(MysticBlockSender) action;
{
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:(MysticBarButton *)[MysticBarButton cancelButton:action]];
    return [buttonItem autorelease];
}
+ (MysticBarButtonItem *) backButtonItem:(ActionBlock) action;
{
    MysticImage *img = [MysticImage image:@(MysticIconTypeBack) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIcon]];
    
    MysticImage *imgHighlighted = [MysticImage image:@(MysticIconTypeBack) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIconHighlighted]];
    
    MysticBarButton *button = (MysticBarButton *)[MysticBarButton clearButtonWithImage:img action:action];
    [button setImage:imgHighlighted forState:UIControlStateHighlighted];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    button.frame = CGRectMake(0, 0, 50, button.frame.size.height);
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:button];
    return [buttonItem autorelease];
}

+ (MysticBarButtonItem *) backButtonItemWithTarget:(id)target action:(SEL) action;
{
    
    MysticImage *img = [MysticImage image:@(MysticIconTypeBack) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIcon]];
    
    MysticImage *imgHighlighted = [MysticImage image:@(MysticIconTypeBack) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIconHighlighted]];
    
    
    MysticBarButton *button = (MysticBarButton *)[MysticBarButton clearButtonWithImage:img target:target sel:action];
    [button setImage:imgHighlighted forState:UIControlStateHighlighted];
    button.frame = CGRectMake(0, 0, 50, button.frame.size.height);
    
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:button];
    return [buttonItem autorelease];
}
+ (MysticBarButtonItem *) closeButtonItem:(ActionBlock)action;
{
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:(MysticBarButton *)[MysticBarButton closeButton:action]];
    return [buttonItem autorelease];
}

+ (MysticBarButtonItem *) camButtonItem:(ActionBlock)action;
{
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:(MysticBarButton *)[MysticBarButton camButton:action]];
    return [buttonItem autorelease];
}

+ (MysticBarButtonItem *) slideOutButtonItem:(ActionBlock)action;
{
    MysticBarButton *btn = (MysticBarButton *)[[MysticBarButton slideOutButtonWithTarget:nil sel:nil] handleControlEvent:UIControlEventTouchUpInside withBlock:action];
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:btn];
    return [buttonItem autorelease];
}

+ (MysticBarButtonItem *) forwardButtonItem:(ActionBlock)action;
{
    
    MysticImage *img = [MysticImage image:@(MysticIconTypeForward) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIcon]];
    
    MysticImage *imgHighlighted = [MysticImage image:@(MysticIconTypeForward) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeNavBarIconHighlighted]];
    
    
    
    MysticBarButton *button = (MysticBarButton *)[MysticBarButton clearButtonWithImage:img target:nil sel:nil];
    [button setImage:imgHighlighted forState:UIControlStateHighlighted];
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:action];
    
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:button];
    return [buttonItem autorelease];
}

+ (MysticBarButtonItem *) infoButtonItem:(MysticBlockSender)action;
{
    UIImage *img = [MysticIcon imageNamed:@"iconMask-info.png" colorType:MysticColorTypeWhiteBarActive];
    UIImage *img2 = [MysticIcon imageNamed:@"iconMask-info.png" colorType:MysticColorTypePink];
    MysticBarButton *button = (MysticBarButton *)[MysticBarButton clearButtonWithImage:img target:nil sel:nil];
    [button setImage:img2 forState:UIControlStateHighlighted];
    [button handleControlEvent:UIControlEventTouchUpInside withBlockSender:action];
    
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:button];
    return [buttonItem autorelease];
}

+ (MysticBarButtonItem *) questionButtonItem:(MysticBlockSender)action;
{
    UIImage *img = [MysticIcon imageNamed:@"iconMask-question.png" colorType:MysticColorTypeWhiteBarActive];
    UIImage *img2 = [MysticIcon imageNamed:@"iconMask-question.png" colorType:MysticColorTypePink];
    
    MysticBarButton *button = (MysticBarButton *)[MysticBarButton clearButtonWithImage:img target:nil sel:nil];
    [button setImage:img2 forState:UIControlStateHighlighted];
    [button handleControlEvent:UIControlEventTouchUpInside withBlockSender:action];
    
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:button];
    return [buttonItem autorelease];
}

+ (MysticBarButtonItem *) barButtonItem:(ActionBlock)action;
{
    return [[[self alloc] initWithCustomView:(MysticBarButton *)[MysticBarButton buttonWithImage:nil action:action]] autorelease];
}

+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title action:(ActionBlock)action;
{
    return [[self class] barButtonItemWithTitle:title action:action];
}

+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
{
    return [[self class] barButtonItemWithTitle:title senderAction:action];
}

+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
{
    MysticBarButton *btn = (MysticBarButton *)[MysticBarButton buttonWithTitle:title target:target sel:action];
    return [[[self alloc] initWithCustomView:btn ] autorelease];
    
    
}

+ (MysticBarButtonItem *) barButtonItemWithTitle:(NSString *)title action:(ActionBlock)action;
{
    MysticBarButton *btn = (MysticBarButton *)[MysticBarButton buttonWithTitle:title target:nil sel:nil];
    [btn handleControlEvent:UIControlEventTouchUpInside withBlock:action];
    return [[[self alloc] initWithCustomView:btn ] autorelease];
}

+ (MysticBarButtonItem *) barButtonItemWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
{
    MysticBarButton *btn = (MysticBarButton *)[MysticBarButton buttonWithTitle:title target:nil sel:nil];
    [btn handleControlEvent:UIControlEventTouchUpInside withBlockSender:action];
    return [[[self alloc] initWithCustomView:btn ] autorelease];
}

+ (MysticBarButtonItem *) buttonItem:(id)titleOrImg senderAction:(MysticBlockSender)action;
{
    MysticBarButton *btn = (MysticBarButton *)[MysticBarButton button:titleOrImg action:action];
    
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:btn];
    return [buttonItem autorelease];
}




+ (MysticBarButtonItem *) backButtonItem:(id)titleOrImg action:(ActionBlock)action;
{
    MysticBarButton *btn;
    if([titleOrImg isKindOfClass:[NSString class]])
    {
        btn = (MysticBarButton *)[MysticBarButton backButtonWithTitle:titleOrImg target:nil sel:nil];
    }
    else
    {
        btn = (MysticBarButton *)[MysticBarButton backButtonWithImage:titleOrImg target:nil sel:nil];
    }
    [btn handleControlEvent:UIControlEventTouchUpInside withBlock:action];
    
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:btn];
    return [buttonItem autorelease];
}

+ (MysticBarButtonItem *) forwardButtonItem:(id)titleOrImg action:(ActionBlock)action
{
    MysticBarButton *btn;
    if([titleOrImg isKindOfClass:[NSString class]])
    {
        btn = (MysticBarButton *)[MysticBarButton forwardButtonWithTitle:titleOrImg target:nil sel:nil];
    }
    else
    {
        btn = (MysticBarButton *)[MysticBarButton forwardButtonWithImage:titleOrImg target:nil sel:nil];
    }
    [btn handleControlEvent:UIControlEventTouchUpInside withBlock:action];
    
    MysticBarButtonItem *buttonItem = [[self alloc] initWithCustomView:btn];
    return [buttonItem autorelease];
}
+ (MysticBarButtonItem *) clearButtonItemWithImage:(UIImage *)image action:(ActionBlock)action;
{
    MysticBarButton *button = (MysticBarButton *)[MysticBarButton clearButtonWithImage:image action:action];
    return [[[self alloc] initWithCustomView:button] autorelease];
}

+ (MysticBarButtonItem *) emptyItem;
{
    UIView *cview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48.0f, 36.0f)];
    MysticBarButtonItem *item = [[self alloc] initWithCustomView:cview];
    [cview release];
    
    return [item autorelease];
}
+ (MysticBarButtonItem *) clearSwitchButtonItemTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage action:(MysticBlockSender)action;
{
    return [[[self alloc] initWithCustomView:[MysticUI clearSwitchButtonTurned:isOn onImage:onImage offImage:offImage action:action]] autorelease];
}

+ (MysticBarButtonItem *) moreButtonItem:(MysticBlockSender)action;
{
    MysticBarButton *button = [MysticBarButton moreButton:action];
    return [[self class] buttonItem:button];
}

+ (MysticBarButtonItem *) moreButtonItem:(id)target action:(SEL)action;
{
    MysticBarButton *button = [MysticBarButton moreButton:target action:action];
    return [[self class] buttonItem:button];
}

@end
