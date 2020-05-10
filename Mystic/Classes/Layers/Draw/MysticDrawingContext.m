//
//  MysticDrawingContext.m
//  Mystic
//
//  Created by Me on 12/15/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticDrawingContext.h"
#import "UIColor+Mystic.h"
#import "UIDevice+Machine.h"
#import "MysticAttrString.h"
@interface MysticDrawingContext ()
{
    BOOL _nonMysticContext;
}
@end
@implementation MysticDrawingContext
+ (id) contextWithTargetSize:(CGSize)targetSize minimumScaleFactor:(CGFloat)min;
{
    MysticDrawingContext *d = [[self class] context];
    d.targetSize=targetSize;
    d.minimumScaleFactor = min;
    return d;
}
+ (id) context;
{
    return [[[[self class] alloc] init] autorelease];
}
+ (id) contextWithContext:(MysticDrawingContext *)context;
{
    return [[context copy] autorelease];
}
- (void) dealloc;
{
    [_attributedString release];
    [_attributes release];
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        self.minimumScaleFactor = 1;
        _nonMysticContext = NO;
        _adjustedTargetSize = NO;
        _adjustTargetSize = NO;
        _maxTargetSize = CGSizeZero;
        _sizeOptions = MysticSizeOptionMatchDefault;
        _fontSizeScaleFactor = 0.025;
        _fontSizePointFactor = 0;
        _scaleFactor = 0.1;
        _minimumRatio =CGSizeZero;
        _attributes = nil;
        _adjustContentSizeToFit = YES;
        _attributedString = nil;
        _autoScaleFont = YES;
        _totalSize = CGSizeZero;
        _bounds = CGRectZero;
        _fontSize = 0;
        _targetScale = 1;
        _fontSizeStart = 0;
        _targetSize = CGSizeZero;
        _fontScaleFactor = CGSizeZero;
    }
    return self;
}
- (CGFloat) fontSize;
{
    return _fontSize != 0 ? _fontSize : (self.attributedString ? self.attributedString.fontSize : _fontSize);
}
- (id) copy;
{
    MysticDrawingContext *c = [[[self class] alloc] init];
    c.sizeOptions = self.sizeOptions;
    c.fontSizePointFactor = self.fontSizePointFactor;
    c.fontSizeScaleFactor = self.fontSizePointFactor;
    c.fontSize = self.fontSize;
    c.fontSizeStart = self.fontSizeStart;
    c.scaleFactor = self.scaleFactor;
    c.minimumRatio = self.minimumRatio;
    c.attributes = self.attributes;
    c.adjustContentSizeToFit = self.adjustContentSizeToFit;
    c.attributedString = [[self.attributedString copy] autorelease];
    c.autoScaleFont = self.autoScaleFont;
    c.bounds = self.bounds;
    c.targetSize = self.targetSize;
    c.totalSize = self.totalSize;
    c.fontScaleFactor = self.fontScaleFactor;
    c.minimumScaleFactor = self.minimumScaleFactor;
    return c;
}
- (void) setNewTargetSize:(CGSize)newTargetSize;
{
    [self setNextTargetSize:newTargetSize];
}
- (BOOL) setNextTargetSize:(CGSize)nt;
{
    if(!CGSizeIsZero(nt) && !CGSizeIsZero(self.totalSize) && !CGSizeEqualToSizeEnough(nt, self.totalSize))
    {
        int w = 0;
        if(self.sizeOptions & MysticSizeOptionNone || (self.sizeOptions & MysticSizeOptionMatchHeight && self.sizeOptions & MysticSizeOptionMatchWidth))
        {
            w = 0;
        }
        else if(self.sizeOptions & MysticSizeOptionMatchGreatest)
        {
            w = nt.width > nt.height ? 1 : 2;
        }
        else if(self.sizeOptions & MysticSizeOptionMatchLeast)
        {
            w = nt.width < nt.height ? 1 : 2;
        }
        else if(self.sizeOptions & MysticSizeOptionMatchWidth)
        {
            w = 1;
        }
        else if(self.sizeOptions & MysticSizeOptionMatchHeight)
        {
            w = 2;
        }
        
        if(!CGSizeIsZero(self.fontScaleFactor) && self.attributedString != nil && self.attributedString.string.length)
        {
            self.fontSizeStart = self.fontSize;
            self.fontSize = w == 1 ? nt.width*self.fontScaleFactor.width : nt.height * self.fontScaleFactor.height;
            NSDictionary *attr = [self.attributedString attributesAtIndex:0 effectiveRange:NULL];
            UIFont *attrFont = self.attributedString.font;
            NSString *attrText = self.attributedString.string;

            NSMutableDictionary *attr2 = [NSMutableDictionary dictionary];
            [attr2 addEntriesFromDictionary:attr];
            
            UIFont *newFont = [attrFont fontWithSize:self.fontSize];
            if(!Mor(newFont, attrFont))
            {
                DLog(@"%@", [self.attributedString class]);
                ALLog(@"there is no new font", @[@"fontSize %2.2f", @(self.fontSize),
                                                 @"attr", MObj(self.attributedString)]);
                
                newFont = nil;
            }
            [attr2 setObject:Mor(newFont, attrFont) forKey:NSFontAttributeName];
            
            
            
            
            MysticAttrString *newStr = [NSMutableAttributedString attributedStringWithString:attrText];
            NSRange r = NSMakeRange(0, attrText.length);
            for (id key in attr2.allKeys) [newStr addAttribute:key value:[attr2 objectForKey:key] range:r];
            self.attributedString = newStr;
        }
        _totalSize = nt;
        _newTargetSize = nt;
        return YES;
    }
    return NO;
}
- (BOOL) isMysticContext;
{
    if(_nonMysticContext) return NO;
    
    if(CGSizeIsZero(self.totalSize) && !self.attributedString) return NO;
    
    return YES;
}
- (NSString *) description;
{
    return ALLogStr([self isMysticContext] ? @[
                      @"totalSize", SLogStrd(self.totalSize, 3),
                      @"targetScale %2.1f", @(self.targetScale),
                      @"fontSize", [NSString stringWithFormat:@"%2.1f -> %2.1f", self.fontSizeStart, self.fontSize],
                      @"fontScale", SLogStrd(self.fontScaleFactor, 3),
                      @"target size", SLogStr(self.targetSize),
                      @"minimumScaleFactor", @(self.minimumScaleFactor),
                      @"-",
                      @"* totalBounds", SLogStr(self.totalBounds.size),
                      @"* actualScaleFactor", @(self.actualScaleFactor),

//                      @"minimumRatio", SLogStr(self.minimumRatio),
//                      @"minimumScale", @(self.minimumScaleFactor),
//                      @"fontSizePointFactor", [NSString stringWithFormat:@"%2.1f%%  |  %2.1fpt", self.fontSizeScaleFactor, self.fontSizePointFactor],
//                      @"bounds", FLogStr(self.bounds),
//                      @"autoScale", MBOOL(self.autoScaleFont),
//                      @"attr", MObj(self.attributes),
                      ] : @[@"targetSize", SLogStr(self.targetSize),
                            @"targetScale %2.1f", @(self.targetScale),
                            @"minimumScaleFactor", @(self.minimumScaleFactor),

                            @"-",
                            
                            @"* totalBounds", SLogStr(self.totalBounds.size),
                            @"* actualScaleFactor", [NSString stringWithFormat:@"%2.2f -> %2.2f", self.minimumScaleFactor, self.actualScaleFactor],
                            ]);
}
@end
