//
//  MysticChoice.h
//  Mystic
//
//  Created by Travis A. Weerts on 10/24/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticConstants.h"
#import "BezierUtils.h"
#import "MysticPath.h"

@class MysticLayerBaseView, MysticAttrString;
@interface MysticChoice : NSObject

@property (nonatomic, assign) BOOL isActive, cancelsEffect, showAllActiveControls, usesCustomDrawing, isThumbnail, drawEffectsOnViewLayer, alphaChangesColor, onlyDrawFill, onlyDrawBorder, hasEffectsThatHaveToBeDrawn, rebuildFrame, refitFrame, effectsHaveChanged, frameSet, pathAdjustsFrameSize;
@property (nonatomic, readonly) BOOL hasBorder, hasShadow, hasCornerRadius, hasFillColor,  hasInflections, hasPathInfo;
@property (nonatomic, retain) NSNumber *effectsHaveToBeDrawn, *innerShadow, *extrude, *emboss, *innerBevel, *bevel, *drawAroundFrame;
@property (nonatomic, copy) MysticChoiceBlock action;
@property (nonatomic, retain) NSMutableDictionary *info;
@property (nonatomic, retain) NSString *title, *key, *name, *lineCap, *lineJoin;
@property (nonatomic, retain) MysticPath *pathInfo;
@property (nonatomic, assign) MysticObjectType type;
@property (nonatomic, assign) MysticPosition borderPosition;
@property (nonatomic, assign) CGScale scale, propertiesScale, propertiesScaleInverse;
@property (nonatomic, assign) CGPoint center, offset;
@property (nonatomic, assign) MysticChoiceProperty changedEffects;
@property (nonatomic, assign) CGSize size, shadowOffset, shadowOffsetValue, innerShadowSize, embossSize, embossDarkSize, embossSizeChange;
@property (nonatomic, assign) NSInteger inflections;
@property (nonatomic, readonly) NSInteger inflectionsValue;
@property (nonatomic, assign) float borderAlpha, alpha, shadowAlpha, shadowRadius, cornerRadius, borderWidth, thumbnailBorderWidth, borderAlphaValue, shadowAlphaValue, shadowRadiusValue, borderWidthValue, alphaValue, cornerRadiusValue, embossBlur, embossRadius, extrudeRadius, extrudeAngle, innerShadowBlur, bevelRadius, bevelAngle, innerBevelRadius, innerBevelAngle, innerBevelBlur, bevelBlur, inflectionRadiusPercent;
@property (nonatomic, assign) float inflectionsRadiusPercentValue, maxWidth;
@property (nonatomic, assign) CGRect frame, bounds, boundsInset, originalInnerFrame, pathBounds, frameBorder, frameNoBorder, frameNoBorderInset, maskFrame, originalContentFrame;
@property (nonatomic, retain) UIColor *bevelColorOrDefault, *embossColorOrDefault, *embossDarkColorOrDefault, *innerShadowColorOrDefault, *borderColorOrDefault, *innerBevelColorOrDefault, *innerBevelShadowColorOrDefault, *bevelShadowColorOrDefault, *colorOrDefault;
@property (nonatomic, retain) UIColor *color, *borderColor, *thumbnailBorderColor, *backgroundColor, *color2, *color3, *color4, *shadowColor, *embossColor, *embossDarkColor, *extrudeColor, *innerShadowColor, *innerBevelColor, *bevelColor, *bevelShadowColor, *innerBevelShadowColor;
@property (nonatomic, readonly) NSString *tag, *packName, *function;
@property (nonatomic, readonly) id content;
@property (nonatomic, assign) UIView *contentView;
@property (nonatomic, readonly) SEL customDrawingSelector;
@property (nonatomic, retain) UIImage *image, *selectedImage, *highlightedImage, *disabledImage;
@property (nonatomic, assign) CGPathRef shadowPath;
@property (nonatomic, assign) MysticObjectType setting;
@property (nonatomic, retain) MysticChoice *texture, *mask;
@property (nonatomic, assign) UIViewContentMode contentMode;
@property (nonatomic, retain) MysticAttrString *attributedString;
@property (nonatomic, assign) CGSize dashSize;
@property (nonatomic, retain) UIBezierPath *path;
+ (id) choiceWithInfo:(id)info key:(NSString *)key type:(MysticObjectType)type;
- (UIColor *) borderColor:(BOOL)returnDefault;
- (BOOL) isSame:(id)otherChoice;
- (id) objectForKey:(id)key;
- (void) updateTag;
- (id) info:(id)key;
- (instancetype) addChoice:(MysticChoice *)otherChoice;
- (instancetype) addChoice:(MysticChoice *)otherChoice resetInfo:(BOOL)resetInfo;
- (instancetype) resetScale;
- (instancetype) scale:(CGScale)scale;
- (instancetype) resetScale:(CGScale)scale;
- (instancetype) setScale:(CGScale)scale scaleProperties:(BOOL)shouldScale;
- (CGScaleOfView) scaleOfView:(MysticLayerBaseView *)fromView fromView:(UIView *)toView;
- (UIImage *) image:(CGSize)size color:(UIColor *)color scale:(float)scale quality:(CGInterpolationQuality)quality contentMode:(UIViewContentMode)contentMode;
- (CGFrameBounds) updateView:(UIView *)view;
- (CGFrameBounds) updateView:(UIView *)view debug:(id)debug;
- (void) resetFraming;

- (void) setBorderWidth:(float)borderWidth sender:(id)sender;
- (void) effect:(MysticChoiceProperty)effect changed:(BOOL)changed;
- (NSString *)description:(UIView *)view;
- (NSString *) changedEffectsString;
- (id) setNeedsLayout;
@end
