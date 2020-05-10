//
//  MysticMoveToolbar.m
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticMoveToolbar.h"

@implementation MysticMoveToolbar

@synthesize targetOption=_targetOption;



+ (NSArray *) defaultItemsWithDelegate:(MysticMoveToolbar *)delegate toolbar:(MysticLayerToolbar *)toolbar height:(CGFloat)height;
{
    CGFloat paddedHeight = MYSTIC_UI_PANEL_HEIGHT_MOVE - (MYSTIC_UI_TOOLBAR_HEIGHT_PADDING*2);
    
    MysticObjectType objectType = delegate.objectType;
    
    
    return @[@{
                 @"toolType": @(MysticToolTypePanUp),
                 @"objectType":@(objectType),
                 @"color":@(MysticColorTypeToolbarIcon),
                 @"continueOnHold": @YES,
                 @"continueInterval": @(0.03),

                 },
             @(MysticToolTypeFlexible),
             @{
                 @"toolType": @(MysticToolTypePanDown),
                 @"objectType":@(objectType),
                 @"color":@(MysticColorTypeToolbarIcon),
                 @"continueOnHold": @YES,
                 @"continueInterval": @(0.03),


                 },
             @(MysticToolTypeFlexible),
             @{
                 @"toolType": @(MysticToolTypePanLeft),
                 @"objectType":@(objectType),
                 @"color":@(MysticColorTypeToolbarIcon),
                 @"continueOnHold": @YES,
                 @"continueInterval": @(0.03),


                 },
             @(MysticToolTypeFlexible),
             @{
                 @"toolType": @(MysticToolTypePanRight),
                 @"objectType":@(objectType),
                 @"color":@(MysticColorTypeToolbarIcon),
                 @"continueOnHold": @YES,
                 @"continueInterval": @(0.03),

                 },
             ];
    
    
    
    
}

- (void) dealloc;
{
    [_targetOption release];
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        NSArray *_items = [[self class] defaultItemsWithDelegate:self];
        [self setItems:[self items:_items addSpacing:NO] animated:NO];
        
    }
    return self;
}

- (void) commonInit;
{
    self.tag = MysticViewTypeToolbarFont;
}

    


- (void) itemTapped:(MysticBarButton *)sender;
{
    [super itemTapped:sender];
    [self itemTouchDown:sender];
}
- (void) itemTouchDown:(MysticBarButton *)sender;
{
    CGFloat increment = 0;
    PackPotionOption *option = self.targetOption;
    BOOL valueChanged = YES;
    increment = [option increment:sender.toolType];

    switch (sender.toolType)
    {
        case MysticToolTypeRotateRight:
        {
            CGFloat rotationRadians= 0.0f;
            rotationRadians = self.targetOption.rotation;
            
            rotationRadians+=increment;
            self.targetOption.rotation = rotationRadians;
            break;
        }
        case MysticToolTypeRotateLeft:
        {
            CGFloat rotationRadians= 0.0f;
            rotationRadians = self.targetOption.rotation;
            
            rotationRadians+=increment;
            self.targetOption.rotation = rotationRadians;
            break;
        }
        case MysticToolTypeSizeBigger:
        {
            
            CGRect newRect= CGRectZero;
            CGFloat ax = [option increment:sender.toolType];
            CGFloat ay = [option increment:sender.toolType];
            newRect = option.transformRect;
            
    
            ax = option.adjustedRect.size.width != 0 ? ax * option.adjustedRect.size.width : ax;
            ay = option.adjustedRect.size.height != 0 ? ay * option.adjustedRect.size.height : ay;
            
            
            
            newRect.size.width+=ax;
            newRect.size.height+=ay;
            option.transformRect = newRect;
            
            
            break;
        }
        case MysticToolTypeSizeSmaller:
        {
            
            CGRect newRect= CGRectZero;
            CGFloat ax = [option increment:sender.toolType];
            CGFloat ay = [option increment:sender.toolType];

            newRect = option.transformRect;
            
    
            
            ax = option.adjustedRect.size.width != 0 ? ax * option.adjustedRect.size.width : ax;
            ay = option.adjustedRect.size.height != 0 ? ay * option.adjustedRect.size.height : ay;
            
            
            newRect.size.width+=ax;
            newRect.size.height+=ay;
            
            option.transformRect = newRect;
            
            
            break;
        }
        case MysticToolTypePanLeft:
        {
            CGRect newRect= CGRectZero;
            CGFloat ax = [option increment:sender.toolType];
            CGFloat ay = 0.0f;

            newRect = option.transformRect;
            newRect.origin.x+=ax;
            newRect.origin.y+=ay;
            option.transformRect = newRect;
            
            break;
        }
        case MysticToolTypePanRight:
        {
            CGRect newRect= CGRectZero;
            CGFloat ax = [option increment:sender.toolType];
            CGFloat ay = 0.0f;

            newRect = option.transformRect;
            newRect.origin.x+=ax;
            newRect.origin.y+=ay;
            option.transformRect = newRect;
            
            break;
        }
        case MysticToolTypePanUp:
        {
            CGRect newRect= CGRectZero;
            CGFloat ax = 0.0f;
            CGFloat ay = [option increment:sender.toolType];

            newRect = option.transformRect;
            
            
            newRect.origin.x+=ax;
            newRect.origin.y+=ay;
            option.transformRect = newRect;
            
            break;
        }
        case MysticToolTypePanDown:
        {
            CGRect newRect= CGRectZero;
            CGFloat ax = 0.0f;
            CGFloat ay = [option increment:sender.toolType];

            newRect = option.transformRect;
            
            newRect.origin.x+=ax;
            newRect.origin.y+=ay;
            option.transformRect = newRect;
            
            break;
        }
            
        default:
            valueChanged = NO;
            break;
    }
    
    if(valueChanged)
    {
        if(option)
        {
            [option valueChanged:sender.toolType change:@(increment)];
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(toolbar:valueChanged:toolType:)])
        {
            [self.delegate toolbar:self valueChanged:sender toolType:sender.toolType change:increment];
        }
        if(self.onChange)
        {
            self.onChange(self, sender, @(increment));
        }
    }
    
}

- (void) setTargetOption:(PackPotionOption *)targetOption;
{
    if(_targetOption)
    {
        [_targetOption release], _targetOption = nil;
    }
    if(targetOption)
    {
        _targetOption = [targetOption retain];
    }
    //    [super setTargetOption:targetOption];
    [self updateToolsWithOption:_targetOption];
}

- (void) updateToolsWithOption:(PackPotionOption *)option;
{
    PackPotionOptionFontStyle *fontOption = (PackPotionOptionFontStyle *)option;
    for (MysticBarButtonItem *item in self.items) {
        switch (item.toolType) {
            
            default: break;
        }
    }
}

@end

