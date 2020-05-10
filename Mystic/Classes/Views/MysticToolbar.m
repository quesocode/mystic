//
//  MysticToolbar.m
//  Mystic
//
//  Created by travis weerts on 3/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticToolbar.h"
#import "UIColor+Mystic.h"
#import "MysticButton.h"

@implementation MysticToolbar


- (void) applyTranslucentBackground;
{
    [super setBackgroundColor:[UIColor clearColor]];
    self.opaque = NO;
    self.translucent = YES;
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.barTintColor = backgroundColor;
    self.translucent = backgroundColor.alpha > 0 ? NO : YES;
    self.opaque = self.translucent;
}



- (id) initWithFrame:(CGRect) frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (id) itemWithTag:(NSInteger)itemTag;
{
    for (UIBarButtonItem *item in self.items)
    {
        if(item.tag == itemTag) return item;
        if(item.customView && item.customView.tag == itemTag) return item.customView;
    }
    return nil;
}
- (id) selectedItem;
{
    for (UIBarButtonItem *item in self.items)
    {
        if(item.customView && [item.customView respondsToSelector:@selector(selected)] && [(MysticButton *)item.customView isSelected]) return item;
    }
    return nil;
}
- (id) selectedButton;
{
    UIBarButtonItem *item = self.selectedItem;
    return item && item.customView ? item.customView : nil;
}
- (NSInteger) indexOfItemWithTag:(NSInteger)itemTag;
{
    NSInteger index = 0;
    for (UIBarButtonItem *item in self.items)
    {
        if(item.tag == itemTag) return index;
        if(item.customView && item.customView.tag == itemTag) return index;
        index++;
    }
    return NSNotFound;
}
- (void) setup;
{
    self.userInteractionEnabled = YES;
}

//- (void) printFrame;
//{
//    NSMutableArray *lines = [NSMutableArray arrayWithArray:@[]];
//    
//    CGFloat tw = 0;
//    CGFloat aw = 0;
//    
//    int i = 0;
//    for (MysticBarButtonItem *item in self.items) {
//        
//        [lines addObject:[NSString stringWithFormat:@"%d", i+1]];
//        [lines addObject:[NSString stringWithFormat:@"width %2.2f", item.frameWidth]];
//        tw += item.frameWidth > 0 ? item.frameWidth : 0;
//        aw += item.frameWidth;
//        i++;
//    }
//    [lines addObject:@"---"];
//    [lines addObject:@"---"];
//
//    [lines addObject:@"Positive Width"];
//    [lines addObject:@(tw)];
//    
//    [lines addObject:@"Sum Width"];
//    [lines addObject:@(aw)];
//
//    NSString *header = [NSString stringWithFormat:@"Toolbar: %@", [self class]];
//    ALLog(header, lines);
//}

@end
