//
//  MysticFontStyleView2.m
//  Mystic
//
//  Created by Me on 3/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticFontStyleView2.h"
#import "FontStyleSubView.h"

@interface MysticFontStyleView2 ()

@property (nonatomic, retain) NSMutableArray *overlays;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGFloat padding;

@end
@implementation MysticFontStyleView2

- (void) commonInit;
{
    [super commonInit];
    self.overlays = [NSMutableArray array];
    self.padding = 10;
}
- (CGFloat) padding;
{
    return _padding*self.lineHeightScale;
}
- (void) setColor:(UIColor *)color;
{
    for (MysticFontStyleLabelView *subview in self.overlays) {
        subview.backgroundColor = color;
    }
}
- (void) removeOverlays;
{
    for (UIView *subview in self.overlays) {
        [subview removeFromSuperview];
    }
    [self.overlays removeAllObjects];
    _contentSize = CGSizeZero;
}
- (void) updateWithEffect:(MysticLayerEffect)effect;
{
//    DLog(@"-------------------------- update");
//    ALLog(@"Update with effect", @[
//                                   @"effect", @(effect),
//                                   @"lineHeightScale", @(self.lineHeightScale),
//                                   @"lineHeight", @(self.actualLineHeight),
//                                   @"fontSize", @(self.font.pointSize)]
//          );
    [super updateWithEffect:effect];
    [self removeOverlays];
    
    CGFloat x = self.contentBounds.origin.x;
//    CGFloat y = self.contentBounds.origin.y;
    NSArray *theLines = self.lines;
    CGFloat __lineHeight = self.actualLineHeight;

    CGFloat theHeight = (__lineHeight * theLines.count) + (self.padding * (theLines.count-1));
    
    CGFloat y = self.frame.size.height/2 - theHeight;
    
    CGPoint center = (CGPoint){self.frame.size.width/2, self.frame.size.height/2};
    CGFloat ny = 0;
    CGRect labelRect = CGRectMake(x, y, self.contentBounds.size.width, self.actualLineHeight);
    int i = 1;
    CGSize contentSize = CGSizeZero;
    for (NSArray *line in theLines) {
        NSString *thelineText = [line componentsJoinedByString:@""];
        thelineText = [self lineTextForLineIndex:thelineText index:i];
//        CGSize lineSize = [thelineText sizeWithFont:self.font];
        MysticTextAlignment textA = [self textAlignmentForEffect:effect];
        UIEdgeInsets insets = UIEdgeInsetsZero;
        
//        labelRect.size.width = lineSize.width + 10*2;
//        labelRect.size.width = MIN(labelRect.size.width, self.contentBounds.size.width);
        labelRect.size.width = self.contentBounds.size.width;
        
        switch (effect) {
            case MysticLayerEffectTwo:
            {
                labelRect.origin.x = center.x - (labelRect.size.width/2);
                break;
            }
            case MysticLayerEffectThree:
            {
                break;
            }
            case MysticLayerEffectFour:
            {
                labelRect.origin.x = center.x - (labelRect.size.width/2);
                break;
            }
            case MysticLayerEffectFive:
            {
                break;
            }
            case MysticLayerEffectSix:
            {
                break;
            }
            case MysticLayerEffectSeven:
            {
                break;
            }
            default:
            {
                labelRect.origin.x = self.contentBounds.origin.x + self.contentBounds.size.width - (labelRect.size.width);
                insets = UIEdgeInsetsMake(0, 1, 0, 12);
                break;
            }
        }
        
        labelRect.size.height = __lineHeight + insets.top + insets.bottom;
        
        labelRect = CGRectIntegral(labelRect);
        
        FontStyleSubView *label = [[FontStyleSubView alloc] initWithFrame:labelRect];
//        label.adjustsFontSizeToFitWidth = YES;
        label.label.textAlignment = textA;
        label.label.contentInset = insets;
        label.label.font = self.font;
        label.label.textColor = [UIColor blackColor];
        label.label.text = thelineText;
        
        label.backgroundColor = [UIColor whiteColor];
        
        

        [self.overlays addObject:label];
        labelRect.origin.y = label.frame.origin.y + label.frame.size.height + self.padding;
        CGRect l = label.frame;
        [label release];
        contentSize.width = MAX(contentSize.width, l.origin.x + l.size.width);
        contentSize.height = ny + l.size.height;
        
        ny += l.size.height;
        i++;
        
    }
    
    contentSize.height += self.padding*(self.overlays.count-1);
    
    self.contentSize = contentSize;
    
    
    [self layoutSubviews:YES];
//    self.contentSize = CGSizeZero;
//    [self layoutSubviews:NO];
    
}

- (void) setContentSize:(CGSize)value;
{
    if(CGSizeEqualToSize(value, CGSizeZero) && self.overlays.count)
    {
        CGRect labelRect;
        for (MysticFontStyleLabelView *label in self.overlays) {
            
            labelRect = label.frame;
            value.width = MAX(value.width, labelRect.origin.x + labelRect.size.width);
            value.height = MAX(value.height, labelRect.origin.y + labelRect.size.height);
            
        }
        value.height += self.padding*(self.overlays.count-1);

    }
    _contentSize = value;
}

- (void) layoutSubviews;
{
    [self layoutSubviews:NO];
}
- (void) layoutSubviews:(BOOL)add;
{
    [super layoutSubviews];
    CGPoint center = (CGPoint){self.frame.size.width/2, self.frame.size.height/2};
    CGFloat y = 0;
    y = (y + self.frame.size.height/2) - self.contentSize.height/2;
    CGRect labelRect;
//
//    SLog(@"content size", self.contentSize);
//    SLog(@"frame", self.frame.size);
//    DLog(@"start y: %2.1f", y);
    for (FontStyleSubView *label in self.overlays) {
        
        labelRect = label.frame;
        labelRect.origin.y = y;
        
        CGFloat lw = [label.label lineWidth:label.label.text] + (label.label.contentInset.left + label.label.contentInset.right)*2;
//        labelRect.size.width = lw;
        CGRect nf = label.backgroundView.frame;
        nf.size.width = lw;
        nf.origin.x = label.frame.size.width - lw;
        label.backgroundView.frame = nf;
        switch (self.effect) {
            case MysticLayerEffectTwo:
            {
                labelRect.origin.x = center.x - (labelRect.size.width/2);
                break;
            }
            case MysticLayerEffectThree:
            {
                break;
            }
            case MysticLayerEffectFour:
            {
                labelRect.origin.x = center.x - (labelRect.size.width/2);
                break;
            }
            case MysticLayerEffectFive:
            {
                break;
            }
            case MysticLayerEffectSix:
            {
                break;
            }
            case MysticLayerEffectSeven:
            {
                break;
            }
            default:
            {
                labelRect.origin.x = self.contentBounds.origin.x + self.contentBounds.size.width - (labelRect.size.width);
                break;
            }
        }

        label.frame = CGRectIntegral(labelRect);
        if(add) [self addSubview:label];
        y = label.frame.origin.y + label.frame.size.height + self.padding;
    }
}

- (NSString *) lineTextForLineIndex:(NSString *)text index:(NSInteger)index;
{
    return [text uppercaseString];
}
- (MysticTextAlignment) textAlignmentForEffect:(MysticLayerEffect)effect;
{
    switch (effect) {
        case MysticLayerEffectTwo:
            return MysticTextAlignmentCenter;
        case MysticLayerEffectThree:
            return MysticTextAlignmentJustified;
        case MysticLayerEffectFour:
            return MysticTextAlignmentCenter;
        case MysticLayerEffectFive:
            return MysticTextAlignmentLeft;
        case MysticLayerEffectSix:
            return MysticTextAlignmentJustified;
        case MysticLayerEffectSeven:
            return MysticTextAlignmentLeft;
        default:
            return MysticTextAlignmentRight;
    }
}

- (NSArray *) lines;
{
    NSMutableArray *__lines = [NSMutableArray array];
    NSMutableArray *__line = [NSMutableArray array];
    CGSize lineSize = CGSizeMake(0, 0);
    NSArray *__w = super.words;
    for (int i = 0; i < __w.count; i++) {
        
        NSString *word = [__w objectAtIndex:i];
        [__line addObject:word];
        CGSize wordSize = [word sizeWithFont:self.font];
        lineSize.height = MAX(lineSize.height, wordSize.height);
        
        lineSize.width += wordSize.width;
        
        if(__line.count == 2)
        {
            [__lines addObject:__line];
            __line = [NSMutableArray array];
            lineSize = CGSizeZero;
        }
        else if(i == __w.count - 1)
        {
            [__lines addObject:__line];
        }
        
        
    }
    return __lines;
}


@end
