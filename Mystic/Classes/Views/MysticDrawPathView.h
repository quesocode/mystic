//
//  MysticDrawPathView.h
//  Mystic
//
//  Created by Travis A. Weerts on 11/21/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticPath.h"
#import "MysticTypedefs.h"
#import "MysticUtility.h"

@class MysticPathView;

@interface CALayer(Mystic)
- (id) layerWithName:(NSString *)name;
@end
@interface MysticPathLayer : CAShapeLayer
@property (nonatomic, assign) CGFloat scaled;
@property (nonatomic, readonly) UIBezierPath *bezierPath;
@property (nonatomic, readonly) CGRect pathBounds;
@end

@interface MysticMaskLayer : MysticPathLayer
@end

@interface MysticBorderLayer : MysticPathLayer
@end

@interface MysticFillLayer : MysticPathLayer

@end


@interface MysticDrawPathView : UIView
{
    MysticPathLayer *_pathLayer;
}
@property (nonatomic, assign) MysticMaskLayer *maskLayer;
@property (nonatomic, assign) MysticBorderLayer *borderLayer;
@property (nonatomic, assign) MysticFillLayer *fillLayer;
@property (nonatomic, assign) MysticPathLayer *pathLayer;
@property (nonatomic, readonly) Class pathLayerClass;
@property (nonatomic, assign) CGRect pathFrame;
@property (nonatomic, retain) MysticPath *pathInfo;
@property (nonatomic, assign) id color;
@property (nonatomic, assign) UIBezierPath *path;
- (void) updateFrame:(CGRect)frame;
- (void) updatedSuperview:(CGRect)bounds scale:(CGScale)scale previous:(CGRect)oldBounds;

- (MysticPathLayer *) pathInfo:(MysticPath *)pathInfo;
- (MysticPathView *) showDebugMask:(id)fillColor;
- (MysticPathView *) showDebugMask:(id)fillColor border:(id)borderColor;

@end



@interface MysticPathView : MysticDrawPathView
//- (MysticPathLayer *) setPath:(UIBezierPath *)path frame:(CGRect)frame;

@end

@interface MysticDrawPathFillView : MysticPathView

@end

@interface MysticDrawPathBorderView : MysticPathView

@end

@interface MysticPathBorderDebug : MysticDrawPathBorderView

@end

@interface MysticPathFillDebug : MysticDrawPathFillView

@end

