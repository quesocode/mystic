//
//  MysticFontToolbar.m
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticFontToolbar.h"
#import "MysticBarButtonItem.h"
#import "MysticFontTools.h"


@implementation MysticFontToolbar

@synthesize targetOption=_targetOption;





+ (NSArray *) defaultItemsWithDelegate:(id)delegate toolbar:(MysticLayerToolbar *)toolbar height:(CGFloat)height;
{
    

    CGFloat paddedHeight = height - (MYSTIC_UI_TOOLBAR_HEIGHT_PADDING*2);
    
    MysticFontAlignButton *alignButton = [[MysticFontAlignButton alloc] initWithFrame:CGRectMake(0, 0, paddedHeight, paddedHeight)];
    alignButton.onToggle = ^(MysticFontAlignButton *toggleSender)
    {
        [delegate itemTapped:toggleSender];
    };
    
//    MysticFontSpacingControl *spacingControl = [[MysticFontSpacingControl alloc] initWithFrame:CGRectMake(0, 0, 100, height)];
    MysticFontLineHeightControl *lineHeightControl = [[MysticFontLineHeightControl alloc] initWithFrame:CGRectMake(0, 0, 100, height)];
    MysticFontSizeControl *sizeControl = [[MysticFontSizeControl alloc] initWithFrame:CGRectMake(0, 0, 130, height)];
    
//    sizeControl.backgroundColor = [UIColor hex:@"61534b"];
//    spacingControl.backgroundColor = [UIColor hex:@"627a5f"];

    id sizeDelegate = delegate && [delegate respondsToSelector:@selector(sizeControlChanged:)] ? delegate : toolbar;
//    id spacingDelegate = delegate && [delegate respondsToSelector:@selector(spacingControlChanged:)] ? delegate : toolbar;
    id lineHeightDelegate = delegate && [delegate respondsToSelector:@selector(lineHeightControlChanged:)] ? delegate : toolbar;
    
    if(sizeDelegate) [sizeControl addTarget:sizeDelegate action:@selector(sizeControlChanged:) forControlEvents:UIControlEventValueChanged];

    if(lineHeightDelegate)[lineHeightControl addTarget:lineHeightDelegate action:@selector(lineHeightControlChanged:) forControlEvents:UIControlEventValueChanged];
    
    return @[
             @(MysticToolTypeNoMarginLeft),
             @(MysticToolTypeFlexible),

             @{@"toolType": @(MysticToolTypeTextAlign), @"height":@(height), },
             
             
             @(MysticToolTypeNoSpace),
             @{@"tool": @(MysticToolTypeSeparator), @"height":@(height), @"insets": CGSizeMakeValue(0, 0)},
             @(MysticToolTypeNoSpace),
             @(MysticToolTypeFlexible),
             @{
                 @"toolType": @(MysticToolTypeFontSize),
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
                 @"toolType": @(MysticToolTypeFontLineHeight),
                 @"height":@(height),
                 @"view": [lineHeightControl autorelease],
                 @"eventAdded": @YES,
                 },
             

             @(MysticToolTypeFlexible),
             @(MysticToolTypeNoMarginRight)
             
             ];
    
    
    
    
}

+ (id) toolbarWithDelegate:(id)delegate height:(CGFloat)height;
{
//    NSArray *items = [[self class] defaultItemsWithDelegate:delegate height:height];
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
    self.tag = MysticViewTypeToolbarFont;
}

- (void) spacingControlChanged:(MysticFontSpacingControl *)sender;
{
//    DLog(@"spacing tapped: %2.0f", sender.value);

    self.targetOption.spacing = sender.value;
    
}

- (void) lineHeightControlChanged:(MysticFontLineHeightControl *)sender;
{
    //    DLog(@"spacing tapped: %2.0f", sender.value);
    
    self.targetOption.lineHeightScale = sender.value;
    
}



- (void) sizeControlChanged:(MysticFontSizeControl *)sender;
{
    
//    DLog(@"size tapped: %2.0f", sender.value);

    self.targetOption.fontSize = sender.value;
}

- (void) itemTapped:(MysticBarButton *)sender;
{
    switch (sender.toolType) {
        case MysticToolTypeTextAlign:
        {
            [self.targetOption setTextAlignment:[(MysticFontAlignButton *)sender value]];
            break;
        }
            
        default:
            [super itemTapped:sender];
            break;
    }
    
}

- (void) setTargetOption:(PackPotionOptionFontStyle *)targetOption;
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
    for (MysticBarButtonItem *item in self.items)
    {
        MysticControl *control = [self controlForItem:item];

        if(!control || ![control respondsToSelector:@selector(setCancelsEvents:)]) continue;
        control.cancelsEvents = YES;

        switch (item.toolType)
        {
            case MysticToolTypeTextAlign:
            {
                
                MysticFontAlignButton *ccontrol = (MysticFontAlignButton *)control;
                
                if(option && option.hasValues)
                {
                    ccontrol.value = textAlignment(fontOption.textAlignment);
                    ccontrol.enabled = YES;
                    
                }
                else
                {
                    
                    ccontrol.value = control.defaultValue;
                    ccontrol.enabled = NO;
                    
                }
                
                break;
            }
            case MysticToolTypeFontSize:
            {
                
                if(option && option.hasValues)
                {
                    control.value = [fontOption fontSize];
                    control.enabled = YES;
                    
                }
                else
                {
                    [control setEmpty];
                    control.enabled = NO;
                    
                }
                
                break;
            }
            case MysticToolTypeFontLineHeight:
            {
                
                if(option && option.hasValues)
                {
                    control.value = [fontOption lineHeightScale];
                    control.enabled = YES;
                    
                }
                else
                {
                    [control setEmpty];
                    control.enabled = NO;
                    
                }
                
                break;
            }
            case MysticToolTypeFontSpacing:
            {
                
                if(option && option.hasValues)
                {
                    control.value = [fontOption spacing];
                    control.enabled = YES;
                    
                }
                else
                {
                    [control setEmpty];
                    control.enabled = NO;
                    
                }
                break;
            }
            default: break;
        }
        if(control)
        {
            control.cancelsEvents = NO;
        }
        
    }
}

@end
