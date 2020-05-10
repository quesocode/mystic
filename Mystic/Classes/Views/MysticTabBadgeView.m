//
//  MysticTabBadgeView.m
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticTabBadgeView.h"
#import <QuartzCore/QuartzCore.h>
#import "Mystic.h"
#include <stdlib.h>

@implementation MysticTabBadgeView


@synthesize badgeCount=_badgeCount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}
- (void) commonInit;
{
    
    int min = 1;
    int max = 20;
    self.useCheckmark = YES;
    
    
    self.opaque = NO;
    self.highlightedTextColor = [UIColor color:MysticColorTypeTabBadgeTextHighlighted];
    self.textColor = [UIColor color:MysticColorTypeTabBadgeText];
    CGFloat fontSize = 11;

    self.font = [UIFont fontWithName:@"AvenirNext-Bold" size:fontSize];
    
    self.textAlignment = NSTextAlignmentCenter;
    
    self.badgeCount = 1;
}

- (NSInteger) badgeCount;
{
    return _badgeCount;
}

- (void) setBadgeCount:(NSInteger)badgeCount;
{
    [self setBadgeCount:badgeCount animated:NO];
}
- (void) setBadgeCount:(NSInteger)badgeCount animated:(BOOL)animated;
{
//    int min = 1;
//    int max = 9;
//    
//    int randomNumber = min + rand() % (max-min);
//    badgeCount = randomNumber;
    _badgeCount = badgeCount;

    if(animated)
    {
        __unsafe_unretained __block MysticTabBadgeView *weakSelf = self;
        [MysticUIView animateWithDuration:0.3 animations:^{
            weakSelf.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf updateBadgeCount:badgeCount];
            [MysticUIView animateWithDuration:0.3 animations:^{
                weakSelf.alpha = 1;
            } completion:nil];
        }];
    }
    else
    {
        [self updateBadgeCount:badgeCount];
    }
    

//    max = 20;
//    
//    CGFloat fontSize = 10;
//    int randomNumber2 = min + rand() % (max-min);
//    
//    if(randomNumber2 <= 5)
//    {
//        self.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:fontSize];
//        
//    }
//    else if(randomNumber2 <= 10)
//    {
//        self.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:fontSize];
//        
//    }
//    else if(randomNumber2 <= 15)
//    {
//        self.font = [UIFont fontWithName:@"Superclarendon-Black" size:fontSize];
//        self.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:fontSize];
//
//        
//    }
//    else
//    {
//        self.font = [UIFont fontWithName:@"GillSans-Bold" size:fontSize];
//        self.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:fontSize];
//
//        
//    }
//    DLog(@"font badge: %@", self.font.fontName);

    

}

- (void) updateBadgeCount:(NSInteger)badgeCount;
{
    if(badgeCount <= 1 && self.useCheckmark)
    {
        self.text = @"";
        self.backgroundColor = [UIColor colorWithPatternImage:[MysticImage image:@(MysticIconTypeBadgeCheck) size:self.bounds.size color:@(MysticColorTypeUnknown)]];
        return;
    }
//    self.backgroundColor = [UIColor colorWithPatternImage:[MysticImage image:@(MysticIconTypeBadgeCircle) size:self.bounds.size color:@(MysticColorTypeUnknown)]];
    self.backgroundColor = [UIColor clearColor];
    NSString *countStr = badgeCount <= 9 ? [NSString stringWithFormat:@"%ld", (long)badgeCount] : @"+";
    self.text = NSLocalizedString(countStr, nil);
}

//- (void) setHighlighted:(BOOL)highlighted;
//{
//    [super setHighlighted:highlighted];
//    
//    self.backgroundColor = [UIColor color:(highlighted ? MysticColorTypeTabBadgeHighlighted : MysticColorTypeTabBadge)];
//
//}


- (void) setFrame:(CGRect)frame;
{
    frame.size.width = frame.size.height;
    
    [super setFrame:frame];
    self.layer.cornerRadius = frame.size.height/2;
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
