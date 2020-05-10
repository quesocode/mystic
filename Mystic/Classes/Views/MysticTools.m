//
//  MysticTools.m
//  Mystic
//
//  Created by travis weerts on 3/2/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticTools.h"
#import "UserPotion.h"
#import "MysticOptions.h"

static CGFloat kFadeOutDuration = 0.4f;
static CGFloat kFadeInDuration = 1.0f;

static CGFloat kFadeOutRealFastDuration = 0.1f;
static CGFloat kFadeOutFastDuration = 0.2f;
static CGFloat kFadeInFastDuration = 0.2f;

static CGFloat kPauseBeforeTimerInterval = 0.3f;
static CGFloat kLongPauseBeforeTimerInterval = 6.0f;
static CGFloat kFadeOutTimerDuration = MYSTIC_TOOLS_FADEIN_SHOWTIME;

@interface MysticTools ()
{
    CGFloat buttonHeight;
    CGFloat buttonWidth;
    NSTimer *timer, *reloadTimer, *blurTimer, *blurTimer2;
}

@property (nonatomic, assign) BOOL holdingControl;
@property (nonatomic, assign) SEL holdingAction;
@property (nonatomic, retain) NSTimer *holdingTimer;
@property (nonatomic, assign) MysticPosition rotatePosition;

@end
@implementation MysticTools

@synthesize viewController=_viewController, currentSetting=_currentSetting, holdingControl=_holdingControl, blurView=_blurView, hideControlsWhenDone=_hideControlsWhenDone;


- (void) dealloc
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    Block_release(_onTransform);
    [_blurView release];
    _option = nil;
    _viewController = nil;
    if(_holdingTimer)
    {
        [_holdingTimer invalidate];
        [_holdingTimer release];
        _holdingTimer = nil;
    }
    [super dealloc];
}
- (void) removeFromSuperview;
{

    self.onTransform = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    for (MysticTransformButton *btn in self.subviews) {

            [btn removeFromSuperview];
            
    }
    
    
    [super removeFromSuperview];
    
}

- (CGRect) innerFrame;
{
    return CGRectInset(self.bounds, MYSTIC_UI_TOOLS_MARGIN_X, MYSTIC_UI_TOOLS_MARGIN_Y);
}
- (id)initWithFrame:(CGRect)frame setting:(MysticObjectType)setting
{
    self = [super initWithFrame:frame];
    if (self) {

        blurTimer = nil;
        blurTimer2 = nil;
        _rotatePosition = MysticPositionTop;
        buttonHeight = 0;
        buttonWidth = 0;
        _hideControlsWhenDone = YES;
        _toolHitInsets = 0;
        _lastActiveTransform = MysticToolsTransformTypeNone;
        
        self.userInteractionEnabled = YES;
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.toolSize = MYSTIC_UI_TOOLS_TOOL_SIZE;
        self.toolHitInsets = MYSTIC_UI_TOOLS_HIT_INSET;
        _currentSetting = setting;
        
        

        
    }
    return self;
}
- (void) resetDefaults;
{
    self.onTransform = nil;
    _toolHitInsets = MYSTIC_UI_TOOLS_HIT_INSET;
    _hideControlsWhenDone = YES;
    _lastActiveTransform = MysticToolsTransformTypeNone;

}
- (void) setToolSize:(CGFloat)size;
{
    BOOL c = buttonHeight != size && buttonHeight != 0;
    buttonHeight = size;
    buttonWidth = buttonHeight;
    
    if(c)
    {
        for (MysticTransformButton *btn in self.subviews) {
            if([btn isKindOfClass:[MysticTransformButton class]])
            {
                [btn removeFromSuperview];
            }
        }
        MysticObjectType s = _currentSetting;
        
        _currentSetting = MysticSettingNone;
        
        self.currentSetting = s;
        
    }
}

- (void) setToolHitInsets:(CGFloat)v;
{
    BOOL c = _toolHitInsets != v;
    _toolHitInsets = v;
//    if(c)
//    {
        for (MysticTransformButton *btn in self.subviews) {
            if([btn isKindOfClass:[MysticTransformButton class]])
            {
                btn.button.hitInsets = UIEdgeInsetsMake(v, v, v, v);

            }
        }
     
        
//    }
}

- (void) setToolHitInsets:(UIEdgeInsets)v forType:(MysticToolsTransformType)type;
{
    MysticTransformButton *btn = (id)[self viewWithTag:MYSTIC_UI_TOOLS_TAG + type];
    
    if(btn && [btn isKindOfClass:[MysticTransformButton class]])
    {
        btn.button.hitInsets = v;

    }
}

- (void) setCurrentSetting:(MysticObjectType)currentSetting;
{
    MysticTransformButton *flv, *rightBtn, *leftBtn, *topBtn, *btmBtn, *rotateBtn, *leftRotateBtn, *plusBtn, *minusBtn, *flipVertBtn, *flipHorizBtn;
    
    _currentSetting = currentSetting;
    switch (_currentSetting) {
        case MysticSettingNone:
        case MysticSettingNoneFromLoadProject:
        case MysticSettingNoneFromBack:
        case MysticSettingNoneFromCancel:
        case MysticSettingNoneFromConfirm:
        {
            
            break;
        }
            
        default:
        {
            plusBtn = [self showPlusButton];
            plusBtn.frame = [MysticUI positionRect:plusBtn.frame inBounds:self.innerFrame position:MysticPositionBottomRight];
            
            minusBtn = [self showMinusButton];
            minusBtn.frame = [MysticUI positionRect:minusBtn.frame inBounds:self.innerFrame position:MysticPositionBottomLeft];

            rotateBtn = [self showRotateButton];
            rotateBtn.frame = [MysticUI positionRect:rotateBtn.frame inBounds:self.innerFrame position:MysticPositionTopRight];

            leftRotateBtn = [self showLeftRotateButton];
            leftRotateBtn.frame = [MysticUI positionRect:leftRotateBtn.frame inBounds:self.innerFrame position:MysticPositionTopLeft];

            topBtn = [self showTopButton];
            topBtn.frame = [MysticUI positionRect:topBtn.frame inBounds:self.innerFrame position:MysticPositionTop];

            btmBtn = [self showBottomButton];
            btmBtn.frame = [MysticUI positionRect:btmBtn.frame inBounds:self.innerFrame position:MysticPositionBottom];


            leftBtn = [self showLeftButton];
            leftBtn.frame = [MysticUI positionRect:leftBtn.frame inBounds:self.innerFrame position:MysticPositionLeft];

            rightBtn = [self showRightButton];
            rightBtn.frame = [MysticUI positionRect:rightBtn.frame inBounds:self.innerFrame position:MysticPositionRight];

//            
//            if(_currentSetting != MysticSettingText)
//            {
//                flipVertBtn = [self showFlipVerticalButton];
//                flipVertBtn.frame = [MysticUI positionRect:flipVertBtn.frame inBounds:self.innerFrame position:MysticPositionLeftBottomAligned];
//                flipHorizBtn = [self showFlipHorizontalButton];
//                flipHorizBtn.frame = [MysticUI positionRect:flipHorizBtn.frame inBounds:self.innerFrame position:MysticPositionRightBottomAligned];
//                
//                leftBtn.frame = [MysticUI positionRect:leftBtn.frame inBounds:self.innerFrame position:MysticPositionLeftTopAligned];
//                rightBtn.frame = [MysticUI positionRect:rightBtn.frame inBounds:self.innerFrame position:MysticPositionRightTopAligned];
//                
//            }
            break;
        }
    }
}


- (PackPotionOption *) currentOption;
{
    PackPotionOption *o = nil;
    if(self.option)
    {
        o = self.option;
    }
    else
    {
        o = [UserPotion optionForType:_currentSetting];
        if(!o)
        {
            o = [[MysticOptions current] transformingOption:_currentSetting];
            if(!o)
            {
                o = [[MysticOptions current] transformingOption];
            }
        }
        
    }
    return o;
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event;
{
    for (UIView *sub in self.subviews) {
        CGRect subFrame = sub.frame;

        UIEdgeInsets hitInsets = [sub isKindOfClass:[MysticTransformButton class]] ? [(MysticTransformButton *)sub button].hitInsets : UIEdgeInsetsMakeFrom(0);
        
        CGRect frame2 = CGRectMake(subFrame.origin.x +hitInsets.left,
                                   subFrame.origin.y +hitInsets.top,
                                   subFrame.size.width + (hitInsets.left*-1) + (hitInsets.right*-1),
                                   subFrame.size.height + (hitInsets.top*-1) + (hitInsets.bottom*-1));

        if(CGRectContainsPoint(frame2, point)) return YES;
        
    }
    
    
    return NO;
}




- (MysticTransformButton *) showFlipVerticalButton;
{
    id b = [self toolOfType:MysticToolsTransformFlipPortrait];
    if(b) return b;
    CGRect iframe = self.innerFrame;
    MysticTransformButton *topBtn = [MysticTransformButton buttonWithType:UIButtonTypeCustom underlyingView:nil];
    topBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    topBtn.button.continueOnHold = NO;

    //    [topBtn setTitle:@"R" forState:UIControlStateNormal];
    topBtn.frame = CGRectMake(CGRectGetWidth(iframe) - buttonWidth + iframe.origin.x, buttonHeight + 10, buttonWidth, buttonHeight);
    
    UIImage *img = [MysticImage image:@(MysticIconTypeToolFlipVertical) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_FLIP_VERT_WIDTH, MYSTIC_UI_TRANSFORM_TOOL_FLIP_VERT_HEIGHT) color:@(MysticColorTypeTransformToolIcon)];
    [topBtn setImage:img forState:UIControlStateNormal];
    [topBtn setImage:img forState:UIControlStateHighlighted];
    UIImage *img2 = [MysticImage image:@(MysticIconTypeToolFlipVerticalBottomColor) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_FLIP_VERT_WIDTH, MYSTIC_UI_TRANSFORM_TOOL_FLIP_VERT_HEIGHT) color:@(MysticColorTypeTransformToolIcon)];
    [topBtn setImage:img2 forState:UIControlStateSelected];


    if(self.currentOption)
    {
        topBtn.button.selected = self.currentOption.flipVertical;
    }
    topBtn.tag = MYSTIC_UI_TOOLS_TAG + MysticToolsTransformFlipPortrait;
    [topBtn addTarget:self action:@selector(didFlipVertical:) forControlEvents:UIControlEventTouchUpInside];
    topBtn.userInteractionEnabled = YES;
    [self addSubview:topBtn];
    return topBtn;
    
}

- (MysticTransformButton *) showFlipHorizontalButton;
{
    id b = [self toolOfType:MysticToolsTransformFlipLandscape];
    if(b) return b;
    MysticTransformButton *topBtn = [MysticTransformButton buttonWithType:UIButtonTypeCustom underlyingView:nil];
    topBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    topBtn.button.continueOnHold = NO;

    //    [topBtn setTitle:@"R" forState:UIControlStateNormal];
    topBtn.frame = CGRectMake(0, buttonHeight + 10, buttonWidth, buttonHeight);
    UIImage *img = [MysticImage image:@(MysticIconTypeToolFlipHorizontal) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_FLIP_HORIZ_WIDTH, MYSTIC_UI_TRANSFORM_TOOL_FLIP_HORIZ_HEIGHT) color:@(MysticColorTypeTransformToolIcon)];
    [topBtn setImage:img forState:UIControlStateNormal];
    [topBtn setImage:img forState:UIControlStateHighlighted];
    UIImage *img2 = [MysticImage image:@(MysticIconTypeToolFlipHorizontalRightColor) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_FLIP_HORIZ_WIDTH, MYSTIC_UI_TRANSFORM_TOOL_FLIP_HORIZ_HEIGHT) color:@(MysticColorTypeTransformToolIcon)];
    [topBtn setImage:img2 forState:UIControlStateSelected];
    [topBtn addTarget:self action:@selector(didFlipHorizontal:) forControlEvents:UIControlEventTouchUpInside];
    topBtn.userInteractionEnabled = YES;
    topBtn.tag = MYSTIC_UI_TOOLS_TAG + MysticToolsTransformFlipLandscape;
    
    if(self.currentOption)
    {
//        self.currentOption.flipHorizontal = !self.currentOption.flipHorizontal;
        topBtn.button.selected = self.currentOption.flipHorizontal;
    }
    [self addSubview:topBtn];
    return topBtn;
    
}

- (MysticTransformButton *) showCropButton
{
//    CGRect frame = self.frame;
//    MysticTransformButton *topBtn = [MysticTransformButton buttonWithType:UIButtonTypeCustom underlyingView:nil];
//    topBtn.underlyingView = self.underlyingView;
//    topBtn.button.continueOnHold = NO;
//
//    //    [topBtn setTitle:@"-" forState:UIControlStateNormal];
//    topBtn.frame = CGRectMake(0, CGRectGetHeight(frame) - buttonHeight, buttonWidth, buttonHeight);
//    [topBtn setImage:[UIImage imageNamed:@"crop.png"] forState:UIControlStateNormal];
//    [topBtn setImage:[UIImage imageNamed:@"crop-black.png"] forState:UIControlStateHighlighted];
//    [topBtn addTarget:self action:@selector(didCrop:) forControlEvents:UIControlEventTouchUpInside];
//    topBtn.userInteractionEnabled = YES;
//    [self addSubview:topBtn];
//    return topBtn;
    return nil;
}

- (MysticTransformButton *) showRotateButton
{
    id b = [self toolOfType:MysticToolsTransformRotateRight];
    if(b) return b;
    CGRect frame = self.frame;
    MysticTransformButton *topBtn = [MysticTransformButton buttonWithType:UIButtonTypeCustom underlyingView:nil];
    topBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
//    topBtn.button.continueOnHold = YES;
    //    [topBtn setTitle:@"R" forState:UIControlStateNormal];
    topBtn.frame = CGRectMake(CGRectGetWidth(frame) - buttonWidth, 0, buttonWidth, buttonHeight);
    UIImage *img = [MysticImage image:@(MysticIconTypeToolRotateRight) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_ROTATE_WIDTH, MYSTIC_UI_TRANSFORM_TOOL_ROTATE_HEIGHT) color:@(MysticColorTypeTransformToolIcon)];
    [topBtn setImage:img forState:UIControlStateNormal];
    [topBtn setImage:img forState:UIControlStateHighlighted];

    [topBtn addTarget:self action:@selector(didTouchRightRotateBtn:) forControlEvents:UIControlEventTouchDown];
//    [topBtn addTarget:self action:@selector(rotateRight) forControlEvents:UIControlEventTouchDownRepeat];
    [topBtn addTarget:self action:@selector(didLetGoRotateBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topBtn addTarget:self action:@selector(didLetGoRotateBtn:) forControlEvents:UIControlEventTouchDragOutside];

    [topBtn addTarget:self action:@selector(holdingEnded:) forControlEvents:UIControlEventEditingDidEnd];

//    [topBtn addTarget:self action:@selector(didLetGoRotateBtn:) forControlEvents:UIControlEventTouchUpOutside];
    topBtn.tag = MYSTIC_UI_TOOLS_TAG + MysticToolsTransformRotateRight;
    topBtn.userInteractionEnabled = YES;
    [self addSubview:topBtn];
    return topBtn;
    
}

- (MysticTransformButton *) showLeftRotateButton
{
    id b = [self toolOfType:MysticToolsTransformRotateLeft];
    if(b) return b;
    MysticTransformButton *topBtn = [MysticTransformButton buttonWithType:UIButtonTypeCustom underlyingView:nil];

    topBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;

    
//    [topBtn setTitle:@"L" forState:UIControlStateNormal];
    topBtn.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
    
    UIImage *img = [MysticImage image:@(MysticIconTypeToolRotateLeft) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_ROTATE_WIDTH, MYSTIC_UI_TRANSFORM_TOOL_ROTATE_HEIGHT) color:@(MysticColorTypeTransformToolIcon)];
    [topBtn setImage:img forState:UIControlStateNormal];
    [topBtn setImage:img forState:UIControlStateHighlighted];

    [topBtn addTarget:self action:@selector(didTouchLeftRotateBtn:) forControlEvents:UIControlEventTouchDown];
    [topBtn addTarget:self action:@selector(didLetGoLeftRotateBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topBtn addTarget:self action:@selector(didLetGoLeftRotateBtn:) forControlEvents:UIControlEventTouchDragOutside];

//    [topBtn addTarget:self action:@selector(rotateLeft) forControlEvents:UIControlEventTouchDownRepeat];
    [topBtn addTarget:self action:@selector(holdingEnded:) forControlEvents:UIControlEventEditingDidEnd];
    topBtn.tag = MYSTIC_UI_TOOLS_TAG + MysticToolsTransformRotateLeft;
    topBtn.userInteractionEnabled = YES;
    [self addSubview:topBtn];
    return topBtn;
    
}
- (MysticTransformButton *) toolOfType:(MysticToolsTransformType)type;
{
    id s  = [self viewWithTag:MYSTIC_UI_TOOLS_TAG + type];
    
    return s && [s isKindOfClass:[MysticTransformButton class]] ? s : nil;
}
- (MysticTransformButton *) showPlusButton
{
    id b = [self toolOfType:MysticToolsTransformPlus];
    if(b) return b;
    
    CGRect frame = self.frame;
    MysticTransformButton *topBtn = [MysticTransformButton buttonWithType:UIButtonTypeCustom underlyingView:nil];
//    [topBtn setTitle:@"+" forState:UIControlStateNormal];
    topBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;

    topBtn.frame = CGRectMake(CGRectGetWidth(frame) - buttonWidth, CGRectGetHeight(frame) - buttonHeight, buttonWidth, buttonHeight);
    UIImage *img = [MysticImage image:@(MysticIconTypeToolPlus) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_PLUS_WIDTH, MYSTIC_UI_TRANSFORM_TOOL_PLUS_HEIGHT) color:@(MysticColorTypeTransformToolIcon)];
    [topBtn setImage:img forState:UIControlStateNormal];
    [topBtn setImage:img forState:UIControlStateHighlighted];

    [topBtn addTarget:self action:@selector(didTouchPlusBtn:) forControlEvents:UIControlEventTouchDown];
    [topBtn addTarget:self action:@selector(didLetGoPlusBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topBtn addTarget:self action:@selector(didLetGoPlusBtn:) forControlEvents:UIControlEventTouchDragOutside];

//    [topBtn addTarget:self action:@selector(plus) forControlEvents:UIControlEventTouchDownRepeat];
    [topBtn addTarget:self action:@selector(holdingEnded:) forControlEvents:UIControlEventEditingDidEnd];
    topBtn.tag = MYSTIC_UI_TOOLS_TAG + MysticToolsTransformPlus;
    topBtn.userInteractionEnabled = YES;
    [self addSubview:topBtn];
    return topBtn;

}


- (MysticTransformButton *) showMinusButton
{
    id b = [self toolOfType:MysticToolsTransformMinus];
    if(b) return b;
    
    CGRect frame = self.frame;
    MysticTransformButton *topBtn = [MysticTransformButton buttonWithType:UIButtonTypeCustom underlyingView:nil];
//    [topBtn setTitle:@"-" forState:UIControlStateNormal];
    topBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;

    topBtn.frame = CGRectMake(0, CGRectGetHeight(frame) - buttonHeight, buttonWidth, buttonHeight);
    UIImage *img = [MysticImage image:@(MysticIconTypeToolMinus) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_MINUS_WIDTH, MYSTIC_UI_TRANSFORM_TOOL_MINUS_HEIGHT) color:@(MysticColorTypeTransformToolIcon)];
    [topBtn setImage:img forState:UIControlStateNormal];
    [topBtn setImage:img forState:UIControlStateHighlighted];

    [topBtn addTarget:self action:@selector(didTouchMinusBtn:) forControlEvents:UIControlEventTouchDown];
    [topBtn addTarget:self action:@selector(didLetGoMinusBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topBtn addTarget:self action:@selector(didLetGoMinusBtn:) forControlEvents:UIControlEventTouchDragOutside];

//    [topBtn addTarget:self action:@selector(minus) forControlEvents:UIControlEventTouchDownRepeat];
    [topBtn addTarget:self action:@selector(holdingEnded:) forControlEvents:UIControlEventEditingDidEnd];
    topBtn.tag = MYSTIC_UI_TOOLS_TAG + MysticToolsTransformMinus;

    topBtn.userInteractionEnabled = YES;
    [self addSubview:topBtn];
    return topBtn;

}





- (MysticTransformButton *) showTopButton
{
    id b = [self toolOfType:MysticToolsTransformUp];
    if(b) return b;
    CGRect frame = self.frame;
    MysticTransformButton *topBtn = [MysticTransformButton buttonWithType:UIButtonTypeCustom underlyingView:nil];
    topBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;

    topBtn.frame = CGRectMake(CGRectGetWidth(frame)/2 - buttonWidth/2, 0, buttonWidth, buttonHeight);
    UIImage *img = [MysticImage image:@(MysticIconTypeToolUp) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_ICON_WIDTH_LANDSCAPE, MYSTIC_UI_TRANSFORM_TOOL_ICON_HEIGHT_LANDSCAPE) color:@(MysticColorTypeTransformToolIcon)];
    [topBtn setImage:img forState:UIControlStateNormal];
    [topBtn setImage:img forState:UIControlStateHighlighted];

    [topBtn addTarget:self action:@selector(didTouchUpBtn:) forControlEvents:UIControlEventTouchDown];
    [topBtn addTarget:self action:@selector(didLetGoUpBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topBtn addTarget:self action:@selector(didLetGoUpBtn:) forControlEvents:UIControlEventTouchDragOutside];

//    [topBtn addTarget:self action:@selector(up) forControlEvents:UIControlEventTouchDownRepeat];
    [topBtn addTarget:self action:@selector(holdingEnded:) forControlEvents:UIControlEventEditingDidEnd];
    topBtn.tag = MYSTIC_UI_TOOLS_TAG + MysticToolsTransformUp;

    topBtn.userInteractionEnabled = YES;
    [self addSubview:topBtn];
    return topBtn;
}

- (MysticTransformButton *) showBottomButton
{
    id b = [self toolOfType:MysticToolsTransformDown];
    if(b) return b;
    CGRect frame = self.frame;
    MysticTransformButton *btmBtn = [MysticTransformButton buttonWithType:UIButtonTypeCustom underlyingView:nil];
    btmBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;

    btmBtn.frame = CGRectMake(CGRectGetWidth(frame)/2 - buttonWidth/2, CGRectGetHeight(frame)-buttonHeight, buttonWidth, buttonHeight);
    UIImage *img = [MysticImage image:@(MysticIconTypeToolDown) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_ICON_WIDTH_LANDSCAPE, MYSTIC_UI_TRANSFORM_TOOL_ICON_HEIGHT_LANDSCAPE) color:@(MysticColorTypeTransformToolIcon)];
    [btmBtn setImage:img forState:UIControlStateNormal];
    [btmBtn setImage:img forState:UIControlStateHighlighted];

    [btmBtn addTarget:self action:@selector(didTouchDownBtn:) forControlEvents:UIControlEventTouchDown];
    [btmBtn addTarget:self action:@selector(didLetGoDownBtn:) forControlEvents:UIControlEventTouchDragOutside];

    [btmBtn addTarget:self action:@selector(didLetGoDownBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [btmBtn addTarget:self action:@selector(down) forControlEvents:UIControlEventTouchDownRepeat];
    [btmBtn addTarget:self action:@selector(holdingEnded:) forControlEvents:UIControlEventEditingDidEnd];
    btmBtn.tag = MYSTIC_UI_TOOLS_TAG + MysticToolsTransformDown;
    btmBtn.userInteractionEnabled = YES;
    [self addSubview:btmBtn];
    return btmBtn;
}

- (MysticTransformButton *) showLeftButton
{
    id b = [self toolOfType:MysticToolsTransformLeft];
    if(b) return b;
    CGRect frame = self.frame;
    MysticTransformButton *leftBtn = [MysticTransformButton buttonWithType:UIButtonTypeCustom underlyingView:nil];
    leftBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;

    leftBtn.frame = CGRectMake(0, CGRectGetHeight(frame)/2 - buttonHeight/2, buttonWidth, buttonHeight);
    UIImage *img = [MysticImage image:@(MysticIconTypeToolLeft) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_ICON_WIDTH, MYSTIC_UI_TRANSFORM_TOOL_ICON_HEIGHT) color:@(MysticColorTypeTransformToolIcon)];
    [leftBtn setImage:img forState:UIControlStateNormal];
    [leftBtn setImage:img forState:UIControlStateHighlighted];

    [leftBtn addTarget:self action:@selector(didTouchLeftBtn:) forControlEvents:UIControlEventTouchDown];
    [leftBtn addTarget:self action:@selector(didLetGoLeftBtn:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn addTarget:self action:@selector(didLetGoLeftBtn:) forControlEvents:UIControlEventTouchDragOutside];

    [leftBtn addTarget:self action:@selector(holdingEnded:) forControlEvents:UIControlEventEditingDidEnd];
    leftBtn.userInteractionEnabled = YES;
    leftBtn.tag = MYSTIC_UI_TOOLS_TAG + MysticToolsTransformLeft;
    [self addSubview:leftBtn];
    return leftBtn;
}

- (MysticTransformButton *) showRightButton
{
    id b = [self toolOfType:MysticToolsTransformRight];
    if(b) return b;
    CGRect frame = self.frame;
    MysticTransformButton *rightBtn = [MysticTransformButton buttonWithType:UIButtonTypeCustom underlyingView:nil];
    rightBtn.frame = CGRectMake(CGRectGetWidth(frame) - buttonWidth, CGRectGetHeight(frame)/2-buttonHeight/2, buttonWidth, buttonHeight);
    rightBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    UIImage *img = [MysticImage image:@(MysticIconTypeToolRight) size:CGSizeMake(MYSTIC_UI_TRANSFORM_TOOL_ICON_WIDTH, MYSTIC_UI_TRANSFORM_TOOL_ICON_HEIGHT) color:@(MysticColorTypeTransformToolIcon)];
    [rightBtn setImage:img forState:UIControlStateNormal];
    [rightBtn setImage:img forState:UIControlStateHighlighted];

    [rightBtn addTarget:self action:@selector(didTouchRightBtn:) forControlEvents:UIControlEventTouchDown];
    [rightBtn addTarget:self action:@selector(didLetGoRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn addTarget:self action:@selector(didLetGoRightBtn:) forControlEvents:UIControlEventTouchDragOutside];

//    [rightBtn addTarget:self action:@selector(right) forControlEvents:UIControlEventTouchDownRepeat];
    [rightBtn addTarget:self action:@selector(holdingEnded:) forControlEvents:UIControlEventEditingDidEnd];

    rightBtn.userInteractionEnabled = YES;
    rightBtn.tag = MYSTIC_UI_TOOLS_TAG + MysticToolsTransformRight;
    [self addSubview:rightBtn];
    return rightBtn;
}


- (void) setControlsHidden:(BOOL)hidden except:(MysticButton *)sender;
{
    
    NSMutableArray *subs = [NSMutableArray arrayWithArray:self.subviews];
    if(sender && sender.superview)
    {
        [subs removeObject:sender.superview];
    }
        
    for (UIView *sub in subs)
    {
        
        
        if([sub isKindOfClass:[MysticTransformButton class]] && sub.hidden != hidden)
        {
            sub.hidden = hidden;
        }
    }
}

- (void) didLetGoUpBtn:(MysticTransformButton *)sender
{
    [self setControlsHidden:NO except:nil];
    _lastActiveTransform = MysticToolsTransformUp;
    self.holdingControl = YES;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformUp, self, YES);
        return;
    }
    [self up:sender];
}

- (void) up:(MysticTransformButton *)sender;
{
    _lastActiveTransform = MysticToolsTransformUp;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformUp, self, NO);
        return;
    }
//    DLog(@"moving up");
    CGRect newRect= CGRectZero;
    CGFloat ax = 0.0f;
    CGFloat ay = -1.0f*kMoveStepIncrement;
    PackPotionOption *option = self.currentOption;
    newRect = option.transformRect;

    
    newRect.origin.x+=ax;
    newRect.origin.y+=ay;
    option.transformRect = newRect;
    
    
    [self reloadImage];
}

- (void) didLetGoDownBtn:(MysticTransformButton *)sender
{
    _lastActiveTransform = MysticToolsTransformDown;

    [self setControlsHidden:NO except:nil];

    self.holdingControl = YES;
    
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformDown, self, YES);
        return;
    }
    
    [self down:sender];
}
- (void) down:(MysticTransformButton *)sender;
{
    _lastActiveTransform = MysticToolsTransformDown;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformDown, self, NO);
        return;
    }
    CGRect newRect= CGRectZero;
    CGFloat ax = 0.0f;
    CGFloat ay = kMoveStepIncrement;
    PackPotionOption *option = self.currentOption;
    newRect = option.transformRect;
    
    newRect.origin.x+=ax;
    newRect.origin.y+=ay;
    option.transformRect = newRect;

    [self reloadImage];
}

- (void) didLetGoRightBtn:(MysticTransformButton *)sender
{
    _lastActiveTransform = MysticToolsTransformRight;
    [self setControlsHidden:NO except:nil];

    self.holdingControl = YES;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformRight, self, YES);
        return;
    }
    [self right:sender];
}
- (void) right:(MysticTransformButton *)sender;
{
    _lastActiveTransform = MysticToolsTransformRight;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformRight, self, NO);
        return;
    }
//    DLog(@"moving right");
    CGRect newRect= CGRectZero;
    CGFloat ax = kMoveStepIncrement;
    CGFloat ay = 0.0f;
    PackPotionOption *option = self.currentOption;
    newRect = option.transformRect;
    newRect.origin.x+=ax;
    newRect.origin.y+=ay;
    option.transformRect = newRect;

    [self reloadImage];
}

- (void) didTouchLeftBtn:(MysticTransformButton *)sender
{
    [self setControlsHidden:YES except:(id)sender];
    self.holdingControl = YES;
    [self left:sender];
}




- (void) didLetGoRotateBtn:(MysticTransformButton *)sender
{
    _lastActiveTransform = MysticToolsTransformRotateClockwise;
    [self setControlsHidden:NO except:nil];

    self.holdingControl = YES;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformRotateClockwise, self, YES);
        return;
    }
    [self rotateClockwise:sender];
}
- (void) rotateClockwise:(MysticTransformButton *)sender;
{
    _lastActiveTransform = MysticToolsTransformRotateClockwise;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformRotateClockwise, self, NO);
        return;
    }
    //     DLog(@"rotating left");
    CGFloat rotationRadians= 0.0f;
    CGFloat cr = -1*kRotateStepIncrement;
    CGFloat cr2 = kRotateStepIncrement;
    
    PackPotionOption *option = self.currentOption;
    rotationRadians = option.rotation;
    switch (option.type) {
        case MysticObjectTypeText:
        case MysticObjectTypeBadge:
            cr = kRotateSmallStepIncrement;
            rotationRadians+=cr;
            break;
            
        default:
        {
            _rotatePosition = option.rotatePosition;

            if(_rotatePosition == MysticPositionUnknown)
            {
                if((rotationRadians <= 0 && rotationRadians > cr) || (rotationRadians >= 0 && rotationRadians < cr2))
                {
                    _rotatePosition = MysticPositionTop;
                    
                }
                else if((rotationRadians <= cr && rotationRadians > cr*2) || (rotationRadians >= cr2*2 && rotationRadians < cr2*3))
                {
                    _rotatePosition = MysticPositionLeft;
                    
                }
                else if((rotationRadians <= cr*2 && rotationRadians > cr*3) || (rotationRadians >= cr2 && rotationRadians < cr2*2))
                {
                    _rotatePosition = MysticPositionBottom;
                    
                }
                else
                {
                    _rotatePosition = MysticPositionRight;
                }
            }
            switch (_rotatePosition)
            {
                case MysticPositionTop:
                    DLog(@"current position top");
                    _rotatePosition = MysticPositionRight;
                    rotationRadians = cr2;
                    break;
                case MysticPositionRight:
                    DLog(@"current position right");

                    _rotatePosition = MysticPositionBottom;
                    rotationRadians = cr2 * 2;
                    break;
                case MysticPositionBottom:
                    DLog(@"current position bottom");

                    _rotatePosition = MysticPositionLeft;
                    rotationRadians = cr2 * 3;
                    break;
                case MysticPositionLeft:
                    
                    DLog(@"current position left");

                    _rotatePosition = MysticPositionTop;
                    rotationRadians = 0;
                    break;
                    
                default:
                {
                    
                    break;
                }
            }
            
            option.rotatePosition = _rotatePosition;
            break;
        }
            
    }
    
    
    option.rotation = rotationRadians;
    [self reloadImage];
}
- (void) rotateRight:(MysticTransformButton *)sender;
{
    _lastActiveTransform = MysticToolsTransformRotateRight;
    _rotatePosition = MysticPositionUnknown;

    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformRotateRight, self, NO);
        return;
    }
    CGFloat rotationRadians= 0.0f;
    CGFloat cr = kRotateSmallStepIncrement;
    PackPotionOption *option = self.currentOption;
    rotationRadians = option.rotation;
    
    rotationRadians+=cr;
    option.rotation = rotationRadians;
    [self reloadImage];
}

- (void) didLetGoLeftRotateBtn:(MysticTransformButton *)sender
{
    _lastActiveTransform = MysticToolsTransformRotateCounterClockwise;
    self.holdingControl = YES;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformRotateCounterClockwise, self, YES);
        return;
    }
    [self rotateCounterClockwise:sender];

}
- (void) rotateCounterClockwise:(MysticTransformButton *)sender;
{
    _lastActiveTransform = MysticToolsTransformRotateCounterClockwise;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformRotateCounterClockwise, self, NO);
        return;
    }
    //     DLog(@"rotating left");
    CGFloat rotationRadians= 0.0f;
    CGFloat cr = -1*kRotateStepIncrement;
    CGFloat cr2 = kRotateStepIncrement;

    PackPotionOption *option = self.currentOption;
    rotationRadians = option.rotation;
    switch (option.type) {
        case MysticObjectTypeText:
        case MysticObjectTypeBadge:
            cr = -1*kRotateSmallStepIncrement;
            rotationRadians+=cr;
            break;
            
        default:
        {
            _rotatePosition = option.rotatePosition;

            if(_rotatePosition == MysticPositionUnknown)
            {
                if((rotationRadians <= 0 && rotationRadians > cr) || (rotationRadians >= cr2 *3 && rotationRadians < cr2*4))
                {
                    _rotatePosition = MysticPositionTop;

                }
                else if(rotationRadians >= 0 && rotationRadians < cr2)
                {
                    _rotatePosition = MysticPositionRight;
                }
                else if((rotationRadians <= cr && rotationRadians > cr*2) || (rotationRadians >= cr2*2 && rotationRadians < cr2*3))
                {
                    _rotatePosition = MysticPositionLeft;

                }
                else
                {
                    _rotatePosition = MysticPositionBottom;
                }
            }
            switch (_rotatePosition)
            {
                case MysticPositionTop:
                    _rotatePosition = MysticPositionLeft;
                    rotationRadians = cr;
                    break;
                case MysticPositionLeft:
                    _rotatePosition = MysticPositionBottom;
                    rotationRadians = cr * 2;
                    break;
                case MysticPositionBottom:
                    _rotatePosition = MysticPositionRight;
                    rotationRadians = cr * 3;
                    break;
                case MysticPositionRight:
                    _rotatePosition = MysticPositionTop;
                    rotationRadians = 0;
                    break;
                    
                default:
                {
                    
                    break;
                }
            }
            
            option.rotatePosition = _rotatePosition;
            
            break;
        }
            
    }
    
    
    option.rotation = rotationRadians;
    [self reloadImage];
}
- (void) rotateLeft:(MysticTransformButton *)sender;
{
    _lastActiveTransform = MysticToolsTransformRotateLeft;
    _rotatePosition = MysticPositionUnknown;

    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformRotateLeft, self, NO);
        return;
    }
//     DLog(@"rotating left");
    CGFloat rotationRadians= 0.0f;
    CGFloat cr = -1*kRotateSmallStepIncrement;
    PackPotionOption *option = self.currentOption;
    rotationRadians = option.rotation;
    
    rotationRadians+=cr;
    option.rotation = rotationRadians;
    [self reloadImage];
}




- (void) didFlipVertical:(MysticTransformButton *)sender
{
    _lastActiveTransform = MysticToolsTransformFlipPortrait;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformFlipPortrait, self, YES);
        return;
    }
    
    PackPotionOption *option = self.currentOption;
    

    
    
    if(option)
    {
        [(MysticTransformButton *)sender.superview setSelected:![(id)sender.superview selected]];

        option.flipVertical = !option.flipVertical;
    }

    [self reloadImageWithCompletion:nil];
}

- (void) didFlipHorizontal:(MysticTransformButton *)sender
{
    _lastActiveTransform = MysticToolsTransformFlipLandscape;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformFlipLandscape, self, YES);
        return;
    }
    PackPotionOption *option = self.currentOption;
    if(option)
    {
        [(MysticTransformButton *)sender.superview setSelected:![(id)sender.superview selected]];

        option.flipHorizontal = !option.flipHorizontal;

    }
    
    


    [self reloadImageWithCompletion:nil];

}

- (void) didCrop:(MysticTransformButton *)sender
{
    
    
}



- (void) didLetGoPlusBtn:(MysticTransformButton *)sender
{
    _lastActiveTransform = MysticToolsTransformPlus;
    [self setControlsHidden:NO except:nil];
    self.holdingControl = YES;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformPlus, self, YES);
        return;
    }
    [self plus:sender];
    
}
- (void) plus:(MysticTransformButton *)sender;
{
    _lastActiveTransform = MysticToolsTransformPlus;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformPlus, self, NO);
        return;
    }
    CGRect newRect= CGRectZero;
    CGFloat ax = kSizeStepIncrement;
    CGFloat ay = kSizeStepIncrement;
    PackPotionOption *option = self.currentOption;
    newRect = option.transformRect;
    ax = option.adjustedRect.size.width != 0 ? ax * option.adjustedRect.size.width : ax;
    ay = option.adjustedRect.size.height != 0 ? ay * option.adjustedRect.size.height : ay;
    newRect.size.width+=ax;
    newRect.size.height+=ay;
    option.transformRect = newRect;
    [self reloadImage];
}

- (void) didLetGoMinusBtn:(MysticTransformButton *)sender
{
    _lastActiveTransform = MysticToolsTransformMinus;
    [self setControlsHidden:NO except:nil];

    self.holdingControl = YES;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformMinus, self, YES);
        return;
    }
    [self minus:sender];

}
- (void) minus:(MysticTransformButton *)sender;
{
    _lastActiveTransform = MysticToolsTransformMinus;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformMinus, self, NO);
        return;
    }
    CGRect newRect= CGRectZero;
    CGFloat ax = -1*kSizeStepIncrement;
    CGFloat ay = -1*kSizeStepIncrement;
    PackPotionOption *option = self.currentOption;
    newRect = option.transformRect;
    

    ax = option.adjustedRect.size.width != 0 ? ax * option.adjustedRect.size.width : ax;
    ay = option.adjustedRect.size.height != 0 ? ay * option.adjustedRect.size.height : ay;
    

    newRect.size.width+=ax;
    newRect.size.height+=ay;
    
    option.transformRect = newRect;
    
    [self reloadImage];
}


- (void) didTouchUpBtn:(MysticTransformButton *)sender
{
//    self.holdingAction = @selector(up);
    [self setControlsHidden:YES except:(id)sender];

    self.holdingControl = YES;
    [self up:sender];
}

- (void) didTouchDownBtn:(MysticTransformButton *)sender
{
//    self.holdingAction = @selector(down);
    [self setControlsHidden:YES except:(id)sender];

    self.holdingControl = YES;
    [self down:sender];
}

- (void) didTouchRightBtn:(MysticTransformButton *)sender
{
//    self.holdingAction = @selector(right);
    [self setControlsHidden:YES except:(id)sender];
    self.holdingControl = YES;
    [self right:sender];
}


- (void) didLetGoLeftBtn:(MysticTransformButton *)sender
{
    _lastActiveTransform = MysticToolsTransformLeft;
    [self setControlsHidden:NO except:nil];
    self.holdingControl = YES;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformLeft, self, YES);
        return;
    }
    [self left:sender];
    
}
- (void) left:(MysticTransformButton *)sender;
{
    _lastActiveTransform = MysticToolsTransformLeft;
    if(self.onTransform)
    {
        self.onTransform(sender, MysticToolsTransformLeft, self, NO);
        return;
    }
    //    DLog(@"moving left");
    CGRect newRect= CGRectZero;
    CGFloat ax = -1.0f*kMoveStepIncrement;
    CGFloat ay = 0.0f;
    PackPotionOption *option = self.currentOption;
    newRect = option.transformRect;
    newRect.origin.x+=ax;
    newRect.origin.y+=ay;
    option.transformRect = newRect;
    
    [self reloadImage];
}
- (void) didTouchPlusBtn:(MysticTransformButton *)sender;
{
//    self.holdingAction = @selector(plus);
    [self setControlsHidden:YES except:(id)sender];
    
    self.holdingControl = YES;
    [self plus:sender];
}

- (void) didTouchMinusBtn:(MysticTransformButton *)sender
{
//    self.holdingAction = @selector(minus);
    [self setControlsHidden:YES except:(id)sender];

    self.holdingControl = YES;
    [self minus:sender];
}

- (void) didTouchLeftRotateBtn:(MysticTransformButton *)sender;
{
//    self.holdingAction = @selector(rotateLeft);
    [self setControlsHidden:YES except:(id)sender];

    self.holdingControl = YES;
    [self rotateLeft:sender];
}

- (void) didTouchRightRotateBtn:(MysticTransformButton *)sender;
{
//    self.holdingAction = @selector(rotateRight);
    [self setControlsHidden:YES except:(id)sender];

    self.holdingControl = YES;
    [self rotateRight:sender];
}


- (void) holdingEnded:(MysticTransformButton *)sender;
{
    [self setControlsHidden:NO except:nil];
    self.holdingControl = NO;
    if(self.onTransform)
    {
        self.onTransform(sender, sender.tag - MYSTIC_UI_TOOLS_TAG, self, YES);
        return;
    }
}
- (void) setHoldingControl:(BOOL)value
{
    [self stopTimer];
    _holdingControl = value;

    if(!_holdingControl && self.hideControlsWhenDone)
    {
        [self fadeOutInSeconds:kFadeOutTimerDuration];
        NSString *theName = MYSTIC_TRANSFORM_COMPLETE_NOTIFICATION;
        [[NSNotificationCenter defaultCenter] postNotificationName:theName object:nil];
    }
}


- (void) reloadImage
{
    if(!self.holdingControl) return;
    [self reloadImageWithCompletion:nil];
}
- (void) reloadImageWithCompletion:(MysticBlock)finished;
{
    __unsafe_unretained __block PackPotionOption *_transformOption = self.option ? self.option : [[MysticOptions current] option:self.currentSetting];
    _transformOption.refreshState = MysticSettingTransform;
    _transformOption.hasChanged = YES;
    if(_transformOption.transformFilter) _transformOption.transformFilter.affineTransform = _transformOption.transform;

    [[MysticOptions current].filters refresh:_transformOption completion:finished];
}
    
- (void) reloadImageWithTimer;
{
    if(reloadTimer) {
        [reloadTimer invalidate]; [reloadTimer release]; reloadTimer = nil;
    }
    reloadTimer = [[NSTimer scheduledTimerWithTimeInterval:MYSTIC_TOOLS_RELOAD_INTERVAL target:self selector:@selector(reloadImage:) userInfo:nil repeats:NO] retain];
}

- (void) reloadImage:(NSTimer *)timer
{
//    [self.viewController reloadImage:YES];
    [[MysticOptions current].filters refresh:nil];
    if(reloadTimer) {
        [reloadTimer invalidate]; [reloadTimer release]; reloadTimer = nil;
    }
}

- (void) startTimer;
{
    [self fadeOutInSeconds:kFadeOutTimerDuration];
    
}

- (void) stopTimer;
{
    if(timer)
    {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}

- (void) fadeOutInSeconds:(NSTimeInterval)wait;
{
    if(timer) {  [timer invalidate]; [timer release]; timer = nil; }
    timer = [[NSTimer scheduledTimerWithTimeInterval:wait target:self selector:@selector(fadeOut) userInfo:nil repeats:NO] retain];
}
- (void) fadeOutWithTimer;
{
    [self fadeOut];
    [self startTimer];
}

- (void) fadeInWithTimer;
{
    [self fadeInWithTimer:kFadeOutTimerDuration];
    
}
- (void) fadeInWithTimer:(NSTimeInterval)fadeOutDelay;
{
    [self stopTimer];
    [self fadeInFast];
    [NSTimer wait:kPauseBeforeTimerInterval block:^{
        [self fadeOutInSeconds:fadeOutDelay];
    }];
    
}
- (void) fadeOut;
{
    [self fadeOut:nil];
}
- (void) fadeOut:(MysticBlockBOOL)finishedAnim;
{
    if(self.holdingControl) return;
    [self stopTimer];
    __unsafe_unretained __block MysticTools *weakSelf = self;
    [MysticUIView animateWithDuration:kFadeOutDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{

        weakSelf.alpha = 0;
    } completion:finishedAnim];
}


- (void) fadeIn;
{
    [self fadeIn:nil];
}
- (void) fadeIn:(MysticBlockBOOL)finishedAnim;
{
    [self stopTimer];
    [self setControlsHidden:NO except:nil];
    __unsafe_unretained __block MysticTools *weakSelf = self;

    [MysticUIView animateWithDuration:kFadeInDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{

        weakSelf.alpha = 1.0;
    } completion:finishedAnim];
}

- (void) fadeOutRealFast;
{
    [self fadeOutRealFast:nil];
}
- (void) fadeOutRealFast:(MysticBlockBOOL)finishedAnim;
{
    [self stopTimer];
    __unsafe_unretained __block MysticTools *weakSelf = self;

    [MysticUIView animateWithDuration:kFadeOutRealFastDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        weakSelf.alpha = 0.0;
    } completion:finishedAnim];
}
- (void) fadeOutFast;
{
    [self fadeOutFastAfterDelay:0 completion:nil];
}
- (void) fadeOutFast:(MysticBlockBOOL)finishedAnim;
{
    [self fadeOutFastAfterDelay:0 completion:finishedAnim];

}
- (void) fadeOutFastAfterDelay:(NSTimeInterval)delay;
{
    [self fadeOutFastAfterDelay:delay completion:nil];

}
- (void) fadeOutFastAfterDelay:(NSTimeInterval)delay completion:(MysticBlockBOOL)finishedAnim;
{
    [self stopTimer];
    __unsafe_unretained __block MysticTools *weakSelf = self;

    [MysticUIView animateWithDuration:kFadeOutFastDuration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{

        weakSelf.alpha = 0.0;
    } completion:finishedAnim];
}

- (void) fadeInFast;
{
    [self fadeInFastAfterDelay:0 completion:nil];
}
- (void) fadeInFastAfterDelay:(NSTimeInterval)delay;
{
    [self fadeInFastAfterDelay:delay completion:nil];
}
- (void) fadeInFast:(MysticBlockBOOL)finishedAnim;
{
    [self fadeInFastAfterDelay:0 completion:finishedAnim];

}
- (void) fadeInFastAfterDelay:(NSTimeInterval)delay completion:(MysticBlockBOOL)finishedAnim;
{
    [self stopTimer];
    [self setControlsHidden:NO except:nil];
    __unsafe_unretained __block MysticTools *weakSelf = self;

    [MysticUIView animateWithDuration:kFadeInFastDuration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{

        weakSelf.alpha = 1.0f;
    } completion:finishedAnim];
}



- (void) setAlphaSubs:(CGFloat)alpha
{
    
        for (MysticTransformButton *subButton in self.subviews) {

            if([subButton isKindOfClass:[MysticTransformButton class]])
            {
                subButton.alpha = alpha;
            }
        }
}

- (void) gestureRecognized:(UIGestureRecognizer *)gesture;
{
    
    if(gesture && [gesture isKindOfClass:[UIPanGestureRecognizer class]])
    {
        if(!self.holdingControl)
        {
            [self.viewController panned:(id)gesture];
        }
    }
    if(gesture && [gesture isKindOfClass:[UIPinchGestureRecognizer class]])
    {
        if(!self.holdingControl)
        {
            [self.viewController pinched:(id)gesture];
        }
    }
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2) {
        //This will cancel the singleTap action
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{

    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1)
    {
        if (CGRectContainsPoint(self.frame,[touch locationInView:self]))
        {
            [self performSelector:@selector(tapped) withObject:nil afterDelay:0.2];
            
        }
    } else if (touch.tapCount == 2) {
        
        
        [self doubleTapped];
        
    }
    
    
}

- (void) tapped;
{
    if(self.viewController.isMenuVisible) return;
        
    if(self.alpha == 1.0 && !self.holdingControl)
    {
        [self fadeOutFast];
    }
}

- (void) doubleTapped;
{
    if(self.viewController.isMenuVisible) return;

    if(self.alpha == 1.0 && !self.holdingControl)
    {
        [self.viewController doubleTapped:nil];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
