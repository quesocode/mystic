//
//  MysticSegmentedControl.m
//  Mystic
//
//  Created by Me on 1/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticSegmentedControl.h"

@implementation MysticSegmentedControl


@synthesize itemsInfo=_itemsInfo;

+ (void) initialize;
{
    [[MysticSegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [MysticUI gothamBold:MYSTIC_UI_SEGMENT_TEXTSIZE], UITextAttributeFont,
                                                                    [UIColor color:MysticColorTypeSegmentControlTextColor], UITextAttributeTextColor,
                                                                    [UIColor clearColor], UITextAttributeTextShadowColor,
                                                                    [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                                    nil] forState:UIControlStateNormal];
    
    [[MysticSegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [MysticUI gothamBold:MYSTIC_UI_SEGMENT_TEXTSIZE], UITextAttributeFont,
                                                                 [UIColor color:MysticColorTypeSegmentControlTextColorSelected], UITextAttributeTextColor,
                                                                 [UIColor clearColor], UITextAttributeTextShadowColor,
                                                                 [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                                 nil] forState:UIControlStateSelected];
    
    [[MysticSegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [MysticUI gothamBold:MYSTIC_UI_SEGMENT_TEXTSIZE], UITextAttributeFont,
                                                                 [UIColor color:MysticColorTypeSegmentControlTextColorHighlighted], UITextAttributeTextColor,
                                                                 [UIColor clearColor], UITextAttributeTextShadowColor,
                                                                 [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                                 nil] forState:UIControlStateHighlighted];
    
    [[MysticSegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [MysticUI gothamBold:MYSTIC_UI_SEGMENT_TEXTSIZE], UITextAttributeFont,
                                                                 [UIColor color:MysticColorTypeSegmentControlTextColorDisabled], UITextAttributeTextColor,
                                                                 [UIColor clearColor], UITextAttributeTextShadowColor,
                                                                 [NSValue valueWithCGSize:CGSizeMake(0, 0)], UITextAttributeTextShadowOffset,
                                                                 nil] forState:UIControlStateDisabled];

}

+ (NSArray *) processItems:(NSArray *)items;
{
    NSMutableArray *_items = [NSMutableArray array];
    for (id obj in items) {
        id newObj = obj;
        if([obj isKindOfClass:[NSNumber class]])
        {
            newObj = [MysticImage image:obj size:CGSizeMake(MYSTIC_UI_PANEL_SEGMENTS_HEIGHT - 16, MYSTIC_UI_PANEL_SEGMENTS_HEIGHT - 16) color:@(MysticColorTypeSegmentControlImageColor)];
        }
        [_items addObject:newObj];
    }
    return _items;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}
- (id) initWithItems:(NSArray *)items itemInfo:(NSArray *)theInfo;
{
//    _itemsInfo = theInfo ? [theInfo retain] : nil;
    self = [super initWithItems:[MysticSegmentedControl processItems:items]];
    if(self)
    {
        [self commonInit];
        self.itemsInfo = theInfo;
    }
    return self;}

- (id) initWithItems:(NSArray *)items;
{
    self = [super initWithItems:[MysticSegmentedControl processItems:items]];
    if(self)
    {
        [self commonInit];
    }
    return self;
}

- (void) commonInit;
{
    if(!self.itemsInfo) self.itemsInfo = [NSArray array];
    self.tintColor = [UIColor colorWithType:MysticColorTypeSegmentControl];
}

- (NSDictionary *) itemInfoAtIndex:(NSInteger)atIndex;
{
    if(_itemsInfo && _itemsInfo.count > atIndex)
    {
        return [_itemsInfo objectAtIndex:atIndex];
    }
    return [NSDictionary dictionary];
}

- (void) setupWidths;
{
    for (int i =0; i<self.numberOfSegments; i++) {
        [self setWidth:[self widthForSegmentAtIndex:i] forSegmentAtIndex:i];
    }
    [self setNeedsLayout];
}

- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment;
{
    NSDictionary *txtAttr = [self titleTextAttributesForState:self.state];
    NSString *title = [self titleForSegmentAtIndex:segment];
    CGFloat w = 0;
    CGSize titleSize = CGSizeZero;
    NSDictionary *itemInfo = [self itemInfoAtIndex:segment];
    
    CGFloat padding = [itemInfo objectForKey:@"padding"] ? [[itemInfo objectForKey:@"padding"] floatValue] : MYSTIC_UI_SEGMENT_WIDTH_PADDING;
    

    if(title)
    {
        if([title respondsToSelector:@selector(sizeWithAttributes:)])
        {
            titleSize = [title sizeWithAttributes:txtAttr];
        }
        else
        {
            
            titleSize = [title sizeWithFont:[UIFont systemFontOfSize:14]];
        }
    }
    else
    {
        UIImage *titleImage = [self imageForSegmentAtIndex:segment];
        if(titleImage)
        {
            titleSize = titleImage.size;
        }
        padding = MYSTIC_UI_SEGMENT_WIDTH_PADDING_IMAGE;
    }
    w = titleSize.width + (padding * 2);
    

    return w;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
