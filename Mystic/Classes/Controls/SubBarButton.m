//
//  SubBarButton.m
//  Mystic
//
//  Created by travis weerts on 1/28/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "SubBarButton.h"
#import "MysticConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Mystic.h"
#import "MysticOptions.h"
#import "MysticTabBar.h"

@interface SubBarButtonBlockCallingObject : NSObject

@property (copy, nonatomic) ActionBlock block;
@property (copy, nonatomic) MysticBlockSender senderBlock, holdBlock;
@end

@implementation SubBarButtonBlockCallingObject
@synthesize block = _block, senderBlock=_senderBlock, holdBlock=_holdBlock;

- (void)dealloc {

    self.block=nil;
    self.holdBlock=nil;
    self.senderBlock=nil;
    [super dealloc];
}

- (void)callblock  {
    self.block();
}

- (void)callSenderBlock:(id)sender  {
    self.senderBlock(sender);
}

- (void)callHoldBlock:(id)sender  {
    self.holdBlock(sender);
}
@end



@interface SubBarButton ()
{
    UIColor *lbgColor, *rbgColor;
    BOOL printLayout;
    UIEdgeInsets _insets;
    BOOL __enabled;

}

@property (nonatomic, retain) SubBarButtonBlockCallingObject *blockObject, *senderBlockObject, *holdBlockObject;
@property (nonatomic, readonly) CGRect imageBounds;

@end


@implementation SubBarButton


@synthesize rightOffset=_rightOffset, leftOffset=_leftOffset, radius=_radius, imageView=_imageView, states=_states, active, rootColor=_rootColor;
@synthesize holdBlockObject=_holdBlockObject, senderBlockObject=_senderBlockObject, blockObject=_blockObject, imageEdgeInsets=_imageEdgeInsets, type=_type, isFirst, isLast, imageBounds, contentInsets=_contentInsets, activeColorType=_activeColorType, normalColorType=_normalColorType, selectedColorType=_selectedColorType, adjustsImageWhenDisabled=_adjustsImageWhenDisabled, adjustsImageWhenHighlighted=_adjustsImageWhenHighlighted, setting=_setting, titleIconSpacing=_titleIconSpacing, controlState=_controlState;



+ (id) buttonWithType:(UIButtonType)type;
{
    SubBarButton *button = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, 50, 50) showTitle:MYSTIC_UI_TABBAR_SHOW_TITLES];
    return [button autorelease];
}
+ (id) buttonWithType:(UIButtonType)type frame:(CGRect)frame showTitle:(BOOL)showTitle;
{
    SubBarButton *button = [[[self class] alloc] initWithFrame:frame showTitle:showTitle];
    return [button autorelease];
}

- (Class) backgroundViewClass;
{
    return [SubBarButtonBackgroundView class];
}
+ (UIFont *) labelFont;
{
    return [MysticUI gothamBold:MYSTIC_UI_TABBAR_TITLE_FONTSIZE];
}
+ (UIEdgeInsets) contentInsets;
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
    
}

- (UIEdgeInsets) contentInsets;
{
    return UIEdgeInsetsEqualToEdgeInsets(_contentInsets, MysticInsetsUnknown) ? [[self class] contentInsets] : _contentInsets;
    
}


- (id)initWithFrame:(CGRect)frame showTitle:(BOOL)showTitle;
{
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        printLayout = NO;
        _insets = UIEdgeInsetsZero;
        _contentInsets = MysticInsetsUnknown;
        _imageEdgeInsets = UIEdgeInsetsZero;
        _activeColorType = MysticColorTypeControlIconActive;
        _selectedColorType = MysticColorTypeControlIconActive;
        _normalColorType = MysticColorTypeControlIconInactive;
        _adjustsImageWhenDisabled = NO;
        _adjustsImageWhenHighlighted = YES;
        _rightOffset = 0.0f;
        _leftOffset = 0.0f;
        _canUnselect = YES;
        _toggleSelected = NO;
        _maxImageHeight = MYSTIC_FLOAT_UNKNOWN;
        _titleIconSpacing = MYSTIC_FLOAT_UNKNOWN;
        _setting = MysticSettingUnknown;
        _radius = 8.0f;
        self.contentMode = UIViewContentModeCenter;
        _allowSelect = NO;
        rbgColor = nil;
        lbgColor = nil;
        isFirst = NO;
        isLast = NO;
        self.opaque = NO;
        self.autoresizesSubviews = YES;
        self.userInteractionEnabled = YES;
        _bgView = [[[self backgroundViewClass] alloc] initWithFrame:self.bounds];
        _bgView.userInteractionEnabled = NO;
        if([_bgView isKindOfClass:[SubBarButtonBackgroundView class]])
        {
            _bgView.contentInsets = self.contentInsets;
            _bgView.type = self.type;

        }
        _bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bgView];
        
        self.opaque = NO;
        self.clipsToBounds = NO;

        self.backgroundColor = [UIColor color:MysticColorTypeTabBackground];
        
        

        self.imageView = [[[UIImageView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, self.contentInsets)] autorelease];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.imageView.clipsToBounds = YES;
        self.imageView.userInteractionEnabled = NO;
        
        
        [self setImageViewFrame:self.imageView.frame];
        [self addSubview:self.imageView];
        
        if(showTitle)
        {
            CGRect labelFrame = CGRectMake(0, 0, self.bounds.size.width, MYSTIC_UI_TABBAR_TITLE_HEIGHT);
            labelFrame = CGRectAlignOffset(labelFrame, self.bounds, MysticAlignTypeBottom, CGPointMake(0, self.titleIconSpacing));
            
            UIEdgeInsets labelInsets = UIEdgeInsetsMake(-1*self.contentInsets.top, self.contentInsets.left, self.contentInsets.bottom, self.contentInsets.right);
            

            self.titleLabel = [[[UILabel alloc] initWithFrame:UIEdgeInsetsInsetRect(labelFrame, labelInsets)] autorelease];
            self.titleLabel.backgroundColor = [UIColor clearColor];
            self.titleLabel.userInteractionEnabled = NO;
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
            [self setTitleColor:self.titleLabel.textColor forState:UIControlStateNormal];
            self.titleLabel.font = [[self class] labelFont];
            self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;

            [self addSubview:self.titleLabel];
            if([_bgView isKindOfClass:[SubBarButtonBackgroundView class]])
            {
                _bgView.alignDotsOnTop = YES;
            }
        }
        
        
        self.states = [NSMutableDictionary dictionary];
 
    }
    return self;
}

- (void) setNeedsDisplay;
{
    if([_bgView isKindOfClass:[SubBarButtonBackgroundView class]]) _bgView.types = self.types;
    [super setNeedsDisplay];
    [_bgView setNeedsDisplay];
}



- (void) setType:(MysticObjectType)value;
{
    _type = value;
    if(_setting == MysticSettingUnknown)
    {
        self.setting = MysticSettingForObjectType(_type);
    }
    switch (_type) {
        case MysticObjectTypePotion:
        {
            self.rootColor = [MysticColor colorWithType:MysticColorTypeObjectRecipe];
            
            break;
        }
        case MysticSettingPreferences:
        {
            self.rootColor = [MysticColor colorWithType:MysticColorTypeObjectSettings];
            break;
        }
        case MysticObjectTypeText:
        {
            self.rootColor = [MysticColor colorWithType:MysticColorTypeObjectText];
            break;
        }
        case MysticObjectTypeTexture:
        {
            self.rootColor = [MysticColor colorWithType:MysticColorTypeObjectTexture];
            break;
        }
        case MysticObjectTypeFrame:
        {
            self.rootColor = [MysticColor colorWithType:MysticColorTypeObjectFrame];
            break;
        }
        case MysticObjectTypeLight:
        {
            self.rootColor = [MysticColor colorWithType:MysticColorTypeObjectLight];
            break;
        }
        case MysticObjectTypeSetting:
        {
            self.rootColor = [MysticColor colorWithType:MysticColorTypeObjectSettings];
            break;
        }
        default:
            self.rootColor = [UIColor mysticGrayBackgroundColor];
            break;
    }
    if([_bgView isKindOfClass:[SubBarButtonBackgroundView class]])
    {
        _bgView.type = _type;
        _bgView.types = self.types;
    }


    
}
- (UIColor *) rootColor;
{
    return [UIColor color:MysticColorTypeTabBackground];

}
- (void) setRootColor:(UIColor *)value;
{

}
- (void) setTitle:(NSString *)title forState:(UIControlState)thestate;
{
    [self.states setObject:title forKey:[NSString stringWithFormat:@"title-%d", (int)thestate]];
    if(self.state == thestate)
    {
        self.titleLabel.text = title;
    }

}
- (void) setTitleColor:(UIColor *)color forState:(UIControlState)thestate;
{
    [self.states setObject:color forKey:[NSString stringWithFormat:@"titleColor-%d", (int)thestate]];
    if(self.state == thestate)
    {
        self.titleLabel.textColor = color;
    }
    
}
- (void) setImage:(UIImage *)image forState:(UIControlState)thestate;
{
    [self.states setObject:image forKey:[NSString stringWithFormat:@"image-%d", (int)thestate]];
    if(self.state == thestate)
    {
        self.imageView.image = image;
    }
}
- (void) setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
{
    
}
- (CGFloat) labelHeight;
{
    return (self.titleLabel ? self.titleLabel.bounds.size.height : 0);
}
- (CGFloat) labelWidth;
{
    return (self.titleLabel ? self.titleLabel.bounds.size.width : 0);
}
+ (CGFloat) maxImageHeight;
{
    return MYSTIC_FLOAT_UNKNOWN;
}
- (CGFloat) maxImageHeight;
{
    if(_maxImageHeight != MYSTIC_FLOAT_UNKNOWN)
    {
        return _maxImageHeight;
    }
    CGFloat h = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets).size.height;
    
    return h - self.labelHeight;
}

- (CGRect) imageBounds;
{
    CGRect rect = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets);
    if(self.titleLabel)
    {
        rect.size.height -= self.titleLabel.frame.size.height;
    }
    return rect;
}
- (void) setImageEdgeInsets:(UIEdgeInsets)value;
{
    printLayout = YES;
    _imageEdgeInsets = value;
    [self setImageViewFrame:UIEdgeInsetsInsetRect(self.imageBounds, _imageEdgeInsets)];
}

- (CGRect) setImageViewFrame:(CGRect)newFrame;
{
    
    newFrame.size.height = MIN(self.maxImageHeight, newFrame.size.height);
    self.imageView.frame = newFrame;
    [self setNeedsLayout];
    return self.imageView.frame;
}

- (void) setBackgroundColor:(UIColor *)value animated:(BOOL)animate;
{
    if(animate && [_bgView isKindOfClass:[SubBarButtonBackgroundView class]])
    {
        [MysticUIView animateWithDuration:0.1 animations:^{
            _bgView.fillColor = value;
        }];
    }
    else if([_bgView isKindOfClass:[SubBarButtonBackgroundView class]])
    {
        
        _bgView.fillColor = value;
        
    }
    [self setNeedsDisplay];
    [_bgView setNeedsDisplay];
//    
}

- (void) setActive:(BOOL)isActive
{
    if([_bgView isKindOfClass:[SubBarButtonBackgroundView class]]) _bgView.selected = isActive;
    
    active = isActive;
    if(self.titleLabel)
    {
        self.titleLabel.highlighted = active;
    }
    [self setNeedsDisplay];
    [_bgView setNeedsDisplay];
}
- (void) setActive:(BOOL)isActive animated:(BOOL)animated;
{
    if([_bgView isKindOfClass:[SubBarButtonBackgroundView class]]) _bgView.selected = isActive;

    active = isActive;
    if(self.titleLabel)
    {
        self.titleLabel.highlighted = active;
    }

    [self setNeedsDisplay];
    [_bgView setNeedsDisplay];
}

- (MysticObjectType) objectType;
{
    return self.type < MysticObjectTypeLastOfObjects ? MysticTypeForSetting(self.type, nil) : self.type;
}

- (void) setSelected:(BOOL)doselected
{
    if(doselected)
    {
        for (SubBarButton *siblingButton in self.superview.subviews)
            if(![siblingButton isEqual:self] && [siblingButton isKindOfClass:[self class]] && siblingButton.canUnselect) siblingButton.selected = NO;
    }
    [self showAsSelected:doselected];

}

- (void) showAsSelected:(BOOL)doselected;
{

    [super setSelected:doselected];
    UIImage *image = [self imageForState:doselected ? UIControlStateSelected : UIControlStateNormal] ;
    NSString *title = [self titleForState:doselected ? UIControlStateSelected : UIControlStateNormal];
    if(image) self.imageView.image = image;
    if(title && self.titleLabel && title.length > 0) self.titleLabel.text = title;
    [self setNeedsDisplay];
}
- (BOOL) enabled;
{
    return super.enabled;
}
- (void) setEnabled:(BOOL)enabled;
{
//    super.enabled = enabled;
    super.enabled = enabled;
    __enabled = enabled;
    if(!enabled)
    {
        self.titleLabel.highlighted = NO;
    }
    UIControlState ns = enabled ? (self.selected ? UIControlStateSelected : UIControlStateNormal) : UIControlStateDisabled;
    UIImage *image = [self imageForState:ns];
    if(image) self.imageView.image = image;

    NSString *        title = [self titleForState:ns];
    if(title && self.titleLabel && title.length > 0) self.titleLabel.text = title;
    UIColor *c = [self titleColorForState:ns];
    
    
    
    if(c)
    {
        self.titleLabel.textColor = c;
    }
    else
    {
        self.titleLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
    }

}
- (void) setDebug:(BOOL)debug;
{
    _debug = debug;
    if(_debug)
    {
        MBorder(self, [[UIColor red] colorWithAlphaComponent:0.3], 1);
        MBorder(self.imageView, [[UIColor greenColor] colorWithAlphaComponent:0.1], 1);
        MBorder(self.titleLabel, [[UIColor yellowColor] colorWithAlphaComponent:0.1], 1);

    }
    else
    {
        MBorder(self, nil, 0);
        MBorder(self.imageView, nil, 0);
        MBorder(self.titleLabel, nil, 0);


    }
}
- (NSString *) titleForState:(UIControlState)thestate;
{
    return [self.states objectForKey:[NSString stringWithFormat:@"title-%d", (int)thestate]];
}
- (UIColor *) titleColorForState:(UIControlState)thestate;
{
    return [self.states objectForKey:[NSString stringWithFormat:@"titleColor-%d", (int)thestate]];
}

- (UIImage *) imageForState:(UIControlState)thestate;
{
    
    UIImage *theimage = [self.states objectForKey:[NSString stringWithFormat:@"image-%d", (int)thestate]];
    
    if(!theimage && self.adjustsImageWhenHighlighted && thestate == UIControlStateHighlighted)
    {
        theimage = [self.states objectForKey:[NSString stringWithFormat:@"image-%d", (int)UIControlStateNormal]];
        CGSize  oimage = theimage.size;
        if(theimage)
        {
            
            theimage = [MysticImage imageByApplyingAlpha:0.3 toImage:theimage];
            theimage = [MysticImage image:theimage size:oimage color:nil];
            [self setImage:theimage forState:UIControlStateHighlighted];
        }
    }
    
    return theimage;
}

- (void) setHighlighted: (BOOL) highlighted {
    [super setHighlighted: highlighted];
    self.titleLabel.highlighted = highlighted;
    UIImage *image;
    if(highlighted)
    {
        image = [self imageForState:UIControlStateHighlighted];
        if(image) self.imageView.image = image;
    }
    else
    {
        image = [self imageForState:self.state];
        if(image) self.imageView.image = image;
    }
    
    UIColor *c = [self titleColorForState:highlighted ? UIControlStateHighlighted : UIControlStateNormal];
    if(c)
    {
        self.titleLabel.textColor = c;
    }
}



-(SubBarButton *) handleControlEvent:(UIControlEvents)event
                           withBlock:(ActionBlock) action
{
    
    
    if(!action)
    {
        self.blockObject=nil;
        [self removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        return self;
    }
    SubBarButtonBlockCallingObject *obj = [[SubBarButtonBlockCallingObject alloc] init];
    obj.block = action;
    self.blockObject = obj;
    [obj release];
    
    Block_release(action);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
    return self;
}

-(SubBarButton *) handleControlEvent:(UIControlEvents)event
                     withBlockSender:(MysticBlockSender) action
{
    if(!action)
    {
        self.senderBlockObject=nil;
        [self removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        return self;
    }
    
    SubBarButtonBlockCallingObject *obj = [[SubBarButtonBlockCallingObject alloc] init];
    obj.senderBlock = action;
    self.senderBlockObject = obj;
    [obj release];
    [self addTarget:self action:@selector(callActionSenderBlock:) forControlEvents:event];
    return self;
}

- (SubBarButton *) handleTouchAndHoldForDuration:(NSTimeInterval)duration action:(MysticBlockSender)action;
{
    if(!action)
    {
        self.gestureRecognizers = nil;
        return self;
    }
    
    SubBarButtonBlockCallingObject *obj = [[SubBarButtonBlockCallingObject alloc] init];
    obj.holdBlock = action;
    self.holdBlockObject = obj;
    [obj release];
    
    
    Block_release(action);
    UILongPressGestureRecognizer *longPress_gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(callHoldActionSenderBlock:)];
    [longPress_gr setMinimumPressDuration:duration]; // triggers the action after 2 seconds of press
    [self addGestureRecognizer:longPress_gr];
    [longPress_gr release];
    return self;
}

-(void) callHoldActionSenderBlock:(id)sender{
    [self.holdBlockObject callHoldBlock:self];
}

-(void) callActionSenderBlock:(id)sender{
    [self.senderBlockObject callSenderBlock:self];
}

-(void) callActionBlock:(id)sender{
    [self.blockObject callblock];
}


- (void) clear;
{
    self.senderBlockObject=nil;
    self.holdBlockObject=nil;
    self.blockObject=nil;
}


- (void) setFrame:(CGRect)frame;
{
    [super setFrame:frame];
    [self setNeedsLayout];
}

- (NSArray *) types;
{
    NSMutableArray *btnTypes = [NSMutableArray arrayWithObject:@(self.type)];
    MysticTabBar *tabBar = (MysticTabBar *)self.superview;
    
    switch (self.type) {
        case MysticObjectTypeSetting:
        case MysticSettingSettings:
        {
            if(tabBar && ![tabBar containsButtonOfType:MysticObjectTypeFilter])
            {
                [btnTypes addObject:@(MysticObjectTypeFilter)];
            }
            
            break;
        }
            
        default: break;
    }
    
    return btnTypes;
}
- (CGFloat) titleIconSpacing;
{
    return _titleIconSpacing != MYSTIC_FLOAT_UNKNOWN ? _titleIconSpacing : MYSTIC_UI_TABBAR_TITLE_SPACE_BTWN_ICON;
}
- (void) setTitleIconSpacing:(CGFloat)titleIconSpacing;
{
    _titleIconSpacing = titleIconSpacing;
    [self setNeedsLayout];
}
- (void) setContentInsets:(UIEdgeInsets)contentInsets;
{
    BOOL changed = !UIEdgeInsetsEqualToEdgeInsets(contentInsets, _contentInsets);
    _contentInsets = contentInsets;
//    DLog(@"set content insets: %@: %@ == %@", MBOOL(changed), NSStringFromUIEdgeInsets(_contentInsets), NSStringFromUIEdgeInsets(self.contentInsets));
    if(changed)
    {
//        printLayout = YES;
        [self setNeedsLayout];
    }
}
- (void) layoutSubviews;
{
//    if(printLayout) ALLog(@"layout subviews before", @[@"title label", FLogStr(self.titleLabel.frame),
//                                                @"image view", FLogStr(self.imageView.frame),]);
    
    [super layoutSubviews];
    if(self.contentMode == UIViewContentModeCenter)
    {
        CGRect cFrame = CGRectZero;
        CGFloat btnH = self.titleIconSpacing + self.imageEdgeInsets.bottom;
        cFrame.size.height += self.imageView.frame.size.height + self.labelHeight + (self.labelHeight > 0 ? btnH : 0);
        cFrame.size.width = MAX(self.labelWidth, self.imageView.frame.size.width);
        
        cFrame.origin.y = (self.bounds.size.height - cFrame.size.height)/2;
        
        CGRect iFrame = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets);
        iFrame.size.height = self.imageView.frame.size.height;
        
        iFrame.origin.y = cFrame.origin.y;
        
        iFrame.origin.x += self.imageEdgeInsets.left;
        iFrame.origin.y += self.imageEdgeInsets.top;
        
        self.imageView.frame = iFrame;
        
        if(self.titleLabel)
        {
            CGRect lFrame = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets);

            CGRect lFrame2 = self.titleLabel.frame;
            lFrame2.size.width = lFrame.size.width;
            lFrame2.origin.x = lFrame.origin.x;
            lFrame2.origin.y = cFrame.origin.y + (cFrame.size.height - lFrame2.size.height);
            
            self.titleLabel.frame = lFrame2;
        }
        
//        if(printLayout) ALLog(@"layout subviews", @[@"title label", FLogStr(self.titleLabel.frame),
//                                                    @"image view", FLogStr(self.imageView.frame),]);
        
    }
}
- (void) setControlStateNormal:(int)controlStateNormal;
{
    if(controlStateNormal < 1000)
    {
        controlStateNormal += 1000;
    }
    _controlStateNormal = controlStateNormal;
}
- (int) controlState; { return _controlState-1000; }
- (BOOL) hasControlStates; { return self.controlStates && self.controlStates.count > 0; }
- (void) nextControlState;
{
    NSInteger cs =_controlState;
    cs = cs == UIControlStateNormal ? _controlStateNormal : cs;
    NSInteger i = [self.controlStates indexOfObject:@(cs)];
    NSInteger bi = i;
    if(i == NSNotFound) i = 0;
    else i = i+1 > self.controlStates.count-1 ? 0 : i+1;
    id ii = [self.controlStates objectAtIndex:i>=self.controlStates.count?0:i];
    self.controlState = [ii intValue];
}
- (void) setControlState:(int)state;
{
    NSMutableString *str = [NSMutableString string];
    for (id sss in self.controlStates) [str appendFormat:@"\n     %d (%@), ",[sss intValue], MysticObjectTypeToString([sss intValue]-1000)];
    BOOL s0 = _controlStates && [_controlStates containsObject:@(state)];
    BOOL s1000 = _controlStates && [_controlStates containsObject:@(1000+state)];
    
//    DLogSuccess(@"setting state: %d (%@)   s0: %@  s1000: %@   %@", state, state==UIControlStateNormal ? @"Normal" : MysticObjectTypeToString(s0?state-1000:state-1000), MBOOL(s0), MBOOL(s1000), str);
    if(state == UIControlStateNormal)
    {
        UIImage *img = [self imageForState:(UIControlState)_controlStateNormal];
        if(img) self.imageView.image = img;
        _controlState = _controlStateNormal;
        return;
    }
    if(_controlStates && (s0 || s1000))
    {
        int sv = s0 ? state : s1000 ? 1000+state : -1;
        UIImage *img = [self imageForState:(UIControlState)sv];
        if(img) self.imageView.image = img;
//        DLog(@"control state image:  %d  %@", sv, ILogStr(img));
        _controlState = sv;
        [self setNeedsDisplay];
    }
    
}
- (void) setControlStates:(NSArray *)controlStates;
{
    if(_controlStates) [_controlStates release], _controlStates=nil;
    if(controlStates && controlStates.count>0)
    {
        NSMutableArray *ss = [NSMutableArray array];
        for (NSNumber *s in controlStates) [ss addObject:@(1000+[s intValue])];
        if(ss.count) _controlStates = [[NSArray arrayWithArray:ss] retain];
        _type = [_controlStates.firstObject intValue]-1000;
    }
    if(_controlStates.count) _controlStateNormal = [_controlStates.firstObject intValue];
}
-(void) dealloc{
    [self removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    self.senderBlockObject=nil;
    self.holdBlockObject=nil;
    self.blockObject=nil;
    self.rootColor = nil;
    [_controlStates release];
    [_userInfo release];
    [_rootColor release], _rootColor=nil;
    [_states release], _states=nil;
    [rbgColor release], rbgColor=nil;
    [lbgColor release], lbgColor=nil;
    [_bgView release], _bgView=nil;
    [_imageView release];
    [_titleLabel release];
    [super dealloc];
}

@end




@interface SubBarButtonBackgroundView ()
{
    
}
@property (assign, nonatomic) UIEdgeInsets radii;
@end

@implementation SubBarButtonBackgroundView

@synthesize fillColor=_fillColor, selected=_selected, type=_type, types=_types, showDots=_showDots, alignDotsOnTop=_alignDotsOnTop, contentInsets=_contentInsets;

- (void) dealloc;
{
    [_fillColor release];
    [_types release];

    [super dealloc];
    
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.radii = UIEdgeInsetsMake(0, MYSTIC_UI_SUB_BTN_CORNER_RADIUS, MYSTIC_UI_SUB_BTN_CORNER_RADIUS, MYSTIC_UI_SUB_BTN_CORNER_RADIUS);
        self.showDots = YES;
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
        self.clearsContextBeforeDrawing = YES;
        self.alignDotsOnTop = MYSTIC_UI_TABBAR_SHOW_TITLES > 0;

    }
    return self;
}
- (void) setFillColor:(UIColor *)value;
{
    [_fillColor release];
    _fillColor = [value retain];
    [self setNeedsDisplay];
}

- (void) setShowDots:(BOOL)value;
{
    _showDots = value;
    [self setNeedsDisplay];
}

- (void) setContentInsets:(UIEdgeInsets)value;
{
    _contentInsets = value;
    [self setNeedsDisplay];
}
- (void) setSelected:(BOOL)selected;
{
    _selected = selected;
    [self setNeedsDisplay];
}
//- (void) drawRect:(CGRect)rect;
//{
//    
//    
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGMutablePathRef retPath;
//    
//    rect.origin = CGPointZero;
//    
//
//    
//}

@end
