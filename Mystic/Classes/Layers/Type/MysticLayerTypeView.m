//
//  MysticLayerTypeView.m
//  Mystic
//
//  Created by Me on 12/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerTypeView.h"
#import "MysticChoice.h"

@interface MysticLayerTypeView ()
{
    
}
@property (nonatomic, assign) BOOL shouldEndDraw;

@end
@implementation MysticLayerTypeView

@synthesize text=_text, font=_font, textAlignment=_textAlignment,lineHeight=_lineHeight,lineHeightScale=_lineHeightScale, textSpacing=_textSpacing, fontSize=_fontSize, lineBreakMode=_lineBreakMode, subText=_subText, attributedText=_attributedText, lineSpacing =_lineSpacing, alignPosition=_alignPosition;

+ (CGRect) boundsForContent:(id)_content target:(CGSize)targetSize context:(MysticDrawingContext **)context scale:(CGFloat)_scale;
{
    id content = _content ? _content : [[self class] attributedText:MYSTIC_DEFAULT_FONT_TEXT layer:nil];
    CGRect r = [MysticDrawTypeView boundsForContent:content target:targetSize context:context scale:_scale];
    return [super boundsForContent:content target:r.size context:context scale:_scale];
}
+ (MysticAttrString *) attributedText:(NSString *)str layer:(MysticLayerTypeView *)layer;
{
    NSMutableAttributedString* attrM;
    if([str isKindOfClass:[NSAttributedString class]])
    {
        attrM = [NSMutableAttributedString attributedStringWithAttributedString:(id)[str copy]];
        return [MysticAttrString string:attrM];
    }
    else if([str isKindOfClass:[MysticAttrString class]])
    {
        attrM = [NSMutableAttributedString attributedStringWithAttributedString:(id)[[(MysticAttrString *)str attrString] copy]];
        return [MysticAttrString string:attrM];
    }
    else
    {
        attrM = [NSMutableAttributedString attributedStringWithString:str];
    }
    
    MysticAttrString* attrString = [MysticAttrString string:attrM];
    
    NSMutableParagraphStyle *style = attrString.paragraph ? attrString.paragraph : [[NSMutableParagraphStyle alloc] init];
    if(layer && layer.lineSpacing) [style setLineSpacing:layer.lineSpacing];
    style.lineBreakMode = layer ? layer.lineBreakMode : NSLineBreakByWordWrapping;
    style.alignment = layer ? layer.textAlignment : NSTextAlignmentCenter;
    UIColor *newColor = layer ? layer.color : [UIColor whiteColor];

    attrString.paragraph = [style autorelease];
    attrString.color = newColor;
    attrString.font = layer ? layer.font : [MysticFont defaultTypeFont:MYSTIC_DEFAULT_RESIZE_LABEL_FONTSIZE];
    
    return attrString;
}

- (void) dealloc;
{
    [_font release],_font=nil;
    [_text release], _text=nil;
    [_subText release], _subText=nil;
    [_attributedText release], _attributedText=nil;
    [_rasteredAttrStringDrawContext release];
    _drawView = nil;
    [super dealloc];
}
- (void) commonInit;
{
    [super commonInit];
    self.opaque = NO;
    self.shouldEndDraw = NO;
    if(self.drawContext)
    {
        BOOL setup = [self.drawContext setNextTargetSize:_contentFrame.size];
        
    }
    _attributedText = self.drawContext && self.drawContext.attributedString ? [self.drawContext.attributedString retain] : nil;
    _fontSize = self.drawContext ? self.drawContext.fontSize : MYSTIC_FLOAT_UNKNOWN;
    _lineBreakMode = NSLineBreakByWordWrapping;
    _lineHeight = MYSTIC_FLOAT_UNKNOWN;
    _lineHeightScale = MYSTIC_DEFAULT_RESIZE_LABEL_LINEHEIGHT_SCALE;
    _lineSpacing = 0.f;
    _textAlignment = NSTextAlignmentCenter;
    _text = self.drawContext ? [self.drawContext.attributedString.string retain] : [MYSTIC_DEFAULT_FONT_TEXT retain];
    _textSpacing = 0;
    self.type = MysticObjectTypeFont;
}

- (CGFloat) offsetHeight;
{
    return self.attributedText.font.lineHeight;
}


- (CGFloat) fontSize; { return _fontSize != MYSTIC_FLOAT_UNKNOWN ? _fontSize : _font ? _font.pointSize : MYSTIC_DEFAULT_RESIZE_LABEL_FONTSIZE; }
- (void) setDrawView:(MysticDrawTypeView *)drawView;
{
    if(self.contentView)
    {
        drawView.frame = self.contentView.contentBounds;
        self.contentView.view =drawView;
    }
}
- (MysticDrawTypeView *) drawView;
{
    return self.contentView && [self.contentView.view isKindOfClass:[MysticDrawTypeView class]] ? (id)self.contentView.view : nil;
}
- (NSString *) text; { return _text != nil ? _text : _attributedText ? _attributedText.string : self.choice.content; }
- (UIFont *) font;
{
    UIFont *f = nil;
    f = !f && _font ? _font : f;
    if(f) return f;
    f = _attributedText ? self.attributedText.font : nil;
    return f? f : [MysticFont defaultTypeFont:self.fontSize];
}
- (id) attribute:(id)key;
{
    if(!key || !_attributedText) return nil;
    NSDictionary *attr = [_attributedText attributesAtIndex:0 effectiveRange:NULL];
    return attr[key];
    
}

- (void) setFontSize:(CGFloat)fontSize;
{
    _fontSize = fontSize;
    self.font = [self.font fontWithSize:_fontSize];
}

- (MysticAttrString *) attributedTextRastered;
{
    MysticAttrString *newStr = [MysticAttrString attributedStringWithString:self.attributedText];
    [newStr scaleFactor:self.drawContext.fontScaleFactor target:self.contentView.frame.size debug:nil];
    self.rasteredAttrStringDrawContext = [[self.drawContext copy] autorelease];
    return newStr;
}
- (BOOL) replaceContent:(MysticChoice *)choice adjust:(BOOL)adjust scale:(CGSize)scale;
{
    self.text = choice && [choice isKindOfClass:[MysticChoice class]] && choice.attributedString ? [choice.attributedString string] : (id)choice;
    MysticDrawingContext *newContext = [self.drawContext copy];
    newContext.adjustContentSizeToFit = NO;
    newContext.adjustTargetSize = YES;
    newContext.maxTargetSize = self.layersView.maxLayerBounds.size;
    newContext.targetScale = self.contentView.scale;
    self.attributedText = [self attributedText:choice && [choice isKindOfClass:[MysticChoice class]] && choice.attributedString ? choice.attributedString.attrString : (id)@YES];
    CGSize newTargetSize = !(!CGSizeIsZero(scale) && scale.width > 1) ? self.contentFrame.size : CGSizeCeil(CGSizeWithWidth(self.contentFrame.size, self.contentFrame.size.width*scale.width));
    CGSize nt = newTargetSize;
    if(adjust && !CGRectContainsRect(CGRectz(self.layersView.maxLayerBounds), CGRectSize(newTargetSize)))
        newTargetSize = CGSizeCeil(CGRectFit(CGRectSize(newTargetSize), CGRectz(self.layersView.maxLayerBounds)).size);

    newTargetSize.height = CGFLOAT_MAX;
    newTargetSize = CGRectSizeFloor(CGRectScale([MysticDrawTypeView boundsForContent:_attributedText target:newTargetSize context:&newContext scale:self.layersView.contentScale], self.contentView.scale)).size;

    MysticDrawingContext *scaledStrContext = [MysticDrawingContext contextWithTargetSize:newTargetSize minimumScaleFactor:0];
    choice.attributedString = [[MysticAttrString string:_attributedText] scaleFactor:newContext.fontScaleFactor target:newTargetSize debug:nil];
    choice.frame = [choice.attributedString boundingRectWithSize:newTargetSize options:NSStringDrawingUsesLineFragmentOrigin context:scaledStrContext];
    self.fontSize = newContext.fontSize;
    self.drawContext = newContext;
    choice.size = CGSizeUnknown;
    choice.frameSet = NO;
    choice.offset = CGPointUnknown;
    choice.color = self.choice.attributedString.color;
    choice.path = nil;
    choice.maxWidth = newTargetSize.width;
    
    MysticTransView *choiceView = choice.contentView ? [(id)[choice.contentView retain] autorelease] : nil;
    BOOL diff = [super replaceContent:[choice scale:CGScaleWithSize(scale)] adjust:adjust scale:scale];
    self.choice.attributedString = self.attributedText;
    self.choice.originalContentFrame = CGRectUnknown;
    self.transView.frame = [self.choice updateView:(id)self.transView].bounds;
    CGScaleOfView scaleOfViews = [self.choice scaleOfView:self fromView:choiceView];
    if(choiceView) self.transView.frame = [[self.choice scale:scaleOfViews.scale] updateView:(id)self.transView].bounds;

    
    [self.transView resizeToSmallestLayer];
    if(self.transView.hasBorderView)
    {
        [self increaseContentInsets:UIEdgeInsetsScale(UIEdgeInsetsMinus(UIEdgeInsetsRectDiff(self.transView.borderView.borderLayer.pathBounds,self.transView.innerFrame), UIEdgeInsetsRectDiff(self.transView.frame, self.transView.innerFrame)),CGScaleWith(1/self.contentView.scale))];
    }
    [self setContentFrameAndLayout:CGRectz(CGRectSizeCeil(CGRectScale(self.transView.frame, 1/self.contentView.scale)))];
//    DLog(@"replace text: %@ %@   %@   %@", b(diff), textAlignmentString(self.attributedText.textAlignment), textAlignmentString(self.choice.attributedString.textAlignment), textAlignmentString(choice.attributedString.textAlignment));
    self.choice = choice;

    return diff;
}


- (BOOL) rebuildContext;
{
    BOOL c = [super rebuildContext];
    if(c)
    {
        MysticDrawingContext *newContext = [self.drawContext copy];
        newContext.adjustContentSizeToFit = NO;
        CGRect newBounds = [MysticDrawTypeView boundsForContent:[self attributedText:(id)@YES] target:self.contentFrame.size context:&newContext scale:self.layersView.contentScale];
        self.fontSize = newContext.fontSize;
        self.attributedText = [self attributedText:(id)@YES];
        if(self.drawView) self.drawView.contextSizeContext = newContext;
        self.drawContext = [newContext autorelease];
    }
    return c;
}

- (void) setContent:(id)content;
{
    BOOL hasContent = _content != nil;
    [super setContent:content];
//    if(_attributedText) [_attributedText release], _attributedText=nil;
    [self attributedText:hasContent?(id)@YES:MYSTIC_DEFAULT_FONT_TEXT];

    if(!hasContent) {
        CGPoint center = self.center;
        MysticDrawingContext *newContext = [self.drawContext copy];
        newContext.adjustContentSizeToFit = NO;
        newContext.adjustTargetSize = YES;
        newContext.maxTargetSize = self.layersView.maxLayerBounds.size;
        newContext.targetScale = self.contentView.scale;
        
        
        CGSize newTargetSize = CGRectHeight(self.contentFrame, CGFLOAT_MAX).size;
        CGRect newBounds = [MysticDrawTypeView boundsForContent:_attributedText target:newTargetSize context:&newContext scale:self.layersView.contentScale];
        CGRect newBoundsScaled = CGRectScale(newBounds, self.contentView.scale);
        MysticDrawingContext *scaledStrContext = [MysticDrawingContext context];
        scaledStrContext.minimumScaleFactor = 0;
        scaledStrContext.targetSize = CGRectSizeFloor(newBoundsScaled).size;
        
        MysticAttrString *scaledStr = [MysticAttrString string:_attributedText];
        [scaledStr scaleFactor:newContext.fontScaleFactor target:scaledStrContext.targetSize debug:nil];
        
        CGRect attrBounds = [scaledStr boundingRectWithSize:CGRectSizeFloor(newBoundsScaled).size options:NSStringDrawingUsesLineFragmentOrigin context:scaledStrContext];
        newBounds.size.width = attrBounds.size.width/self.contentView.scale;
        newBounds.size.height = attrBounds.size.height/self.contentView.scale;
        newBounds = CGRectSizeCeil(newBounds);
        self.transView.frame = CGRectz(newBounds);
        
        
        self.fontSize = newContext.fontSize;
        self.drawContext = newContext;
        self.choice.offset = CGPointUnknown;
        self.choice.frame = attrBounds;
        self.choice.attributedString = scaledStr;
        self.choice.color = self.choice.attributedString.color;
        
        [self.choice updateView:(id)self.transView debug:nil];
        [self setContentFrameAndLayout:CGRectz(newBounds)];
        [self.choice setNeedsLayout];
        [self.transView updateLayout];
        self.center = center;

    }
}


- (void) loadView;
{
    [super loadView];
    self.contentView.view = [[[MysticTransView alloc] initWithFrame:self.contentView.contentBounds] autorelease];
    _transView = (id)self.contentView.view;
}

- (MysticAttrString *) attributedText;
{
    return [self attributedText:nil];
}
- (MysticAttrString *) attributedText:(id)str;
{
    if(_attributedText && (!str || ([str isKindOfClass:[NSString class]] && [_attributedText.string isEqualToString:str]))) return _attributedText;
    
    str = str && ([str isKindOfClass:[NSString class]] || [str isKindOfClass:[NSAttributedString class]]) ? str : (_attributedText ? _attributedText : self.text);

    MysticAttrString *attrString = [[self class] attributedText:str layer:self];
    if(_attributedText) [_attributedText release], _attributedText=nil;

    _attributedText = attrString ? [attrString retain] : nil;
    return attrString;
}


- (NSString *) debugDescription;
{
    MysticAttrString *rAttr = self.attributedTextRastered;
    NSString *title = [NSString stringWithFormat:@"%@ #%d", NSStringFromClass(self.class), (int)self.index];
    NSString *s = ALLogStrf(title,
                                        @[@"frame", FLogStr(self.frame),
                                          @"content", FLogStr(self.contentView.bounds),
                                          @"contentScale", @(self.contentView.scale),
                                          @"contentTransformScale", sc(self.contentView.transformScale),
                                          @"rotation", @(self.rotation),
                                          LINE,
                                          @"fontSize", @(self.attributedText.fontSize),
                                          @"contentFontSize", @(self.drawView.scaledAttributedText.fontSize),
                                          LINE,
                                          
                                          @"rasterFontSize", @(rAttr.fontSize),
                                          @"rasterFontScaleFactor", SLogStrd(self.rasteredAttrStringDrawContext.fontScaleFactor, 3),
                                          @"rasterScale", @(rAttr.scale),
                                          LINE,
                                          @"lineHeightMultiple", @(_attributedText.lineHeightMultiple),
                                          @"kerning", @(_attributedText.kerning),
                                      
                                      ]);
    
    return [s stringByAppendingFormat:@"\n\n%@\n\n", _attributedText.description];
}
- (NSString *) description;
{
    return [NSString stringWithFormat:@"%@  %2.1fpt  \"%@\" ", [super description], self.fontSize, self.text];
}


@end
