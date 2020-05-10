//
//  MysticDrawTypeView.m
//  Mystic
//
//  Created by Me on 12/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticDrawTypeView.h"
#import "Mystic.h"
#import "MysticLayerBaseView.h"


@implementation MysticDrawTypeView

+ (CGRect) boundsForContent:(id)content target:(CGSize)targetSize context:(MysticDrawingContext **)_context scale:(CGFloat)scale;
{
    MysticDrawingContext *context = *_context;
    if(!_context)
    {
        MysticDrawingContext *dc = [[[MysticDrawingContext alloc] init] autorelease];
        dc.minimumScaleFactor = 0.5;
        dc.fontSizePointFactor = 0.5;
        dc.sizeOptions = MysticSizeOptionMatchDefault;
        dc.minimumRatio = (CGSize){0.7,0.7};
        context = dc;
        *_context = dc;
    }
    context.minimumRatio = (CGSize){0.7,0.7};
    if(!content)
    {
        NSMutableAttributedString *str = [NSMutableAttributedString attributedStringWithString:MYSTIC_DEFAULT_FONT_TEXT];
        content = str;
    }
    NSDictionary *newInfo = MysticAttributedStringThatFits(targetSize, content, &context);
    return CGSizeIsZero(context.totalSize) ? CGRectSize(targetSize) : CGRectSize(context.totalSize);
}
- (void) dealloc;
{
    [super dealloc];
    [_attributedText release], _attributedText=nil;
    [_text release], _text=nil;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self) self.redrawText = YES;
    return self;
}
- (NSString *) text;
{
    return _text != nil ? _text : _attributedText ? _attributedText.string : nil;
}
- (void) setAttributedText:(MysticAttrString *)attributedText;
{
    [self setAttributedText:attributedText rebuild:NO];
}
- (void) setAttributedText:(MysticAttrString *)attributedText rebuild:(BOOL)rebuild;
{
    BOOL setNew = _attributedText != nil;
    if(_attributedText) [_attributedText release], _attributedText=nil;
    _attributedText = attributedText ? [attributedText retain] : nil;
    if(rebuild || !self.contextSizeContext) [self contentSizeThatFits:setNew ? self.maxBounds : self.bounds];
}
- (MysticAttrString *) scaledAttributedText;
{
    if(_scaledAttributedText) return _scaledAttributedText;
    MysticAttrString *scaledStr = [MysticAttrString string:self.attributedText];
    [scaledStr scaleFactor:self.layerView.drawContext.fontScaleFactor target:CGRectSizeFloor(self.bounds).size debug:nil];
    _scaledAttributedText = [scaledStr retain];
    return _scaledAttributedText;
}
- (MysticDrawBlock) drawBlock;
{
    if(!_drawBlock)
    {
        __unsafe_unretained __block MysticDrawTypeView *weakSelf = self;
        _drawBlock = Block_copy(^(CGContextRef context, CGRect rect, CGRect bounds, UIView *view)
        {
            MysticDrawingContext *newContext = [MysticDrawingContext context];
            newContext.minimumScaleFactor = 0;
            newContext.targetSize = CGRectSizeFloor(weakSelf.bounds).size;
            weakSelf.renderRect = CGRectIsZero(weakSelf.renderRect) ? CGRectSizeFloor(weakSelf.bounds) : CGRectXY(weakSelf.renderRect, (weakSelf.bounds.size.width - weakSelf.renderRect.size.width)/2, (weakSelf.bounds.size.height - weakSelf.renderRect.size.height)/2);
            [weakSelf.scaledAttributedText drawWithRect:weakSelf.renderRect options:NSStringDrawingUsesLineFragmentOrigin context:newContext];
            weakSelf.actualContext = newContext;
        });
    }
    return _drawBlock;
}
- (void) drawWithRect:(CGRect)rect;
{
    [super drawWithRect:rect];
    if(self.attributedText && self.redrawText)
    {
        self.drawBlock(UIGraphicsGetCurrentContext(), rect, self.bounds, self);
        // possibly a duplicate draw call ? BUG ?
//        if(CGSizeIsZero(newContext.totalBounds.size)) [self.attributedText drawWithRect:renderRect options:NSStringDrawingUsesLineFragmentOrigin context:newContext];
    }
}


- (CGSize) contentSizeThatFits:(CGRect)rect;
{
    CGSize s = [super contentSizeThatFits:rect];
    MysticDrawingContext *dc = [[[MysticDrawingContext alloc] init] autorelease];
    dc.minimumScaleFactor = self.minimumScaleFactor;
    dc.fontSizePointFactor = 0.5;
    dc.sizeOptions = self.contentSizeOptions;
    dc.minimumRatio = (CGSize){0.5,0.5};
    dc.adjustContentSizeToFit = self.layerView.drawContext.adjustContentSizeToFit;
    NSDictionary *newInfo = MysticAttributedStringThatFits(rect.size, self.attributedText, &dc);
    [self setAttributedText:dc.attributedString rebuild:NO];
    self.contextSizeContext = dc;
    return CGSizeIsZero(dc.totalSize) ? s : dc.totalSize;
}

- (void) setContextSizeContext:(MysticDrawingContext *)newContext;
{
    BOOL reset = NO;
    if(_contextSizeContext)
    {
        reset = YES;
    }
    [super setContextSizeContext:newContext];
    if(reset) [self setAttributedText:newContext.attributedString rebuild:NO];
}




@end
