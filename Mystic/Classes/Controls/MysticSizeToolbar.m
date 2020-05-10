//
//  MysticSizeToolbar.m
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticSizeToolbar.h"
#import "MysticFontTools.h"

@implementation MysticSizeToolbar

@synthesize targetOption=_targetOption;


+ (NSArray *) defaultItemsWithDelegate:(MysticLayerToolbar *)delegate toolbar:(MysticLayerToolbar *)toolbar height:(CGFloat)height;
{
    CGFloat paddedHeight = MYSTIC_UI_PANEL_HEIGHT_MOVE - (MYSTIC_UI_TOOLBAR_HEIGHT_PADDING*2);
    
    DLog(@"toolbar height: %2.0f", height);
//    MysticObjectType objectType = toolbar.objectType;
    MysticFontSizeControl *sizeControl = [[MysticFontSizeControl alloc] initWithFrame:CGRectMake(0, 0, 130, height)];
    id sizeDelegate = delegate && [delegate respondsToSelector:@selector(sizeWidthControlChanged:)] ? delegate : toolbar;
    if(sizeDelegate)
    {
        [sizeControl addTarget:sizeDelegate action:@selector(sizeWidthControlChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    
    MysticFontSizeControl *sizeHeightControl = [[MysticFontSizeControl alloc] initWithFrame:CGRectMake(0, 0, 130, height)];
    id sizeHeightDelegate = delegate && [delegate respondsToSelector:@selector(sizeHeightControlChanged:)] ? delegate : toolbar;
    if(sizeHeightDelegate)
    {
        [sizeHeightControl addTarget:sizeHeightDelegate action:@selector(sizeHeightControlChanged:) forControlEvents:UIControlEventValueChanged];
    }

    
    return @[
             @(MysticToolTypeNoMarginLeft),
             
             
             @(MysticToolTypeFlexible),
             @{
                 @"toolType": @(MysticToolTypeSizeWidth),
                 @"height":@(height),
                 @"view": [sizeControl autorelease],
                 @"eventAdded": @YES,
                 },
             
             
             
             @(MysticToolTypeFlexible),
             @(MysticToolTypeNoSpace),
             @{@"tool": @(MysticToolTypeSeparator), @"height":@(height), @"insets": CGSizeMakeValue(0, 0)},
             @(MysticToolTypeNoSpace),
             
             @(MysticToolTypeFlexible),
             
             @{
                 @"toolType": @(MysticToolTypeSizeHeight),
                 @"height":@(height),
                 @"view": [sizeHeightControl autorelease],
                 @"eventAdded": @YES,
                 },
             
             
             @(MysticToolTypeFlexible),
             @(MysticToolTypeNoMarginRight)
             
             ];
    
    
    
    
}




+ (id) toolbarWithDelegate:(id)delegate height:(CGFloat)height;
{
    return [[[self class] alloc] initWithFrame:CGRectMake(0, 0, [MysticUI screen].width, height) delegate:delegate];
    
}

- (void) dealloc;
{
    [_targetOption release];
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame delegate:(id)theDelegate;
{
    self = [super initWithFrame:frame delegate:theDelegate];
    if(self)
    {
        NSArray *_items = [[self class] defaultItemsWithDelegate:theDelegate toolbar:self height:frame.size.height];
        [self setItems:[self items:_items addSpacing:NO] animated:NO];
        
    }
    return self;
}

- (void) commonInit;
{
    self.tag = MysticViewTypeToolbarSize;
}


- (void) sizeWidthControlChanged:(MysticFontSizeControl *)sender;
{
    
//        DLog(@"size width tapped: %2.0f", sender.value);
    
}

- (void) sizeHeightControlChanged:(MysticFontSizeControl *)sender;
{
    
//    DLog(@"size height tapped: %2.0f", sender.value);
    
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
        _targetOption = (id)[targetOption retain];
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
