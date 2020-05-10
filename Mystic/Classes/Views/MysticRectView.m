//
//  MysticRectView.m
//  Mystic
//
//  Created by Travis A. Weerts on 11/16/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticRectView.h"
#import "MysticConstants.h"
#import "UIColor+Mystic.h"

@implementation MysticRectView

- (void) dealloc;
{
    [super dealloc];
    _fromView=nil;
    [_border release];
    [_color release];
    [_viewInfo release];
}
+ (id) viewWithFrame:(CGRect)frame border:(id)borderWidth color:(id)color;
{
    MysticRectView *view = [[[self class] alloc] initWithFrame:frame];
    view.originalFrame = frame;
    view.border = Border(borderWidth);
    view.color = color;
    MysticLayerRect *layer = (id)view.layer;
    layer.path = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    layer.lineDashPattern = view.border;
    layer.strokeColor = color ? [MysticColor color:color].CGColor : [UIColor red].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = view.border ? [[(NSArray *)view.border objectAtIndex:0] floatValue] : 1;
    return [view autorelease];
}

- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(!self) return nil;
    self.userInteractionEnabled = NO;
    return self;
}
- (BOOL) hasColor:(id)color;
{
    if(!self.color && !color) return YES;
    if(self.color && !color) return NO;
    return self.color && [[MysticColor color:self.color] isEqualToColor:[MysticColor color:color]];
}
- (NSString *) viewInfo; { return nil; }
- (NSString *) classString;
{
    if(_viewInfo)
    {
        return [NSString stringWithFormat:@"→ %@", _viewInfo];
    }
    return NSStringFromClass([self class]);
}
+ (Class) layerClass;
{
    return [MysticLayerRect class];
}
- (BOOL) ignoreLayerDebug; { return YES; }

@end

@implementation MysticLayerRect

- (NSString *)name; { return @"rect"; }

@end
