//
//  MysticButtonBrush.m
//  Mystic
//
//  Created by Travis A. Weerts on 2/29/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticButtonBrush.h"
#import "UIColor+Mystic.h"
#import "MysticRadialGradientView.h"

@interface MysticButtonBrush ()
@property (nonatomic, assign) BOOL alreadySetup;
@property (nonatomic, assign) MysticRadialGradientView *brushView;
@end
@implementation MysticButtonBrush
+ (NSString *) brushValueString:(MysticBrushSetting)setting brush:(MysticBrush)brush;
{
    NSString *brushStr = nil;
    switch (setting) {
        case MysticBrushSettingOpacity:
            brushStr = brush.opacity < 0.01 && brush.opacity > 0 ? @"0.5" : [NSString stringWithFormat:@"%d", (int)(100*brush.opacity)];
            break;
        case MysticBrushSettingFeather:
            brushStr = brush.feather < 0.01 && brush.feather > 0 ? @"0.5" : [NSString stringWithFormat:@"%d", (int)(100*brush.feather)];
            break;
        case MysticBrushSettingSize:
            brushStr = brush.size < 0.01 && brush.size > 0 ? @"0.5" : [NSString stringWithFormat:@"%d", (int)(100*brush.size)];
            break;
            
        default: break;
    }
    return brushStr;
}
+ (instancetype) brushButtonWithSetting:(MysticBrushSetting)setting brush:(MysticBrush)brush color:(UIColor *)color displayColor:(UIColor *)displayColor action:(MysticBlockSender)action;
{
    MysticButtonBrush *b = [MysticButtonBrush button:[[self class] brushValueString:setting brush:brush] action:action];
    b.setting = setting;
    b.brush = brush;
    b.color = color;
    b.displayColor = displayColor;
    [b setNeedsLayout];

    return b;
}
+ (instancetype) brushButtonWithSetting:(MysticBrushSetting)setting brush:(MysticBrush)brush color:(UIColor *)color displayColor:(UIColor *)displayColor target:(id)target action:(SEL)action;
{
    MysticButtonBrush *b = [MysticButtonBrush button:[[self class] brushValueString:setting brush:brush] target:target sel:action];
    b.setting = setting;
    b.brush = brush;
    b.color = color;
    b.displayColor = displayColor;
    [b setNeedsLayout];
    return b;
}
- (void) dealloc;
{
    [super dealloc];
    _brushView=nil;
    [_color release];
    [_displayColor release];
}

- (void) commonInit;
{
    [super commonInit];
    self.contentMode = UIViewContentModeLeft;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleEdgeInsets = UIEdgeInsetsZero;
    self.autoresizesSubviews=YES;
    self.clipsToBounds = NO;
    self.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 10);
    _ignoreFeather = NO;
    _ignoreOpacity = NO;
    _ignoreColor = NO;
    _alreadySetup = NO;
    _setting=MysticBrushSettingAll;
    _brush = MysticBrushDefault;
    _brushButtonPosition = MysticAlignPositionRight;
    if(!self.brushView)
    {
        MysticRadialGradientView *brushView = [[MysticRadialGradientView alloc] initWithFrame:CGRectMake(0, 0, CGSizeSquareSmall(self.bounds.size).width, CGSizeSquareSmall(self.bounds.size).height)];
        brushView.contentMode = UIViewContentModeRedraw;
        brushView.userInteractionEnabled = NO;
        [self addSubview:brushView];
        _brushView = [brushView autorelease];
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}
- (void) setSetting:(MysticBrushSetting)setting;
{
    _setting = setting;
    switch (setting) {
        case MysticBrushSettingSize:
            self.ignoreFeather = YES;
            self.ignoreOpacity = YES;
            break;
        case MysticBrushSettingFeather:
            self.ignoreFeather = NO;
            self.ignoreOpacity = YES;
            break;
        case MysticBrushSettingOpacity:
            self.ignoreFeather = YES;
            self.ignoreOpacity = NO;
            break;
        default: break;
    }
}

- (UIViewContentMode) contentMode; { return UIViewContentModeRight; }
- (void) setBrush:(MysticBrush)brush;
{
    _brush = brush;
    [self setNeedsLayout];
}
- (void) setOpacity:(CGFloat)value;
{
    _brush.opacity = value;
    [self setNeedsLayout];
}
- (CGFloat) opacity; { return _brush.opacity; }

- (void) setFeather:(CGFloat)value;
{
    _brush.feather = value;
    [self setNeedsLayout];
}
- (CGFloat) feather; { return _brush.feather; }

- (void) setSize:(CGFloat)value;
{
    _brush.size = value;
    [self setNeedsLayout];
}
- (CGFloat) size; { return _brush.size; }

- (void) setType:(MysticBrushType)value;
{
    _brush.type = value;
    [self setNeedsLayout];
}
- (MysticBrushType) type; { return _brush.type; }


- (void) updateBrushView;
{
    UIColor *color = self.displayColor ? self.displayColor : self.color ? self.color : self.brushView.backgroundColor && ![self.brushView.backgroundColor isEqualToColor:[UIColor clearColor]] ? self.brushView.backgroundColor : [UIColor color:MysticColorTypePink];

    self.brushView.feather = self.setting == MysticBrushSettingFeather || self.setting == MysticBrushSettingAll ?  self.feather : 1;
    self.brushView.color1 = color;
    self.brushView.color2 = self.setting == MysticBrushSettingFeather || self.setting == MysticBrushSettingAll ? [color alpha:0.05] : nil;
    
    CGRect b = CGRectS(self.bounds, CGSizeSquareSmall(self.bounds.size));
    self.brushView.clipsToBounds = YES;
    if(!(self.setting == MysticBrushSettingFeather || self.setting == MysticBrushSettingAll))
    {
        self.brushView.backgroundColor = color;
        self.brushView.layer.cornerRadius = b.size.height/2;
    }
    else
    {
        self.brushView.backgroundColor = [UIColor clearColor];
    }
    
    self.brushView.alpha = self.ignoreOpacity ? self.brushView.alpha : self.opacity;
    self.brushView.center = CGPointCenter(self.bounds);
    CGRect b2 = (self.setting == MysticBrushSettingFeather || self.setting == MysticBrushSettingAll) ? CGRectz(CGRectScale(b, 1+(self.feather/3))) : CGRectz(b);
    CGFloat diff = !self.alreadySetup && (self.setting == MysticBrushSettingFeather || self.setting == MysticBrushSettingAll) ? b2.size.width - b.size.width : 0;
    CGPoint c = self.alreadySetup ? CGPointX(self.brushView.center, self.contentEdgeInsets.left + 35 + b.size.width/2) : CGPointZero;

    switch (self.brushButtonPosition) {
        case MysticAlignPositionLeft:
        {
            if(CGPointIsZero(c)) c = CGPointX(CGPointCenter(self.bounds), b2.size.width/2);
            self.contentMode = UIViewContentModeLeft;
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            break;
        }
       
        case MysticAlignPositionCenter:
        {
            if(CGPointIsZero(c)) c = CGPointCenter(self.bounds);
            self.contentMode = UIViewContentModeCenter;
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            break;
        }
        default:
        {
            if(CGPointIsZero(c)) c = CGPointX(CGPointCenter(self.bounds), self.bounds.size.width);
            self.contentMode = UIViewContentModeRight;
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            break;
        }
    }
    if([self titleForState:UIControlStateNormal].length)
    {
        NSString *title = [[self class] brushValueString:self.setting brush:self.brush];
        [self setTitle:[[@" " repeat:3-title.length] stringByAppendingString:title] forState:UIControlStateNormal];

    }
    if(self.alreadySetup) self.brushView.frame = (CGRect){c.x - b2.size.width/2,c.y-b2.size.height/2,b2.size.width,b2.size.height};
    else
    {
        [self sendSubviewToBack:self.brushView];
        switch (self.brushButtonPosition) {
            case MysticAlignPositionLeft:
            {
                self.titleLabel.textAlignment = NSTextAlignmentCenter;
                break;
            }
                
            case MysticAlignPositionCenter:
            {
                self.titleLabel.textAlignment = NSTextAlignmentCenter;
                break;
            }
            default:
            {
                self.titleLabel.textAlignment = NSTextAlignmentCenter;
                break;
            }
        }
        self.brushView.frame = (CGRect){self.contentEdgeInsets.left + 35,c.y-b2.size.height/2,b2.size.width,b2.size.height};
        [self setFont:[MysticFont font:11]];
        [self setTitleColor:[UIColor hex:@"5f524f"] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor hex:@"fd5a6b"] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor hex:@"b9ac9f"] forState:UIControlStateSelected];
    }
    
    [self.brushView setNeedsDisplay];
    [self setNeedsDisplay];
    if(!self.alreadySetup) self.alreadySetup = YES;
}
- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    [self setNeedsLayout];
}
- (void) layoutSubviews;
{
    [super layoutSubviews];
    [self updateBrushView];
}


@end
