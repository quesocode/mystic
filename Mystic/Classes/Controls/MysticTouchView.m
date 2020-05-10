//
//  MysticTouchView.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/26/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticTouchView.h"

@implementation MysticTouchView

@synthesize tap=_tap, doubleTap=_doubleTap;

- (void) dealloc;
{
    [super dealloc];
    Block_release(_touchBegan);
    Block_release(_touchCancelled);
    Block_release(_touchEnded);
    Block_release(_touchMoved);
    Block_release(_tap);
    Block_release(_doubleTap);

}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) setTap:(MysticBlockTouchTap)tap;
{
    if(_tap) Block_release(_tap);
    _tap = tap ? Block_copy(tap) : nil;
    [self updateGestures];
}
- (void) setDoubleTap:(MysticBlockTouchDoubleTap)tap;
{
    if(_doubleTap) Block_release(_doubleTap);
    _doubleTap = tap ? Block_copy(tap) : nil;
    [self updateGestures];
}
- (void) updateGestures;
{
    UITapGestureRecognizer *doubleTapGesture = !self.doubleTap ? nil : [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    if(doubleTapGesture)
    {
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.cancelsTouchesInView = YES;
    }
    UITapGestureRecognizer *tapGesture = !self.tap ? nil : [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    if(tapGesture)
    {
        tapGesture.cancelsTouchesInView = YES;
        if(doubleTapGesture)
            [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
    }
    NSMutableArray *g = [NSMutableArray array];
    if(doubleTapGesture) [g addObject:doubleTapGesture];
    if(tapGesture) [g addObject:tapGesture];
    self.gestureRecognizers = g.count > 0 ? g : nil;
}
- (void) tapped:(UITapGestureRecognizer *)sender;
{
    self.startPoint = [sender locationInView:self];
    self.originalPoint = self.startPoint;
    self.currentPoint = self.startPoint;
    self.endPoint = self.startPoint;
    self.totalChangePoint = CGPointZero;
    self.changePoint = CGPointZero;
    if(self.tap)
    {
        self.tap(nil, nil, self);
    }
}
- (void) doubleTapped:(UITapGestureRecognizer *)sender;
{
    self.startPoint = [sender locationInView:self];
    self.originalPoint = self.startPoint;
    self.currentPoint = self.startPoint;
    self.endPoint = self.startPoint;
    self.totalChangePoint = CGPointZero;
    self.changePoint = CGPointZero;
    if(self.doubleTap)
    {
        self.doubleTap(nil, nil, self);
    }
}
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [super touchesBegan:touches withEvent:event];
    self.startPoint = [[touches anyObject] locationInView:self];
    self.originalPoint = self.startPoint;
    self.currentPoint = self.startPoint;
    self.endPoint = self.startPoint;
    self.totalChangePoint = CGPointZero;
    self.changePoint = CGPointZero;
    if(self.touchBegan)
    {
        self.touchBegan(touches, event, self);
    }
}
- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [super touchesEnded:touches withEvent:event];
    self.endPoint = [[touches anyObject] locationInView:self];
    self.currentPoint = self.endPoint;
    self.changePoint = CGPointDiff(self.startPoint, self.endPoint);
    self.totalChangePoint = CGPointDiff(self.originalPoint, self.endPoint);
    if(self.touchEnded) self.touchEnded(touches, event, self);
    

//    UITouch *touch = [touches anyObject];
//    DLog(@"double tap: %@  count: %d  changePoint: %@", MBOOL(self.doubleTap != nil), (int)touch.tapCount, PLogStr(self.totalChangePoint));
    
//    if(self.doubleTap && touch.tapCount == 2 && fabs(self.totalChangePoint.x) < 2  && fabs(self.totalChangePoint.y) < 2)
//    {
//        self.doubleTap(touch, event, self);
//    }
//    else if(self.tap && touch.tapCount == 1 && fabs(self.totalChangePoint.x) < 1.5 && fabs(self.totalChangePoint.y) < 1.5)
//    {
//        self.tap(touch, event, self);
//    }
}
- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [super touchesCancelled:touches withEvent:event];
    self.endPoint = [[touches anyObject] locationInView:self];
    self.currentPoint = self.endPoint;
    self.changePoint = CGPointDiff(self.startPoint, self.endPoint);
    self.totalChangePoint = CGPointDiff(self.originalPoint, self.endPoint);

    if(self.touchCancelled)
    {
        self.touchCancelled(touches, event, self);
    }
}
- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [super touchesMoved:touches withEvent:event];
    self.currentPoint = (CGPoint)[[touches anyObject] locationInView:self];
    self.changePoint = CGPointDiff(self.startPoint, self.currentPoint);
    self.totalChangePoint = CGPointDiff(self.originalPoint, self.currentPoint);
    self.startPoint = self.currentPoint;
    if(self.touchMoved)
    {
        self.touchMoved(touches, event, self);
    }
}

@end
