//
//  MysticPointColorBtn.m
//  Mystic
//
//  Created by Travis A. Weerts on 3/31/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticPointColorBtn.h"
#import "UIColor+Mystic.h"
#import "MysticTypedefs.h"
#import "MysticUtility.h"

@interface MysticPointColorBtn ()

@property (nonatomic, assign) UIView *color2View;
@property (nonatomic, assign) CGSize _size;
@end
@implementation MysticPointColorBtn

@synthesize point=_point;
+ (instancetype) color:(id)color point:(CGPoint)point size:(CGSize)size index:(int)index action:(MysticBlockSender)action;
{
    MysticPointColorBtn *p = [[self class] button:nil action:action];
    p.point = point;
    p.size = size;
    p.color = color;
    p.index = index;
    return p;
}
- (void) commonInit;
{
    [super commonInit];
    __size = CGSizeZero;
    _point = CGPointUnknown;
    self.layer.cornerRadius = CGRectH(self.frame)/2;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2;
    self.clipsToBounds = YES;
    self.canSelect=YES;
}
- (NSInteger) index; { return (self.tag - MysticViewTypeEyeDropper); }
- (void) setIndex:(NSInteger)i;
{
    self.tag = MysticViewTypeEyeDropper + (MAX(0,MIN(INT_MAX,i==NSNotFound?0:i)));
}
- (CGSize) size; { return self.frame.size; }
- (void) setSize:(CGSize)size;
{
    [super setFrame:CGRectSize(CGSizeSquare(size))];
    self.center = self.point;
    self.layer.cornerRadius = CGRectH(self.frame)/2;
    if(CGSizeIsZero(__size)) __size = size;
    [self setNeedsDisplay];
}
- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    self.center = self.point;
    self.layer.cornerRadius = CGRectH(frame)/2;

}
- (CGPoint) point; { return CGPointIsUnknown(_point) ? self.center : _point; }
- (void) setPoint:(CGPoint)point;
{
    _point = point;
    self.center = point;
}
- (UIColor *) color; { return self.backgroundColor; }
- (void) setColor:(UIColor *)color;
{
    if(isNullOr(color)==nil) return;
    self.backgroundColor = [MysticColor color:color];
    [self setNeedsDisplay];
}
- (void) setColor2:(UIColor *)cc;
{
    if(isNullOr(cc)==nil) return;
    if(_color2) [_color2 release],_color2=nil;
    if(cc) _color2 = [[cc alpha:1] retain];
    [self setNeedsDisplay];
}
- (void) setSelected:(BOOL)selected;
{
    [super setSelected:selected];
    self.alpha=1;
    self.layer.borderWidth = selected ? 3 : 1;
//    self.layer.borderColor = selected ? [UIColor whiteColor].CGColor : self.color.CGColor;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

//    CGColorRef cf = CGColorCreateCopyWithAlpha(self.layer.borderColor, selected ? 1.0 : 0.5);
//    self.layer.borderColor = cf;
//    CGColorRelease(cf);
//    if(selected)
//    {
//        self.layer.borderColor = [UIColor whiteColor].CGColor;
//        CGColorRef cf = CGColorCreateCopyWithAlpha(self.layer.borderColor, selected ? 1.0 : 0.2);
//        self.layer.borderColor = cf;
//        CGColorRelease(cf);
//
//    }
//    else self.layer.borderColor = nil;
    
}
- (void) setFocus:(int)focus;
{
    _focus = focus;
    switch (focus) {
        case -1:
            self.transform = CGAffineTransformMakeScale(0.5, 0.5);
            break;
        case 1:
            self.transform = CGAffineTransformMakeScale(1.5, 1.5); 
            break;
        case 2:
            self.transform = CGAffineTransformMakeScale(2, 2);
            break;
        case 3:
            self.transform = CGAffineTransformMakeScale(2.75, 2.75);
            break;
        default:
            self.transform = CGAffineTransformIdentity;
            break;
    }
}
- (void) drawRect:(CGRect)rect;
{
    if(isNullOr(self.color2)==nil && isNullOr(self.backgroundColor)==nil) return;

    CGContextRef c = UIGraphicsGetCurrentContext();
    if(isNullOr(self.color2)==nil)
    {
        [self.backgroundColor setFill];
        CGContextFillRect(c, rect);
    }
    if(isNullOr(self.color2)==nil) return;
    CGFloat locs[3]={
        0.0f,
        .6f,
        1.f,
    };
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGGradientRef grad;
    
    NSArray *colors=[NSArray arrayWithObjects:
                     (id)[self.color2 CGColor],
                     (id)[self.backgroundColor CGColor],
                     (id)[self.backgroundColor CGColor],
                     nil];
    grad=CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locs);
    
    CGContextDrawLinearGradient(c, grad, CGPointMake(0,rect.size.height), CGPointMake(0, 0), 0);
    
    CGGradientRelease(grad);


    CGColorSpaceRelease(colorSpace);
}
@end
