//
//  MysticTipView.m
//  Mystic
//
//  Created by Travis A. Weerts on 5/27/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticTipView.h"
#import "MysticUser.h"

@implementation MysticTipsView


- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event;
{
    for (UIView *sub in self.subviews) {
        if(![sub isKindOfClass:MysticTipView.class]) continue;
        UIEdgeInsets hitInsets = UIEdgeInsetsMakeFrom(1);
        if(CGRectContainsPoint(CGRectMake(sub.frame.origin.x +hitInsets.left,
                                          sub.frame.origin.y +hitInsets.top,
                                          sub.frame.size.width + (hitInsets.left*-1) + (hitInsets.right*-1),
                                          sub.frame.size.height + (hitInsets.top*-1) + (hitInsets.bottom*-1)), point)) return YES;
        
    }
    
    
    return NO;
}

@end
@implementation MysticTipViewManager

+ (instancetype) manager;
{
    static dispatch_once_t pred;
    static MysticTipViewManager *manager = nil;
    
    dispatch_once(&pred, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}
+ (void) resetTips;
{
    [[MysticTipViewManager manager].tipsShown removeAllObjects];
    [MysticUser set:@{} key:@"tips-shown"];
}
+ (BOOL) tipHasBeenShown:(id)key;
{
    return key && [[MysticTipViewManager manager].tipsShown objectForKey:key] != nil;
}
+ (void) hideLast;
{
    [self hideLast:NO];
}
+ (void) hideLast:(BOOL)animated;
{
    id lastKey = [MysticTipViewManager manager].tipsOrder.lastObject;
    [self hide:lastKey animated:animated];

}

+ (void) hide:(id)key;
{
    MysticTipView *tip = [self tip:key];
    [tip hide:tip.animated];

}
+ (void) hide:(id)key animated:(BOOL)animated;
{
    MysticTipView *tip = [self tip:key];
    [tip hide:animated];
}
+ (void) hideAll;
{
    [self hideAll:NO];
}
+ (void) hideAll:(BOOL)animated;
{
    [self hideAll:animated except:nil];
}
+ (void) hideAll:(BOOL)animated except:(id)exceptions;
{
    BOOL foundException = NO;
    exceptions = !exceptions || [exceptions isKindOfClass:[NSArray class]] ? exceptions : @[exceptions];
    NSMutableArray *tips = [NSMutableArray arrayWithArray:[MysticTipViewManager manager].tipsOrder];
    if(!animated) { ((MysticTipViewManager *)[self manager]).tipsView.hidden = YES; }
    for (id key in tips) {
        if([exceptions containsObject:key]) { foundException = YES; continue; }
        [self hide:key animated:animated];
    }
    if(foundException) ((MysticTipViewManager *)[self manager]).tipsView.hidden = NO;
    if(((MysticTipViewManager *)[self manager]).tipsView.hidden)
    {
        [((MysticTipViewManager *)[self manager]).tipsView removeFromSuperview];
        ((MysticTipViewManager *)[self manager]).tipsView = nil;
    }
}
+ (MysticTipView *) lastTip;
{
    id lastKey = [MysticTipViewManager manager].tipsOrder.lastObject;
    return [self tip:lastKey];
}
+ (void) removeLastTip;
{
    id lastKey = [MysticTipViewManager manager].tipsOrder.lastObject;
    [self remove:lastKey];
}
+ (id) tip:(id)key;
{
    if(!key) return nil;
    return [[MysticTipViewManager manager].tips objectForKey:key];
}
+ (id) remove:(MysticTipView *)tip;
{
    if(!tip) return nil;
    [self set:[tip isKindOfClass:[MysticTipView class]] ? tip.key : tip tip:nil];
    return tip;
}
+ (id) add:(MysticTipView *)tip;
{
    return [self set:tip.key tip:tip];
}
+ (id) set:(id)key tip:(MysticTipView *)tip;
{
    if(!key) return nil;
    if(!tip)
    {
        [[MysticTipViewManager manager].tipsOrder removeObject:key];
        [[MysticTipViewManager manager].tips removeObjectForKey:key];
        return nil;
    }
    [[MysticTipViewManager manager].tipsShown setObject:@YES forKey:key];
    [[MysticTipViewManager manager].tipsOrder addObject:key];
    [[MysticTipViewManager manager].tips setObject:tip forKey:key];
    NSDictionary *userTips = [MysticUser get:@"tips-shown"];
    NSMutableDictionary *newTipsShown = [NSMutableDictionary dictionaryWithDictionary:userTips ? userTips : @{}];
    [newTipsShown setObject:@YES forKey:key];
    [MysticUser set:newTipsShown key:@"tips-shown"];
    return tip;
}
- (instancetype) init;
{
    self = [super init];
    if(!self) return nil;
    self.tips = [NSMutableDictionary dictionary];
    NSDictionary *userTips = [MysticUser get:@"tips-shown"];
    self.tipsShown = [NSMutableDictionary dictionaryWithDictionary:userTips ? userTips : @{}];
    self.tipsOrder = [NSMutableArray array];
    return self;
}

@end

@interface MysticTipView ()
@property (nonatomic, strong) NSTimer *autoHideTimer;
@property (nonatomic, assign) BOOL setObserver;
@end
@implementation MysticTipView
+ (BOOL) tip:(NSString *)key inView:(UIView *)view targetView:(UIView *)targetView offsetArrow:(CGPoint)offset hideAfter:(NSTimeInterval)hideAfter delay:(NSTimeInterval)delay animated:(BOOL)animated;
{
    NSDictionary *tipsData = [[[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"tips.plist"]] objectForKey:@"tips"] objectForKey:key];
    if(!tipsData) return NO;
    MysticTipView *tip = nil;
    id title = tipsData[@"title"];
    id message = tipsData[@"message"];
    [MysticTipViewManager hide:key animated:NO];
    if((title || message) && [MysticUser showTips] && ![MysticTipViewManager tipHasBeenShown:key])
    {
        [MysticTipViewManager hideAll];
        tip = [MysticTipView tipWithTitle:title message:message point:CGPointUnknown];
        tip.key = key;
        if(targetView && view) {
            tip.container = [targetView containerOfSuperview:view];
            tip.arrowOffset = offset;
            
            if(![MysticTipViewManager manager].tipsView)
            {
                [MysticTipViewManager manager].tipsView = [[MysticTipsView alloc] initWithFrame:view.bounds];
                [view addSubview:[MysticTipViewManager manager].tipsView];
            }
            [view bringSubviewToFront:[MysticTipViewManager manager].tipsView];
            [MysticTipViewManager manager].tipsView.hidden = NO;
            [[MysticTipViewManager manager].tipsView addSubview:tip];
            tip.targetView = targetView;
            tip.animated = animated;
            [tip setNeedsLayout];
            if(animated)
            {
                tip.alpha = 0;
                tip.transform = CGAffineTransformMakeTranslation(0, -15);
                [MysticUIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
                    tip.alpha = 1;
                    tip.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    tip.autoHideAfter = hideAfter;
                }];
            }
        }
    }
    return tip != nil;
}
+ (instancetype) tip:(NSString *)key inView:(UIView *)view targetView:(UIView *)targetView hideAfter:(NSTimeInterval)hideAfter delay:(NSTimeInterval)delay animated:(BOOL)animated;
{
    NSDictionary *tipsData = [[[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"tips.plist"]] objectForKey:@"tips"] objectForKey:key];
    if(!tipsData) return nil;
    MysticTipView *tip = nil;
    id title = tipsData[@"title"];
    id message = tipsData[@"message"];
    [MysticTipViewManager hide:key animated:NO];
    if((title || message) && [MysticUser showTips] && ![MysticTipViewManager tipHasBeenShown:key])
    {
        [MysticTipViewManager hide:key animated:NO];
        tip = [MysticTipView tipWithTitle:title message:message point:CGPointUnknown];
        tip.key = key;
        if(targetView && view) {
            tip.container = [targetView containerOfSuperview:view];
            if(![MysticTipViewManager manager].tipsView)
            {
                [MysticTipViewManager manager].tipsView = [[MysticTipsView alloc] initWithFrame:view.bounds];
                [view addSubview:[MysticTipViewManager manager].tipsView];
            }
            [view bringSubviewToFront:[MysticTipViewManager manager].tipsView];
            [MysticTipViewManager manager].tipsView.hidden = NO;
            [[MysticTipViewManager manager].tipsView addSubview:tip];
            tip.targetView = targetView;
            tip.animated = animated;
            [tip setNeedsLayout];
            if(animated)
            {
                tip.alpha = 0;
                tip.transform = CGAffineTransformMakeTranslation(0, -15);
                [MysticUIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
                    tip.alpha = 1;
                    tip.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    tip.autoHideAfter = hideAfter;
                }];
            }
        }
    }
    return tip;
}
+ (instancetype) tip:(NSString *)title message:(NSAttributedString *)message inView:(UIView *)view targetView:(UIView *)targetView;
{
    MysticTipView *tip = nil;
    if((title || message) && [MysticUser showTips])
    {
        CGPoint point = targetView && view ? [view convertPoint:targetView.center fromView:targetView] : CGPointUnknown;
        tip = [MysticTipView tipWithTitle:title message:message point:point];
        if(targetView && view) {
            tip.container = [targetView containerOfSuperview:view];
            tip.center = CGPointY(point, point.y - targetView.frame.size.height/2 - 7 - tip.arrowHeight);
            [view addSubview:tip];
            tip.targetView = targetView;
        }
    }
    return tip;
}
+ (instancetype) tipWithTitle:(NSString *)title message:(NSAttributedString *)message point:(CGPoint)point;
{
    MysticTipView *tip = [[MysticTipView alloc] initWithFrame:(CGRect){0,0,100,50}];
    tip.title = title;
    tip.message = message;
    tip.point = point;
    return tip;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(!self) return nil;
    return [self commonInit];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(!self) return nil;
    return [self commonInit];
}
- (id) commonInit;
{
    MysticBlurBackgroundView *bg = [[MysticBlurBackgroundView alloc] initWithFrame:self.bounds];
    bg.backgroundColorAlpha = 1;
    bg.backgroundColor = [UIColor color:MysticColorTypePink];
    [self addSubview:bg];
    self.backgroundView = bg;
    self.arrowHeight = 8;
    self.hideOnTouch = YES;
    self.setObserver = NO;
    self.arrowOffset = CGPointZero;
    self.offset = CGPointZero;
//    MBorder(self, [UIColor.whiteColor colorWithAlphaComponent:0.3], 1);
    return self;
}
- (void) setKey:(NSString *)key;
{
    _key = key;
    [MysticTipViewManager add:self];
}
- (void) setAutoHideAfter:(NSTimeInterval)autoHideAfter;
{
    _autoHideAfter = autoHideAfter;
    if(self.autoHideTimer)
    {
        [self.autoHideTimer invalidate];
        self.autoHideTimer = nil;
    }
    if(autoHideAfter > 0)
    {
        NSTimer *timer = [NSTimer timerWithTimeInterval:autoHideAfter target:self selector:@selector(hide) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        self.autoHideTimer = timer;
    }
    
}
- (void) hide;
{
    [self hide:self.animated];
}
- (void) hide:(BOOL)animated;
{
    if(self.autoHideAfter)
    {
        [self.autoHideTimer invalidate];
        self.autoHideTimer = nil;
    }
    if(animated)
    {
        [MysticUIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    else [self removeFromSuperview];
    
}
- (void) removeFromSuperview;
{
    [MysticTipViewManager remove:self];
    if(self.setObserver) { [self.container removeObserver:self forKeyPath:@"frame"]; }
    self.setObserver=NO;
    [super removeFromSuperview];
    
}
- (void) setArrowHeight:(CGFloat)arrowHeight;
{
    _arrowHeight = arrowHeight;
    [self setNeedsLayout];
}
- (void) setTargetView:(UIView *)targetView;
{
    _targetView = targetView;
    if(!_targetView) { [self.container removeObserver:self forKeyPath:@"frame"]; self.setObserver = NO; }
    else if(self.superview && self.container && ![self.container isKindOfClass:[MysticToolbar class]]) {
        [self.container addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        self.setObserver = YES;
    }
}
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context;
{
    if([keyPath isEqualToString:@"frame"]) [self reposition];
}
- (void) reposition;
{
    if(!self.superview || !self.container || !self.targetView) return;
    CGRect newFrame = self.frame;
    
    CGPoint point = [self.container.superview convertPoint:self.targetView.center fromView:self.targetView.superview];
    point = CGPointY(point, point.y - self.targetView.frame.size.height/2 - 7 - self.arrowHeight);
    point = CGPointMake(point.x - newFrame.size.width/2, point.y - newFrame.size.height/2);
    newFrame.origin = point;
    MysticPosition pos = MysticPositionUnknown;
    MysticPosition pos2 = MysticPositionUnknown;
    MysticPosition finalpos = MysticPositionUnknown;
    MysticPosition arrowpos = MysticPositionUnknown;
    
    if(newFrame.origin.x < 0) pos = MysticPositionLeft;
    if(newFrame.origin.x + newFrame.size.width > self.superview.frame.size.width) pos = MysticPositionRight;
    if(newFrame.origin.y < 0) pos2 = MysticPositionTop;
    if(newFrame.origin.y + newFrame.size.height > self.superview.frame.origin.y + self.superview.frame.size.height)
        pos2 = MysticPositionBottom;
    
    finalpos = pos != MysticPositionUnknown ? pos : pos2;
    if(finalpos != MysticPositionUnknown)
    {
        if(pos2 == MysticPositionTop)
            finalpos = finalpos == MysticPositionLeft ? MysticPositionTopLeft : MysticPositionTopRight;
        else if(pos2 == MysticPositionBottom)
            finalpos = finalpos == MysticPositionLeft ? MysticPositionBottomLeft : MysticPositionBottomRight;
        else finalpos = pos;
    }
    
    switch (self.position) {
        case MysticPositionLeft:
        case MysticPositionTopLeft:
        case MysticPositionBottomLeft:
            newFrame.origin.x = 15;
            break;
        case MysticPositionRight:
        case MysticPositionTopRight:
        case MysticPositionBottomRight:
            newFrame.origin.x = 15;
            break;
        default:
            break;
    }
    switch (self.position) {
        case MysticPositionTopLeft:
        case MysticPositionTopRight:
            newFrame.origin.y = 15;
            break;
        case MysticPositionBottomLeft:
        case MysticPositionBottomRight:
            newFrame.origin.y = self.superview.frame.origin.y + self.superview.frame.size.height - newFrame.size.height - 15;
            break;
        default:
            break;
    }
    newFrame.origin.x += self.offset.x;
    newFrame.origin.y += self.offset.y + self.arrowOffset.y;
    [self setFrame:newFrame force:YES];
    
}
- (void) setFrame:(CGRect)frame;
{
    [self setFrame:frame force:NO];
}
- (void) setFrame:(CGRect)frame force:(BOOL)force;
{
    CGSize size = self.frame.size;
    [super setFrame:frame];
    self.backgroundView.frame = self.bounds;
    if(CGSizeEqualToSize(size, frame.size) && self.layer.mask && !force) return;
    [self drawMask];
}
- (void) drawMask;
{
    CGPoint point = [self.container.superview convertPoint:self.targetView.center fromView:self.targetView.superview];
    point = CGPointY(point, point.y - self.targetView.frame.size.height/2 - 7 - self.arrowHeight);
    
    CGPoint point2 = [self convertPoint:point fromView:self.container.superview];
    CGFloat triangleHeight = self.arrowHeight;

    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectXH(self.bounds, 0, self.bounds.size.height-triangleHeight) cornerRadius:6];
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    point2.x += self.arrowOffset.x;
    point2.y += self.arrowOffset.y;
    [triangle moveToPoint:CGPointMake(point2.x - triangleHeight, self.bounds.size.height-triangleHeight)];
    [triangle addLineToPoint:CGPointMake(point2.x + triangleHeight, self.bounds.size.height-triangleHeight)];
    [triangle addLineToPoint:CGPointMake(point2.x, self.bounds.size.height)];
    [triangle closePath];
    [maskPath appendPath:triangle];
    maskLayer.path = maskPath.CGPath;
    self.backgroundView.layer.mask = maskLayer;
}
- (void) setTitle:(NSString *)title;
{
    if(!self.titleLabel)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectXYH(self.bounds,0,0,40)];
        [self addSubview:label];
        self.titleLabel = label;
    }
    if(!title || title.length < 1) {
        [self.titleLabel removeFromSuperview];
        self.titleLabel = nil;
        return;
    }
    title = [title isKindOfClass:[NSString class]] ? NSLocalizedString(title, nil) : title;
    self.titleLabel.attributedText = [[MysticAttrString string:title style:MysticStringStyleTipTitle] attrString];
    [self.titleLabel sizeToFit];
    [self setNeedsLayout];
}
- (void) setMessage:(NSAttributedString *)message;
{
    if(!self.messageLabel)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectXYH(self.bounds,0,0,40)];
        [self addSubview:label];
        self.messageLabel = label;
    }
    if(!message || message.length < 1) {
        [self.messageLabel removeFromSuperview];
        self.messageLabel = nil;
        return;
    }
    message = (NSAttributedString *)([message isKindOfClass:[NSString class]] ? NSLocalizedString((NSString *)message, nil) : message);

    self.messageLabel.attributedText = [message isKindOfClass:[NSAttributedString class]] ? message : [[MysticAttrString string:(id)message style:MysticStringStyleTipMessage] attrString];
    [self.messageLabel sizeToFit];
    [self setNeedsLayout];
}
- (void) layoutSubviews;
{
    CGSize size = self.titleLabel.frame.size;
    CGFloat messagePadding = 5;
    if(self.messageLabel)
    {
        size.height += self.messageLabel.frame.size.height + messagePadding;
        size.width = MAX(size.width, self.messageLabel.frame.size.width);
    }
    size.height += self.arrowHeight;
    CGRect newFrame = CGRectZero;
    newFrame.size = size;
    newFrame = CGRectInset(newFrame, -10, -10);
    newFrame.origin = CGPointZero;
    
    CGPoint point = [self.container.superview convertPoint:self.targetView.center fromView:self.targetView.superview];
    point = CGPointY(point, point.y - self.targetView.frame.size.height/2 - 7 - self.arrowHeight);
    point = CGPointMake(point.x - newFrame.size.width/2, point.y - newFrame.size.height/2);
    newFrame.origin = point;
    MysticPosition pos = MysticPositionUnknown;
    MysticPosition pos2 = MysticPositionUnknown;
    MysticPosition finalpos = MysticPositionUnknown;
    MysticPosition arrowpos = MysticPositionUnknown;
    if(newFrame.origin.x < 0) pos = MysticPositionLeft;
    if(newFrame.origin.x + newFrame.size.width > self.superview.frame.size.width) pos = MysticPositionRight;
    if(newFrame.origin.y < 0) pos2 = MysticPositionTop;
    if(newFrame.origin.y + newFrame.size.height > self.superview.frame.origin.y + self.superview.frame.size.height)
        pos2 = MysticPositionBottom;
    
    finalpos = pos != MysticPositionUnknown ? pos : pos2;
    if(finalpos != MysticPositionUnknown)
    {
        if(pos2 == MysticPositionTop)
            finalpos = finalpos == MysticPositionLeft ? MysticPositionTopLeft : MysticPositionTopRight;
        else if(pos2 == MysticPositionBottom)
            finalpos = finalpos == MysticPositionLeft ? MysticPositionBottomLeft : MysticPositionBottomRight;
        else finalpos = pos;
    }
    
    switch (finalpos) {
        case MysticPositionTopLeft: arrowpos = MysticPositionBottomLeft; break;
        case MysticPositionTopRight: arrowpos = MysticPositionBottomRight; break;
        case MysticPositionBottomLeft: arrowpos = MysticPositionTopLeft; break;
        case MysticPositionBottomRight: arrowpos = MysticPositionTopRight; break;
        default: arrowpos = MysticPositionCenter; finalpos = finalpos == MysticPositionUnknown ? MysticPositionCenter : pos; break;
    }
    self.position = finalpos;
    self.arrowPosition = arrowpos;
    
//    DLog(@"tip position:  '%@'  %@   %@   arrow: %@", self.key, f(newFrame), MysticPositionStr(self.position), MysticPositionStr(self.arrowPosition));
    
    switch (self.position) {
        case MysticPositionLeft:
        case MysticPositionTopLeft:
        case MysticPositionBottomLeft:
            newFrame.origin.x = 15;
            break;
        case MysticPositionRight:
        case MysticPositionTopRight:
        case MysticPositionBottomRight:
            newFrame.origin.x = 15;
            break;
        default:
            break;
    }
    switch (self.position) {
        case MysticPositionTopLeft:
        case MysticPositionTopRight:
            newFrame.origin.y = 15;
            break;
        case MysticPositionBottomLeft:
        case MysticPositionBottomRight:
            newFrame.origin.y = self.superview.frame.origin.y + self.superview.frame.size.height - newFrame.size.height - 15;
            break;
        default:
            break;
    }
    newFrame.origin.x += self.offset.x;
    newFrame.origin.y += self.offset.y+ self.arrowOffset.y;
    [self setFrame:newFrame force:YES];
//    [self reposition];
    self.titleLabel.center = CGPointMake(self.bounds.size.width/2, 10+self.titleLabel.frame.size.height/2);
    if(self.messageLabel)
    {
        self.messageLabel.frame = CGRectXY(self.messageLabel.frame, (self.bounds.size.width - self.messageLabel.frame.size.width)/2, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + messagePadding);
    }

    
}
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    if(!self.hideOnTouch) return;
    [MysticTipViewManager hide:self.key animated:YES];
}
@end

