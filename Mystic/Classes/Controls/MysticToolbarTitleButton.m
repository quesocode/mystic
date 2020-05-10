//
//  MysticToolbarTitleButton.m
//  Mystic
//
//  Created by Me on 5/1/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticToolbarTitleButton.h"
#import "MysticFont.h"

@interface MysticToolbarTitleButton ()


@end
@implementation MysticToolbarTitleButton

@synthesize attributedText=_attributedText, font=_font;

+ (id) button:(id)titleOrImg action:(MysticBlockSender)action;
{
    MysticToolbarTitleButton *btn = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    if(titleOrImg && [titleOrImg isKindOfClass:[NSString class]])
    {
        btn.titleLabel.text = titleOrImg;
    }
    else if([titleOrImg isKindOfClass:[UIImage class]])
    {
        [btn.button setImage:titleOrImg forState:UIControlStateNormal];
    }
    return [btn autorelease];
}

- (void) dealloc;
{
    [_font release];
    [_attributedText release];
    [_button release];
    [_titleLabel release];
    [_selectedBackgroundColor release];
    [_normalBackgroundColor release];
    [_attrTitles release];
    [super dealloc];

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        self.enabled = YES;
        self.ready = NO;
        self.useAttrText = YES;
        self.userInteractionEnabled = YES;
        self.attrTitles = [NSMutableDictionary dictionary];
        MysticButton *btn = [[MysticButton alloc] initWithFrame:self.bounds];
        btn.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        btn.enabled = NO;
        btn.userInteractionEnabled = NO;
        
        self.button = [btn autorelease];
        
        [self addSubview:self.button];
        
        OHAttributedLabel *label = [[OHAttributedLabel alloc] initWithFrame:self.bounds];
        label.centerVertically = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

        self.titleLabel = [label autorelease];
        self.font = [MysticFont font:12];
        [self addSubview:self.titleLabel];
        
        
    }
    return self;
}
- (void) commonInit;
{
    
}

- (NSTextAlignment) textAlignment;
{
    return self.titleLabel.textAlignment;
}
- (void) setTextAlignment:(NSTextAlignment)textAlignment;
{
//    self.titleLabel.textAlignment = textAlignment;
    
    
    if(!self.attributedText) return;
    
    [self setAttributedTitle:[self alignedText:self.attributedText alignment:textAlignment]];

}

- (NSAttributedString *)alignedText:(NSAttributedString *)titleStr alignment:(NSTextAlignment)textAlignment;
{
    NSMutableAttributedString *title = [NSMutableAttributedString attributedStringWithAttributedString:titleStr];
    
    NSRange strRange = NSMakeRange(0, [title.string length]);
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = textAlignment;
    [title addAttribute:NSParagraphStyleAttributeName
                  value:style
                  range:strRange];
    
    [style release];
    
    return title;
}
- (BOOL) continueOnHold; { return self.button.continueOnHold; }
- (void) setContinueOnHold:(BOOL)continueOnHold;
{
    self.button.continueOnHold = continueOnHold;
}
- (void) setSelected:(BOOL)selected;
{
    [super setSelected:selected];
    if(!self.canSelect) return;
    [self.button setSelected:selected];
    [self updateState];
}

- (void) setHighlighted:(BOOL)highlighted;
{
    [super setHighlighted:highlighted];
    self.button.highlighted = highlighted;
    self.titleLabel.highlighted = highlighted;
    [self updateState];

}

- (void) updateState;
{
    if(!self.ready) {
        
        return;
    }

    UIColor *stateColor = [self.button titleColorForState:UIControlStateNormal];
    if(self.highlighted)
    {
        
        
        self.titleLabel.attributedText  = [self attributedTitleForState:UIControlStateHighlighted];
        
        stateColor = [self.button titleColorForState:UIControlStateHighlighted] ? [self.button titleColorForState:UIControlStateHighlighted] : stateColor;
    }
    else if(self.selected)
    {
        self.titleLabel.attributedText = [self attributedTitleForState:UIControlStateSelected];
        stateColor = [self.button titleColorForState:UIControlStateSelected] ? [self.button titleColorForState:UIControlStateSelected] : stateColor;
    }
    else
    {
        
        self.titleLabel.attributedText = [self attributedTitleForState:UIControlStateNormal];
    }
    
    if(!self.useAttrText || !self.titleLabel.attributedText)
    {
        self.titleLabel.textColor = stateColor;
    }
}
- (UIColor *) textColor;
{
    return [self.button titleColorForState:UIControlStateNormal];
}
- (UIColor *) titleColorForState:(UIControlState)state;
{
    return [self.button titleColorForState:state];
}
- (void) setTextColor:(UIColor *)textColor;
{
    [self setTitleColor:textColor forState:UIControlStateNormal];
}
- (void) setTitleColor:(UIColor *)color forState:(UIControlState)state;
{
    
    [self.button setTitleColor:color forState:state];
//    self.titleLabel.textColor = color;
    [self updateState];
}
- (NSAttributedString *) attributedText;
{
    return self.titleLabel.attributedText;
}
- (void) setAttributedText:(NSAttributedString *)attributedText;
{
    [self setAttributedTitle:attributedText];
}
- (void) setAttributedTitle:(NSAttributedString *)title;
{
    
    [self setAttributedTitle:title forState:UIControlStateNormal];
}
- (void) setAttributedTitle:(NSAttributedString *)titleStr forState:(UIControlState)state;
{
//    NSMutableAttributedString *title = [NSMutableAttributedString attributedStringWithAttributedString:titleStr];
//    NSRange strRange = NSMakeRange(0, [title.string length]);
//    
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    style.alignment = NSTextAlignmentCenter;
//    //    [style setLineSpacing:3];
//    [title addAttribute:NSParagraphStyleAttributeName
//                value:style
//                range:strRange];
//    
//    [style release];
//    if(state == UIControlStateNormal)
//    {
//        self.titleLabel.attributedText = title;
//    }
    
    NSAttributedString *title = [self alignedText:titleStr alignment:self.textAlignment];
    BOOL changed = NO;
    if(title)
    {
        changed = [self.attrTitles objectForKey:@(state)] != nil;
        [self.attrTitles setObject:title forKey:@(state)];
    }
    if(changed) [self updateState];
}
- (NSAttributedString *)attributedTitleForState:(UIControlState)state;
{
    if([self.attrTitles objectForKey:@(state)])
    {
        return [self.attrTitles objectForKey:@(state)];
    }
    return nil;
//    return self.titleLabel.attributedText;
}

- (NSString *)titleForState:(UIControlState)state;
{
    NSAttributedString *s = [self attributedTitleForState:state];
    if(s) return s.string;
    return [self.button titleForState:state];
}

- (UIColor *)titleShadowColorForState:(UIControlState)state;
{
    return [self.button titleShadowColorForState:state];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state;
{
    [self.button setImage:image forState:state];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
{
    [self.button setBackgroundImage:image forState:state];
}
- (UIImage *)imageForState:(UIControlState)state;
{
    return [self.button imageForState:state];
}
- (UIImage *)backgroundImageForState:(UIControlState)state;
{
    return [self.button backgroundImageForState:state];
}
- (void) setFont:(UIFont *)font;
{
    self.titleLabel.font = font;
}
- (UIFont *) font;
{
    return self.titleLabel.font;
}
- (void) clear;
{
    [self.button clear];
}
- (void) addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
{
    [super addTarget:target action:action forControlEvents:controlEvents];
}
- (void) removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
{
    [super removeTarget:target action:action forControlEvents:controlEvents];
}
- (void) tap;
{
    [self.button tap];
}
- (void) setBackgroundColor:(id)backgroundColor forState:(UIControlState)forState;
{
    [self.button setBackgroundColor:backgroundColor forState:forState];
    
    
}


@end
