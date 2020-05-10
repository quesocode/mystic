//
//  MysticDrawingContext.h
//  Mystic
//
//  Created by Me on 12/15/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"
@class MysticAttrString;

@interface MysticDrawingContext : NSStringDrawingContext
@property (nonatomic, assign) MysticSizeOptions sizeOptions;
@property (nonatomic, assign) CGFloat fontSizePointFactor, scaleFactor, fontSizeScaleFactor, fontSize, fontSizeStart, targetScale;
@property (nonatomic, assign) CGSize minimumRatio, totalSize, targetSize, fontScaleFactor, newTargetSize, maxTargetSize;
@property (nonatomic, retain) NSDictionary *attributes;
@property (nonatomic, retain) MysticAttrString *attributedString;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) BOOL autoScaleFont, adjustContentSizeToFit, adjustTargetSize, adjustedTargetSize;
+ (id) contextWithTargetSize:(CGSize)targetSize minimumScaleFactor:(CGFloat)min;
+ (id) contextWithContext:(MysticDrawingContext *)context;
+ (id) context;
- (BOOL) setNextTargetSize:(CGSize)nt;

@end
