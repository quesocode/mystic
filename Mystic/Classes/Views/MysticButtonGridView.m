//
//  MysticButtonGridView.m
//  Mystic
//
//  Created by travis weerts on 6/24/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticButtonGridView.h"
#import "UIColor+Mystic.h"
#import "MysticUI.h"

@implementation MysticButtonGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor mysticGrayBackgroundColor];

    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.backgroundColor = [UIColor color:MysticColorTypeDrawerBackground];
    }
    return self;
}
- (void) commonInit;
{
    self.backgroundColor = [UIColor color:MysticColorTypeDrawerBackground];
    self.borderColor = [UIColor color:MysticColorTypeDrawerBackgroundCellBorder];
    self.borderWidth = 3;
    self.numberOfDivisions = 3;
    self.borderPosition = MysticPositionCenter|MysticPositionVerticalDivisions;
    
    self.showBorder = YES;
    
}
//
//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    [self.backgroundColor setFill];
//    
//    CGContextFillRect(context, rect);
//    
//    
//        CGRect newRect = CGRectMake(0, (rect.size.height/2)-1.0f, rect.size.width, 2.0f);
//    CGRect newRect2 = CGRectMake(ceilf((rect.size.width - 4)/3), 0, 2.0f, rect.size.height);
//    CGRect newRect3 = CGRectMake(ceilf(((rect.size.width - 4)/3)*2), 0, 2.0f, rect.size.height);
//    if ((int)newRect2.origin.x % 2) {
//        newRect2.origin.x -= 1;
//    }
//    if ((int)newRect3.origin.x % 2) {
//        newRect3.origin.x -= 1;
//    }
////    CGContextSaveGState(context);
////    
////    CGContextClipToRect(context, newRect);
//    
//    
//    [[UIColor color:MysticColorTypeDrawerBorder] setFill];
//    
//    
//    CGContextFillRect(context, CGRectMake(0, rect.size.height/2, <#CGFloat width#>, <#CGFloat height#>));
//
//    
////    CGContextDrawTiledImage(context, CGRectMake(0,0, 6, 2.0f), [UIImage imageNamed:@"dottedTileDark.png"].CGImage);
//
////    CGContextRestoreGState(context);
////    CGContextSaveGState(context);
//    
////    CGContextClipToRect(context, newRect2);
//    
////    CGContextDrawTiledImage(context, CGRectMake(0,0, 2.0f, 6.0f), [UIImage imageNamed:@"dottedTileDarkVert.png"].CGImage);
//    
//    
////    CGContextRestoreGState(context);
//
////    CGContextClipToRect(context, newRect3);
//    
//    
////    CGContextDrawTiledImage(context, CGRectMake(0,0, 2.0f, 6.0f), [UIImage imageNamed:@"dottedTileDarkVert.png"].CGImage);
//    
//    
//    
//    
//    
//    
//    
//    
//}

@end
