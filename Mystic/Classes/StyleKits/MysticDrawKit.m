//
//  MysticDrawKit.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/29/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticDrawKit.h"
#import "MysticConstants.h"
#import "MysticUI.h"
#import "UIColor+Mystic.h"



@implementation MysticDrawKit
+ (id) kit;
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = self.new;
    });
    return instance;
}
+ (UIImage *) imageMask:(MysticChoice *)choice scale:(float)scale quality:(CGInterpolationQuality)quality;
{
    SEL selector = choice.customDrawingSelector;
    Class drawClass = [self drawClass:choice];

    if(![drawClass respondsToSelector:selector]) return nil;


    
    UIGraphicsBeginImageContextWithOptions(choice.frame.size, NO, scale <= 0 ? [MysticUI scale] : scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    
//    CGContextTranslateCTM(context, 0, choice.frame.size.height);
//    CGContextScaleCTM(context, 1, -1);
//    
    CGContextSetInterpolationQuality(context, quality < 0 ? kCGInterpolationMedium : quality);
    CGContextSetShouldSmoothFonts(context, YES);
    CGContextSetShouldAntialias(context, YES);
    
    [drawClass performSelector:selector withObject:choice];
    
    
    if(choice.path)
    {
        [choice.color setFill];
        [choice.path fill];
    }
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return img;
}
+ (UIImage *) image:(SEL)selector frame:(CGRect)frame color:(UIColor *)color;
{
    return [[self class] image:selector frame:frame bounds:CGRectUnknown color:color scale:0 contentMode:-1 quality:kCGInterpolationMedium];
}
+ (UIImage *) image:(SEL)selector frame:(CGRect)frame bounds:(CGRect)bounds color:(UIColor *)color scale:(float)scale  contentMode:(UIViewContentMode)contentMode quality:(CGInterpolationQuality)quality;
{
    if(![[self class] respondsToSelector:selector]) return nil;
    if(!CGRectUnknownOrZero(bounds))
    {
        contentMode = contentMode < 0 ? UIViewContentModeScaleToFill : contentMode;
        frame = CGRectWithContentMode(frame, bounds, contentMode);
    }
    
    
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, scale <= 0 ? [MysticUI scale] : scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality < 0 ? kCGInterpolationMedium : quality);
    CGContextSetShouldSmoothFonts(context, YES);
    CGContextSetShouldAntialias(context, YES);
    color = [color isKindOfClass:[UIColor class]] ? color : [color isKindOfClass:[NSString class]] ? [UIColor string:(id)color] : [color isKindOfClass:[NSNumber class]] && [(NSNumber *)color integerValue] != MysticColorTypeAuto ? [UIColor color:[(NSNumber *)color integerValue]] : nil;
    
    [[self class] performSelector:selector withObject:[NSValue valueWithCGRect:frame] withObject:color];
    
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return img;
}
+ (Class) drawClass:(MysticChoice *)choice;
{
    Class c = nil;
    if([choice.packName equals:@"decorative"]) c = NSClassFromString(@"MysticShapesDecorativeKit");
    if(!c && [choice.packName equals:@"animals"]) c = NSClassFromString(@"MysticShapesAnimalsKit");
    if(!c && [choice.packName equals:@"textures"]) c = NSClassFromString(@"MysticShapesTexturesKit");

    if(!c && choice.packName && NSClassFromString([@"MysticShapes%@Kit" with:[choice.packName capitalizedString], nil])) c = NSClassFromString([@"MysticShapes%@Kit" with:[choice.packName capitalizedString], nil]);
    return c ? c : [self class];
}
+ (UIBezierPath *) path:(MysticChoice *)choice frame:(CGRect)frame;
{
    choice.frame = frame;
    Class drawClass = [self drawClass:choice];
    
    if(!choice.usesCustomDrawing || ![drawClass respondsToSelector:choice.customDrawingSelector]) {
        DLog(@"no path selector found: %@  '%@: %@'", MBOOL(choice.usesCustomDrawing), drawClass, NSStringFromSelector(choice.customDrawingSelector));
        
        return nil;
    }
    NSDictionary *d = [drawClass performSelector:choice.customDrawingSelector withObject:choice];
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (UIBezierPath *subPath in d[@"paths"]) { [path appendPath:subPath]; }
    return path;
}

+ (NSDictionary *) pathAndSubpaths:(MysticChoice *)choice frame:(CGRect)frame;
{
    CGRect f = choice.frame;
    choice.frame = frame;
    Class drawClass = [self drawClass:choice];
    
    if(!choice.usesCustomDrawing || ![drawClass respondsToSelector:choice.customDrawingSelector]) { DLog(@"no path selector found: %@  '%@: %@'", MBOOL(choice.usesCustomDrawing), drawClass, NSStringFromSelector(choice.customDrawingSelector));
        
        return nil; }
    NSDictionary *d = [drawClass performSelector:choice.customDrawingSelector withObject:choice];
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSMutableArray *subpaths = [NSMutableArray array];
    for (UIBezierPath *subPath in d[@"paths"]) {
        
        NSArray *sps = path.subpaths;
        if(sps.count)
        {
            [subpaths addObjectsFromArray:sps];
        }
        [path appendPath:subPath];
    }
    choice.frame = f;
    return @{@"path": path ? path : [UIBezierPath bezierPath], @"subpaths": subpaths};
}
+ (NSDictionary *) pathBounds:(MysticChoice *)choice;
{
    return [self pathBounds:choice border:0];
}
+ (NSDictionary *) pathBounds:(MysticChoice *)choice border:(float)borderWidth;
{
    UIBezierPath *p = [self path:choice frame:CGRectz(choice.frame)];
    p = MovePathToPoint(p, CGPointZero);
    CGRect b = PathBoundingBox(p);
    borderWidth = borderWidth < 0 ? choice.borderWidth : borderWidth;
    b =  borderWidth <= 0 ? b : CGRectInset(b, -borderWidth/2, -borderWidth/2);
    return @{@"path":p ? p : [NSNull null], @"frame":[NSValue valueWithCGRect:b]};
}

+ (NSDictionary *) draw:(MysticChoice *)choice frame:(CGRect)frame;
{
    BOOL changedChoice = NO;
    frame = choice.frame;
//    choice.frame = frame;
    Class drawClass = [self drawClass:choice];

    if(!choice.usesCustomDrawing || ![drawClass respondsToSelector:choice.customDrawingSelector]) return nil;
    if(choice.isThumbnail && !choice.drawEffectsOnViewLayer)
    {
        UIColor *borderColor = [choice borderColor:NO];
        if(choice.borderWidth == 0) { choice.borderWidth = choice.thumbnailBorderWidth != 0 ? choice.thumbnailBorderWidth : 0; changedChoice = choice.borderWidth != 0; }
        if(!borderColor && choice.thumbnailBorderColor) choice.borderColor = choice.thumbnailBorderColor;
        if(!borderColor && !choice.thumbnailBorderColor && changedChoice) choice.borderColor = choice.color;
    }
    NSDictionary *d = [drawClass performSelector:choice.customDrawingSelector withObject:choice];
    MysticBlockPathChoice block = nil;

    [drawClass fill:d[@"paths"] choice:choice block:block];
    
    return d;
}
+ (void) fill:(NSArray *)paths choice:(MysticChoice *)choice block:(MysticBlockPathChoice)block;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [MyObjOr(MyColorNotClear(choice.colorOrDefault), [UIColor white]) setFill];
    for (UIBezierPath *path in paths) {
        if(block) block(path, choice, context);
        else [path fill];
    }
}

+ (NSDictionary *) drawInflectedShape:(MysticChoice *)choice;
{
    return @{@"paths":@[BezierInflectedShape(choice.inflections, choice.inflectionRadiusPercent, choice.frame)]};
}
+ (NSDictionary *) drawPolygon:(MysticChoice *)choice;
{
    return @{@"paths":@[BezierPolygon(choice.inflections, choice.frame)]};
}

+ (NSDictionary *) drawStar:(MysticChoice *)choice;
{
    return @{@"paths":@[BezierStarShape(choice.inflections, choice.inflectionRadiusPercent, choice.frame)]};
}
+ (NSDictionary *) drawSquare:(MysticChoice *)choice;
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:choice.frame];
    return @{@"paths":@[path]};
}
+ (NSDictionary *) drawCircle:(MysticChoice *)choice;
{
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:choice.frame];
    return @{@"paths":@[path]};
}
+ (NSDictionary *) drawRoundedRect:(MysticChoice *)choice;
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:choice.frame cornerRadius:choice.cornerRadius];
    return @{@"paths":@[path]};
}


+ (void)drawBorderWidthWithFrame: (NSValue *)_frame color:(UIColor *)color;
{
    CGRect frame = [_frame CGRectValue];
    //// Color Declarations
    color = color ? color : [UIColor colorWithRed: 0.91 green: 0.337 blue: 0.42 alpha: 1];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.58573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66575 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74696 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01103 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70690 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01001 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.72727 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01023 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74450 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07098 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.72590 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07022 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.70607 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07001 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66575 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83402 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02416 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83540 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02461 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.83471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02438 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.83471 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02438 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82600 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05310 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83314 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02396 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84084 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02584 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02679 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91448 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06910 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.87004 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03628 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.89395 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05066 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.87439 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11374 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82344 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08317 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.85956 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10042 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.84229 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09003 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83370 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05498 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82656 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08412 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81886 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08223 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81660 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08159 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81560 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08126 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.81610 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08142 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.81610 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08142 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83402 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02416 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.96865 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14454 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97311 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15578 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.97024 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14824 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.97173 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15199 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.98759 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23235 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.98109 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18087 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.98536 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20415 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.92778 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23709 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91634 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17513 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.92589 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21323 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.92244 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19439 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91353 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16825 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.91576 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17363 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.91468 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17092 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.96865 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14454 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.98997 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31458 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34568 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32275 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32954 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39472 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39472 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34568 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.92997 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31476 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32960 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.32285 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.98997 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31458 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47472 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55472 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55472 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47472 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47472 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63472 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.98977 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71510 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68726 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.98996 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70009 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.92977 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71432 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.92996 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69966 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68698 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63472 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63472 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.98412 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79940 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97544 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83526 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.98202 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81213 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.97919 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82386 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.94694 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82588 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97607 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83306 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97415 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84088 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84396 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.95284 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88547 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.96791 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.85852 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.96108 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.87243 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.90211 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.85343 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91683 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82344 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.90806 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84401 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.91300 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83396 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.94502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83370 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91589 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82653 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91781 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81871 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91845 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81650 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.92492 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78963 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.92121 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80812 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.92331 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79939 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.98412 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79940 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.88772 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95140 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84470 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97294 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.87426 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.96014 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.85984 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.96737 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.80112 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98359 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.82922 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97790 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.81562 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98117 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79126 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92440 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82523 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91620 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.80294 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92246 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.81375 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91986 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85506 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90107 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.83492 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91260 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.84533 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90738 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.88772 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95140 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71651 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98971 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.70109 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98996 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.68799 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71558 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92972 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.68766 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.70059 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92996 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71651 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98971 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98998 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.33041 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.32399 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31637 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92998 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.32407 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.33046 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23418 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98793 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16461 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97540 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.20676 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98597 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18519 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98219 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17401 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94691 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16687 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97605 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15915 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97415 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97321 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.14652 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.96949 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.15283 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97204 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.14966 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97080 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16968 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91414 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17656 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91683 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.17195 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91509 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17424 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91598 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94502 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17344 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91588 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18116 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91777 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18341 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91842 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23845 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92808 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.19882 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92350 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.21563 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92645 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23418 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98793 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07036 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91587 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02679 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84396 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.05132 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.89504 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.03650 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.87064 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83472 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.02553 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84007 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.02473 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83740 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08165 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81822 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08359 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82466 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.08226 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82036 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.08291 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82250 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.11465 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.87540 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.09019 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84272 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.10089 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.86034 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07036 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91587 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01123 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74865 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66727 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01028 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.72850 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01002 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70777 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66724 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07116 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74583 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07002 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70682 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07027 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.72691 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01123 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.74865 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58731 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50731 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.50731 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58731 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58731 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42731 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34731 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34731 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42731 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42731 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01058 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26653 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02001 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18050 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01156 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22925 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01418 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20384 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07822 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19504 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07056 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26810 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07365 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21334 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07144 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23482 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01058 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26653 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.05924 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09732 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.13065 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.03792 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07844 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07261 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.10280 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05232 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15822 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09121 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.10662 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13413 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.13809 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.10162 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.12049 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11628 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.05924 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09732 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21836 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01373 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30139 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01009 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24026 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01130 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.26428 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01034 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30180 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07009 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22498 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07336 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.26660 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07033 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.24434 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07122 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21836 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01373 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [color setFill];
    [rectanglePath fill];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.39000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.31000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.71000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.85000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46000 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    [color setFill];
    [bezierPath fill];
}

+ (void)drawBorderAlphaFrame: (NSValue *)_frame color:(UIColor *)color;
{
    CGRect frame = [_frame CGRectValue];
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    color = color ? color : [UIColor colorWithRed: 0.91 green: 0.337 blue: 0.42 alpha: 1];
    UIColor* gradientColor = color ? [color colorWithAlphaComponent:0.196] : [UIColor colorWithRed: 0.91 green: 0.337 blue: 0.42 alpha: 0.196];
    
    UIColor* color2 = [UIColor colorWithRed: 0.533 green: 0.471 blue: 0.431 alpha: 0.471];
    
    //// Gradient Declarations
    CGFloat gradientLocations[] = {0, 1};
    
    color = color ? color : [UIColor clearColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)@[(id)color.CGColor, (id)gradientColor.CGColor], gradientLocations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83541 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02461 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.76810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.79633 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01171 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82601 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05310 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83315 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02396 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84084 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02584 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02679 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15604 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.90403 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04865 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.95135 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09597 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97692 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16843 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.97480 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16098 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.97590 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16470 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.98837 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21018 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23909 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97539 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83541 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76810 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.98829 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79633 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.94690 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82601 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83315 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97416 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84084 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84396 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97321 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.95135 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90403 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.90403 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95135 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83157 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97692 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.83902 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97480 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.83530 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97590 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.78982 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98837 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.76091 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16459 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97539 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.20367 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98829 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17399 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94690 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16685 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97604 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15916 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97416 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97321 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02679 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84396 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.09597 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95135 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.04865 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90403 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02308 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83157 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.02520 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83902 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.02410 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83530 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01163 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78982 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76091 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02461 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16459 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23190 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01171 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20367 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.05310 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17399 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16685 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02584 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15916 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02679 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15604 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02679 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.04865 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09597 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.09597 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04865 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16843 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02308 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.16098 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02520 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.16470 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02410 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.21018 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01163 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23909 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18430 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08094 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.21881 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07148 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17534 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08359 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.18132 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08176 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17834 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08264 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08317 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17656 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.13316 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09897 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.09897 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13316 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.05498 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16630 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08412 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17344 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08224 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18112 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08159 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18339 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07156 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21377 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23948 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08094 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81570 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.75498 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07148 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78119 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08359 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82466 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.08176 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81868 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.08264 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82166 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17656 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91683 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.09897 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.86684 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.13316 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90103 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94502 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17344 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91588 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18112 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91776 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18339 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91841 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.21377 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92844 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23948 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81570 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91906 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75498 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.78119 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92852 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82466 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91641 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.81868 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91824 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.82166 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91736 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91683 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82344 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.86684 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90103 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.90103 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.86684 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.94502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83370 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91588 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82656 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91776 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81888 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91841 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81661 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.92844 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78623 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76052 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91906 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18430 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24502 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.92852 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21881 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91641 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17534 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.91824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18132 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.91736 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17834 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82344 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08317 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.90103 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13316 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.86684 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09897 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83370 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05498 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82656 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08412 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81888 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08224 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81661 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08159 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.78623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07156 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.76052 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGRect rectangleBounds = CGPathGetPathBoundingBox(rectanglePath.CGPath);
    CGContextDrawLinearGradient(context, gradient,
                                CGPointMake(CGRectGetMinX(rectangleBounds), CGRectGetMidY(rectangleBounds)),
                                CGPointMake(CGRectGetMaxX(rectangleBounds), CGRectGetMidY(rectangleBounds)),
                                0);
    CGContextRestoreGState(context);
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.20000 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.22000 + 0.5), floor(CGRectGetWidth(frame) * 0.76000 + 0.5) - floor(CGRectGetWidth(frame) * 0.20000 + 0.5), floor(CGRectGetHeight(frame) * 0.76000 + 0.5) - floor(CGRectGetHeight(frame) * 0.22000 + 0.5))];
    [color2 setFill];
    [ovalPath fill];
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}
+ (void)drawBorderColorFrame: (NSValue *)_frame color:(UIColor *)color;
{
    CGRect frame = [_frame CGRectValue];
    if(color)
    {
        //// Color Declarations
        UIColor* fillColor = color;
        
        
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPath];
        [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83541 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02461 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.76810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.79633 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01171 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82601 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05310 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83315 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02396 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84084 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02584 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02679 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15604 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.90403 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04865 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.95135 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09597 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97692 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16843 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.97480 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16098 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.97590 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16470 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.98837 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21018 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23909 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97539 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83541 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76810 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.98829 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79633 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.94690 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82601 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83315 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97416 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84084 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84396 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97321 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.95135 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90403 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.90403 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95135 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83157 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97692 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.83902 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97480 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.83530 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97590 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.78982 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98837 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.76091 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16459 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97539 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.20367 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98829 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17399 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94690 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16685 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97604 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15916 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97416 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97321 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02679 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84396 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.09597 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95135 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.04865 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90403 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02308 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83157 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.02520 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83902 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.02410 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83530 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01163 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78982 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76091 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02461 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16459 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23190 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01171 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20367 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.05310 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17399 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16685 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02584 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15916 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02679 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15604 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02679 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.04865 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09597 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.09597 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04865 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16843 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02308 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.16098 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02520 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.16470 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02410 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.21018 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01163 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23909 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
        [rectanglePath closePath];
        [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18430 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08094 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.21881 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07148 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17534 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08359 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.18132 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08176 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17834 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08264 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08317 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17656 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.13316 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09897 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.09897 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13316 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.05498 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16630 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08412 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17344 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08224 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18112 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08159 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18339 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07156 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21377 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23948 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08094 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81570 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.75498 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07148 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78119 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08359 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82466 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.08176 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81868 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.08264 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82166 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17656 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91683 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.09897 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.86684 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.13316 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90103 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94502 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17344 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91588 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18112 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91776 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18339 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91841 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.21377 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92844 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23948 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81570 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91906 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75498 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.78119 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92852 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82466 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91641 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.81868 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91824 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.82166 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91736 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91683 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82344 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.86684 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90103 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.90103 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.86684 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.94502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83370 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91588 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82656 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91776 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81888 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91841 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81661 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.92844 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78623 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76052 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91906 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18430 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24502 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.92852 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21881 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91641 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17534 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.91824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18132 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.91736 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17834 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82344 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08317 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.90103 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13316 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.86684 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09897 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83370 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05498 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82656 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08412 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81888 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08224 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81661 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08159 * CGRectGetHeight(frame))];
        [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.78623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07156 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.76052 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
        [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
        [rectanglePath closePath];
        [fillColor setFill];
        [rectanglePath fill];
        return;
    }
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* gradient2Color = [UIColor colorWithRed: 0.404 green: 0.561 blue: 0.851 alpha: 1];
    UIColor* gradient2Color2 = [UIColor colorWithRed: 0.529 green: 0.635 blue: 0.537 alpha: 1];
    UIColor* gradient2Color3 = [UIColor colorWithRed: 0.886 green: 0.706 blue: 0.345 alpha: 1];
    UIColor* gradient2Color4 = [UIColor colorWithRed: 0.922 green: 0.282 blue: 0.478 alpha: 1];
    UIColor* gradient2Color5 = [UIColor colorWithRed: 0.871 green: 0.431 blue: 0.278 alpha: 1];
    
    //// Gradient Declarations
    CGFloat gradient2Locations[] = {0, 0.25, 0.5, 0.76, 1};
    CGGradientRef gradient2 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)@[(id)gradient2Color.CGColor, (id)gradient2Color2.CGColor, (id)gradient2Color3.CGColor, (id)gradient2Color5.CGColor, (id)gradient2Color4.CGColor], gradient2Locations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83541 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02461 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.76810 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.79633 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01171 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82601 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05310 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83315 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02396 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84084 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02584 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02679 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15604 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.90403 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04865 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.95135 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09597 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97692 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16843 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.97480 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16098 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.97590 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16470 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.98837 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21018 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23909 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97539 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83541 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76810 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.98829 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.79633 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.94690 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82601 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83315 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97416 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84084 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84396 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97321 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.95135 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90403 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.90403 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95135 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83157 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97692 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.83902 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97480 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.83530 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97590 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.78982 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98837 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.76091 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16459 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97539 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23190 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.99000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.20367 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.98829 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17399 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94690 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16685 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97604 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15916 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97416 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.97321 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02679 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84396 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.09597 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95135 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.04865 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90403 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02308 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83157 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.02520 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83902 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.02410 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83530 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01163 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78982 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76091 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02461 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16459 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.01000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23190 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.01171 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20367 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.05310 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17399 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02396 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16685 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02584 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15916 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02679 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15604 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.15604 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02679 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.04865 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09597 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.09597 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04865 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16843 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02308 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.16098 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02520 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.16470 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02410 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.21018 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01163 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23909 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.01000 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    [rectanglePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18430 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08094 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.21881 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07148 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17534 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08359 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.18132 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08176 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.17834 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08264 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08317 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17656 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.13316 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09897 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.09897 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13316 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.05498 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16630 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08412 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17344 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08224 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18112 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08159 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18339 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07156 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21377 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23948 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08094 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81570 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.75498 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07148 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78119 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.08359 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82466 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.08176 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81868 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.08264 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82166 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17656 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91683 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.09897 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.86684 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.13316 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90103 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.16630 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.94502 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.17344 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91588 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18112 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91776 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.18339 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91841 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.21377 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92844 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.23948 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81570 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91906 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75498 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.93000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.78119 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92852 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82466 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91641 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.81868 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91824 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.82166 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.91736 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91683 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82344 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.86684 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.90103 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.90103 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.86684 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.94502 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83370 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91588 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.82656 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91776 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81888 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91841 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.81661 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65427 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.92844 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78623 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76052 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34573 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91906 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18430 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.93000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24502 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.92852 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21881 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.91641 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17534 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.91824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18132 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.91736 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17834 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82344 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08317 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.90103 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.13316 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.86684 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.09897 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.83370 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05498 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.82656 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08412 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81888 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08224 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.81661 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08159 * CGRectGetHeight(frame))];
    [rectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.65427 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.78623 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07156 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.76052 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
    [rectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.07000 * CGRectGetHeight(frame))];
    [rectanglePath closePath];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    UIBezierPath* rectangleRotatedPath = [rectanglePath copy];
    CGAffineTransform rectangleTransform = CGAffineTransformMakeRotation(45*(-M_PI/180));
    [rectangleRotatedPath applyTransform: rectangleTransform];
    CGRect rectangleBounds = CGPathGetPathBoundingBox(rectangleRotatedPath.CGPath);
    rectangleTransform = CGAffineTransformInvert(rectangleTransform);
    
    CGContextDrawLinearGradient(context, gradient2,
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(rectangleBounds), CGRectGetMidY(rectangleBounds)), rectangleTransform),
                                CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(rectangleBounds), CGRectGetMidY(rectangleBounds)), rectangleTransform),
                                0);
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(gradient2);
    CGColorSpaceRelease(colorSpace);
}

@end
