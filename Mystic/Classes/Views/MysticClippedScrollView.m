//
//  MysticClippedScrollView.m
//  Mystic
//
//  Created by travis weerts on 3/10/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticClippedScrollView.h"
#import "SubBarButton.h"

@interface MysticClippedScrollView ()
{
    NSMutableArray *buttons;
}
@end

@implementation MysticClippedScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        buttons = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event { return YES; }
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    
    UIView *hitView = [super hitTest:point withEvent:event];
    if (nil != hitView) {
//        if([hitView isKindOfClass:[SubBarButton class]])
//        {
////            SubBarButton *subview = (SubBarButton *)hitView;
////            DLog(@"scrollhit view: %@", MysticObjectTypeToString(subview.type));
//        }
////        DLog(@"scrollhit view: %@",hitView);
        return hitView;
    }
    return nil;
}

- (void) addSubview:(UIView *)view
{
    if([view isKindOfClass:[UIButton class]] && ![buttons containsObject:view])
    {
        [buttons addObject:view];
    }
    [super addSubview:view];
    
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
