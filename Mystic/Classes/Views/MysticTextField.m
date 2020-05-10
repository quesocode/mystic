//
//  MysticTextField.m
//  Mystic
//
//  Created by travis weerts on 3/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticTextField.h"
#import "UIColor+Mystic.h"

@implementation MysticTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clearButtonMode = UITextFieldViewModeAlways;
        UIImage *inputBgImage = [[UIImage imageNamed:@"ButtonSelected"] stretchableImageWithLeftCapWidth:16 topCapHeight:0];
        
//        if([inputBgImage respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
//        {
//            inputBgImage = [inputBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(16,16,16, 16) resizingMode:UIImageResizingModeStretch];
//        }
//        else
//        {
//            inputBgImage = [inputBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(16,16,16, 16)];
//        }
        self.background = inputBgImage;
        self.textColor = [UIColor mysticWhiteColor];
        self.font = [UIFont fontWithName:@"Helvetica" size:13];
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    return self;
}
- (CGRect) rightViewRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width-(bounds.size.height - 6)-4, 3, bounds.size.height - 6, bounds.size.height - 6);
}
- (CGRect) leftViewRectForBounds:(CGRect)bounds
{
    return CGRectMake(4, 3, bounds.size.height - 6, bounds.size.height - 6);
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    [[UIColor mysticInactiveIconColor] setFill];
    [[self placeholder] drawInRect:rect withFont:self.font];
}


//- (CGRect)textRectForBounds:(CGRect)bounds
//{
//    CGRect inset = [super textRectForBounds:bounds];
//    inset.origin.x += 3;
//    inset.size.width -= 3;
//    FLog(@"inset field", inset);
//    return inset;
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
