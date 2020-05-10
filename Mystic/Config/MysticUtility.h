//
//  MysticUtility.h
//  Mystic
//
//  Created by Travis A. Weerts on 12/2/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//
#import "MysticTypedefs.h"

#ifndef MysticUtility_h
#define MysticUtility_h

#import "LLog.h"

void runBlock(MysticBlock block);
void mdispatch(MysticBlock block);
void mdispatch_high(MysticBlock block);
void mdispatch_bg(MysticBlock block);
void mdispatch_default(MysticBlock block);
void mdispatch_low(MysticBlock block);

MysticShaderIndex MysticShaderIndexFromArray(NSArray *a);
MysticShaderIndex MysticShaderIndexClean(MysticShaderIndex i);
MysticShaderIndex MysticShaderIndexWithIndex(MysticShaderIndex index, NSInteger i);
MysticShaderIndex MysticShaderIndexWithStackIndex(MysticShaderIndex index, NSInteger i);
MysticShaderIndex MysticShaderIndexWith(MysticShaderIndex index);
BOOL MysticShaderIndexEqualToIndex(MysticShaderIndex index1, MysticShaderIndex index2);
BOOL MysticShaderIndexIsUnknown(MysticShaderIndex index);


MysticCollectionRange MysticCollectionRangeMakeWithIndexPaths(NSArray *indexPaths);
MysticCollectionRange MysticCollectionRangeMakeWithCollectionView(UICollectionView *collectionView);
BOOL MysticCollectionRangeEqual(MysticCollectionRange range, MysticCollectionRange range2);
BOOL MysticCollectionRangeIsZero(MysticCollectionRange range);
BOOL MysticCollectionRangeIsUnknown(MysticCollectionRange range);
NSString * MysticIndexPathToString(NSIndexPath *i);
NSString * MysticCollectionRangeToString(MysticCollectionRange range);


BOOL MysticHSBEqualToHSB(MysticHSB hsb1, MysticHSB hsb2);
MysticHSB MysticHSBMake(CGFloat hue, CGFloat saturation, CGFloat brightness);
MysticHSB MysticHSBFromArray(NSArray *hsbArray);
NSString *NSStringFromMysticHSB(MysticHSB hsb);


BOOL MysticTypeSubTypeOf(MysticObjectType type, MysticObjectType parentType);
NSString *MysticObjectTypeTitleParent(MysticObjectType type, MysticObjectType lastType);
NSString *MysticObjectTypeTitle(MysticObjectType type);

NSString *MysticObjectTypeToString(MysticObjectType type);
NSString *MysticObjectTypeKey(MysticObjectType type);
MysticOptionTypes MysticTypeToOptionTypes(MysticOptionTypes types);
NSArray *MysticOptionTypesToObjectTypeKeys(MysticOptionTypes types);
NSArray *MysticOptionTypesToObjectTypes(MysticOptionTypes types);
NSDictionary *MysticOptionTypesToObjectTypesDictionary(MysticOptionTypes types);
MysticObjectType MysticOptionTypesToObjectType(MysticOptionTypes types);
MysticOptionTypes MysticOptionTypesWithArray(NSArray *typesArray);
MysticOptionTypes MysticOptionTypesClean(MysticOptionTypes types);
NSArray  *rw(CGRectMinMaxWithin m);
NSString *m(MysticObjectType type);
NSString *MysticString(MysticObjectType type);
NSString *MysticStrings(NSArray *types);
NSString *MyString(MysticObjectType type);
BOOL MysticBrushIsDefault(MysticBrush brush);
BOOL MysticBrushEquals(MysticBrush brush, MysticBrush brush2);

MysticShareType MysticShareTypeForType(MysticIconType iconType);

NSArray *Border(id border);

void MysticWait(NSTimeInterval delay, MysticBlock block);
void MysticWaitQueue(NSTimeInterval delay, MysticBlock block, dispatch_queue_t queue);
NSString *transd(CGAffineTransform t, int d);
NSString *trans(CGAffineTransform transform);
CGAffineTransform CGAffineTransformMove(CGAffineTransform transform, CGPoint move);
CGAffineTransform CGAffineTransformScaleOf(CGAffineTransform transform);
CGAffineTransform CGAffineTransformRotateOf(CGAffineTransform transform);
CGAffineTransform CGAffineTransformTranslateOf(CGAffineTransform transform);

CGSize CGAffineTransformToSize(CGAffineTransform trans);
CGAffineTransform CGAffineTransformRotateReset(CGAffineTransform transform);
CGAffineTransform CGAffineTransformScaleReset(CGAffineTransform transform);
CGAffineTransform CGAffineTransformRotateAdd(CGAffineTransform transform, float r);

CGAffineTransform CGAffineTransformTranslateReset(CGAffineTransform transform);
CGAffineTransform CGAffineTransformConcatRotate(CGAffineTransform transform, CGAffineTransform rotate);
CGAffineTransform CGAffineTransformConcatScale(CGAffineTransform transform, CGAffineTransform scale);
CGAffineTransform CGAffineTransformConcatTranslate(CGAffineTransform transform, CGAffineTransform move);

CGAffineTransform CGAffineTransformScaleSize(CGAffineTransform transform, CGSize size);
CGAffineTransform CGAffineTransformPoint(CGAffineTransform transform, CGPoint offset);
CGAffineTransform CGScaleInverseTransform(CGAffineTransform transform, CGScale scale);
CGAffineTransform CGScaleTransform(CGAffineTransform transform, CGScale scale);
CGAffineTransform CGScaleTransformMake(CGScale scale);
CGAffineTransform CGScaleEqualTransform(CGAffineTransform transform, CGScale scale);
CGAffineTransform CGTransformSize(CGSize size);

BOOL CGAffineTransformIsUnknown(CGAffineTransform transform);
BOOL CGAffineTransformIsIdentityOrUnknown(CGAffineTransform transform);
BOOL CGAffineTransformEqualsIdentity(CGAffineTransform transform);
BOOL CGAffineTransformHasRotation(CGAffineTransform transform);
BOOL CGAffineTransformHasScale(CGAffineTransform transform);
BOOL CGAffineTransformHasTranslate(CGAffineTransform transform);



NSString *MysticColorTypeString(MysticColorType type);
NSString *ImageOrientationToString (UIImageOrientation imageOrientation);
BOOL isNull(id obj);
BOOL isMEmpty(id obj);
BOOL ismt(id obj);
BOOL isM(id obj);
BOOL isMBOOL(id v);
BOOL isZeroOrNotFound(NSInteger n);
BOOL isZeroOrOne(float n);
id MVal(id obj);
id MyObjOr(id obj, id obj2);
UIColor *MyColorNotClear(id color);
UIColor *C(MysticColorType color);
UIColor *CA(MysticColorType color, float a);
BOOL CGSizeEqual(CGSize s, CGSize s2);


BOOL CGRectEqualOrZero(CGRect r, CGRect r2);
BOOL CGRectEqual(CGRect r, CGRect r2);
BOOL CGRectSizeEqual(CGRect r, CGRect r2);
BOOL CGPointEqual(CGPoint p, CGPoint p2);
BOOL CGPointIsUnknown(CGPoint p);
BOOL CGPointUnknownOrZero(CGPoint p);
void ILog(NSString *name, UIImage *img);
CGRect SetBounds(UIView *view, CGRect bounds, CGPoint center);
NSString *b(BOOL val);
NSString * ILogStr(UIImage *img);
NSString *SLogStr(CGSize size);
NSString *SLogStrd(CGSize size, int depth);
NSString *scd(CGScale scale, int depth);
NSString *sc(CGScale scale);
NSString *scs(CGScale scale);
NSString *FLogStr(CGRect frame);
NSString *fpad(CGRect frame);
NSString *fpadd(CGRect frame, NSUInteger l);

NSString *FLogStrd(CGRect frame, int depth);
NSString *EdgeLogStr(UIEdgeInsets insets);
NSString *PLogStr(CGPoint origin);
NSString *PLogStrd(CGPoint origin, int depth);
NSString *ins(UIEdgeInsets insets);
NSString *f(CGRect frame);
NSString *s(CGSize size);
NSString *p(CGPoint p);
NSString *fp(CGRect frame);
NSString *fs(CGRect frame);
NSString *fspad(CGRect frame);
NSString *ColorStrSuffix(UIColor *c, NSString *suffix, int d);
NSString *ColorStr(UIColor *c);
NSString *ColorStrd(UIColor *c, int d);
NSString *ColorStrDotted(UIColor *c, int d);
NSString *ColorToString(UIColor *c);
NSString *ColorString(UIColor *c);
NSString *ColorWrap(NSString *str, id color);
NSString *ColorWrapf(NSString *str, float v, id color);
NSString *ColorWrapInt(NSString *str, int v, id color);

NSString *Red(NSString *str);
NSString *Blue(NSString *str);
NSString *Green(NSString *str);
NSString *Purple(NSString *str);
NSString *Cyan(NSString *str);
NSString *Yellow(NSString *str);
NSString *Magenta(NSString *str);
NSString *Pink(NSString *str);

UIFont *MysticFontBold(UIFont *font);
UIFont *MysticFontItalic(UIFont *font);
UIFont *MysticFontBoldItalic(UIFont *font);
UIFont *MysticFontRegular(UIFont *font);
NSString * MysticPositionToString(MysticPosition position);
NSString * MysticPositionStr(MysticPosition position);

void MyLog(NSString *format, ...);
NSMutableString *LineStrf(NSMutableString *s, int longestLine, int longestKey);
NSString * LLogStr(NSArray *objs);
NSString * LLogStrDebug(id __objs, BOOL wrap, BOOL debug);
void ALLog(NSString *format, id objs);
void ALLogDebug(NSString *format, id objs);

NSString *ALLogStr(id objs);
NSString *ALLogStrf(NSString *format, id objs);
NSString * BgLogStr(NSString *str);
NSString * _BgLogStr(NSString *str, BOOL wrapLines, int l);

void MBorder(id view, id color, CGFloat borderWidth);
void MBord(id view);

MysticOptionTypes MysticObjectTypeToOptionTypes(MysticObjectType type);
MysticObjectType MysticSettingForObjectType(MysticObjectType objectType);

MysticFilterType MysticFilterTypeFromString(NSString *_type);
NSString *MysticFilterTypeToString(MysticFilterType _type);
NSString *MysticLayerEffectNotifyString(MysticLayerEffect _type);
NSString *MBOOLStr(BOOL val);
NSString *MObj(id val);
id MNull(id val);
NSString * AdjustmentStateToString(MysticAdjustmentState state);
NSString *MBOOL(BOOL val);
NSString *LayerPanelState(MysticLayerPanelState state);
NSString *ExceptionString(NSException *exception);
NSString *CallBackStackString(NSException *exception);
NSString *NSStringFromCGScale(CGScale r);
NSString *MMOpenSide(NSInteger side);
MysticObjectType MysticTypeForSetting(MysticObjectType type,  id option);
MysticDirection MysticDirectionFrom(CGPoint p1, CGPoint p2);
MysticDirection MysticDirectionFromThreshold(CGPoint p1, CGPoint p2, CGFloat threshold);
MysticDirection MysticDirectionOf(CGPoint p1);
MysticDirection MysticDirectionOfThreshold(CGPoint p1, CGFloat threshold);
BOOL MysticDirectionIsDiagnal(MysticDirection d);
BOOL MysticDirectionIsVertical(MysticDirection d, BOOL ignoreDiag);
BOOL MysticDirectionIsHorizontal(MysticDirection d, BOOL ignoreDiag);
NSInteger MysticBuildNumber();
BOOL MysticSizeHeightOnly(CGSize size);
BOOL MysticSizeWidthOnly(CGSize size);
BOOL MysticSizeHasUnknown(CGSize size);
NSValue *CGSizeMakeValue(CGFloat width, CGFloat height);
NSValue *CGRectMakeValue(CGFloat x, CGFloat y, CGFloat width, CGFloat height);
CGSize CGSizeInverseScaleWithSize(CGSize size, CGSize scale);
CGSize CGSizeScaleWithSize(CGSize size, CGSize scale);
CGSize CGSizeScaleWithScale(CGSize size, CGScale scale);
CGSize CGSizeImage(UIImage *source);
CGSize CGSizeMakeUnknown(CGSize size);
CGSize CGSizeNormal(CGSize s, CGSize rect);
CGSize CGSizeMakeUnknownHeight(CGSize size);
CGSize CGSizeMakeUnknownWidth(CGSize size);
CGSize CGSizeFilterUnknown(CGSize size);
CGSize CGSizeScaleDown(CGSize size, float scale);
CGSize CGSizeConstrain(CGSize size, CGSize maxSize);
CGSize CGSizeFromMaxPoint(CGPoint p);
CGSize CGSizeMakeWithString(NSString *str);
CGSize CGSizeScaleToSize(CGSize size1, CGSize size2);
CGSize CGSizeAdd(CGSize size, CGFloat w, CGFloat h);
CGFloat CGRectRatio(CGRect rect);
CGRect CGRectApplyRatio(CGRect rect, CGFloat ratio);
CGRect CGRectAroundCenter(CGRect rect, CGPoint c);
CGFloat CGRectAtan2(CGRect frame, CGPoint center);

BOOL CGSizeEqualRatio(CGSize size1, CGSize size2);
BOOL CGSizeIsWide(CGSize size);
BOOL CGSizeIsTall(CGSize size);
BOOL CGRectIsTall(CGRect rect);
BOOL CGRectIsWide(CGRect rect);


UIEdgeInsets UIEdgeInsetsAdd(UIEdgeInsets ins, UIEdgeInsets add);
UIEdgeInsets UIEdgeInsetsMinus(UIEdgeInsets ins, UIEdgeInsets add);

UIEdgeInsets UIEdgeInsetsMakeFrom(CGFloat p);
UIEdgeInsets UIEdgeInsetsScaleBy(UIEdgeInsets insets, CGFloat scale);
UIEdgeInsets UIEdgeInsetsTopBottom(UIEdgeInsets insets, CGFloat top, CGFloat bottom);
UIEdgeInsets UIEdgeInsetsLeftRight(UIEdgeInsets insets, CGFloat left, CGFloat right);
UIEdgeInsets UIEdgeInsetsRight(UIEdgeInsets insets, CGFloat right);
UIEdgeInsets UIEdgeInsetsLeft(UIEdgeInsets insets, CGFloat left);
UIEdgeInsets UIEdgeInsetsBottom(UIEdgeInsets insets, CGFloat bottom);
UIEdgeInsets UIEdgeInsetsTop(UIEdgeInsets insets, CGFloat top);
UIImage * imageInClipboard();
BOOL MysticTypeEqualsType(MysticObjectType type1, MysticObjectType type2);
float floatToNearest(float n, int decimals);
float floatRoundedUp(float n, int decimals);
float floatRoundedDown(float n, int decimals);
CGBlendMode CGBlendModeFromMysticFilterType(MysticFilterType _type);
float MysticMatrix4x4Sum(MysticMatrix4x4 matrix);
BOOL CGSizeEqualToSizeEnough(CGSize s1, CGSize s2);
CGSizes CGSizesMake(CGSize size1, CGSize size2);
MysticTextAlignment textAlignment(NSTextAlignment a);
NSTextAlignment textAlignmentValue(NSInteger a);
NSString * textAlignmentString(NSInteger a);
CGSize CGAffineTransformToSize(CGAffineTransform trans);
NSUInteger loadFonts( );
NSString * NSStringFromMysticDirection(MysticDirection d);
UIEdgeInsets UIEdgeInsetsFromNormalizedInsetsSize(UIEdgeInsets normalInsets, CGSize size);
UIEdgeInsets UIEdgeInsetsIntegralFromNormalizedInsetsSize(UIEdgeInsets normalInsets, CGSize size);
UIEdgeInsets UIEdgeInsetsRectDiff(CGRect r, CGRect r2);
UIEdgeInsets UIEdgeInsetsMakeWithPoint(CGPoint p);
UIEdgeInsets UIEdgeInsetsMakeWithSize(CGSize s);
UIEdgeInsets UIEdgeInsetsMakeWithXY(CGFloat x, CGFloat y);
UIEdgeInsets UIEdgeInsetsRescale(UIEdgeInsets ins, CGScale oldScale, CGScale scale);
MysticKeyboardInfo MysticKeyboardNotification(NSNotification *notification);
CGRect CGRectInsetBy(CGRect rect, CGFloat value);
CGRect CGRectContainer(CGRect r);
CGRect CGRectScale(CGRect rect, CGFloat scale);
CGRect CGRectScaleDivide(CGRect rect, CGFloat scale);

CGRect CGRectTransform(CGRect rect, CGAffineTransform t);
CGRect CGRectWithCenter(CGRect rect, CGPoint c);
CGFloat CGPointAngle(CGPoint startingPoint,CGPoint endingPoint);
CGFloat CGPointAngleFromCenter(CGPoint startingPoint,CGPoint endingPoint, CGPoint center);

CGSize CGSizeScale(CGSize size, CGFloat scale);
CGRect CGRectInverseScale(CGRect rect, CGFloat scale);
CGSize CGSizeInverseScale(CGSize size, CGFloat scale);

CGRect PathRect(UIBezierPath *p);
CGRect CGRectInt(CGRect r);
CGRect InsetRect(CGRect r, UIEdgeInsets i);
CGRect CGRectPoint(CGPoint p);
CGRect CGRectPointAddY(CGPoint p, CGFloat y);
CGRect CGRectPointAddX(CGPoint p, CGFloat x);
CGRect CGRectPointAddXY(CGPoint p, CGFloat x, CGFloat y);

CGRect UIViewRect(UIView *view, CGRect frame);
CGRect UIViewX(UIView *view, CGFloat x);
CGRect UIViewY(UIView *view, CGFloat y);
CGRect UIViewXY(UIView *view, CGFloat x, CGFloat y);
CGRect UIViewWidth(UIView *view, CGFloat w);
CGRect UIViewHeight(UIView *view, CGFloat h);
CGRect UIViewSize(UIView *view, CGSize size);
CGRect UIViewPoint(UIView *view, CGPoint origin);
CGRect UIViewAddX(UIView *view, CGFloat x);
CGRect UIViewAddY(UIView *view, CGFloat y);
CGRect UIViewAddWidth(UIView *view, CGFloat w);
CGRect UIViewAddHeight(UIView *view, CGFloat h);

CGRectMinMaxWithin CGRectWithin(CGRect r, CGRect min, CGRect max);
CGRect CGRectMove(CGRect rect, CGPoint offset);
CGRect CGRectInsets(CGRect rect, CGFloat i);
CGRect CGRectScaleWithScale(CGRect rect, CGScale scale);
CGRectRect CGRectsMatchSize(CGRect frame1, CGRect frame2);
CGRect CGRectFitSquare(CGRect fit, CGRect bounds);

CGRect CGRectNoNaN(CGRect rect);
BOOL CGPointIsNaN(CGPoint point);
BOOL CGRectIsNaN(CGRect rect);
BOOL CGSizeIsNaN(CGSize size);
void PrintView(NSString *name, UIView *view);


BOOL CGRectUnknownOrZero(CGRect rect);
BOOL CGRectIsUnknownOrZero(CGRect rect);
BOOL CGRectIsUnknown(CGRect rect);
BOOL CGSizeIsUnknownOrZero(CGSize size);
BOOL CGSizeIsUnknownOrZero(CGSize size);
BOOL CGSizeIsUnknown(CGSize size);
NSString *MysticAdjustmentsToString(NSDictionary *adjustments);
id MysticSubviewOfClass(UIView *view, Class viewClass);
CGSize CGSizeSquareHeight(CGSize size);
CGSize CGSizeSquareWidth(CGSize size);
CGSize CGSizeSquareBig(CGSize size);
CGSize CGSizeSquare(CGSize size);
CGSize CGSizeSquareSmall(CGSize size);
CGRect CGRectAlign(CGRect rect, CGRect bounds, MysticAlignType alignType);
CGRect CGRectAlignOffset(CGRect rect, CGRect bounds, MysticAlignType alignType, CGPoint offset);
BOOL CGRectGreater(CGRect r, CGRect bounds);
BOOL CGRectLess(CGRect r, CGRect bounds);
MysticRGB RGBRed(MysticRGB rgb, float v);
MysticRGB RGBBlue(MysticRGB rgb, float v);
MysticRGB RGBGreen(MysticRGB rgb, float v);
MysticRGB RGBAlpha(MysticRGB rgb, float v);

CGRect CGRectMin(CGRect r, CGRect r2);
CGRect CGRectMax(CGRect r, CGRect r2);

CGRect CGRectCenterAround(CGRect rect, CGRect bounds);
CGRect CGRectSizeInset(CGRect rect, CGFloat x, CGFloat y);
CGRect CGRectSize(CGSize size);
CGRect CGRectSubtractXY(CGRect rect, CGFloat x, CGFloat y);
CGRect CGRectAddXY(CGRect rect, CGFloat x, CGFloat y);
CGRect CGRectAddX(CGRect rect, CGFloat x);
CGRect CGRectAddY(CGRect rect, CGFloat y);
CGRect CGRectXY(CGRect rect, CGFloat x, CGFloat y);
CGRect CGRectWH(CGRect rect, CGFloat w, CGFloat h);
CGRect CGRectX(CGRect rect, CGFloat x);
CGRect CGRectY(CGRect rect, CGFloat y);
CGRect CGRectXYH(CGRect rect, CGFloat x, CGFloat y, CGFloat h);
CGRect CGRectXYW(CGRect rect, CGFloat x, CGFloat y, CGFloat w);
CGRect CGRectXYWH(CGRect rect, CGFloat x, CGFloat y, CGFloat w, CGFloat h);
CGRect CGRectXH(CGRect rect, CGFloat x, CGFloat h);
CGRect CGRectXW(CGRect rect, CGFloat x, CGFloat w);
CGRect CGRectXWH(CGRect rect, CGFloat x, CGFloat w, CGFloat h);
CGRect CGRectYWH(CGRect rect, CGFloat y, CGFloat w, CGFloat h);
CGRect CGRectYW(CGRect rect, CGFloat y, CGFloat w);
CGRect CGRectYH(CGRect rect, CGFloat y, CGFloat h);

CGRect CGRectAddXYW(CGRect rect, CGFloat x, CGFloat y, CGFloat w);
CGRect CGRectAddYH(CGRect rect, CGFloat y, CGFloat h);
CGRect CGRectAddYW(CGRect rect, CGFloat y, CGFloat w);
CGRect CGRectAddYWH(CGRect rect, CGFloat y, CGFloat w, CGFloat h);
CGRect CGRectAddWH(CGRect rect, CGFloat w, CGFloat h);
CGRect CGRectAddXH(CGRect rect, CGFloat x, CGFloat h);
CGRect CGRectAddXW(CGRect rect, CGFloat x, CGFloat w);
CGRect CGRectAddXWH(CGRect rect, CGFloat x, CGFloat w, CGFloat h);
CGRect CGRectAddXYWH(CGRect rect, CGFloat x, CGFloat y, CGFloat w, CGFloat h);
CGRect CGRectz(CGRect rect);
CGRect CGRectS(CGRect r, CGSize size);
CGRect CGRectSizeXY(CGSize s, CGFloat x, CGFloat y);
CGRect CGRectWidthHeight(CGRect rect, CGFloat w, CGFloat h);
CGRect CGRectNormal(CGRect r, CGRect r1);
CGRect CGRectWidth(CGRect rect, CGFloat w);
CGRect CGRectHeight(CGRect rect, CGFloat w);
CGRect CGRectWithPointAndSize(CGPoint p, CGSize s);
CGRect CGRectMakeAroundCenter(CGPoint c, CGPoint radius);
float CGSizeBiggestPercentDifference(CGSize s1, CGSize s2);
float CGSizeSmallestPercentDifference(CGSize s1, CGSize s2);
CGSize CGSizePercentDifference(CGSize s1, CGSize s2);
CGSize CGSizeIntegral(CGSize size);
CGSize CGSizeWithWidth(CGSize size, CGFloat w);
CGSize CGSizeWithHeight(CGSize size, CGFloat h);
CGRect CGRectMakeWithPointSize(CGPoint point, CGSize size);
CGRect MysticPositionRect(CGRect rect, CGRect bounds, MysticPosition position);
CGRect CGRectPosition(CGRect rect, CGRect bounds, MysticPosition position);
CGRect CGRectPositionOffset(CGRect rect, CGRect bounds, MysticPosition position, UIEdgeInsets inset);
NSString *DOCS_PATH(NSString *filename);

MysticPosition MysticPositionFromAlignment(MysticAlignPosition alignPos);
CGPoint CGPointOfNormal(CGPoint n, CGSize s);
CGPoint CGPointNormal(CGPoint p, CGRect rect);
CGPoint CGPointIntegral(CGPoint point);
CGPoint CGPointXY(CGPoint p, CGFloat x, CGFloat y);
CGPoint CGPointX(CGPoint p, CGFloat x);
CGPoint CGPointY(CGPoint p, CGFloat y);
CGPoint CGPointInverseScale(CGPoint point, CGFloat scale);
CGPoint CGPointScale(CGPoint point, CGFloat scale);
CGPoint CGPointScaleWithScale(CGPoint point, CGScale scale);
CGPoint CGPointCenter(CGRect r);
CGPoint CGPointMid(CGRect r);
CGPoint CGPointInverse(CGPoint p);
CGPoint CGPointMidPoint(CGPoint p1,CGPoint p2);
CGPoint snapToPoint(CGRect frame, CGRect bounds, MysticSnapPosition positions, CGFloat paddingOffset);
CGPoint CGPointDiff(CGPoint point1, CGPoint point2);
CGRect CGPointDiffRect(CGPoint c1, CGPoint c2);
CGPoint CGPointAdd(CGPoint point1, CGPoint point2);
CGPoint CGPointAddX(CGPoint point1, CGFloat x);
CGPoint CGPointAddXY(CGPoint point1, CGFloat x, CGFloat y);
CGPoint CGPointAddY(CGPoint point1, CGFloat y);

CGPoint CGPointWith(CGFloat n);
CGRect CGRectDiffABS(CGRect r1, CGRect r2);
CGRect CGRectDiff(CGRect r1, CGRect r2);
CGSize CGSizeDiff(CGSize s1, CGSize s2);
CGSize CGSizeDiffABS(CGSize s1, CGSize s2);
CGPoint CGPointDiffABS(CGPoint point1, CGPoint point2);

NSString *MysticPrintViewsOf(UIView *parentView, int depth);

NSString *MysticPrintSubviewsOf(UIView *parentView, BOOL showDesc, NSString *prefix, int depth, int d, int totalDepth, int maxDepth);
NSString *MysticContentModeToString(UIViewContentMode cmode);

CGRect MysticTranslateRectFromAnchor(MysticPosition anchor, CGRect oldBounds, CGRect bounds, CGRect rect);
CGRect CGRectWithContentMode(CGRect rect, CGRect bounds, UIViewContentMode contentMode);
CGRect CGRectCenter(CGRect rect, CGRect bounds);
CGRect CGRectFit(CGRect rect, CGRect bounds);
CGRect CGRectUnfit(CGRect rect);
CGRect CGRectAspectFill(CGRect rect, CGRect bounds);
CGRect CGRectSizeCeil(CGRect r);
CGRect CGRectSizeFloor(CGRect r);
CGFloat CGRectH(CGRect rect);
CGFloat CGRectW(CGRect rect);

BOOL MysticObjectHasAutoLayer (id option);
BOOL CGSizeGreater(CGSize size1, CGSize size2);
BOOL CGSizeLess(CGSize size1, CGSize size2);
CGFloat CGSizeMaxWH(CGSize size);
CGFloat CGSizeMinWH(CGSize size);
CGSize CGSizeMin(CGSize size1, CGSize size2);
CGSize CGSizeMax(CGSize size1, CGSize size2);
CGSize CGSizeMakeAtLeast(CGSize size1, CGSize size2);
CGSize CGSizeMakeAtMost(CGSize size1, CGSize size2);
CGSize CGSizeCeil(CGSize size);
CGSize CGSizeFloor(CGSize size);
CGSize CGSizeApplyRatio(CGSize size, CGSize fromSize);
CGFloat radianToDegrees(CGFloat radians);
CGFloat degreesToRadians(CGFloat degrees);

BOOL CGScaleEqualToScale(CGScale scale, CGScale scale2);
BOOL CGScaleIsZero(CGScale scale);
BOOL CGScaleIsUnknown(CGScale scale);
BOOL CGScaleUnknownOrZero(CGScale scale);
BOOL CGScaleIsUnknownEqualOrZero(CGScale scale);
BOOL CGScaleIsEqual(CGScale scale);
CGScale CGScaleMax(CGScale scale);
CGScale CGScaleMin(CGScale scale);
CGScale CGScaleOfRectsMin(CGRect rect, CGRect rect2);
CGScale CGScaleOfRectsMax(CGRect rect, CGRect rect2);
CGScale CGScaleMakeScale(CGScale scale);
CGScale CGScaleScale(CGScale value, CGScale scale);
CGScale CGScaleWith(CGFloat scale);
CGScale CGScaleWithSize(CGSize scaleSize);
CGScale CGScaleFromTransform(CGAffineTransform transform);
CGScale CGScaleOfViews(UIView *view, UIView *view2);
CGScale CGScaleOfSizes(CGSize size1, CGSize size2);
CGScale CGScaleOfRects(CGRect rect, CGRect rect2);
CGScale CGScaleInverse(CGScale scale);
CGScale CGScaleInverseSize(CGSize size);
BOOL CGSizeIsZero(CGSize size);
BOOL CGRectIsZero(CGRect rect);
BOOL CGPointIsZero(CGPoint point);
UIColor *ColorOfImageAtPoint(UIImage *image, CGPoint point);
BOOL isIndexOf(NSInteger i, NSArray *v);

MysticHSB MysticHSBAddHue(MysticHSB hsb, float hue);
MysticHSB MysticHSBAddSaturation(MysticHSB hsb, float saturation);
MysticHSB MysticHSBAddBrightness(MysticHSB hsb, float brightness);
MysticHSB MysticHSBBrightness(MysticHSB hsb, float brightness);
MysticHSB MysticHSBSaturation(MysticHSB hsb, float saturation);
MysticHSB MysticHSBHue(MysticHSB hsb, float hue);
NSString *MysticThresholdStr(MysticThreshold t);

id isNullOr(id obj);
id Mor(id obj, id obj2);
id Mord(id obj, id obj2, id _default);
BOOL MysticColorIsEmpty(MysticColorType color);
CGFloat CGPointDistanceFrom(CGPoint point1, CGPoint point2);
NSDictionary * MysticAttributedStringThatFits(CGSize targetSize, MysticAttrString *attrStr, MysticDrawingContext **context);
CGFloat CGSizeRatioOf(CGSize size);
NSString *MyLocalStr(NSString *str);
//void QLog(NSString *format, ...);
void NoLog(NSString *format, ...);
//void DLog(NSString *format, ...);
void FLog(NSString *name, CGRect frame);
void ELog(NSString *name, UIEdgeInsets insets);
void SLog(NSString *name, CGSize size);
void PLog(NSString *name, CGPoint origin);
NSString *MysticCacheTypeToString(MysticCacheType type);
BOOL MysticTypeHasPack(MysticObjectType type);
MysticToolType MysticTransformTypeToToolType(MysticToolsTransformType type);


BOOL usingIOS7 ();
BOOL usingIOS8 ();

UIEdgeInsets UIEdgeInsetsScale(UIEdgeInsets ins, CGScale scale);

UIEdgeInsets UIEdgeInsetsInverse(UIEdgeInsets insets);
UIEdgeInsets UIEdgeInsetsCopy(UIEdgeInsets insets);
CGRect UIEdgeInsetsOffsetRect(CGRect frame, UIEdgeInsets insets);
MFRange MFRangeMake(float _location, float _length);
MFRange MFRangeMakeCenter(float _location, float _length, float _center);
MFRange MFRangeMakeWithCenterLength(float _location, float _length, float _center);
BOOL isNotFoundOrAuto(NSInteger i);
NSString *VLogViewStr(UIView *view, int depth, int totalDepth, int extra);
void VLog(UIView *view);
void VLLog(UIView *view);
void VLogf(NSString *format, UIView *view);
void VLogd(NSString *format, UIView *view, int depth);
NSString *VLogStr(UIView *view);
NSString *VLogStrd(UIView *view, int depth);
BOOL isnanOrZero(float n);
NSString *MysticPrintLayersOf(UIView *parentView, int depth);
NSString *MysticPrintSubLayersOf(UIView *parentView, BOOL showDesc, NSString *prefix, int depth, int d, int totalDepth, int maxDepth, int pl);
NSString *VLLogViewStr(UIView *parentView, int d, int t, int extra, int pl, NSArray *subviews);
NSString *VLLogStr(UIView *view);
int VTotalDepth(UIView *view, int maxDepth, int d);
int VLTotalDepth(UIView *view, int maxDepth, int d);
NSString *MysticRGBStrh(MysticRGB rgb, int highlight);
NSString *MysticRGBStr(MysticRGB rgb);
NSString *MysticHSBStr(MysticColorHSB hsb);
NSString *UIControlStateStr(UIControlState s);
BOOL MysticRGBisBlack(MysticRGB rgb);
BOOL MysticRGBisWhite(MysticRGB rgb);
MysticRGB RGBWithArray(NSArray *rgb);
BOOL runningOnPhone();
CGPoint MCenterOfRect(CGRect rect);
NSString * viewGesturesString(UIView *view, BOOL showAll);
NSString *MysticLayerEffectStr(MysticLayerEffect _type);
CGFloat rotationRadians(CGAffineTransform nt);
NSString *MysticScrollDirectionStr(MysticScrollDirection d);
UInt32 MysticInt(NSInteger type);
NSArray *NSArrayWithRGB(MysticRGB rgb);
BOOL RGBIsEqual(MysticRGB r, MysticRGB g);
BOOL MysticColorHSBIsEqual(MysticColorHSB r, MysticColorHSB g);
float ColorMean(UIColor *avg, UIColor*max, UIColor*min);
uint64_t MysticGetFileSize(NSString *path, BOOL inMB);

MysticHSBInt HSBInt(MysticColorHSB hsb);
NSString *MysticHSBStrh(MysticColorHSB hsb, int highlight);
NSString *MysticHSBColorStr(MysticColorHSB hsb, int highlight, UIColor *c);
MysticThreshold ThresholdWithArray(NSArray *threshold);
NSArray *NSArrayWithThreshold(MysticThreshold threshold);
void rgbToHSV(float rgb[3], float hsv[3]);
void hsvToRGB(float hsv[3], float rgb[3]);
NSString *UIGestureRecognizerStateStr(UIGestureRecognizerState state);
CGAffineTransform snapRotation45and90(CGAffineTransform t);
CGAffineTransform snapRotation(CGAffineTransform t);
CGFloat rotationDegrees(CGAffineTransform nt);
NSString *RGBStr(float r, float g, float b);
NSString *ColorRGBStr(UIColor *c);
NSString *subviewsShadowStr(UIView *view, NSMutableString *s, int depth);
BOOL CGSizeIsEqualThreshold(CGSize size1, CGSize size2, float threshold);
BOOL CGSizeHeightIsEqualThreshold(CGSize size1, CGSize size2, float threshold);
BOOL CGSizeWidthIsEqualThreshold(CGSize size1, CGSize size2, float threshold);

BOOL isValidAlignment(NSInteger a);
uint64_t getFreeDiskspace(BOOL inMB);
#define normalizedDegreesToRadians(x) (M_PI * (x*180) / 180.0f)
#define fromDegreesToRadians(x) (M_PI * x / 180.0f)


//
//#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
//#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
//#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
//#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
//#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
//#define iOSVersion9()  ([[[UIDevice currentDevice] systemVersion] compare:9.1 options:NSNumericSearch] != NSOrderedAscending)
//
//#define iOSVersion(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)



#endif /* MysticUtility_h */


@interface MLogObj : NSObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) id value;

+ (instancetype) key:(NSString *)key value:(id)value;

@end
MLogObj * SPCif(BOOL cond, NSString *key, id value);

MLogObj * SKPif(BOOL cond, NSString *key, id value);
MLogObj * LOR(BOOL cond, NSString *key, id value, NSString *key2, id value2);

