//
//  MysticGridView.m
//  Mystic
//
//  Created by travis weerts on 8/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "MysticGridView.h"

@implementation MysticGridView

@synthesize blockSize, rows, columns,   useSquares, centerBorderColor=_centerBorderColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        useSquares = YES;
        self.blockSize = (CGSize){40,40};
        self.borderWidth = 1;
//        self.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
        
        self.borderColor = [[UIColor hex:@"887C71"] colorWithAlphaComponent:1];

        
        
    }
    return self;
}

- (void) commonInit;
{
    [super commonInit];
    self.dashed = YES;
    self.borderPosition = MysticPositionCenter|MysticPositionCenterVertical;
    self.borderColor = [[UIColor hex:@"887C71"] colorWithAlphaComponent:1];

}
- (UIColor *) centerBorderColor;
{
    if(_centerBorderColor) return _centerBorderColor;
    return self.borderColor;
}
- (void) setRows:(NSInteger)value;
{
    rows = value;
    blockSize.height = ceilf(self.frame.size.height/rows);
    if(useSquares) blockSize.width = blockSize.height;

}
- (void) setColumns:(NSInteger)value;
{
    columns = value;
    blockSize.width = ceilf(self.frame.size.width/columns);
    if(useSquares) blockSize.height = blockSize.width;
}
- (void) setBlockSize:(CGSize)value
{
    blockSize = value;
    if(value.width != value.height) useSquares = NO;
    rows = ceil(self.frame.size.height/value.height);
    columns = ceil(self.frame.size.width/value.width);
}

//- (void) setBorderColor:(UIColor *)newColor;
//{
//    borderColor = newColor;
//}

//- (void) setBorderWidth:(CGFloat)value
//{
//    borderWidth = value;
//}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(self.backgroundColor)
    {
        [self.backgroundColor setFill];
        CGContextFillRect(context, rect);
    }
    
//    CGContextSaveGState(context);
    
    [super drawRect:rect];
    /*
    if(self.dashed)
    {
        CGFloat dashes[] = {self.dashSize.width,self.dashSize.height};
        CGContextSetLineDash(context, 0.0, dashes, 2);
    }
    
    int _rows = rows;
    int _columns = columns;
    
    if (_rows % 2)
    {
        // odd
        _rows++;
    }
    
    
    if (_columns % 2)
    {
        // odd
        _columns++;
    }
    
    
    CGContextSetLineWidth(context, self.borderWidth);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    
    
    NSInteger centerRowIntB = floor(_rows/2);
    NSInteger centerRowInt = centerRowIntB;
    
    
    
    CGFloat paddingY = ((_rows * blockSize.height) - rect.size.height) / 2;
    paddingY = paddingY > 0 ? -1 * paddingY : 0;
    

    CGPoint point = CGPointMake(0, paddingY);
    for (int r=0; r < _rows; r++) {

        if(point.y >= 1)
        {
            CGContextMoveToPoint(context, point.x, point.y);
            CGContextAddLineToPoint(context, rect.size.width, point.y);
            CGContextSetStrokeColorWithColor(context, (int)centerRowInt == r ? [self.centerBorderColor CGColor] : [self.borderColor CGColor]);
            CGContextStrokePath(context);
            
        }
        point.y += blockSize.height;
    }
	
//    CGFloat centerColumn = floorf((rect.size.width*0.5)/blockSize.width);
    
    NSInteger centerColumnIntB = floor(_columns/2);
    NSInteger centerColumnInt = centerColumnIntB;

    CGFloat paddingX = ((_columns * blockSize.width) - rect.size.width) / 2;
    paddingX = paddingX > 0 ? -1 * paddingX : 0;

    
    
    point = CGPointMake(paddingX, 0);

    for (int c=0; c < _columns; c++)
    {
        
        if(point.x >= 1)
        {
            CGContextMoveToPoint(context, point.x, point.y);
            CGContextAddLineToPoint(context, point.x, rect.size.height);
            CGContextSetStrokeColorWithColor(context, (int)centerColumnInt == c ? [self.centerBorderColor CGColor] : [self.borderColor CGColor]);
            CGContextStrokePath(context);
        }
        point.x += blockSize.width;
    }
    
    */
    
//    CGContextRestoreGState(context);
}





@end
