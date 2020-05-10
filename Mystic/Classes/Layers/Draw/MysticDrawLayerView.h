//
//  MysticDrawLayerView.h
//  Mystic
//
//  Created by Me on 12/15/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "MysticColor.h"
#import "MysticDrawingContext.h"

@class MysticLayerBaseView;

@interface MysticDrawLayerView : UIView
{
    MysticDrawingContext *_contextSizeContext;
    MysticDrawBlock _drawBlock;
}
@property (nonatomic, assign) CGRect boundingRect, backgroundRect, drawRect, rect, maskRect, maxBounds, drawRectScaled, renderRect;
@property (nonatomic, retain) MysticDrawingContext *actualContext;
@property (nonatomic, assign) MysticPosition alignPosition;
@property (nonatomic, assign) CGFloat minimumScaleFactor, strokeWidth, scale;
@property (nonatomic, retain) UIImage *maskImage;
@property (nonatomic, retain) MysticDrawingContext *contextSizeContext;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, assign) MysticSizeOptions *contentSizeOptions;
@property (nonatomic, retain) MysticLayerBaseView *layerView;
@property (nonatomic, assign) BOOL shouldDrawAntiAlias;
@property (nonatomic, copy) MysticDrawBlock drawBlock;

- (void) endDraw:(CGRect)rect;
- (void) drawWithRect:(CGRect)rect;
- (CGSize) contentSizeThatFits:(CGRect)rect;
- (MysticDrawingContext *) contextSizeContext:(CGRect)rect;
+ (CGRect) boundsForContent:(id)content target:(CGSize)targetSize context:(MysticDrawingContext **)context scale:(CGFloat)scale;
- (UIImage *) contentImage:(CGSize)imageSize;

@end
