//
//  MysticAnimatedLabel.m
//  Mystic
//
//  Created by Me on 2/13/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticAnimatedLabel.h"
#import "UIView+Mystic.h"

@implementation MysticAnimatedLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.duration = 0.15;

    }
    return self;
}


- (void) setText:(NSString *)text
{

    [self setText:text animated:NO];
}

- (void) setText:(NSString *)text animated:(BOOL)animated;
{
    if(animated)
    {
        __unsafe_unretained __block MysticAnimatedLabel *weakSelf = self;
        [MysticUIView animateWithDuration:self.duration animations:^{
            weakSelf.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf superSetText:text];
            [MysticUIView animateWithDuration:weakSelf.duration animations:^{
                weakSelf.alpha = 1;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    else
    {
        [self superSetText:text];
    }
}

- (void) superSetText:(NSString *)text;
{
    [super setText:text];
    
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
