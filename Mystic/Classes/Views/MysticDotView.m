//
//  MysticDotView.m
//  Mystic
//
//  Created by travis weerts on 8/8/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticDotView.h"
#import "MysticUtility.h"
#import <QuartzCore/QuartzCore.h>

@implementation MysticDotView
+ (id) dot:(CGPoint)point color:(MysticColorType)colorType size:(CGFloat)size;
{
    return [[[[self class] alloc] initWithPoint:point color:colorType size:size] autorelease];
}
+ (id) dot:(CGPoint)point color:(MysticColorType)colorType size:(CGFloat)size borderWidth:(CGFloat)borderWidth;
{
    return [[[[self class] alloc] initWithPoint:point color:[MysticColor colorWithType:colorType] size:size borderWidth:borderWidth] autorelease];
}
- (id)initWithPoint:(CGPoint)point;
{
    return [self initWithPoint:point color:MysticColorTypeBlue];
    
}
- (id)initWithPoint:(CGPoint)point color:(MysticColorType)colorType;
{
    return [self initWithPoint:point color:colorType size:10];
}
- (id)initWithPoint:(CGPoint)point color:(MysticColorType)colorType size:(CGFloat)size;
{
    return [self initWithPoint:point color:[MysticColor colorWithType:colorType] size:size borderWidth:3];
}
- (id)initWithPoint:(CGPoint)point color:(UIColor *)colorType size:(CGFloat)size borderWidth:(CGFloat)borderWidth;
{
    CGRect frme = CGRectZero;
    frme.size = CGSizeMake(size+(borderWidth*2), size+(borderWidth*2));
    point.x -= frme.size.width/2;
    point.y -= frme.size.height/2;
    frme.origin = point;
    return [self initWithFrame:frme color:colorType borderWidth:borderWidth];

}
- (id)initWithFrame:(CGRect)frame color:(UIColor *)color;
{
    return [self initWithFrame:frame color:color borderWidth:3];
}

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color borderWidth:(CGFloat)borderWidth;
{
    
    
    
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = frame.size.height/2;
        self.backgroundColor = color;
        self.layer.borderColor = [UIColor mysticWhiteColor].CGColor;
        self.layer.borderWidth = borderWidth;
        self.userInteractionEnabled = NO;
        self.hitInsets = UIEdgeInsetsZero;
        //        self.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
        //        self.layer.shadowOffset = CGSizeMake(2, 2);
    }
    
    return self;
}
- (id) connectTo:(MysticDotView *)otherDot color:(id)color;
{
    MysticDotConnectionView *v = [MysticDotConnectionView connect:self to:otherDot color:color];
    [self.superview addSubview:v];
    [self sendAbove:v];
    [otherDot sendAbove:v];
    [v setNeedsDisplay];
    
    return v;
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
@interface MysticDotConnectionView (){
    
}
@property (nonatomic, readonly) BOOL hasBothDots;
@end
@implementation MysticDotConnectionView


+ (id) connect:(MysticDotView *)dot1 to:(MysticDotView *)dot2 color:(id)color;
{
    CGRect r = CGPointDiffRect(dot1.center, dot2.center);
    MysticDotConnectionView *d = [[MysticDotConnectionView alloc] initWithDot:dot1 toDot:dot2];
    d.dot1 = dot1;
    d.dot2 = dot2;
    if(color) d.layer.borderColor = [MysticColor color:color].CGColor;
    return [d autorelease];
}
- (void) dealloc;
{
    [self.dot1 removeObserver:self forKeyPath:@"center"];
    [self.dot2 removeObserver:self forKeyPath:@"center"];

    [super dealloc];
}
- (id) initWithDot:(MysticDotView *)dot1 toDot:(MysticDotView *)dot2;
{
    CGRect frame = CGPointDiffRect(dot1.center, dot2.center);
    self = [super initWithFrame:frame];
    if(!self) return nil;
    
    [self setup];
    self.dot1 = dot1;
    self.dot2 = dot2;
    return self;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(!self) return nil;
    [self setup];
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(!self) return nil;
    [self setup];
    return self;
}
- (void) setDot1:(MysticDotView *)v;
{
    if(_dot1) [_dot1 removeObserver:self forKeyPath:@"center"];
    _dot1 = v;
    if(v) [_dot1 addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
    [self updateFrame];
}
- (void) setDot2:(MysticDotView *)v;
{
    if(_dot2) [_dot2 removeObserver:self forKeyPath:@"center"];
    _dot2 = v;
    if(v) [_dot2 addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
    [self updateFrame];
}
- (void) setup;
{
    self.opaque = NO;
    self.backgroundColor = UIColor.clearColor;
    self.layer.borderWidth = 0;
    self.layer.borderColor = UIColor.whiteColor.CGColor;
//    if(self.dot1) [self.dot1 addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
//    if(self.dot2) [self.dot2 addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
}
- (BOOL) hasBothDots; { return _dot1 && _dot2; }
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context;
{
//    DLog(@"observed:  %@   change:  %@", [object isEqual:_dot1] ? @"dot1" : @"dot2", change);
    if(!self.hasBothDots) return;
    self.frame = CGPointDiffRect(self.dot1.center, self.dot2.center);
    [self setNeedsDisplay];
}
- (void) updateFrame;
{
    if(self.hasBothDots) self.frame = CGPointDiffRect(self.dot1.center, self.dot2.center);
    

    [self setNeedsDisplay];
}
- (void) setFrame:(CGRect)cf;
{
    cf.size.width = MAX(2, cf.size.width);
    cf.size.height = MAX(2, cf.size.height);
    cf.size = CGSizeSquareBig(cf.size);
    
    [super setFrame:cf];
    self.center = CGPointMidPoint(self.dot1.center, self.dot2.center);

}
- (void)drawRect:(CGRect)nrect
{
    if(!self.hasBothDots) return;
    CGRect rect = CGPointDiffRect(self.dot1.center, self.dot2.center);
    rect = CGRectFit(rect, nrect);
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    
    CGContextSetLineWidth(context, 2);
    [[UIColor colorWithCGColor:self.layer.borderColor] set];
    CGContextStrokePath(context);
    
    
}

@end
