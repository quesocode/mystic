//
//  MysticAttrString.h
//  Mystic
//
//  Created by Me on 12/17/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mystic.h"

@interface MysticAttrString : NSObject

@property (nonatomic, assign) UIColor *color, *backgroundColor, *shadowColor, *strokeColor, *underLineColor, *strikeThruColor;
@property (nonatomic, assign) BOOL needsRedraw, underlined, strikeThru, italic, bold, trimLineHeight, fixLines;
@property (nonatomic, assign) UIFont *font;
@property (nonatomic, assign) CGFloat fontSize, lineHeight, lineSpacing, kerning, scale, lineHeightMultiple, obliqueness;
@property (nonatomic, assign) int numberOfLines;
@property (nonatomic, assign) NSTextAlignment textAlignment, textAlignmentValue;
@property (nonatomic, assign) MysticPosition verticalAlignment, alignPosition;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, copy) MysticDrawingContext *context;
@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) NSArray *lines;
@property (nonatomic, assign) NSMutableParagraphStyle *paragraph;
@property(readonly, copy) NSString *string;
@property (nonatomic, assign) CGSize scaleFactor;
@property (nonatomic, assign) MysticStringStyle style;
@property (nonatomic, readonly) CGSize sizeWithAttr;
@property (nonatomic, retain) NSMutableAttributedString *attrString;
@property (nonatomic, readonly) CGFloat fontHeight;

@property (nonatomic, readonly) NSUInteger length;
@property(readonly, retain) NSMutableString *mutableString;
- (instancetype) scaleFactor:(CGSize)scaleFactor target:(CGSize)size;
- (instancetype) scaleFactor:(CGSize)scaleFactor target:(CGSize)size debug:(NSString *)debugStr;

- (void) setAttributes:(NSDictionary *)attrs forLines:(id)lines;
- (void) setAttribute:(NSString *)key value:(id)value forLines:(id)lines;
- (void) setAttributes:(NSDictionary *)d forLine:(int)lines;
- (void) setAttribute:(NSString *)key value:(id)value forLine:(int)lines;

- (void) setNeedsRedraw;
+ (id) string:(id)string;
+ (id) attributedStringWithString:(id)string;
+ (id) attributedStringWithAttributedString:(id)string;
+ (id) string:(id)string style:(MysticStringStyle)style;
+ (id) string:(id)string style:(MysticStringStyle)style state:(int)styleState;

- (id) initWithString:(id)string;
- (void) setupString:(NSMutableAttributedString *)string;
- (void) scaleToSize:(CGSize)size;
- (void) setAttributes:(NSDictionary *)d forString:(NSString *)str;

#pragma mark - NSAttributeString methods
- (void) setStyle:(MysticStringStyle)style state:(int)state;
- (NSDictionary *)attributesAtIndex:(NSUInteger)index
                     effectiveRange:(NSRangePointer)aRange;
- (NSDictionary *)attributesAtIndex:(NSUInteger)index
              longestEffectiveRange:(NSRangePointer)aRange
                            inRange:(NSRange)rangeLimit;
- (id)attribute:(NSString *)attributeName
        atIndex:(NSUInteger)index
 effectiveRange:(NSRangePointer)aRange;
- (id)attribute:(NSString *)attributeName
        atIndex:(NSUInteger)index
longestEffectiveRange:(NSRangePointer)aRange
        inRange:(NSRange)rangeLimit;
- (void)enumerateAttributesInRange:(NSRange)enumerationRange
                           options:(NSAttributedStringEnumerationOptions)opts
                        usingBlock:(void (^)(NSDictionary *attrs,
                                             NSRange range,
                                             BOOL *stop))block;
- (void)enumerateAttribute:(NSString *)attrName
                   inRange:(NSRange)enumerationRange
                   options:(NSAttributedStringEnumerationOptions)opts
                usingBlock:(void (^)(id value,
                                     NSRange range,
                                     BOOL *stop))block;

#pragma mark - NSMutableAttrString methods

- (void)replaceCharactersInRange:(NSRange)aRange
                      withString:(NSString *)aString;

- (void)deleteCharactersInRange:(NSRange)aRange;
- (void)setAttributes:(NSDictionary *)attributes
                range:(NSRange)aRange;
- (void)addAttribute:(NSString *)name
               value:(id)value
               range:(NSRange)aRange;
- (void)addAttributes:(NSDictionary *)attributes
                range:(NSRange)aRange;
- (void)appendAttributedString:(NSAttributedString *)attributedString;
- (void)insertAttributedString:(NSAttributedString *)attributedString
                       atIndex:(NSUInteger)index;
- (void)replaceCharactersInRange:(NSRange)aRange
            withAttributedString:(NSAttributedString *)attributedString;
- (void)setAttributedString:(NSAttributedString *)attributedString;
- (void)beginEditing;
- (void)endEditing;

#pragma mark - Attributes

- (void) setAttribute:(NSString *)name value:(id)value;
- (void) setAttribute:(NSString *)name value:(id)value range:(NSRange)range;
- (void) removeAttribute:(NSString *)name;
- (id) attribute:(id)key;
- (void) drawInRect:(CGRect)rect;
- (void) drawAtPoint:(CGPoint)point;

- (void) setLineHeightMultiple:(CGFloat)value lineHeight:(CGFloat)aLineHeight;


#pragma mark - Attr UIKit Addons

- (CGRect)boundingRectWithSize:(CGSize)size
                       options:(NSStringDrawingOptions)options
                       context:(NSStringDrawingContext *)context;
- (CGSize)size;
- (void)drawWithRect:(CGRect)rect
             options:(NSStringDrawingOptions)options
             context:(NSStringDrawingContext *)context;
@end
