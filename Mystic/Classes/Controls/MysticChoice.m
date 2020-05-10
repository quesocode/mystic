//
//  MysticChoice.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/24/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticChoice.h"
#import "NSString+Mystic.h"
#import "UIColor+Mystic.h"
#import "MysticShapesKit.h"
#import "FBBezierGraph.h"
#import "MysticTransView.h"
#import "ARCGPathFromString.h"
#import "UIBezierPath+TextPaths.h"
#import "MysticController.h"
@interface MysticChoice ()
{
    CGRect _previousPathBounds, _originalViewFrame;
    BOOL _updateViewBefore;
    NSNumber *_prevHasShadow;
    float _changedBorderWidth;
    
}
@property (nonatomic, retain) NSMutableDictionary *viewsInfo;
@end
@implementation MysticChoice

@synthesize frame = _frame, borderWidth=_borderWidth, frameSet=_frameSet, effectsHaveChanged=_effectsHaveChanged, effectsHaveToBeDrawn=_effectsHaveToBeDrawn, borderColor=_borderColor, originalContentFrame=_originalContentFrame, shadowRadius=_shadowRadius;

- (void) dealloc;
{
    [super dealloc];
    _contentView=nil;
    [_viewsInfo release], _viewsInfo=nil;
    [_info release], _info = nil;
    [_image release], _image = nil;
    [_highlightedImage release], _highlightedImage=nil;
    [_selectedImage release], _selectedImage=nil;
    [_disabledImage release], _disabledImage=nil;
    if(_tag) [_tag release], _tag=nil;
    [_color release], _color=nil;
    [_color2 release], _color2=nil;
    [_color3 release], _color3=nil;
    [_color4 release], _color4=nil;
    [_borderColor release], _borderColor=nil;
    [_backgroundColor release], _backgroundColor=nil;
    _shadowPath = nil;
    [_shadowColor release], _shadowColor=nil;
    [_texture release], _texture=nil;
    [_mask release], _mask=nil;
    [_name release], _name = nil;
    [_title release], _title = nil;
    [_key release], _key = nil;
    [_path release], _path = nil;
    [_attributedString release], _attributedString = nil;
    [_drawAroundFrame release], _drawAroundFrame = nil;
    [_lineJoin release];
    [_lineCap release];
    [_embossColor release];
    [_embossDarkColor release];
    [_extrudeColor release];
    [_innerShadowColor release];
    [_emboss release];
    [_innerShadow release];
    [_extrude release];
    [_effectsHaveToBeDrawn release];
    [_innerBevel release];
    [_bevel release];
    [_bevelColor release];
    if(_prevHasShadow) [_prevHasShadow release];
    [_bevelShadowColor release];
    [_innerBevelColor release];
    [_innerBevelShadowColor release];
}

+ (id) choiceWithInfo:(id)info key:(NSString *)key type:(MysticObjectType)type;
{
    MysticChoice *obj = [[[self class] alloc] init];
    
    obj.type = type;
    obj.info = [info isKindOfClass:[MysticChoice class]] ?  [NSMutableDictionary dictionaryWithDictionary:[(MysticChoice *)info info]] : [NSMutableDictionary dictionaryWithDictionary:info ? info : @{}];
    if([info isKindOfClass:[MysticChoice class]]) [obj addChoice:(id)info];
    if(key) obj.key = key;
    NSString *content = obj.content ? obj.content : key ? [key hasSuffix:@":"] ? key : [key suffix:@":"] : nil;
    if(!obj.content && content) [obj.info setObject:content forKey:@"content"];
    if(!obj.function && [obj.content hasSuffix:@":"]) [obj.info setObject:obj.content forKey:@"function"];
    return [obj autorelease];
}

- (id) init;
{
    self = [super init];
    if(self)
    {
        _size = CGSizeUnknown;
        self.showAllActiveControls = NO;
        self.isActive = NO;
        self.cancelsEffect = NO;
        self.type = MysticObjectTypeUnknown;
        _frame = CGRectZero;
        self.info = [NSMutableDictionary dictionary];
        self.viewsInfo = [NSMutableDictionary dictionary];
        _borderWidth = NAN;
        _borderAlpha = NAN;
        _changedBorderWidth = NAN;
        _originalContentFrame = CGRectUnknown;
        _thumbnailBorderWidth = NAN;
        _alpha = NAN;
        _refitFrame = NO;
        _inflectionRadiusPercent = NAN;
        _inflections = NSNotFound;
        _shadowAlpha = NAN;
        _updateViewBefore = NO;
        _shadowRadius = NAN;
        _center = CGPointUnknown;
        _setting = MysticSettingUnknown;
        _shadowOffset = CGSizeUnknown;
        _contentMode = NAN;
        _offset = CGPointUnknown;
        _isThumbnail = NO;
        _rebuildFrame = NO;
        _propertiesScale = CGScaleEqual;
        _frame = CGRectUnknown;
        _bounds = CGRectUnknown;
        _borderPosition = MysticPositionOutside;
        _maxWidth = NAN;
        _drawAroundFrame = nil;
        _alphaChangesColor = NO;
        _previousPathBounds = CGRectUnknown;
        _maskFrame = CGRectZero;
        _changedEffects = MysticChoiceUnknown;
        _originalInnerFrame = CGRectZero;
        _originalViewFrame = CGRectZero;
        _prevHasShadow = nil;
        self.frameSet = NO;
        _onlyDrawBorder = YES;
        _embossBlur = NAN;
        _embossRadius = NAN;
        _innerShadowBlur = NAN;
        _innerShadowSize = CGSizeUnknown;
        _embossSize = CGSizeUnknown;
        _pathBounds = CGRectUnknown;
        _embossDarkSize = CGSizeUnknown;
        _embossSizeChange = CGSizeUnknown;
        _innerBevelRadius = NAN;
        _innerBevelAngle = NAN;
        _bevelRadius = NAN;
        _bevelAngle = NAN;
        _bevelBlur = NAN;
        _innerBevelBlur = NAN;
        _extrudeAngle = NAN;
        _extrudeRadius = NAN;
        _effectsHaveToBeDrawn = nil;
        _emboss = nil;
        _innerShadow = nil;
        _extrude = nil;
        _bevel = nil;
        _innerBevel = nil;
        _cornerRadius = NAN;
        
    }
    return self;
}
- (void) effect:(MysticChoiceProperty)effect changed:(BOOL)changed;
{
    switch (effect) {
        case MysticChoiceBorder:
        case MysticChoiceFill:
        case MysticChoiceShadow:
            
            break;
            
        default:
        {
            _effectsHaveChanged = effect > MysticChoiceNone  && changed ? YES : _effectsHaveChanged;
            break;
        }
    }
    if(effect == MysticChoiceNone)
    {
        _changedEffects = MysticChoiceNone;
        _effectsHaveChanged = NO;
    }
    else
    {
        if(changed && !(self.changedEffects & effect))
        {
            self.changedEffects |= effect;
        }
        else if(!changed && self.changedEffects & effect)
        {
            self.changedEffects = self.changedEffects & ~effect;
        }
        if(_changedEffects & MysticChoiceUnknown) _changedEffects = _changedEffects & ~MysticChoiceUnknown;
        if(_changedEffects & MysticChoiceNone) _changedEffects = _changedEffects & ~MysticChoiceNone;
    }
}
- (NSString *) packName;
{
    return self.info[@"pack"] ? self.info[@"pack"] : nil;
}
- (NSString *) function;
{
    return self.info[@"function"] ? self.info[@"function"] : nil;
}
- (NSString *) changedEffectsString;
{
    NSMutableString *s = [NSMutableString stringWithString:@""];
    if(_changedEffects & MysticChoiceUnknown) [s appendString:@"Unknown, "];
    if(_changedEffects & MysticChoiceNone) [s appendString:@"None, "];
    if(_changedEffects & MysticChoiceFill) [s appendString:@"Fill, "];
    if(_changedEffects & MysticChoiceBorder) [s appendString:@"Border, "];
    if(_changedEffects & MysticChoiceShadow) [s appendString:@"Shadow, "];
    if(_changedEffects & MysticChoiceEmboss) [s appendString:@"Emboss, "];
    if(_changedEffects & MysticChoiceBevel) [s appendString:@"Bevel, "];
    if(_changedEffects & MysticChoiceInnerShadow) [s appendString:@"Inner Shadow, "];
    if(_changedEffects & MysticChoiceInnerBevel) [s appendString:@"Inner Bevel, "];
    if(_changedEffects & MysticChoiceExtrude) [s appendString:@"Extrude, "];
    return s.length > 0 ? [s substringToIndex:s.length-2] : s;
}
- (void) setEffectsHaveChanged:(BOOL)effectsHaveChanged;
{
    _effectsHaveChanged = effectsHaveChanged;
    _changedEffects = effectsHaveChanged ? _changedEffects : MysticChoiceNone;
}
- (BOOL) drawEffectsOnViewLayer;
{
    if(!_drawAroundFrame || self.type==MysticObjectTypeFont) return NO;
    return [_drawAroundFrame boolValue];
}
- (void) setDrawEffectsOnViewLayer:(BOOL)value;
{
    if(_drawAroundFrame) [_drawAroundFrame release], _drawAroundFrame=nil;
    _drawAroundFrame = [[NSNumber numberWithBool:value] retain];
}
- (id) copy;
{
    MysticChoice *c = [[self class] choiceWithInfo:self.info key:self.key type:self.type];
    [c addChoice:self];
    return [c retain];
}
- (instancetype) addChoice:(MysticChoice *)otherChoice;
{
    return [self addChoice:otherChoice resetInfo:YES];
}
- (instancetype) addChoice:(MysticChoice *)otherChoice resetInfo:(BOOL)resetInfo;
{
    if([self isEqual:otherChoice]) return self;
    if(resetInfo)
    {
        [self.info removeAllObjects];
        [self.info addEntriesFromDictionary:otherChoice.info];
        self.key = otherChoice.key;
        self.propertiesScale = otherChoice.propertiesScale;
        self.propertiesScaleInverse = otherChoice.propertiesScaleInverse;
    }
    self.refitFrame = otherChoice.refitFrame;
    self.originalInnerFrame = otherChoice.originalInnerFrame;
    self.originalContentFrame = otherChoice.originalContentFrame;
    [self.viewsInfo addEntriesFromDictionary:otherChoice.viewsInfo];
    self.alphaChangesColor = otherChoice.alphaChangesColor;
    self.shadowOffset = otherChoice.shadowOffset;
    self.shadowPath = otherChoice.shadowPath;
    self.shadowColor = otherChoice.shadowColor;
    if(!isnan(otherChoice.shadowAlpha)) self.shadowAlpha = otherChoice.shadowAlpha;
    if(!isnan(otherChoice.shadowRadius)) self.shadowRadius = otherChoice.shadowRadius;
    self.drawAroundFrame = otherChoice.drawAroundFrame;
    self.color = otherChoice.color;
    self.color2 = otherChoice.color2;
    self.color3 = otherChoice.color3;
    self.color4 = otherChoice.color4;
    self.bounds=otherChoice.bounds;
    self.frame=otherChoice.frame;
    self.borderColor = [otherChoice borderColor:NO];
    if(!isnan(otherChoice.borderAlpha)) self.borderAlpha = otherChoice.borderAlpha;
    if(!isnan(otherChoice.borderWidthValue)) self.borderWidth = otherChoice.borderWidth;
    if(otherChoice.hasCornerRadius) self.cornerRadius = otherChoice.cornerRadius;
    if(otherChoice.alpha != 1) self.alpha = otherChoice.alpha;
    self.backgroundColor = otherChoice.backgroundColor;
    self.setting = otherChoice.setting;
    self.texture = otherChoice.texture;
    
    self.borderPosition = otherChoice.borderPosition;
    self.alpha = otherChoice.alpha;
    self.attributedString = otherChoice.attributedString;
    self.dashSize = otherChoice.dashSize;
    [self setScale:otherChoice.scale scaleProperties:NO];
    self.mask = otherChoice.mask;
    self.isThumbnail = otherChoice.isThumbnail;
    self.setting = otherChoice.setting;
    self.usesCustomDrawing = otherChoice.usesCustomDrawing;
    if(otherChoice.contentMode != UIViewContentModeScaleAspectFit) self.contentMode = otherChoice.contentMode;
    [self updateTag];
    self.innerShadow = otherChoice.innerShadow;
    self.innerShadowColor = otherChoice.innerShadowColor;
    self.innerShadowSize = otherChoice.innerShadowSize;
    self.innerShadowBlur = otherChoice.innerShadowBlur;
    self.embossSize = otherChoice.embossSize;
    self.emboss = otherChoice.emboss;
    self.embossBlur = otherChoice.embossBlur;
    self.embossRadius = otherChoice.embossRadius;
    self.embossColor = otherChoice.embossColor;
    self.embossDarkColor = otherChoice.embossDarkColor;
    
    if(otherChoice.hasInflections) self.inflections = !otherChoice.info[@"inflections"] ? NSNotFound : otherChoice.inflectionsValue;
    if(otherChoice.hasInflections) self.inflectionRadiusPercent = !otherChoice.info[@"inflectionRadiusPercent"] ? NAN : otherChoice.inflectionRadiusPercentValue;

    self.extrude = otherChoice.extrude;
    self.extrudeColor = otherChoice.extrudeColor;
    self.extrudeAngle = otherChoice.extrudeAngle;
    self.extrudeRadius = otherChoice.extrudeRadius;
    self.lineCap = otherChoice.lineCap;
    self.lineJoin = otherChoice.lineJoin;
    
    self.innerBevel = otherChoice.innerBevel;
    self.bevel = otherChoice.bevel;
    self.bevelColor = otherChoice.bevelColor;
    self.bevelRadius = otherChoice.bevelRadius;
    self.bevelAngle = otherChoice.bevelAngle;
    self.innerBevelColor = otherChoice.innerBevelColor;
    self.innerBevelRadius = otherChoice.innerBevelRadius;
    self.innerBevelAngle = otherChoice.innerBevelAngle;
    return self;
}
- (NSInteger) inflectionsValue; { return _inflections; }
- (float) inflectionRadiusPercentValue; { return _inflectionRadiusPercent; }
- (BOOL) hasEffectsThatHaveToBeDrawn;
{
    if(_effectsHaveToBeDrawn != nil) return _effectsHaveToBeDrawn.boolValue;
    return (_emboss != nil && _emboss.boolValue) || (_innerShadow != nil && _innerShadow.boolValue) || (_innerBevel != nil && _innerBevel.boolValue) || (_bevel != nil && _bevel.boolValue) || (_extrude != nil && _extrude.boolValue);
}
- (BOOL) isSame:(id)otherChoice;
{
    if([self isEqual:otherChoice]) return YES;
    if(![self isKindOfClass:[otherChoice class]]) return NO;
    MysticChoice *_otherChoice = otherChoice;
    if([_otherChoice.tag isEqualToString:self.tag]) return YES;
    return NO;
}
- (void) setInfo:(NSMutableDictionary *)info;
{
    if(_info && info && [_info isEqual:info]) return;
    if(_info) [_info release], _info=nil;
    _info = info ? [info retain] : [[NSMutableDictionary dictionary] retain];
    [self updateTag];
}
- (id) objectForKey:(id)key;
{
    return [self.info objectForKey:key];
}
- (id) info:(id)key;
{
    return key ? self.info[key] : nil;
}
- (void) updateTag;
{
    if(_tag) [_tag release], _tag=nil;
    _tag = [[[NSString stringWithFormat:@"%@-%@-%@", [_info.description md5], MysticString(self.type), [self class]] md5] retain];
    if([self info:@"key"] && (!self.key || ![self.key isEqualToString:[self info:@"key"]]))
    {
        self.key = [self info:@"key"];
    }
    else if([self info:@"content"] && (!self.key || ![self.key isEqualToString:[self info:@"content"]]))
    {
        self.key = [self info:@"content"];
    }
}
- (CGSize) size;
{
    _size = CGSizeIsUnknown(_size) ? !isNull([self info:@"size"]) ? CGSizeMakeWithString([self info:@"size"]) : CGSizeUnknown : _size;
    return CGSizeIsUnknown(_size) && self.attributedString ? self.attributedString.size :  _size;
}
- (CGSize) shadowOffset;
{
    return CGSizeIsUnknown(_shadowOffset) ? !isNull([self info:@"shadowOffset"]) ? CGSizeMakeWithString([self info:@"shadowOffset"]) : CGSizeUnknown : _shadowOffset;
}
- (id) content;
{
    return [self info:@"content"];
}
- (NSString *) title;
{
    if(_title) return _title;
    return [self info:@"title"] ? [self info:@"title"] : self.name ? self.name : self.key ? self.key : [NSString stringWithFormat:@"%@", self.content];
}
- (NSString *) name;
{
    NSString *name = _name ? _name : [self info:@"name"];
    if(!name && self.attributedString) name = self.attributedString.string;
    if(!name && self.info[@"content"]) name = self.info[@"content"];
    return name;
}
//- (void) setShadowRadius:(float)shadowRadius;
//{
//    DLogWarn(@"setting shadow radius: %2.2f", shadowRadius);
//    _shadowRadius = shadowRadius;
//    
//}

- (BOOL) hasCornerRadius; { return self.cornerRadius > 0; }
- (BOOL) hasBorder; { return self.borderWidth > 0 && ((_borderAlpha > 0 && !isnan(_borderAlpha)) || isnan(_borderAlpha));  }
- (BOOL) hasShadow;
{
    BOOL p = _prevHasShadow ? _prevHasShadow.boolValue : NO;
    BOOL hasValue = NO;
    NSString * i = @"";
    if(!hasValue && !isnanOrZero(self.shadowAlphaValue)) {hasValue = YES; i = [i stringByAppendingString:@"1|"];}
    if(!hasValue && !CGSizeIsUnknown(self.shadowOffset)) { i = [i stringByAppendingString:@"2|"]; }
    if(!hasValue && (self.shadowAlpha == 0 && !CGSizeIsZero(self.shadowOffset))) {i =  [i stringByAppendingString:@"3|"]; }
    if(!hasValue && (self.shadowAlpha > 0 && self.shadowRadius > 0 && CGSizeIsZero(self.shadowOffset))) {i =  [i stringByAppendingString:@"4|"]; }

    if(!hasValue && !CGSizeIsUnknown(self.shadowOffset) && ((self.shadowAlpha > 0 && !CGSizeIsZero(self.shadowOffset)) || (self.shadowAlpha > 0 && self.shadowRadius > 0 && CGSizeIsZero(self.shadowOffset)))) {
        
        hasValue = YES;
        i =  [i stringByAppendingString:@"5"];
    }

//    DLog(@"choice has shadow: %@", i);
    _prevHasShadow = [@(hasValue) retain];
    return hasValue;
}
- (float) borderWidth;
{
    if(!isnan(_borderWidth) && _borderWidth > 0.3) return _borderWidth;
    if(!isNull([self.info objectForKey:@"borderWidth"]))
    {
        return [[self.info objectForKey:@"borderWidth"] floatValue];
    }
    return 0;
}
- (void) setBorderWidth:(float)borderWidth;
{
    [self setBorderWidth:borderWidth sender:nil];
}
- (void) setBorderWidth:(float)borderWidth sender:(id)sender;
{
    if(self.borderPosition != MysticPositionInside && !isnan(borderWidth) && borderWidth >= 2 && !isnan(_changedBorderWidth) && sender)
    {
        _changedBorderWidth = NAN;
    }
    _borderWidth = borderWidth;
    
}
- (void) setBorderPosition:(MysticPosition)borderPosition;
{
    if(borderPosition == MysticPositionInside && _borderPosition != MysticPositionInside && isnan(_changedBorderWidth))
    {
        _borderWidth = MAX(_borderWidth/2, 1);
        _changedBorderWidth = _borderWidth;
    }
    else if(borderPosition == MysticPositionInside && _borderPosition != MysticPositionInside && !isnan(_changedBorderWidth))
    {
        _borderWidth = _changedBorderWidth;
        //        _changedBorderWidth = NAN;
    }
    
    _borderPosition = borderPosition;
}
- (float) thumbnailBorderWidth;
{
    if(!isnan(_thumbnailBorderWidth)) return _thumbnailBorderWidth;
    if(!isNull([self.info objectForKey:@"thumbnailBorderWidth"]))
    {
        return [[self.info objectForKey:@"thumbnailBorderWidth"] floatValue];
    }
    return 0;
}
- (float) cornerRadiusValue; { return _cornerRadius; }
- (float) alphaValue; { return _alpha; }
- (float) shadowAlphaValue; { return _shadowAlpha; }
- (float) borderAlphaValue; { return _borderAlpha; }
- (float) borderWidthValue; { return _borderWidth; }
- (float) shadowRadiusValue; { return _shadowRadius; }
- (CGSize) shadowOffsetValue; { return _shadowOffset; }

- (float) borderAlpha;
{
    if(!isnan(_borderAlpha)) return _borderAlpha;
    if(!isNull([self.info objectForKey:@"borderAlpha"]))
    {
        return MIN(1, MAX(0, [[self.info objectForKey:@"borderAlpha"] floatValue]));
    }
    return 1;
}
- (BOOL) hasInflections; { return !isnanOrZero(self.inflections); }


- (NSInteger) inflections;
{

    if(_inflections != NSNotFound) return _inflections;
    
    
    if(!isNull([self.info objectForKey:@"inflections"]))
    {
        int a = MAX(0, [[self.info objectForKey:@"inflections"] integerValue]);
        return a;
    }
    return 0;
}
- (float) inflectionRadiusPercent;
{
    if(!isnan(_inflectionRadiusPercent)) return MIN(1, MAX(0, _inflectionRadiusPercent));
    if(!isNull([self.info objectForKey:@"inflectionRadiusPercent"]))
    {
        int a = MIN(1, MAX(0, [[self.info objectForKey:@"inflectionRadiusPercent"] integerValue]));
        return a;
    }
    return 1;
}
- (float) cornerRadius;
{
    if(!isnan(_cornerRadius)) return _cornerRadius;
    if(!isNull([self.info objectForKey:@"cornerRadius"]))
    {
        float a = MAX(0, [[self.info objectForKey:@"cornerRadius"] floatValue]);
        if(a > 1) return a;
        if(a > 0)
        {
            return !CGRectUnknownOrZero(_frame) ? MIN(_frame.size.height * a, _frame.size.width * a) : !CGSizeIsUnknownOrZero(self.size) ? MIN(self.size.width*a, self.size.height*a) : 0;
        }
    }
    return 0;
}
- (float) alpha;
{
    if(!isnan(_alpha)) return _alpha;
    if(!isNull([self.info objectForKey:@"alpha"]))
    {
        return MIN(1, MAX(0, [[self.info objectForKey:@"alpha"] floatValue]));
    }
    return 1;
}
- (float) shadowAlpha;
{
    if(!isnan(_shadowAlpha)) return _shadowAlpha;
    if(!isNull([self.info objectForKey:@"shadowAlpha"]))
    {
        return MIN(1, MAX(0, [[self.info objectForKey:@"shadowAlpha"] floatValue]));
    }
    if(isnan(_shadowAlpha) && !CGSizeIsUnknownOrZero(self.shadowOffset)) return 0.75;
    return 0;
}
- (float) shadowRadius;
{
    if(!isnan(_shadowRadius)) return _shadowRadius;
    if(!isNull([self.info objectForKey:@"shadowRadius"]))
    {
        return [[self.info objectForKey:@"shadowRadius"] floatValue];
    }
    return 0;
}
- (UIViewContentMode) contentMode;
{
    if(!isnan(_contentMode)) return _contentMode;
    if(!isNull([self.info objectForKey:@"contentMode"]))
    {
        return [[self.info objectForKey:@"contentMode"] integerValue];
    }
    return UIViewContentModeScaleAspectFit;
}
- (UIColor *) color;
{
    if(_color) return _color;
    if(self.info[@"color"] && ![self.info[@"color"] equals:@"clear"])
    {
        return [UIColor string:[self.info objectForKey:@"color"]];
    }
    return nil;
}


- (UIColor *) color2;
{
    if(_color2) return _color2;
    if(self.info[@"color2"] && ![self.info[@"color2"] equals:@"clear"])
    {
        return [UIColor string:[self.info objectForKey:@"color2"]];
    }
    return nil;
}
- (UIColor *) color3;
{
    if(_color3) return _color3;
    if(self.info[@"color3"] && ![self.info[@"color3"] equals:@"clear"])
    {
        return [UIColor string:[self.info objectForKey:@"color3"]];
    }
    return nil;
}
- (UIColor *) color4;
{
    if(_color4) return _color4;
    if(self.info[@"color4"] && ![self.info[@"color4"] equals:@"clear"])
    {
        return [UIColor string:[self.info objectForKey:@"color4"]];
    }
    return nil;
}
- (UIColor *) thumbnailBorderColor;
{
    if(_thumbnailBorderColor) return _thumbnailBorderColor;
    if([self.info objectForKey:@"thumbnailBorderColor"])
    {
        return [UIColor string:[self.info objectForKey:@"thumbnailBorderColor"]];
    }
    return nil;
}

- (UIColor *) backgroundColor;
{
    if(_backgroundColor) return _backgroundColor;
    if([self.info objectForKey:@"backgroundColor"])
    {
        return [UIColor string:[self.info objectForKey:@"backgroundColor"]];
    }
    return nil;
}
- (UIColor *) shadowColor;
{
    if(_shadowColor) return _shadowColor;
    if([self.info objectForKey:@"shadowColor"])
    {
        return [UIColor string:[self.info objectForKey:@"shadowColor"]];
    }
    return nil;
}

- (CGScaleOfView) scaleOfView:(MysticLayerBaseView *)fromView fromView:(UIView *)toView;
{
    CGScaleOfView t = CGScaleOfViewEqual;
    t.views = CGRectsMatchSize(toView.smallestSubviewFrame, fromView.transView.smallestSubviewFrame);
    t.offset=CGPointAdd(toView.center, CGPointDiff([[MysticController controller].view convertPoint:fromView.center fromView:fromView.superview], [[MysticController controller].view convertPoint:toView.center fromView:toView.superview]));
    t.frame1 = fromView.transView.contentView.frame;
    t.frame2 = toView.frame;
    t.scale = CGScaleOfRectsMin(t.frame1, t.frame2);
    t.transform = CGScaleTransform(toView.transform, t.scale);
    if(!fromView.transView.hasBorderView)
    {
        t.transform = CGScaleTransform(t.transform, t.views.scale);
        t.scale = CGScaleScale(t.scale, t.views.scale);
    }
    return t;
}

#pragma mark - Scale 

- (void) setScale:(CGScale)scale;
{
    [self setScale:scale scaleProperties:YES];
}
- (instancetype) setScale:(CGScale)scale scaleProperties:(BOOL)shouldScale;
{
    if(CGScaleIsUnknownEqualOrZero(scale)) { _scale = CGScaleEqual; return nil; }
    _scale = scale;
    return shouldScale ? [self scale:scale] : self;
}

- (void) setPropertiesScaleInverse:(CGScale)propertiesScaleInverse;
{
    _propertiesScaleInverse = propertiesScaleInverse;
    
}

- (instancetype) resetScale:(CGScale)scale;
{
    [self resetScale];
    return [self scale:scale];
}
- (instancetype) resetScale;
{
//    if(CGScaleIsUnknownEqualOrZero(self.propertiesScaleInverse)) { return self; }
    return [self scale:self.propertiesScaleInverse];
}
- (instancetype) scale:(CGScale)scale;
{    
    if(CGScaleIsUnknownEqualOrZero(scale)) { self.propertiesScale = CGScaleEqual; self.propertiesScaleInverse = CGScaleEqual; return self; }
    BOOL changed = NO;
    float v;
    if(!isnanOrZero(_cornerRadius))
    {
        v = self.cornerRadius * scale.scale;
        changed = changed ? changed : v != self.cornerRadius;
        self.cornerRadius = v;
    }

    
    if(!isnanOrZero(_innerBevelRadius))
    {
        v = _innerBevelRadius*scale.scale;
        changed = changed ? changed : v != _innerBevelRadius;
        _innerBevelRadius = v;
    }
    if(!isnanOrZero(_bevelRadius))
    {
        v = _bevelRadius*scale.scale;
        changed = changed ? changed : v != _bevelRadius;
        _bevelRadius = v;
    }
    if(!isnanOrZero(_bevelBlur))
    {
        v = _bevelBlur*scale.scale;
        changed = changed ? changed : v != _bevelBlur;
        _bevelBlur = v;
    }
    if(!isnanOrZero(_extrudeRadius))
    {
        v = _extrudeRadius*scale.scale;
        changed = changed ? changed : v != _extrudeRadius;
        _extrudeRadius = v;
    }
    
    if(!isnanOrZero(_borderWidth))
    {
        v = _borderWidth*scale.scale;
        changed = changed ? changed : v != _borderWidth;
        _borderWidth = v;
    }
    if(!isnanOrZero(_embossBlur))
    {
        v = _embossBlur*scale.scale;
        changed = changed ? changed : v != _embossBlur;
        _embossBlur = v;
    }
    if(!isnanOrZero(_embossRadius))
    {
        v = _embossRadius*scale.scale;
        changed = changed ? changed : v != _embossRadius;
        _embossRadius = v;
    }
    if(!CGSizeIsUnknownOrZero(self.innerShadowSize))
    {
        CGSize s = CGSizeScale(self.innerShadowSize, scale.scale);
        changed = changed ? changed : !CGSizeEqualToSize(s, self.innerShadowSize);
        self.innerShadowSize = s;
    }
    if(!CGSizeIsUnknownOrZero(self.embossDarkSize))
    {
        CGSize s = CGSizeScale(self.embossDarkSize, scale.scale);
        changed = changed ? changed : !CGSizeEqualToSize(s, self.embossDarkSize);
        self.embossDarkSize = s;
    }
    if(!CGSizeIsUnknownOrZero(self.embossSize))
    {
        CGSize s = CGSizeScale(self.embossSize, scale.scale);
        changed = changed ? changed : !CGSizeEqualToSize(s, self.embossSize);
        self.embossSize = s;
    }
    if(!CGSizeIsUnknownOrZero(self.embossSizeChange))
    {
        CGSize s = CGSizeScale(self.embossSizeChange, scale.scale);
        changed = changed ? changed : !CGSizeEqualToSize(s, self.embossSizeChange);
        self.embossSizeChange = s;
    }
    if(self.hasShadow)
    {
        self.shadowOffset = CGSizeIsUnknown(self.shadowOffset) ? CGSizeUnknown : CGSizeScaleWithScale(self.shadowOffset, scale);
        self.shadowRadius = isnanOrZero(self.shadowRadius) ? self.shadowRadius : self.shadowRadius*scale.scale;
    }
    self.propertiesScaleInverse = CGScaleInverse(scale);
    self.propertiesScale = CGScaleEqual;
    self.rebuildFrame = changed;
    return self;
}

- (void) setFrame:(CGRect)frame;
{
    _frame = frame;
    self.frameSet = CGRectUnknownOrZero(frame) ? NO : _frameSet;
}
- (UIColor *) innerShadowColorOrDefault;
{
    return self.innerShadowColor ? self.innerShadowColor : [[UIColor blackColor] alpha:0.5];
}

- (UIColor *) innerBevelColorOrDefault;
{
    return self.innerBevelColor ? self.innerBevelColor : [self.color darker:0.5];
}
- (UIColor *) bevelColorOrDefault;
{
    return self.bevelShadowColorOrDefault;
//    return self.bevelColor ? self.bevelColor : [self.color alpha:self.alpha];
}
- (UIColor *) bevelShadowColorOrDefault;
{
    return self.bevelShadowColor ? self.bevelShadowColor : self.bevelColor ? [self.bevelColor darker:0.5] : [self.color darker:0.5];
}
- (UIColor *) innerBevelShadowColorOrDefault;
{
    return self.innerBevelShadowColor ? self.innerBevelShadowColor : [self.color darker:0.5];
}
- (UIColor *) embossColorOrDefault;
{
    return self.embossColor ? self.embossColor : self.embossDarkColor ? [self.embossDarkColor lighter:0.5] : [self.color lighter:0.5];
}
- (UIColor *) embossDarkColorOrDefault;
{
    return self.embossDarkColor ? self.embossDarkColor : [self.color darker:0.5];
}
- (UIColor *) colorOrDefault;
{
    return self.color ? self.color : [UIColor white];
}
- (UIColor *) borderColorOrDefault;
{
    return [self borderColor:YES];
}
- (UIColor *) borderColor;
{
    return [self borderColor:YES];
}
- (UIColor *) borderColor:(BOOL)returnDefault;
{
    if(_borderColor) return _borderColor;
    if([self.info objectForKey:@"borderColor"])
    {
        return [UIColor string:[self.info objectForKey:@"borderColor"]];
    }
    return returnDefault ? [UIColor blackColor] : nil;
}
- (NSNumber *) emboss;
{
    if(!_emboss || self.changedEffects & MysticChoiceEmboss) return @(NO);
    return _emboss;
}
- (NSNumber *) innerBevel;
{
    if(!_innerBevel || self.changedEffects & MysticChoiceInnerBevel) return @(NO);
    return _innerBevel;
}
- (NSNumber *) extrude;
{
    if(!_extrude || self.changedEffects & MysticChoiceExtrude) return @(NO);
    return _extrude;
}
- (NSNumber *) innerShadow;
{
    if(!_innerShadow || self.changedEffects & MysticChoiceInnerShadow) return @(NO);
    return _innerShadow;
}
- (NSNumber *) bevel;
{
    if(!_bevel || self.changedEffects & MysticChoiceBevel) return @(NO);
    return _bevel;
}
- (UIImage *) image:(CGSize)size color:(UIColor *)color scale:(float)scale quality:(CGInterpolationQuality)quality contentMode:(UIViewContentMode)contentMode;
{
    UIImage *img=nil;
    if(!self.usesCustomDrawing)
    {
        img = [MysticImage image:[self info:@"thumbnail"] ? [self info:@"thumbnail"] : [self info:@"content"] size:size color:color];
    }
    else
    {
        UIGraphicsBeginImageContextWithOptions(size, NO, scale == 0 ? [MysticUI scale] : scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        CGContextSetShouldSmoothFonts(context, YES);
        CGContextSetShouldAntialias(context, YES);
        CGSize imgSize = self.size;
        CGRect irect = CGRectSize(size);
        if(!CGSizeIsUnknownOrZero(imgSize))
        {
            irect = CGRectWithContentMode(CGRectSize(imgSize), CGRectSize(size), contentMode == UIViewContentModeRedraw || (int)contentMode < 0 ? self.contentMode : contentMode);
        }
        MysticChoice *newChoice = [MysticChoice choiceWithInfo:self key:nil type:self.type];
        if(color && (!self.color || ![self.color isEqualToColor:color])) newChoice.color = color;
        newChoice.frame = irect;
        [[[MysticShapesKit kit] class] draw:newChoice frame:irect];
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    self.isThumbnail = NO;
    return img;
}
- (SEL) customDrawingSelector;
{
    return NSSelectorFromString(self.info[@"function"] ? [self.info objectForKey:@"function"] : self.info[@"content"]);
}
- (BOOL) usesCustomDrawing;
{
    BOOL f =  [self.info objectForKey:@"function"] != nil;
    if(!f && !_drawAroundFrame && self.type!=MysticObjectTypeFont) self.drawEffectsOnViewLayer = YES;
    return self.attributedString || self.type==MysticObjectTypeFont ? YES : f;
}
- (NSString *) defaultLineCap;
{
    return self.attributedString ? kCALineCapRound : kCALineCapButt;
}
- (NSString *) defaultLineJoin;
{
    return self.attributedString ? kCALineJoinRound : kCALineJoinMiter;
}
- (void) setAttributedString:(MysticAttrString *)attributedString;
{
    if(_attributedString) [_attributedString release];
    _attributedString = !attributedString ? nil : [attributedString retain];
    self.path = nil;
    self.pathInfo = nil;
}
- (void) setPath:(UIBezierPath *)path;
{
    if(_path) [_path release], _path=nil;
    _path = path && !isNull(path) ? [path retain] : nil;
    if(!_path) _frame = CGRectUnknown;
    self.frameSet = !_path ? NO : YES;
}
- (BOOL) isEqualToChoice:(MysticChoice *)choice;
{
    return [choice isKindOfClass:self.class] && [choice.name isEqualToString:self.name];
}
- (CGRect) frame;
{
    return !CGRectIsZero(_frame) ? _frame : !isNull(self.info[@"frame"]) ? [self.info[@"frame"] CGRectValue] : CGSizeIsZero(self.size) ? CGRectZero : CGRectSize(_size);
}
- (CGRect) pathBounds;
{
    return self.hasPathInfo ? self.pathInfo.frame : CGRectUnknownOrZero(self.bounds) ? CGRectZero : self.bounds;
}
- (BOOL) hasPathInfo; { return _pathInfo != nil; }
- (MysticPath *) pathInfo;
{
    if(_pathInfo) return _pathInfo;
    _pathInfo = [[MysticPath alloc] init];
    [_pathInfo setChoice:self maxWidth:!isnan(_maxWidth) ? _maxWidth : self.originalContentFrame.size.width];
    return _pathInfo;
}
- (id) setNeedsLayout;
{
    _effectsHaveChanged = self.hasEffectsThatHaveToBeDrawn ? YES : _effectsHaveChanged;
    return self;
}
- (CGPoint) offset;
{
    if(!CGPointIsUnknown(_offset)) return _offset;
    return self.attributedString ? (CGPoint){0, self.attributedString.font.capHeight} : CGPointZero;
}
- (void) resetFraming;
{
    _frameSet=NO;
    self.path = nil;
    self.pathInfo = nil;
}
- (CGRect) originalContentFrame;
{
    NSString *viewId = [NSString format:@"%p-%@", self.contentView, self.name];
    return self.viewsInfo[viewId] ? [self.viewsInfo[viewId] CGRectValue] : CGRectUnknown;
    
}
- (void) setOriginalContentFrame:(CGRect)originalContentFrame;
{
    if(self.contentView)
    {
        NSString *viewId = [NSString format:@"%p-%@", self.contentView, self.name];
        if(CGRectIsUnknown(originalContentFrame))
        {
            [self.viewsInfo removeAllObjects];
//            [self.viewsInfo removeObjectForKey:viewId];
        }
        else
        {
            [self.viewsInfo setObject:[NSValue valueWithCGRect:originalContentFrame] forKey:viewId];
        }
    }
    _originalContentFrame = originalContentFrame;
}
- (CGFrameBounds) updateView:(UIView *)view;
{
    return [self updateView:view debug:nil];
}
- (CGFrameBounds) updateView:(UIView *)_view debug:(id)debug;
{
    [LLog start];
    self.contentView = _view;
    CGPoint originalCenter = _view.center;
    MysticTransView *transView = [_view isKindOfClass:[MysticTransView class]] ? _view : [_view isKindOfClass:[MysticLayerBaseView class]] ? (id)[(MysticLayerBaseView *)_view contentView].view : nil;
    UIView *view = [_view isKindOfClass:[MysticLayerBaseView class]] ? (id)[(MysticLayerBaseView *)_view contentView].view : _view;
    MysticTransContentView *innerView = [view respondsToSelector:@selector(contentView)] ? [view performSelector:@selector(contentView)] : nil;
    BOOL hasBorder = self.hasBorder;
    self.frameBorder = self.bounds;
    _borderWidthValue = self.borderWidth;
    float borderWidth = !hasBorder ? 0 : self.borderWidth + (self.borderPosition != MysticPositionMiddle ? self.borderWidth : 0);
    MysticContentViewBorder *borderView = hasBorder ? transView.borderView : nil;
    MysticContentViewFill *fillView = self.hasEffectsThatHaveToBeDrawn ? nil : transView.fillView;
    @autoreleasepool {
        [LLog set:@"frameSet" b:_frameSet];
        [LLog set:@"rebuildFrame" b:self.rebuildFrame];
        [LLog set:@"refitFrame" b:self.refitFrame];
        [LLog set:@"frameSet" b:_frameSet];
        [LLog set:@"_frame" f:_frame];
        [LLog set:@"_path" b:_path!=nil];

        [LLog set:@"_originalInnerFrame" f:_originalInnerFrame];

        self.bounds = _originalInnerFrame;
        
        CGRect originalBounds = innerView.bounds;
//        [[LLog set:@"_originalContentFrame" f:self.originalContentFrame] purple];
        
        if(CGRectIsUnknown(self.originalContentFrame)) self.originalContentFrame = CGRectz(originalBounds);
        [LLog space];
        [[LLog set:@"originalContentFrame" f:self.originalContentFrame] purple];
        [LLog line];
        [[LLog set:@"contentView" use:[NSString format:@"%p-%@", self.contentView, self.name]] purple];
        CGPoint offset = self.offset;
        if(CGPointIsUnknown(_center) || !CGPointEqual(CGPointCenter(originalBounds), _center)) self.center = CGPointCenter(originalBounds);

        
        MysticBorderLayer *borderLayer = borderView ? borderView.borderLayer : nil;
        MysticMaskLayer *maskLayer = borderView ? borderView.maskLayer : nil;
        MysticFillLayer *fillLayer = fillView ? fillView.fillLayer : nil;
        MysticMaskLayer *previewMaskLayer = nil;
        BOOL setupBorderLayerAlready = borderLayer != nil;
        BOOL setupFillLayerAlready = fillLayer != nil;

        {
            if(self.hasShadow)
            {
                view.layer.shadowOffset = CGSizeIsUnknown(self.shadowOffset) ? CGSizeZero : self.shadowOffset;
                view.layer.shadowColor = self.shadowColor ? self.shadowColor.CGColor : nil;
                view.layer.shadowOpacity = self.shadowAlpha;
                view.layer.shadowRadius = self.shadowRadius;
                view.layer.shadowPath = self.shadowPath;
                
//                DLogError(@"choice has shadow:  %p  view:  %@ superview: %p  %@", self, view.class, view.superview, view.superview.superview.class);
            }
            if(self.hasBorder && self.drawEffectsOnViewLayer && !self.usesCustomDrawing)
            {
                DLog(@"apply border to layer: %@", self.attributedString);
                
                view.layer.borderColor = self.borderColor ? [self.borderColor alpha:self.borderAlpha].CGColor : [[UIColor blackColor] alpha:self.borderAlpha].CGColor;
                view.layer.borderWidth = self.borderWidth;
            }
            if(!self.usesCustomDrawing)
            {
                if(self.hasBorder || self.hasShadow)
                {
                    view.alpha = view.alpha != 1 ? 1 : view.alpha;
                    if(self.colorOrDefault.alpha != self.alpha) self.color = [self.colorOrDefault alpha:self.alpha];
                    self.alphaChangesColor = YES;
                }
                else
                {
                    view.alpha = self.alphaChangesColor || view.alpha != self.alpha ? self.alpha : view.alpha;
                    self.alphaChangesColor = NO;
                    if(self.colorOrDefault.alpha != 1) self.color = [self.colorOrDefault opaque];
                }
            }
        }

        if(self.usesCustomDrawing)
        {
            self.alphaChangesColor = NO;
            if(self.rebuildFrame || (_frameSet && !CGRectUnknownOrZero(_originalInnerFrame) && !CGSizeEqualToSize(_originalInnerFrame.size, originalBounds.size)))
            {
                [[LLog dark] set:@"Passed rebuildframe"];
                _originalInnerFrame = originalBounds;
                CGRect _newFrame = CGRectUnknownOrZero(_frame) || CGRectEqualToRect(CGRectInfinite, _frame) ? CGRectSize(self.size) : _frame;
                _frame = ( CGSizeGreater(_newFrame.size, self.originalContentFrame.size) || self.refitFrame) ? CGRectFit(_newFrame, self.originalContentFrame) : CGRectCenter(_newFrame, self.originalContentFrame);
                [LLog set:@"_frame" f:_frame];

                _frameSet = YES;
                self.path=nil;

            }

            [LLog bg];

            if(!_frameSet || CGRectUnknownOrZero(_originalInnerFrame)) _originalInnerFrame = originalBounds;
            _frame = CGRectFit(_frameSet ? _frame : CGRectSize(self.size), self.originalContentFrame);

            [LLog set:@"_frame" f:_frame];

            self.bounds = _originalInnerFrame;
            
            [LLog set:@"self.bounds" f:self.bounds];

            CGRect newFrame = _frameSet ? _frame : CGRectFit(_frameSet || !self.hasPathInfo ? _frame : self.pathInfo.frame, self.originalContentFrame);
            if(!_frameSet) _frame = newFrame;
            self.frame =  CGRectCenter(_frame, self.originalContentFrame);

            [LLog set:@"_frame" f:_frame];

            if(self.refitFrame && self.path)
            {
                [LLog dark];
                _frame = CGRectCenter(newFrame, self.originalContentFrame);
                [LLog set:@"refitFrame _frame" f:_frame];
                [LLog set:@"refitFrame maxWidth" fl:_maxWidth];

                [self.pathInfo setChoice:self maxWidth:!isnan(_maxWidth) ? _maxWidth : self.originalContentFrame.size.width];
                self.path=self.pathInfo.path;
                [LLog set:[@"refitFrame path:   " suffix:fpad(self.pathBounds)]];

            }
            
            [LLog dark];
            if(!_path)
            {
                self.path = self.pathInfo.path;
                [LLog set:[@"setting path:   " suffix:fpad(self.pathBounds)]];
                if(self.pathAdjustsFrameSize)
                {
                    _frame=self.pathBounds;
                    self.originalContentFrame=_frame;
                }
            }
            self.frameBorder = !hasBorder ? _frame : CGRectSize((CGSize){_frame.size.width + (borderWidth*(self.lineCap == kCALineCapButt ? 1.25 : 1)), _frame.size.height + (borderWidth*(self.lineCap == kCALineCapButt ? 1.25 : 1))});
            self.bounds = !CGRectGreater(self.frameBorder, self.bounds) ? self.bounds : self.frameBorder;
            self.boundsInset = !hasBorder || self.borderPosition!=MysticPositionOutside ? self.bounds : CGRectSizeInset(self.bounds, -self.borderWidth, -self.borderWidth);
            self.frameNoBorder = CGRectCenter(self.pathBounds, self.bounds);
            self.frameNoBorderInset = CGRectCenter(self.pathBounds, self.boundsInset);
            
            [[LLog set:@"self.frameBorder" f:self.frameBorder] blue];
            [LLog set:@"self.bounds" f:self.bounds];
            [LLog set:@"self.boundsInset" f:self.boundsInset];
            [LLog set:@"self.frameNoBorder" f:self.frameNoBorder];
            [LLog set:@"self.frameNoBorderInset" f:self.frameBorder];
            
            if(self.path)
            {
           
                if(borderView && hasBorder)
                {
                    borderLayer = (id)[borderView pathInfo:self.pathInfo];
                    borderLayer.strokeColor = [self.borderColorOrDefault opaque].CGColor;
                    borderLayer.lineWidth = borderWidth;
                    borderLayer.opacity = self.borderAlpha;
                    borderLayer.lineCap = self.lineCap ? self.lineCap : self.defaultLineCap;
                    borderLayer.lineJoin = self.lineJoin ? self.lineJoin : self.defaultLineJoin;
                    borderLayer.geometryFlipped = self.pathInfo.geometryFlipped;
                    
                    self.boundsInset = CGRectInset(CGRectScale(CGRectz(borderLayer.pathBounds), 1.1), -borderWidth, -borderWidth);
                    self.frameNoBorderInset = CGRectCenter(self.pathBounds, self.boundsInset);
                    
                    
                    SetBounds(borderView, self.self.frameNoBorderInset, self.center);
                    
                    switch (self.borderPosition) {
                        case MysticPositionInside:
                        case MysticPositionOutside:
                        {
                            maskLayer = maskLayer ? maskLayer : [MysticMaskLayer layer];
                            switch (self.borderPosition) {
                                case MysticPositionInside:
                                {
                                    self.maskFrame = self.frameNoBorder;
                                    maskLayer.path = self.path.CGPath;
                                    maskLayer.frame = self.maskFrame;
                                    [innerView bringSubviewToFront:borderView];
                                    borderLayer.fillColor = [UIColor clearColor].CGColor;
                                    borderLayer.frame = self.maskFrame;
                                    break;
                                }
                                case MysticPositionOutside:
                                {
                                    borderLayer.frame = self.pathBounds;
                                    maskLayer.scaled = 1.1;
                                    self.maskFrame = CGRectCenterAround(self.boundsInset, CGRectz(self.frameNoBorder));
                                    maskLayer.path = [self.path inverseInRect:self.frameNoBorderInset bounds:self.boundsInset].CGPath;
                                    maskLayer.frame = self.maskFrame;
                                    [innerView sendSubviewToBack:borderView];
                                    borderLayer.fillColor = borderLayer.strokeColor;
                                    break;
                                }
                                default: break;
                            }
                            
                            borderView.layer.mask = maskLayer;
                            break;
                        }
                        case MysticPositionMiddle:
                        {
                            borderLayer.strokeColor = [self.borderColorOrDefault opaque].CGColor;
                            borderLayer.fillColor = [UIColor clearColor].CGColor;
                            borderLayer.opacity = self.borderAlpha;
                            borderLayer.lineWidth = borderWidth;
                            borderLayer.lineCap = self.lineCap ? self.lineCap : kCALineCapButt;
                            borderLayer.lineJoin = self.lineJoin ? self.lineJoin : kCALineJoinMiter;
                            [innerView bringSubviewToFront:borderView];
                            borderView.layer.mask = nil;
                            break;
                        }
                        default: break;
                    }
                }
                else
                {
                    if(maskLayer && borderView)
                    {
                        borderView.layer.mask = nil;
                        maskLayer = nil;
                    }
                    if(transView.borderView) transView.borderView = nil;
                }
                
                if(fillView)
                {
                    SetBounds(fillView, self.frameNoBorderInset, self.center);
                    fillLayer = (id)[fillView pathInfo:self.pathInfo];
                    fillLayer.fillColor = [self.colorOrDefault alpha:self.alpha > 0 ? 1 : self.alpha].CGColor;
                    fillLayer.opacity = self.alpha;
                    fillLayer.geometryFlipped = self.pathInfo.geometryFlipped;
                }
                
                self.borderWidth = hasBorder ? borderLayer.lineWidth/2 : 0;
                
//                [LLog dark];
//                if(fillView)
//                {
//                    [LLog set:@"fill" f:fillView.frame];
//                    [LLog set:@"fill.layer" f:fillLayer.frame];
//                    [LLog set:@"fill.layer.path" f:fillLayer.pathBounds];
//
//                }
//                if(borderView)
//                {
//                    if(fillView) [LLog space];
//                    [LLog set:@"border" f:borderView.frame];
//                    [LLog set:@"border.layer" f:borderLayer.frame];
//                    [LLog set:@"border.layer.path" f:borderLayer.pathBounds];
//                    [LLog set:@"borderWidth" fl:borderLayer.lineWidth];
//
//                }

                
    #pragma mark - hasEffectsThatHaveToBeDrawn
                if(self.hasEffectsThatHaveToBeDrawn)
                {
                    if(self.effectsHaveChanged)
                    {
                        __unsafe_unretained __block MysticChoice *weakSelf = self;
                        MysticDrawView *drawView = transView.drawView;
                        
                        SetBounds(drawView, self.frameNoBorder, self.center);
                        drawView.drawBlock = ^(CGContextRef context, CGRect rect, CGRect bounds, UIView *view)
                        {
                            if(weakSelf.alpha > 0)
                            {
                                [[weakSelf.colorOrDefault alpha:weakSelf.alpha] setFill];
                                [weakSelf.path fill];
                            }
                            
                            if(weakSelf.innerShadow.boolValue)
                                DrawInnerShadow(weakSelf.path, weakSelf.innerShadowColor ? weakSelf.innerShadowColor : [[UIColor blackColor] alpha:0.5], CGSizeIsUnknownOrZero(weakSelf.innerShadowSize) ? (CGSize){1.5,1.5} : weakSelf.innerShadowSize, isnan(weakSelf.innerShadowBlur) ? 0.5 : weakSelf.innerShadowBlur);
                            
                            
                            if(weakSelf.innerBevel.boolValue)
                                InnerBevel(weakSelf.path, weakSelf.innerBevelColorOrDefault, weakSelf.innerBevelShadowColorOrDefault, isnan(weakSelf.innerBevelRadius) ? 0 : weakSelf.innerBevelRadius, isnan(weakSelf.innerBevelBlur) ? 0 : weakSelf.innerBevelBlur, isnan(weakSelf.innerBevelAngle) ? 90 / 180 * M_PI : weakSelf.innerBevelAngle / 180 * M_PI);
                            
                            if(weakSelf.bevel.boolValue) {
                                
                                CGFloat r = isnan(weakSelf.bevelRadius) ? 0 : weakSelf.bevelRadius;
                                CGFloat b = isnan(weakSelf.bevelBlur) ? 0 : r*weakSelf.bevelBlur;
                                BevelPath(weakSelf.path, weakSelf.bevelColorOrDefault, weakSelf.bevelShadowColorOrDefault, r/2, b, isnan(weakSelf.bevelAngle) ? -M_PI_4 : weakSelf.bevelAngle / 180 * M_PI);
                            }
                            
                            if(weakSelf.extrude.boolValue)
                                ExtrudePath(weakSelf.path, weakSelf.extrudeColor ? weakSelf.extrudeColor : [[UIColor blackColor] alpha:0.5], isnan(weakSelf.extrudeRadius) ? 10 : weakSelf.extrudeRadius, isnan(weakSelf.extrudeAngle) ? -M_PI_4 : weakSelf.extrudeAngle / 180 * M_PI);
                            
                            if(weakSelf.emboss.boolValue)
                            {
                                float r = isnan(weakSelf.embossRadius) ? weakSelf.borderWidth > 0 ? weakSelf.borderWidth : 1.5 : weakSelf.embossRadius;
                                CGSize embossSize = CGSizeIsUnknownOrZero(weakSelf.embossSize) ? (CGSize){r, -r} : (CGSize){weakSelf.embossSize.width, weakSelf.embossSize.height};
                                CGSize embossSizeDark = CGSizeIsUnknownOrZero(weakSelf.embossDarkSize) ? (CGSize){-r, r} : (CGSize){weakSelf.embossDarkSize.width, weakSelf.embossDarkSize.height} ;
                                CGSize embossChange = CGSizeIsUnknownOrZero(weakSelf.embossSizeChange) ? CGSizeZero : weakSelf.embossSizeChange;
                                if(embossSize.width != r)
                                {
                                    embossSize.width = r-embossChange.width;
                                    embossSize.height = -r-embossChange.height;
                                    embossSizeDark.width = -r-embossChange.width;
                                    embossSizeDark.height = r-embossChange.height;
                                }
                                weakSelf.embossSize = embossSize;
                                weakSelf.embossDarkSize = embossSizeDark;
                                
                                EmbossPath(weakSelf.path, weakSelf.embossColorOrDefault, weakSelf.embossDarkColorOrDefault, embossSize, embossSizeDark, isnan(weakSelf.embossBlur) ? 0.5 : weakSelf.embossBlur);
                            }
                        };
                        [view bringSubviewToFront:drawView];
                        if(borderView) [view bringSubviewToFront:innerView];
                        [drawView setNeedsDisplay];
                        if(transView.hasFillView) transView.fillView = nil;

                    }
                }
                else if(transView.hasDrawView)
                {
                    transView.drawView = nil;
                }
            }
      
        }

        if(!transView.hasFillView && !transView.hasBorderView) transView.contentView = nil;
        _frameSet = YES;
        self.rebuildFrame = NO;
        self.refitFrame = NO;
        _updateViewBefore = !_updateViewBefore;
        self.effectsHaveChanged = NO;
        if(!CGPointIsZero(offset))
        {
//            CGFloat h = self.attributedString && self.attributedString.numberOfLines > 1 ? self.attributedString.fontHeight : self.frameNoBorderInset.size.height;
            CGFloat h = self.attributedString ? self.attributedString.fontHeight : self.frameNoBorderInset.size.height;

            innerView.transform = CGAffineTransformPoint(CGAffineTransformTranslateReset(innerView.transform), (CGPoint){0, (h - offset.y)/2});
//            [LLog line];
//            [LLog set:@"attr str num lines" b:self.attributedString && self.attributedString.numberOfLines > 1];
//            [LLog set:@"attr str font height" fl:self.attributedString.fontHeight];
//            [LLog set:@"frameNoBorderInset.height" fl:self.frameNoBorderInset.size.height];
//            [LLog set:@"h" fl:h];
//            [LLog set:@"transform" trans:innerView.transform];
        }
        else if(!CGAffineTransformIsIdentity(innerView.transform))
        {
            innerView.transform = CGAffineTransformIdentity;
        }
        [view setNeedsDisplay];
    }
    [[LLog black] set:@"bounds#CYAN;" f:self.bounds];
    [LLog set:@"frame#CYAN;" f:self.frameNoBorderInset];

    if(debug) [LLog log:[NSString format:@"CHOICE: %@", debug && [debug isKindOfClass:[NSString class]] ? debug : @"Update View"]];
    return (CGFrameBounds){.bounds=self.bounds,.frame=self.frameNoBorderInset};
}

- (NSString *)description;
{
    return [self description:nil];
}
- (NSString *)description:(UIView *)view;
{
    
    return ALLogStr(@[@"Choice", MObj(self.name),
                      @"Draw Effects On Layer", _drawAroundFrame ? b(_drawAroundFrame.boolValue) : [b(self.drawEffectsOnViewLayer) suffix:@" _drawAroundFrame = nil"],
                      self.usesCustomDrawing ? @"path" : SKP, !self.usesCustomDrawing ? SKP : b(self.path != nil),
                      !self.usesCustomDrawing ? SKP : @"path  bounds", !self.usesCustomDrawing ? SKP : f([[[MysticShapesKit pathBounds:self] objectForKey:@"frame"] CGRectValue]),
                      @"frame", f(self.frame),
                      LINE,
                      !self.hasBorder ? SKP : @"Border",
                      !self.hasBorder ? SKP : [NSString stringWithFormat:@"%2.1f  %@   Cap:  %@    Join:  %@  Color:  %@",
                                               self.borderWidth,
                                               MysticPositionStr(self.borderPosition),
                                               MNull(self.lineCap),
                                               MNull(self.lineJoin),
                                               ColorToString(self.borderColorOrDefault)],
                      
                      !self.hasShadow ? SKP : @"Shadow",
                      !self.hasShadow ? SKP : [NSString stringWithFormat:@"Radius:  %2.1f   Alpha:  %2.1f   Offset:  %@   Color:  %@",
                                                                                       self.shadowRadius,
                                                                                       self.shadowAlphaValue,
                                                                                       s(self.shadowOffset),
                                                                                       ColorStr(self.shadowColor)],
                      !self.hasBorder && !self.hasShadow ? SKP : LINE,
                      @"Effects", b(self.hasEffectsThatHaveToBeDrawn),
                      
                      
                       !_bevel.boolValue ? SKP : @"Bevel", !_bevel.boolValue ? SKP : [NSString stringWithFormat:@"Radius: %2.1f  Blur: %2.2f  Angle:  %2.1f   Opacity: %2.1f%%  %@",
                                                                    self.bevelRadius,
                                                                    self.bevelBlur,
                                                                    isnan(self.bevelAngle) ? -M_PI_4 : self.bevelAngle / 180 * M_PI,
                                                                    self.bevelColorOrDefault.alpha,
                                                                    ColorStr(self.bevelColorOrDefault)],
                      
                      !_emboss.boolValue ? SKP : @"Emboss", !_emboss.boolValue ? SKP : [NSString stringWithFormat:@"Radius: %2.1f  Blur:  %2.1f   Color:  %@    Dark:  %@",
                                                                    self.embossRadius,
                                                                    self.embossBlur,
                                                                    
                                                                    ColorStr(self.embossColorOrDefault),
                                                                    ColorStr(self.embossDarkColorOrDefault)],
                      
                      !_innerShadow.boolValue ? SKP : @"InnerShadow", !_innerShadow.boolValue ? SKP : [NSString stringWithFormat:@"Blur:  %2.1f   Size:  %@  Color:  %@",
                                                                      self.innerShadowBlur,
                                                                      s(self.innerShadowSize),
                                                                      
                                                                      ColorStr(self.innerShadowColorOrDefault)],
                      view ? @" - " : @"#end",
                      view ? @"View" : SKP, view ? VLogStr(view) : SKP,
                      LINE,
                      view ? @"Layers" : SKP, view ? VLLogStr(view) : SKP,

                      ]);
    
}
@end
