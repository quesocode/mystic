//
//  MysticAttrString.m
//  Mystic
//
//  Created by Me on 12/17/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticAttrString.h"
#import "UIBezierPath+TextPaths.h"
#import "BezierUtils.h"
#import "MysticAttrStringStyle.h"

@implementation MysticAttrString

@synthesize kerning=_kerning, lineHeightMultiple=_lineHeightMultiple, textAlignment=_textAlignment;

+ (id) attributedStringWithAttributedString:(id)string;
{
    return [self string:string];
}

+ (id) attributedStringWithString:(id)string;
{
    return [self string:string];
}
+ (id) string:(id)string;
{
    MysticAttrString *o = [[[self class] alloc] init];
    [o setupString:string];
    return [o autorelease];
}
+ (id) string:(id)string style:(MysticStringStyle)style;
{
    MysticAttrString *s = [MysticAttrString string:string];
    s.style = style;
    return s;
}
+ (id) string:(id)string style:(MysticStringStyle)style state:(int)styleState;
{
    MysticAttrString *s = [MysticAttrString string:string];
    [s setStyle:style state:styleState];
    return s;
}
- (void) dealloc;
{
    [_context release];
    [_attrString release];
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        _lineHeightMultiple = NAN;
        _kerning = NAN;
        _scale = 1;
        _verticalAlignment = MysticPositionCenterVertical;
        _alignPosition = MysticPositionCenter;
        _numberOfLines = 0;
        _needsRedraw = NO;
        _trimLineHeight = YES;
        _fixLines = YES;
        _textAlignment = -1;
        
    }
    return self;
}
//- (BOOL) isKindOfClass:(Class)aClass;
//{
//    NSString *sc = NSStringFromClass(aClass);
//    if([sc isEqualToString:NSStringFromClass([self class])]) return YES;
//    return [sc containsString:@"AttributedString"] ? YES : [super isKindOfClass:aClass];
//}
- (id) initWithString:(id)string;
{
    self = [self init];
    if(self)
    {
        [self setupString:string];
    }
    return self;
}
- (void) setStyle:(MysticStringStyle)style;
{
    [self setStyle:style state:UIControlStateNormal];
}
- (void) setStyle:(MysticStringStyle)style state:(int)state;
{
    _style = style;
    [MysticAttrStringStyle string:self style:_style state:state];
}

- (NSRange) range;
{
    return NSMakeRange(0, self.length);
}
- (NSString *) string;
{
    return self.attrString.string;
}
- (NSMutableString *) mutableString;
{
    return self.attrString.mutableString;
}
- (void) setupString:(NSMutableAttributedString *)string;
{
    NSMutableAttributedString *a = nil;
    if([string isKindOfClass:[MysticAttrString class]])
    {
        a = [[[(MysticAttrString *)string attrString] copy] autorelease];
    }
    else if(!string || [string isKindOfClass:[NSMutableAttributedString class]])
    {
        a = !string ? nil : [[string copy] autorelease];
    }
    else if([string isKindOfClass:[NSAttributedString class]])
    {
        a = [NSMutableAttributedString attributedStringWithAttributedString:[[string copy] autorelease]];
    }
    else if([string isKindOfClass:[NSString class]])
    {
        a = [NSMutableAttributedString attributedStringWithString:(id)[[string copy] autorelease]];
    }
    else if(string)
    {
        self.attrString = [NSMutableAttributedString attributedStringWithString:[NSString stringWithFormat:@"%@", string]];
    }
    
    if(a!=nil)
    {
        __unsafe_unretained __block NSMutableAttributedString *na = [[NSMutableAttributedString alloc] initWithAttributedString:a];
    
        self.attrString = [na autorelease];
    }
    
    
}
- (void) setScale:(CGFloat)scale;
{
    if(scale != _scale)
    {
        self.fontSize = self.fontSize*scale;
        self.kerning = self.kerning*scale;
    }
    _scale = scale;
    
}

- (void) scaleToSize:(CGSize)size;
{
    CGFloat scale = 1;
    UIBezierPath *p = nil;
    int l = self.numberOfLines;
    if(l <= 1) p = [UIBezierPath pathForAttributedString:self.attrString];
    else p = [UIBezierPath pathForMultilineAttributedString:self.attrString maxWidth:self.size.width];
    CGRect pb = PathBoundingBox(p);
    MysticAttrString *attr = [MysticAttrString string:self];
    CGFloat fs = self.fontSize;
    CGFloat fs2 = fs;
    CGFloat fs3 = fs;
    CGFloat ca = 0.1;
    CGScale targetScale = CGScaleEqual;
    int scaleTries = 0;
    CGSize pbSize = pb.size;
    CGSize pbSizeNew = pbSize;
    CGSize pbSizeTarget = pbSize;
    CGSize sizeDiff = CGSizeDiff(pbSize, size);
    int greater = 0;
    if(CGSizeGreater(size, pbSize))
    {
        greater = 2;
        targetScale = CGScaleOfSizes(size, pbSize);
        fs3 = fs2 * targetScale.min;
        fs = fs3;
        attr = [MysticAttrString string:self];
        attr.scale = targetScale.min;
        p = [UIBezierPath pathForAttributedString:attr.attrString maxWidth:0 lineCount:l];
        pb = PathBoundingBox(p);
        pbSizeNew = pb.size;
        pbSizeTarget = pbSizeNew;
    }
    else if(!CGSizeEqual(pbSize, size))
    {
        greater = 1;

        targetScale = CGScaleOfSizes(size, pbSize);
        fs3 = fs2 * targetScale.min;
        fs = fs3;

        attr = [MysticAttrString string:self];
        attr.scale = targetScale.min;
        p = [UIBezierPath pathForAttributedString:attr.attrString maxWidth:0 lineCount:l];
        pb = PathBoundingBox(p);
        pbSizeNew = pb.size;
        pbSizeTarget = pbSizeNew;

    }
    scale = attr.fontSize/fs2;

//    DLog(@"%d scale tries:      %@  ->  %@  =  %@\n\tFont:  %2.4f pt  ->  %2.4f pt\n\tScale:  %2.4f%%   (%2.4f x %2.4f) \n\tTarget First Size:  %@  %@\n\tMethod:  %@", scaleTries,
//         s(pbSize),
//         ColorWrap(s(size), COLOR_GREEN_BRIGHT),
//         ColorWrap(s(sizeDiff), COLOR_RED),
//         fs2,
//         fs,
//         scale,
//         targetScale.min,
//         targetScale.max,
//         s(pbSizeTarget),
//         b(scaleTries==0),
//         greater == 2 ? @"Scale Up" : greater == 1 ? @"Scale Down" : @"None");
    self.scale = scale;

    
}


//- (void) scaleFactor:(CGSize)scaleFactor target:(CGSize)size;
//{
//    self.scaleFactor = scaleFactor;
//    CGFloat originalFontSize = self.fontSize;
//    CGFloat newFontSize = size.width*scaleFactor.width;
//    CGFloat newScale = newFontSize/self.fontSize;
//    self.scale = newScale;
//    
//    
//    CGRect bounds = CGRectSizeFloor(CGRectSize(size));
//    CGRect selfSize = CGRectSize(self.size);
//   
//    DLog(@"scaleFactor: Scale: %2.2f  | Factor:  %2.2f |  Original FontSize: %2.2f  |  New FontSize:  %2.2f |  Fits: %@", _scale, scaleFactor.width, originalFontSize, newFontSize, MBOOL(CGRectContainsRect(bounds, selfSize)));
//    
//    CGFloat kern = self.kerning;
//    BOOL contained = CGRectContainsRect(bounds, selfSize);
//    if(!contained)
//    {
//        while (!contained) {
//            newFontSize = newFontSize-0.5;
//            self.fontSize = newFontSize;
//            self.kerning = kern * (newFontSize/originalFontSize);
//            selfSize = CGRectSize(self.size);
//            contained = CGRectContainsRect(bounds, selfSize);
//        }
//        
//        DLog(@"\t\tscaleFactorDone: Scale: %2.2f |  Original FontSize: %2.2f  |  New FontSize:  %2.2f", newFontSize/originalFontSize, originalFontSize, newFontSize);
//
//    }
//    _scale = newFontSize/originalFontSize;
//    
//}


- (instancetype) scaleFactor:(CGSize)scaleFactor target:(CGSize)size;
{
    return [self scaleFactor:scaleFactor target:size debug:nil];
}
- (instancetype) scaleFactor:(CGSize)scaleFactor target:(CGSize)size debug:(NSString *)debugStr;
{
    CGFloat kern = self.kerning;
    CGFloat originalFontSize = self.fontSize;
//    CGFloat newFontSize = originalFontSize-0.5;
    CGFloat newFontSize = size.width*scaleFactor.width;
    CGFloat newScale = newFontSize/self.fontSize;
    
    self.fontSize = newFontSize;
    self.kerning = kern * (newFontSize/originalFontSize);
    
    self.scaleFactor = scaleFactor;
    //    self.scale = newScale;
    
    
    CGRect bounds = CGRectSizeFloor(CGRectSize(size));
    
    if(debugStr) DLog(@"%@ scaleFactor: Scale: %2.2f  | Factor:  %2.2f  |  Size.width: %2.2f |  Original FontSize: %2.2f  |  New FontSize:  %2.2f |  Fits: %@", debugStr, (newFontSize/originalFontSize), scaleFactor.width, size.width, originalFontSize, newFontSize, MBOOL(CGRectContainsRect(bounds, CGRectSize(self.size))));
    
    BOOL contained = CGRectContainsRect(bounds, CGRectSize(self.size));
    if(!contained && !CGRectIsNaN(bounds) && !CGSizeIsNaN(self.size) && !CGSizeIsZero(self.size))
    {
        while (!contained) {
            newFontSize = newFontSize-0.5;
            self.fontSize = newFontSize;
            self.kerning = kern * (newFontSize/originalFontSize);
            contained = CGRectContainsRect(bounds, CGRectSize(self.size));            
        }
        
        if(debugStr) DLog(@"%@ \t\tscaleFactorDone: Scale: %2.2f |  Original FontSize: %2.2f  |  New FontSize:  %2.2f", debugStr, newFontSize/originalFontSize, originalFontSize, newFontSize);
        
    }
    _scale = newFontSize/originalFontSize;
    return self;
}



- (BOOL) isEqualToString:(NSString *)string;
{
    return [string isEqualToString:self.string];
}

#pragma mark - Attr UIKit Addons

- (CGRect)boundingRectWithSize:(CGSize)size
                       options:(NSStringDrawingOptions)options
                       context:(NSStringDrawingContext *)context;
{
//    SLog(@"bounding rect bounds", CGSizeCeil(size));
    CGRect r = [self.attrString boundingRectWithSize:CGSizeCeil(size) options:options context:context];
//    FLog(@"bounding rect", CGRectSizeCeil(r));

    return CGRectSizeCeil(r);
}
- (CGSize)size;
{
    return [self.attrString size];
}
- (void)drawWithRect:(CGRect)rect
             options:(NSStringDrawingOptions)options
             context:(NSStringDrawingContext *)context;
{
    [self.attrString drawWithRect:rect options:options context:context];
}

#pragma mark - NSAttributeString methods

- (NSUInteger) length;
{
    return self.attrString.length;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index
                     effectiveRange:(NSRangePointer)aRange;
{
    return [self.attrString attributesAtIndex:index effectiveRange:aRange];
}
- (NSDictionary *)attributesAtIndex:(NSUInteger)index
              longestEffectiveRange:(NSRangePointer)aRange
                            inRange:(NSRange)rangeLimit;
{
    return [self.attrString attributesAtIndex:index longestEffectiveRange:aRange inRange:rangeLimit];
}
- (id)attribute:(NSString *)attributeName
        atIndex:(NSUInteger)index
 effectiveRange:(NSRangePointer)aRange;
{
    return [self.attrString attribute:attributeName atIndex:index effectiveRange:aRange];
}
- (id)attribute:(NSString *)attributeName
        atIndex:(NSUInteger)index
longestEffectiveRange:(NSRangePointer)aRange
        inRange:(NSRange)rangeLimit;
{
    return [self.attrString attribute:attributeName atIndex:index longestEffectiveRange:aRange inRange:rangeLimit];
}
- (void)enumerateAttribute:(NSString *)attrName
                   inRange:(NSRange)enumerationRange
                   options:(NSAttributedStringEnumerationOptions)opts
                usingBlock:(void (^)(id value,
                                     NSRange range,
                                     BOOL *stop))block;
{
    [self.attrString enumerateAttribute:attrName inRange:enumerationRange options:opts usingBlock:block];
}
- (void)enumerateAttributesInRange:(NSRange)enumerationRange
                           options:(NSAttributedStringEnumerationOptions)opts
                        usingBlock:(void (^)(NSDictionary *attrs,
                                             NSRange range,
                                             BOOL *stop))block;
{
    [self.attrString enumerateAttributesInRange:enumerationRange options:opts usingBlock:block];
}
- (BOOL)isEqualToAttributedString:(NSAttributedString *)otherString;
{
    return [self.attrString isEqualToAttributedString:otherString];
}
- (NSAttributedString *)attributedSubstringFromRange:(NSRange)aRange;
{
    return [self.attrString attributedSubstringFromRange:aRange];
}

#pragma mark - NSMutableAttrString methods


- (void)replaceCharactersInRange:(NSRange)aRange
                      withString:(NSString *)aString;
{
    [self.attrString replaceCharactersInRange:aRange withString:aString];
}
- (void)deleteCharactersInRange:(NSRange)aRange;
{
    [self.attrString deleteCharactersInRange:aRange];
}
- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange;
{
    [self.attrString setAttributes:attributes range:aRange];
}


- (void)addAttribute:(NSString *)name
               value:(id)value
               range:(NSRange)aRange;
{
    [self.attrString addAttribute:name value:value range:aRange];
}
- (void)addAttributes:(NSDictionary *)attributes
                range:(NSRange)aRange;
{
    [self.attrString addAttributes:attributes range:aRange];
}
- (void)appendAttributedString:(NSAttributedString *)attributedString;
{
    [self.attrString appendAttributedString:attributedString];
}
- (void)insertAttributedString:(NSAttributedString *)attributedString
                       atIndex:(NSUInteger)index;
{
    [self.attrString insertAttributedString:attributedString atIndex:index];
}
- (void)replaceCharactersInRange:(NSRange)aRange
            withAttributedString:(NSAttributedString *)attributedString;
{
    [self.attrString replaceCharactersInRange:aRange withAttributedString:attributedString];
}
- (void)setAttributedString:(NSAttributedString *)attributedString;
{
    [self.attrString setAttributedString:attributedString];
}
- (void)beginEditing;
{
    [self.attrString beginEditing];
}
- (void)endEditing;
{
    [self.attrString endEditing];
}
- (void) removeAttribute:(NSString *)name;
{
    [self setAttribute:name value:nil];
//    [self.attrString removeAttribute:name range:self.range];
    
}

#pragma mark - Attributes
- (NSMutableDictionary *) attributes;
{
    NSDictionary *attr = [self.attrString attributesAtIndex:0 effectiveRange:NULL];
    return [NSMutableDictionary dictionaryWithDictionary:attr];
}
- (void) setAttributes:(NSMutableDictionary *)value;
{
    //[self.attrString setAttributes:value range:self.range];
    for (NSString*k in value.allKeys) {
        [self setAttribute:k value:value[k]];
    }
    
}




- (void) setAttribute:(NSString *)name value:(id)value;
{
//    [self setAttribute:name value:value range:self.range];
    
    if(!value)
    {
        [self.attrString removeAttribute:name range:self.range];
        return;
    }
    
    [self enumerateAttributesInRange:self.range options:NULL usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
    
        BOOL f = NO;
        NSMutableDictionary *newAttr = [NSMutableDictionary dictionaryWithDictionary:attrs];
        for (NSString *attrKey in attrs.allKeys) {
            if([attrKey isEqualToString:name])
            {
                [newAttr setObject:value forKey:name];
                f = YES;
                break;
            }
        }
        if(!f) [newAttr setObject:value forKey:name];
        
        
        [self setAttributes:newAttr range:range];
        
//        DLog(@"enumberate attr: %d - %d  %@==%@\n\n%@\n\nNew:\n\n%@\n\n", (int)range.location, (int)range.length, NSFontAttributeName, name, attrs, newAttr);
    }];
    
}

- (void) setAttribute:(NSString *)key value:(id)value forLine:(int)lines;
{
    return [self setAttribute:key value:value forLines:@[@(lines)]];
}
- (void) setAttributes:(NSDictionary *)d forString:(NSString *)str;
{
    if(!str) return;
    NSRange r = [self.string rangeOfString:str];
    if(r.location==NSNotFound || r.length<1) return;
    [self setAttributes:d range:r];
}
- (void) setAttributes:(NSDictionary *)d forLine:(int)lines;
{
    return [self setAttributes:d forLines:@[@(lines)]];
}
- (void) setAttributes:(NSDictionary *)attrs forLines:(id)lines;
{
    if(!lines || !attrs) return;
    NSArray *linesA = [lines isKindOfClass:[NSArray class]] ? lines : @[lines];
    if(linesA.count < 1 || attrs.allKeys.count < 1) return;
    NSArray *lineStrs = [NSArray arrayWithArray:self.lines];
    for (NSNumber *n in linesA) {
        if([n integerValue] < 0 || [n integerValue]>=lineStrs.count) continue;
        NSDictionary *l = [lineStrs objectAtIndex:[n integerValue]];
        NSRange r = [l[@"range"] rangeValue];
        if(r.location==NSNotFound || r.length==0) continue;
        [self setAttributes:attrs range:r];
    }
}
- (void) setAttribute:(NSString *)key value:(id)value forLines:(id)lines;
{
    if(!key || !value || !lines) return;
    NSDictionary *d = [NSDictionary dictionaryWithObject:value forKey:key];
    [self setAttributes:d forLines:lines];
}

- (void) setAttribute:(NSString *)name value:(id)value range:(NSRange)range;
{
    if(!value)
    {
        [self.attrString removeAttribute:name range:range];
        return;
    }
    [self addAttribute:name value:value range:range];
}

- (id) attribute:(id)key;
{
    return [self attribute:key atIndex:0];
}
- (id) attribute:(id)key atIndex:(int)index;
{
    if(!key) return nil;
    NSDictionary *attr;
    NSRange r = NSMakeRange(0, self.length);
    for (int i = index; i<self.length; i++) {
        attr = [self.attrString attributesAtIndex:i effectiveRange:&r];
        if(attr && attr.count)
        {
            if(attr[key]) return attr[key];
        }
    }
    return nil;
    
}
- (BOOL) hasAttribute:(NSString *)attr;
{
    if(!attr) return NO;
    return [self attribute:attr] ? YES : NO;
}
#pragma mark - Property Setters

- (void) setFontSize:(CGFloat)size;
{
    if(![self hasAttribute:NSFontAttributeName])
    {

        DLog(@"trying to set fontsize: %2.1f when there is no font", size);
        return;
    }
    float lhm = self.lineHeightMultiple;
    [self enumerateAttribute:NSFontAttributeName inRange:self.range options:NULL usingBlock:^(id value, NSRange range, BOOL *stop){
        UIFont *font = [(UIFont *)value fontWithSize:size];
        [self setAttribute:NSFontAttributeName value:font range:range];
        
        if(lhm != 0)
        {
            [self setLineHeightMultiple:lhm lineHeight:font.lineHeight];
        }
    }];
    //
    
}
- (int) numberOfLines;
{
    return (int)self.lines.count;
}
- (void) setLineHeight:(CGFloat)value;
{
//    DLog(@"set line height: %2.2f", value);
    CGFloat lineHeight = self.font.lineHeight;
    CGFloat m = value/lineHeight;
    self.lineHeightMultiple = m;
}

- (void) setLineHeightMultiple:(CGFloat)value;
{
    [self setLineHeightMultiple:value lineHeight:-1];
}
- (void) setLineHeightMultiple:(CGFloat)value lineHeight:(CGFloat)aLineHeight;
{
    _lineHeightMultiple = value;
    if(!self.trimLineHeight)
    {
        NSMutableParagraphStyle *p = self.paragraph;
        p = p ? p : [[[NSMutableParagraphStyle alloc] init] autorelease];
        p.lineHeightMultiple = value;
        self.paragraph = p;
    }
    else
    {
        MysticAttrString *newStr = [MysticAttrString string:[self.attrString copy]];
        
        NSArray *lines = self.lines;
        if(lines.count < 2)
        {
            _lineHeightMultiple = value;
            return;
        }
        CGFloat lineHeight = aLineHeight <= 0 ? (self.font ? self.font.lineHeight : 0) : aLineHeight;
        NSRange firstRange = [[[lines objectAtIndex:0] objectForKey:@"range"] rangeValue];
        NSRange lastRange = [[lines.lastObject objectForKey:@"range"] rangeValue];

        __unsafe_unretained __block MysticAttrString *weakSelf = self;
        __unsafe_unretained __block NSMutableAttributedString *_newStr = [[NSMutableAttributedString attributedStringWithAttributedString:[newStr.attrString copy]] retain];
        __unsafe_unretained __block NSMutableAttributedString *_mutStr = [[NSMutableAttributedString attributedStringWithString:@""] retain];
        [self enumerateAttributesInRange:self.range options:NULL usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            
            BOOL isFirst = !(range.location > firstRange.length - 1);
            if(!isFirst && range.location == firstRange.length && range.length == 1 && [[_newStr attributedSubstringFromRange:range].string isEqualToString:@"\n"])
            {
                isFirst = YES;
            }
            BOOL isLastLine = NO;
            NSAttributedString *os = [[_newStr attributedSubstringFromRange:range] copy];

            BOOL hasParagraph = attrs[NSParagraphStyleAttributeName] != nil;
            
            NSMutableParagraphStyle *p = [[NSMutableParagraphStyle alloc] init];
            NSMutableParagraphStyle *p2 = attrs[NSParagraphStyleAttributeName] ? attrs[NSParagraphStyleAttributeName] : nil;
            CGFloat oldValue = p2.lineHeightMultiple;
            p.lineHeightMultiple = isFirst || isLastLine ? 0 : value;
            p.maximumLineHeight = isFirst || isLastLine ? lineHeight : value*lineHeight;
            p.lineBreakMode = p2.lineBreakMode;
            p.alignment = _textAlignment;
            p.lineSpacing = p2.lineSpacing;
//            DLogSuccess(@"setting line height for line: %2.2f", p.lineHeightMultiple);
            NSMutableDictionary *mattrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
            [mattrs setObject:[p autorelease] forKey:NSParagraphStyleAttributeName];
            if(hasParagraph) [_newStr removeAttribute:NSParagraphStyleAttributeName range:range];
            NSMutableAttributedString *ns = [NSMutableAttributedString attributedStringWithString:[_newStr.string substringWithRange:range]];
//            [ns addAttributes:mattrs range:NSMakeRange(0, range.length)];
            for (id akey in mattrs.allKeys) {
                [ns addAttribute:akey value:mattrs[akey] range:NSMakeRange(0, range.length)];
            }
            [_mutStr appendAttributedString:ns];
            if(range.location+range.length == weakSelf.length)
            {
                [weakSelf.attrString setAttributedString:_mutStr];
//                DLogError(@"reached end of string:  %@", _mutStr);

                [_newStr release];
            }
        }];

        
    }
}

- (void) setKerning:(CGFloat)value;
{
    if(isnan(_kerning) && value == 0) { _kerning = 0; return; }
    _kerning = value;
    int nli = self.length-1;
    int l = 0;
    BOOL setupKerning = NO;
    int len = self.length;
    MysticAttrString *newStr = [MysticAttrString string:self.attrString];
    [newStr removeAttribute:NSKernAttributeName];
    
    int i = 0;
    if(_fixLines)
    {
        for (i = 0; i < len; i++) {
        NSString *a = [self.attrString.string substringWithRange:NSMakeRange(i, 1)];
        if([a isEqualToString:@"\n"])
        {
            NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary:[self.attrString attributesAtIndex:i effectiveRange:NULL]];
            if(attr[MysticAttrStringNewLineName])
            {
                NSMutableAttributedString *mnlAttrStr = [NSMutableAttributedString attributedStringWithAttributedString:attr[MysticAttrStringNewLineName]];
                NSDictionary *nattr = [mnlAttrStr attributesAtIndex:0 effectiveRange:NULL];
                if(nattr[NSKernAttributeName] && [(id)nattr[NSKernAttributeName] floatValue] != value)
                {
                    [mnlAttrStr addAttribute:NSKernAttributeName value:@(value) range:NSMakeRange(0, mnlAttrStr.length)];
                    [newStr setAttribute:MysticAttrStringNewLineName value:mnlAttrStr range:NSMakeRange(i, 1)];
                }
            }
            
            [newStr setAttribute:NSKernAttributeName value:@(value) range:NSMakeRange(l, (i-1)-l)];
            l = i+1;
            setupKerning = YES;
        }
    }
    }
    if(!setupKerning)
    {
        [newStr setAttribute:NSKernAttributeName value:@(value) range:NSMakeRange(0, newStr.length-1)];
    }
    else if(l < len-1) [newStr setAttribute:NSKernAttributeName value:@(value) range:NSMakeRange(l, (i-1)-l)];
    self.attrString = newStr.attrString;
}



- (void) setLineSpacing:(CGFloat)value;
{
    NSMutableParagraphStyle *p = self.paragraph;
    p = p ? p : [[[NSMutableParagraphStyle alloc] init] autorelease];

    p.lineSpacing = value;
    self.paragraph = p;
}
- (void) setTextAlignmentValue:(NSTextAlignment)textAlignmentValue;
{
    _textAlignment = textAlignmentValue;
}
- (void) setTextAlignment:(NSTextAlignment)value;
{
    NSArray *lines = self.lines;
    _textAlignment = value;
    if(lines.count < 2)
    {
        NSMutableParagraphStyle *p = self.paragraph;
        p = p ? p : [[[NSMutableParagraphStyle alloc] init] autorelease];
        p.alignment = value;
        self.paragraph = p;
    }
    else
    {
        MysticAttrString *newStr = [MysticAttrString string:[self.attrString copy]];
   
        NSRange firstRange = [[[lines objectAtIndex:0] objectForKey:@"range"] rangeValue];
        NSRange lastRange = [[lines.lastObject objectForKey:@"range"] rangeValue];
        
        __unsafe_unretained __block MysticAttrString *weakSelf = self;
        __unsafe_unretained __block NSMutableAttributedString *_newStr = [[NSMutableAttributedString attributedStringWithAttributedString:[newStr.attrString copy]] retain];
        __unsafe_unretained __block NSMutableAttributedString *_mutStr = [[NSMutableAttributedString attributedStringWithString:@""] retain];
        [self enumerateAttributesInRange:self.range options:NULL usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            
            BOOL isFirst = !(range.location > firstRange.length - 1);
            if(!isFirst && range.location == firstRange.length && range.length == 1 && [[_newStr attributedSubstringFromRange:range].string isEqualToString:@"\n"])
            {
                isFirst = YES;
            }
//            BOOL isLastLine = NO;
            NSAttributedString *os = [[_newStr attributedSubstringFromRange:range] copy];
            
            BOOL hasParagraph = attrs[NSParagraphStyleAttributeName] != nil;
            
            NSMutableParagraphStyle *p = [[NSMutableParagraphStyle alloc] init];
            NSMutableParagraphStyle *p2 = attrs[NSParagraphStyleAttributeName] ? attrs[NSParagraphStyleAttributeName] : nil;
            CGFloat oldValue = p2.lineHeightMultiple;
            p.lineHeightMultiple = p2.lineHeightMultiple;
            p.maximumLineHeight = p2.maximumLineHeight;
            p.lineBreakMode = p2.lineBreakMode;
            p.alignment = _textAlignment;
            p.lineSpacing = p2.lineSpacing;
            //            DLogSuccess(@"setting line height for line: %2.2f", p.lineHeightMultiple);
            NSMutableDictionary *mattrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
            [mattrs setObject:[p autorelease] forKey:NSParagraphStyleAttributeName];
            if(hasParagraph) [_newStr removeAttribute:NSParagraphStyleAttributeName range:range];
            NSMutableAttributedString *ns = [NSMutableAttributedString attributedStringWithString:[_newStr.string substringWithRange:range]];
//            [ns addAttributes:mattrs range:NSMakeRange(0, range.length)];
            for (id akey in mattrs.allKeys) [ns addAttribute:akey value:mattrs[akey] range:NSMakeRange(0, range.length)];
            [_mutStr appendAttributedString:ns];
            if(range.location+range.length == weakSelf.length)
            {
                [weakSelf.attrString setAttributedString:_mutStr];
                [_newStr release];
            }
        }];
        
        
    }
    
    
}

- (void) setLineBreakMode:(NSLineBreakMode)value;
{
    NSMutableParagraphStyle *p = self.paragraph;
    p = p ? p : [[[NSMutableParagraphStyle alloc] init] autorelease];

    p.lineBreakMode = value;
    self.paragraph = p;
}

- (void) setColor:(UIColor *)value;
{
    [self setAttribute:NSForegroundColorAttributeName value:value];

}
- (void) setBackgroundColor:(UIColor *)value;
{
    [self setAttribute:NSBackgroundColorAttributeName value:value];

}
- (void) setFont:(UIFont *)newFont;
{
    
    if(![self hasAttribute:NSFontAttributeName])
    {
        [self setAttribute:NSFontAttributeName value:newFont];
    }
    else
    {
        [self enumerateAttribute:NSFontAttributeName inRange:self.range options:NULL usingBlock:^(id value, NSRange range, BOOL *stop) {
            
            
            UIFont *font = value;
            if((font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitItalic) && (font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold))
            {
                UIFont *f2 = MysticFontBoldItalic(newFont);
                font = f2 ? f2 : newFont;
            }
            else if(font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitItalic)
            {
                UIFont *f2 = MysticFontItalic(newFont);
                font = f2 ? f2 : newFont;
            }
            else if(font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold)
            {
                UIFont *f2 = MysticFontBold(newFont);
                font = f2 ? f2 : newFont;
            }
            else
            {
                font = newFont;
            }
            [self setAttribute:NSFontAttributeName value:font range:range];
        }];
    }
    
    
}

- (void) setParagraph:(NSMutableParagraphStyle *)value;
{
    [self setAttribute:NSParagraphStyleAttributeName value:value range:self.range];
    
}




#pragma mark - Properties

- (NSArray *) lines;
{
    NSMutableArray *ranges = [NSMutableArray array];
    if(!self.attrString.string || self.attrString.string.length < 1) return ranges;
    int l = 0;
    int i = 0;
    for (i= 0; i<self.length; i++) {
        if([[self.attrString.string substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"\n"])
        {
            [ranges addObject:@{@"range": [NSValue valueWithRange:NSMakeRange(l, i - l)],
                                @"string": [self.attrString.string substringWithRange:NSMakeRange(l, i-l)]}];
            l = i+1;
        }
    }
    if(l < self.length-1) [ranges addObject:@{@"range": [NSValue valueWithRange:NSMakeRange(l, (i)-l)],
                            @"string": [self.attrString.string substringWithRange:NSMakeRange(l, (i)-l)]}];
    return ranges;
}

- (CGFloat) fontSize;
{
    UIFont *font = self.font;
    if(font) return self.font.pointSize;
    return 0;
}
- (UIFont *) font;
{
    return [self attribute:NSFontAttributeName];
}
- (UIColor *) color;
{
    return [self attribute:NSForegroundColorAttributeName];
}
- (UIColor *) backgroundColor;
{
    return [self attribute:NSBackgroundColorAttributeName];
}
- (NSMutableParagraphStyle *) paragraph;
{
    NSMutableParagraphStyle *p = [self attribute:NSParagraphStyleAttributeName];
    return p;

}
- (CGFloat) lineHeightMultiple;
{
    if(!isnan(_lineHeightMultiple)) return _lineHeightMultiple;
    CGFloat maxValue = CGFLOAT_MIN;
    
    for (int i = 0; i < self.length; i++) {
        NSRange r = NSMakeRange(i, 1);
        NSMutableParagraphStyle *p = [self.attrString attribute:NSParagraphStyleAttributeName atIndex:i effectiveRange:&r];
        if(p) maxValue = MAX(maxValue, p.lineHeightMultiple);
        i = r.location + r.length;
    }
    
    if( maxValue == CGFLOAT_MIN) maxValue = 0;
    else _lineHeightMultiple = maxValue;
    
    return maxValue;
//    return self.paragraph ? self.paragraph.lineHeightMultiple : 0;
}
- (CGFloat) fontHeight;
{
    return self.font.ascender+self.font.descender;
}
- (CGFloat) lineHeight;
{
    if(isnan(_lineHeightMultiple))
    {
        float v = self.lineHeightMultiple;
        _lineHeightMultiple = !isnan(v) && v != 0 ? v : _lineHeightMultiple;
    }
    return self.font ? (!isnan(_lineHeightMultiple) && _lineHeightMultiple != 0 ? self.font.lineHeight*_lineHeightMultiple : self.font.lineHeight) : 0;
}

- (CGFloat) lineSpacing;
{
    return self.paragraph ? self.paragraph.lineSpacing : 0;
    
}
- (NSLineBreakMode) lineBreakMode;
{
    return self.paragraph ? self.paragraph.lineBreakMode : NSLineBreakByWordWrapping;
}
- (NSTextAlignment) textAlignmentValue; { return _textAlignment; }

- (NSTextAlignment) textAlignment;
{
//    if(!isnan(_textAlignment)) return _textAlignment;
    NSMutableParagraphStyle *p = self.paragraph;
//    if((int)p.alignment == 15)
//    {
//        
//        int i = 0;
//    }
    return p && isValidAlignment(p.alignment) ? p.alignment : _textAlignment;
}

- (CGFloat) kerning;
{
    return [self attribute:NSKernAttributeName] ? [[self attribute:NSKernAttributeName] floatValue] : 0;
}

#pragma mark - Redraw
- (void) setNeedsRedraw;
{
    self.needsRedraw = YES;
}
- (void) setNeedsRedraw:(BOOL)needsRedraw;
{
    _needsRedraw = needsRedraw;
    
}

- (void) drawInRect:(CGRect)rect;
{
    [self.attrString drawInRect:rect];
    _needsRedraw = NO;
}

- (void) drawAtPoint:(CGPoint)point;
{
    [self.attrString drawAtPoint:point];
    _needsRedraw = NO;
}

- (CGSize) sizeWithAttr;
{
    return [self.string sizeWithAttributes:[self attributes]];
}

#pragma mark - Copy
- (id)mutableCopyWithZone:(NSZone *)zone;
{
    return [self copy];
}
- (id) copy;
{
    MysticAttrString *str = [[MysticAttrString alloc] init];
    [str setupString:str.attrString];
    str.textAlignmentValue = self.textAlignment;
    str.verticalAlignment = self.verticalAlignment;
    str.alignPosition = self.alignPosition;
    str.scale = self.scale;
    str.scaleFactor = self.scaleFactor;
    str.numberOfLines = self.numberOfLines;
    str.needsRedraw = YES;
    return str;
}

#pragma mark - Description
- (NSString *) debugDescription;
{
    return ALLogStr(@[@"string", MObj(self.string.inlineString),
                      @"size", s(self.size),
                      @"font", MObj(self.font.fontName),
                      @"obliqueness", @(self.obliqueness),
                      @"fontSize", @(self.fontSize),
                      @"fontHeight", @(self.fontHeight),
                      @"kerning", @(self.kerning),
                      @"lineHeight", @(self.lineHeight),
                      @"lineHeightMultiple", @(self.lineHeightMultiple),
                      @"lineSpacing", @(self.lineSpacing),
                      @"color", ColorToString(self.color),
                      @"textAlignment", textAlignmentString(self.textAlignment),
                                      ]);
}
- (NSString *) description;
{
    
    return [self.attrString.description stringByReplacingOccurrencesOfString:@"}" withString:@"}\n\n"];
    
    
}

@end
