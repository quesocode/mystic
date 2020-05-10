//
//  MysticRotateScaleToolbar.m
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticRotateScaleToolbar.h"

@implementation MysticRotateScaleToolbar


@synthesize targetOption=_targetOption;

+ (MysticRotateScaleToolbar *) toolbarWithFrame:(CGRect)frame;
{
    MysticRotateScaleToolbar *toolbar = [[[self class] alloc] initWithFrame:frame];
    
    return [toolbar autorelease];
}

+ (NSArray *) defaultItemsWithDelegate:(MysticRotateScaleToolbar *)delegate;
{
    CGFloat paddedHeight = MYSTIC_UI_PANEL_HEIGHT_MOVE - (MYSTIC_UI_TOOLBAR_HEIGHT_PADDING*2);
    
    MysticObjectType objectType = delegate.objectType;
    
    
    return @[@{
                 @"toolType": @(MysticToolTypeRotateLeft),
                 @"objectType":@(objectType),
                 @"color":@(MysticColorTypeToolbarIcon),
                 @"continueOnHold": @YES,
                 @"continueInterval": @(0.03),

                 },
             @(MysticToolTypeFlexible),
             @{
                 @"toolType": @(MysticToolTypeRotateRight),
                 @"objectType":@(objectType),
                 @"color":@(MysticColorTypeToolbarIcon),
                 @"continueOnHold": @YES,
                 @"continueInterval": @(0.03),


                 },
             @(MysticToolTypeFlexible),
             @{
                 @"toolType": @(MysticToolTypeSizeBigger),
                 @"objectType":@(objectType),
                 @"color":@(MysticColorTypeToolbarIcon),
                 @"continueOnHold": @YES,
                 @"continueInterval": @(0.03),


                 },
             @(MysticToolTypeFlexible),
             @{
                 @"toolType": @(MysticToolTypeSizeSmaller),
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
    switch (sender.toolType) {
            
            
        default: break;
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
