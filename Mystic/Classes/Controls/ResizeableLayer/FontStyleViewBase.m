//
//  FontStyleViewBase.m
//  Mystic
//
//  Created by Me on 3/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "FontStyleViewBase.h"

@interface FontStyleViewBase ()
{
    CGFloat _fixedLineHeight;
    CGFloat _lineHeightScale;
    CGRect _contentBounds;
    NSArray* _textLines;
    
    // Drawing
    int _enumerateIndex;
    
    // For debug mode
    CGPoint _lastTouchPoint;
    UIButton* _debugMenu;
    UITapGestureRecognizer* _gestureRecognizer;
}

@end
@implementation FontStyleViewBase

@dynamic font, lineHeight, lineHeightScale, textAlignment;
@synthesize text=_text, authorText=_authorText;


- (NSString *)text; { return [super text]; }


- (void) dealloc;
{
  
    [_authorText release];
    [super dealloc];
    
}

- (void) commonInit;
{
    [super commonInit];
    self.font = [PackPotionOptionFont defaultFont];
    self.textAlignment = NSTextAlignmentCenter;
}
- (void) setOption:(PackPotionOptionFontStyle *)option;
{
    [super setOption:option];
    self.font = option.font;
    self.text = option.text;
    
}

-(BOOL)needWrapChar:(NSString*)word{
    UIFont* displayFont = [self displayFont];
    
    NSString* s = nil;
    CGFloat width = 0;
    for (int i = 0; i < word.length; i++) {
        s = [word substringWithRange:NSMakeRange(i, 1)];
        width += [s sizeWithFont:displayFont].width;
    }
    return width > _contentBounds.size.width;
}

- (NSArray *)lines;
{
    return _textLines && _textLines.count ? _textLines : @[];
}

- (NSArray *)textlines;
{
    return _textLines && _textLines.count ? _textLines : @[];
}

- (NSString *) longestWord;
{
    NSString *longest = nil;
    int max = 0;
    for (NSString *word in self.words) {
        if(word.length > max)
        {
            max = word.length;
            longest = word;
        }
    }
    return longest;
}

- (NSArray *)words;
{
    NSMutableArray *__words = [NSMutableArray array];
    for (NSArray *ws in self.textlines) {
        for (NSString *w in ws) {
            [__words addObject:w];
//            [__words addObject:[w stringByReplacingOccurrencesOfString:@" " withString:@""]];
        }
    }
    return __words.count ? [NSArray arrayWithArray:__words] : @[];
}
-(UIFont*)displayFont{
    return self.font;
//    return self.adjustsFontSizeToFitWidth ? adjustedFont : self.font;
}

- (CGFloat) actualLineHeight;
{
    CGFloat lineHeight = [@" " sizeWithFont:self.displayFont].height;
    return lineHeight;
    
}

- (CGFloat) lineHeight;
{
    CGFloat lineHeight = [@" " sizeWithFont:self.displayFont].height;
    CGFloat drawLineHeight = lineHeight * self.lineHeightScale;
    return drawLineHeight;
    
}

- (CGFloat) lineHeightScale;
{
    CGFloat l = self.option.lineHeightScale;
    l = l==NSNotFound ? 0 : l;
    return l;
}
//- (void) setTextAlignment:(NSTextAlignment)textAlignment;
//{
//    _textAlignment = textAlignment;
//    
//}
-(void)setText:(NSString*)text
{
    [super setText:text];
    NSString* originalText = _text;
//    [_text release];
//    _text = [text retain];
    self.option.text = text;
//    if (!_textLines || !originalText || ![text isEqualToString:originalText]) {
//        NSMutableArray* alines = [NSMutableArray array];
//        
//        [text enumerateSubstringsInRange:NSMakeRange(0, text.length)
//                                      options:NSStringEnumerationByLines
//                                   usingBlock:^(NSString *word,
//                                                NSRange wordRange,
//                                                NSRange enclosingRange,
//                                                BOOL *stop){
//                                       [alines addObject:[self processTextLineToWords:word]];
//
//                                   }];
//
//        if(_textLines) [_textLines release];
//            _textLines = [[NSArray arrayWithArray:alines] retain];
//        
////        [self sizeToFit];
//    }
}


-(NSArray*)processTextLineToWords:(NSString*)textLine{
    NSMutableArray* words = [NSMutableArray array];
    _enumerateIndex = 0;
    [textLine enumerateSubstringsInRange:NSMakeRange(0, textLine.length)
                                 options:NSStringEnumerationByWords
                              usingBlock:^(NSString *word,
                                           NSRange wordRange,
                                           NSRange enclosingRange,
                                           BOOL *stop){
                                  
                                  NSRange range = NSMakeRange(0, 0);
                                  range.location = enclosingRange.location > _enumerateIndex? _enumerateIndex : enclosingRange.location;
                                  range.length = enclosingRange.location + enclosingRange.length - range.location;
                                
                                  
                                  [self enumerateWord:range.location + range.length];
                                  
                                  NSString* finalWord = [textLine substringWithRange:range];
                                  
                                  BOOL hasFullWidth = NO;
                                  for (int i = 0; i < finalWord.length; i++) {
                                      unichar c = [finalWord characterAtIndex:i];
                                      
                                      if([self fullCharacter:c]){
                                          hasFullWidth = YES;
                                          break;
                                      }
                                  }
                                  
                                  if (hasFullWidth) {
                                      for (int i = 0; i < finalWord.length; i++) {
                                          [words addObject:[finalWord substringWithRange:NSMakeRange(i, 1)]];
                                      }
                                  }else{
                                      [words addObject:finalWord];
                                  }
                              }];
    
    return [NSArray arrayWithArray:words];
}

-(void)enumerateWord:(NSInteger)index{
    _enumerateIndex = index;
}

-(BOOL)fullCharacter:(unichar)unicode
{
    if ((unicode >= 0x1100 && unicode <= 0x115f) ||
        unicode == 0x2329 ||
        unicode == 0x232a ||
        (unicode >= 0x2500 && unicode <= 0x267f) ||
        (unicode >= 0x2e80 && unicode <= 0x2fff) ||
        (unicode >= 0x3001 && unicode <= 0x33ff) ||
        (unicode >= 0x3400 && unicode <= 0x4db5) ||
        (unicode >= 0x4e00 && unicode <= 0x9fa5) ||
        (unicode >= 0xa000 && unicode <= 0xa4c6) ||
        (unicode >= 0xac00 && unicode <= 0xd7a3) ||
        (unicode >= 0xf900 && unicode <= 0xfa6a) ||
        (unicode >= 0xfe30 && unicode <= 0xfe6b) ||
        (unicode >= 0xff01 && unicode <= 0xff60) ||
        (unicode >= 0xffe0 && unicode <= 0xffe6))
    {
        return YES;
    }else{
        return NO;
    }
}
- (void) applyOptionsFrom:(id <MysticLayerViewAbstract>)layerView;
{
    
}
- (void) update;
{
    
}

@end
