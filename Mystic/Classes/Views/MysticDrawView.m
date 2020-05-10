//
//  MysticDrawView.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/27/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticDrawView.h"
#import "MysticShapesKit.h"
#import "MysticLayerBaseView.h"
#import "MysticDrawLayerView.h"

@implementation MysticDrawView

- (void) dealloc;
{
    [super dealloc];
    Block_release(_drawBlock);
    [_choice release], _choice=nil;
    _layerView = nil;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];    
    if(self)
    {
        self.opaque = NO;
        self.shouldDraw = YES;
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    if(self.drawBlock && self.shouldDraw) self.drawBlock(UIGraphicsGetCurrentContext(), rect, rect, self);
}

- (void) setChoice:(MysticChoice *)choice;
{
    if(choice) [choice retain];
    if(_choice) [_choice release], _choice=nil;
    _choice = !choice ? nil : choice;
    if(_choice && !self.drawBlock)
    {
        __unsafe_unretained __block MysticDrawView *weakSelf = self;
        self.drawBlock = _choice.usesCustomDrawing ? ^(CGContextRef context, CGRect rect, CGRect bounds, UIView *view)
        {
            [[[MysticShapesKit kit] class] draw:weakSelf.choice frame:weakSelf.choice.frame];
            
        } : ^(CGContextRef context, CGRect rect, CGRect bounds, UIView *view)
        {
            UIImage *img = [weakSelf.layerView.drawView contentImage:rect.size];
            if(img) [MysticIcon draw:img color:weakSelf.layerView.choice.color highlight:nil rect:CGRectWithContentMode(rect, bounds, weakSelf.layerView.choice.contentMode) bounds:bounds context:context];
        };

    }
}


@end
