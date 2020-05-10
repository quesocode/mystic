//
//  MysticScrollViewControl.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/24/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticScrollViewControl.h"

@implementation MysticScrollViewControl

- (id)initWithFrame:(CGRect)frame effect:(MysticChoice *)effectObject position:(NSInteger)theIndex action:(MysticChoiceBlock)anAction marginInsets:(UIEdgeInsets)marginInsets;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.effect = effectObject;
        self.position = theIndex;
        self.insets = marginInsets;
        self.gridIndex = (MysticGridIndex){NSNotFound,NSNotFound};
    }
    return self;
}
- (void) reuse;
{
    //    self.pageControl.hidden = YES;
    self.targetOption = nil;
    if(self.effect && [self.effect respondsToSelector:@selector(prepareControlForReuse:)])
    {
        [self.effect performSelector:@selector(prepareControlForReuse:) withObject:self];
    }
}

- (UIScrollView *)scrollView;
{
    return (self.superview && [self.superview isKindOfClass:[UIScrollView class]]) ? (id)self.superview : nil;
}

- (void) showAsSelected { [self showAsSelected:YES]; }
- (void) showAsSelected:(BOOL)makeSelected;
{
    [self setSuperSelected:makeSelected];
    [self updateLabel:makeSelected];
}
- (void) setSuperSelected:(BOOL)isSelected
{
    self.wasSelected = [super isSelected];
    [super setSelected:isSelected];
}
- (void) updateLabel:(BOOL)selected;
{
    
}
- (void) prepare;
{
    
}
@end
