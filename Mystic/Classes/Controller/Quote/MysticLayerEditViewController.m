//
//  MysticLayerEditViewController.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/19/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//
#import "AppDelegate.h"
#import "MysticLayerEditViewController.h"
#import "Mystic.h"
#import "MysticBorderView.h"
#import "NSArray+Mystic.h"
#import "MysticDictionaryDownloader.h"
#import "MysticFontStyleView.h"
#import "MysticLayersScrollView.h"
#import "MysticFontTools.h"
#import "ILColorPickerView.h"
#import "MysticSlider.h"
#import "MysticLayerTypeView.h"
#import "SubBarButton.h"
#import "UIColor+Mystic.h"
#import "MysticLayerTypeView.h"
#import "MysticController.h"
#import "NSString+Mystic.h"
#import "MysticHiddenTextField.h"
#import "MysticDictionaryDataSource.h"
#import "MysticCategoryButton.h"
#import "MysticChoiceButton.h"
#import "UIImage+Border.h"
#import "MysticShapesKit.h"
#import "UIColor+Mystic.h"

@interface MysticLayerEditViewController () <UITextFieldDelegate, MysticLayerToolbarDelegate, ILPickerDelegate, EffectControlDelegate, UIScrollViewDelegate>
{
    CGRect _finalTransViewFrame;
}
@property (retain, nonatomic) UITextField* lastResponder, *lastInputResponder;
@property (retain, nonatomic) MysticPacksScrollView *packsScrollView;
@property (retain, nonatomic) MysticChoicesScrollView *choicesScrollView;
@property (retain, nonatomic) MysticInputScrollView *scrollView;
@property (nonatomic, assign) CGRectMinMaxWithin transFrame;
@property (nonatomic, assign) BOOL switchingKeyboard, setupScrollview;
@property (nonatomic, retain) ILColorPickerView *colorPicker;
@property (retain, nonatomic) UILabel *transitionLabel;
@property (retain, nonatomic) MysticDrawView *transImageDrawView;
@property (assign, nonatomic) CGScale transitionScale;
@property (nonatomic, assign) MysticObjectType previousSetting, previousSubSetting;
@property (nonatomic, assign) CGPoint nipplePoint;
@property (nonatomic, retain) NSMutableDictionary *userInfo;
@property (nonatomic, retain) UIView *clipView;
@end

@implementation MysticLayerEditViewController

@synthesize content=_content, stopAutoScroll=_stopAutoScroll, originalClipViewFrame=_originalClipViewFrame;

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
    [_clipView release];
    [_transImageDrawView release];
    [_transView release];
    [_packsScrollView release];
    [_choicesScrollView release];
    [_colorPicker release];
    [_color release];
    [_inputView release];
    [_toolbar release];
    [_option release];
    [_colorChip release];
    [_scrollView release];
    [_touchView release];
    [_toolbarNippleView release];
    [_shadowColor release];
    [_backgroundColor release];
    [_subToolbar release];
    [_layerView release];
    if(releaseHiddenText && _hiddenTextField) { [_hiddenTextField autorelease]; }
    [_presentView release];
    [_content release];
    [_transitionLabel release];
    [_nippleView release];
    [_lastResponder release];
    [_lastInputResponder release];
    [_pack release];
    [_userInfo release];
    _opacitySlider = nil;
    if(_animationIn) Block_release(_animationIn);
    if(_animationOut) Block_release(_animationOut);

}
- (id) init;
{
    self = [super init];
    if(self) [self commonInit];
    return self;
}
- (id) initWithContent:(id)content;
{
    self = [self init];
    if(self)
    {
        _inputFrameInsets = UIEdgeInsetsZero;
        settingUpInput = NO;
        _updateContent = YES;
        _setting = MysticObjectTypeUnknown;
        _shadowOffset = CGSizeUnknown;
        _shadowRadius = NAN;
        _shadowAlpha = NAN;
        _shadowColor = nil;
        _originalClipViewFrame = CGRectZero;
        _backgroundColor = nil;
        self.keyboardRect = (CGRect){0,0,[MysticUI screen].width, 266};
        self.colorInputOptions =MysticColorInputOptionLibrary|MysticColorInputOptionRecent|MysticColorInputOptionAlpha;
        self.colorAlpha = 1;
        self.position = MysticPositionCenter;
        self.content = content;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}
- (CGRect) originalClipViewFrame;
{
    return CGRectIsUnknownOrZero(_originalClipViewFrame) ? self.previewFrame : _originalClipViewFrame;
}
- (void) commonInit;
{
    _shouldResizeContent = NO;
    _setupScrollview = NO;
    self.userInfo = [NSMutableDictionary dictionary];
    releaseHiddenText = YES;
    _previousSubSetting = MysticSettingUnknown;
    _previousSetting = MysticSettingUnknown;
    _userTappedBg = NO;
    _setupPresentView = NO;
    _stopAutoScroll = NO;
    self.colorAlpha=1;
}
- (void) unloadViews;
{
    
    if(self.transView) [self.transView removeFromSuperview];
    if(self.presentView) [self.presentView removeFromSuperview];
    self.transView = nil;
    self.presentView = nil;
    self.hiddenTextField = nil;
    
}
- (void) setSetting:(MysticObjectType)setting;
{
    _previousSetting = _setting;
    _setting = setting;
}
- (void) setSubSetting:(MysticObjectType)subSetting;
{
    if(_subSetting != MysticSettingUnknown)
    {
        _previousSubSetting = _subSetting;
        [self.userInfo setObject:@(_previousSubSetting) forKey:@(_setting)];
    }
    _subSetting = subSetting;
}
#pragma mark - View Controller

- (void) updateToolbarNipple:(id)sender updateOffset:(BOOL)updateOffset;
{
    [self.scrollView bringSubviewToFront:self.toolbarNippleView];
    __unsafe_unretained __block MysticLayerEditViewController *weakSelf = self;
    float x = [self toolBarNippleXForSetting:self.subSetting];
    if(!sender)
    {
        self.toolbarNippleView.center = (CGPoint){x, self.toolbarNippleView.center.y};
    }
    else
    {
        weakSelf.stopAutoScroll = NO;
        [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.toolbarNippleView.center = (CGPoint){x, weakSelf.toolbarNippleView.center.y};
        } completion:!updateOffset ? nil : ^(BOOL finished) {
            MysticWait(0.9, ^{
                if(!weakSelf.stopAutoScroll) [weakSelf.scrollView setContentOffset:weakSelf.scrollView.offsetAnchor animated:YES duration:0.25 delay:0 curve:UIViewAnimationCurveEaseOut animations:nil complete:nil];
            });
        }];
    }
}
- (float) toolBarNippleXForSetting:(MysticObjectType)setting;
{
    switch (setting) {
        case MysticSettingLayerBorder: return 75;
        case MysticSettingLayerShadow: return 167;
        case MysticSettingLayerBevel: return 256;
        case MysticSettingLayerEmboss: return 341;
        default: break;
    }
    return self.presentView.center.x;
}
- (void) moveNipple:(CGFloat)x completion:(MysticBlockAnimationFinished)complete;
{
    [self moveNipple:x animated:YES completion:complete];
}
- (void) moveNipple:(CGFloat)x animated:(BOOL)animated completion:(MysticBlockAnimationFinished)complete;
{
    self.nipplePoint = CGPointX(_nipplePoint, x);
    CGPoint o = self.nippleView.frame.origin;
    CGPoint c = self.nippleView.center;
    if(!animated)
    {
        self.nippleView.center = CGPointMake(x, c.y);
        if(complete) complete(YES);
        return;
    }
    __unsafe_unretained __block MysticBlockAnimationFinished _complete = complete ? Block_copy(complete) : nil;
    [MysticUIView animateWithDuration:0.175 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.nippleView.frame = CGRectY(self.nippleView.frame, o.y + (self.nippleView.frame.size.height - MYSTIC_UI_PANEL_BORDER));
    } completion:^(BOOL finished) {
        self.nippleView.center = CGPointMake(x, self.nippleView.center.y);
        [MysticUIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.nippleView.center = CGPointMake(x, c.y);
        } completion:^(BOOL finished) {
            if(_complete) { _complete(finished); Block_release(_complete); }
        }];
        
    }];
}

- (UITextField *) findLastResponder;
{
    return self.lastResponder;
}

- (void) toolbarKeyboard:(id)sender;
{
    sender = sender ? sender : [self.toolbar buttonForType:MysticToolTypeText];
    if(![self findLastResponder]) return;
    [self.toolbar selectItem:sender];
    self.subSetting = MysticSettingUnknown;
    self.setting = MysticSettingText;
    [self moveNipple:CGRectGetMidX(CGRectX(self.nippleView.frame, 21)) completion:nil];

    [self changeInputView:nil];
}
- (void) toolbarContent:(MysticBarButton *)sender;
{
    sender = sender ? sender : [self.toolbar buttonForType:MysticToolTypeContent];
    
    if(![self findLastResponder]) return;
    self.subSetting = MysticSettingUnknown;
    self.setting = MysticSettingLayerContent;
    [self.toolbar selectItem:sender];
    mdispatch_high(^{
        UIView *inputView = [self inputView:MysticIconTypeToolContent];
        mdispatch(^{
            [self changeInputView:[inputView autorelease]];
            [self moveNipple:CGRectGetMidX(CGRectX(self.nippleView.frame, [self.toolbar convertPoint:sender.center toView:self.lastResponder.inputAccessoryView].x - 10)) completion:nil];
        });
    });
    

}
- (void) toolbarColor:(MysticBarButton *)sender;
{
    sender = sender ? sender : [self.toolbar buttonForType:MysticToolTypeColor];
    if(![self findLastResponder]) return;
    self.subSetting = MysticSettingUnknown;
    self.setting = MysticSettingLayerColor;

    [self.toolbar selectItem:sender];
    mdispatch_high(^{
        UIView *inputView = [self inputView:MysticIconTypeToolColor];
        mdispatch(^{
            [self changeInputView:[inputView autorelease]];
            [self moveNipple:CGRectGetMidX(CGRectX(self.nippleView.frame, [self.toolbar convertPoint:sender.center toView:self.lastResponder.inputAccessoryView].x - 10)) completion:nil];
        });
    });

    
}

- (void) toolbarEffects:(MysticBarButton *)sender;
{
    sender = sender ? sender : [self.toolbar buttonForType:MysticToolTypeSettings];
    if(![self findLastResponder]) return;
    self.subSetting = MysticSettingUnknown;
    self.setting = MysticSettingLayerEffect;

    [self.toolbar selectItem:sender];
    mdispatch_high(^{
        UIView *inputView = [self inputView:MysticIconTypeToolEffects];
        mdispatch(^{
            [self changeInputView:[inputView autorelease]];
            [self moveNipple:CGRectGetMidX(CGRectX(self.nippleView.frame, [self.toolbar convertPoint:sender.center toView:self.lastResponder.inputAccessoryView].x - 10)) completion:nil];
        });
    });
    

}
- (void) toolbarShadow:(MysticBarButton *)sender;
{
    self.stopAutoScroll = NO;
    BOOL alreadySelected = sender ? sender.selected : NO;
    BOOL alreadyOpen = self.scrollView && self.scrollView.contentOffset.y < self.scrollView.offsetAnchor.y;
    BOOL alreadyClosed = self.scrollView && self.scrollView.contentOffset.y >= self.scrollView.offsetAnchor.y;
    BOOL hasSetup = self.scrollView != nil;
    if(!hasSetup) _setupScrollview = NO;
    if(hasSetup && !_setupScrollview) self.stopAutoScroll = YES;
    if(![self findLastResponder]) return;
    
    [self.toolbar selectItem:sender ? sender : [self.toolbar buttonForType:MysticToolTypeLayerShadow]];
    NSValue *lastOffset;
    CGFloat nx = self.toolbarNippleView.center.x;
    NSTimeInterval durationOpen = .4f;
    NSTimeInterval delayOpen = alreadySelected ? 0 : .25f;
    NSTimeInterval openDuration = 1.55f;
    NSTimeInterval durationClose = 0.4;
    
    if(self.previousSubSetting == MysticSettingLayerShadow)
    {
        nx = [self toolBarNippleXForSetting:self.previousSubSetting];
        lastOffset = [self.userInfo objectForKey:[NSString format:@"%d-%d-lastOffset", MysticSettingLayerShadow, MysticSettingLayerShadow]];
        [self shadowBorderToolBarShadow:nil];
    }
    else if(self.previousSubSetting == MysticSettingLayerBevel)
    {
        nx = [self toolBarNippleXForSetting:self.previousSubSetting];
        lastOffset = [self.userInfo objectForKey:[NSString format:@"%d-%d-lastOffset", MysticSettingLayerShadow, MysticSettingLayerBevel]];
        [self shadowBorderToolBarBevel:nil];
    }
    else if(self.previousSubSetting == MysticSettingLayerEmboss)
    {
        nx = [self toolBarNippleXForSetting:self.previousSubSetting];
        lastOffset = [self.userInfo objectForKey:[NSString format:@"%d-%d-lastOffset", MysticSettingLayerShadow, MysticSettingLayerEmboss]];
        [self shadowBorderToolBarEmboss:nil];
    }
    else
    {
        nx = [self toolBarNippleXForSetting:MysticSettingLayerBorder];
        lastOffset = [self.userInfo objectForKey:[NSString format:@"%d-%d-lastOffset", MysticSettingLayerShadow, MysticSettingLayerBorder]];
        [self shadowBorderToolBarBorder:nil];
    }
    [self moveNipple:CGRectGetMidX(CGRectX(self.nippleView.frame, !sender ? CGRectGetMidX(self.toolbar.frame) : [self.toolbar convertPoint:sender.center toView:self.lastResponder.inputAccessoryView].x - 10)) completion:nil];
    CGPoint c = CGPointX(self.toolbarNippleView.center, self.nipplePoint.x);
    
    if(self.stopAutoScroll) return;
    if(lastOffset)
    {
        if(lastOffset.y > self.subToolbar.frame.origin.y + self.subToolbar.frame.size.height)
        {
            UIView *bg = [self.scrollView viewWithTag:MysticViewTypeBackground];
            CGRect bf = self.subToolbar.frame;
            CGRect f = CGRectY(bf, lastOffset.y - bf.size.height);
            CGRect bgf = bg.frame;
            CGPoint bc = self.toolbarNippleView.center;
            [self.scrollView bringSubviewToFront:self.subToolbar];
            [self.scrollView bringSubviewToFront:bg];
            [self.scrollView bringSubviewToFront:self.toolbarNippleView];
            
            CGPoint newOffset = (CGPoint){0, lastOffset.y - (f.size.height + MYSTIC_UI_PANEL_BORDER)};
            if(alreadyOpen && self.scrollView.contentOffset.y <= newOffset.y)
            {
                newOffset.y = lastOffset.y;
                [self.scrollView setContentOffset:newOffset animated:NO];
                self.toolbarNippleView.center = (CGPoint){nx, c.y};
            }
            else
            {
                [self.scrollView setContentOffset:lastOffset.CGPointValue animated:NO];
                self.subToolbar.frame = f;
                bg.frame = CGRectY(bg.frame, f.origin.y - bgf.size.height);
                c.y = lastOffset.y + (bc.y - f.size.height);
                self.toolbarNippleView.center = c;
            }
        }
        [self.userInfo removeObjectForKey:[NSString stringWithFormat:@"%d-%d-lastOffset", self.setting, self.subSetting]];
    }
    else
    {
        __unsafe_unretained __block MysticLayerEditViewController *_vc = self;
        if(!alreadyOpen)
        {
            if(alreadySelected && alreadyClosed)
            {
                    [MysticUIView animateWithDuration:0.3 delay:durationOpen*.5 options:UIViewAnimationCurveEaseOut animations:^{
                        _vc.toolbarNippleView.center = (CGPoint){nx, c.y};
                    }];
                    [MysticUIView animateWithDuration:durationOpen options:UIViewAnimationCurveEaseInOut animations:^{
                        _vc.scrollView.contentOffset = (CGPoint){0,0};
                    }];
            }
            else
            {
                self.toolbarNippleView.center = (CGPoint){nx, c.y};
                [self.scrollView setContentOffset:(CGPoint){0,0} animated:NO];
            }
        }
        else
        {
            [MysticUIView animateWithDuration:durationClose*.8 options:UIViewAnimationCurveEaseOut animations:^{
                _vc.toolbarNippleView.center = (CGPoint){c.x, c.y};
            }];
        }

        if(!alreadySelected || alreadyOpen)
        {
            [MysticUIView animateWithDuration:alreadyOpen?durationClose:durationOpen delay:alreadyOpen?0:delayOpen options:alreadyOpen?UIViewAnimationCurveEaseIn : UIViewAnimationCurveEaseInOut animations:^{
                _vc.scrollView.contentOffset = (CGPoint){0, !alreadyOpen?0:_vc.scrollView.offsetAnchor.y};
            } completion:(alreadyOpen || alreadySelected) ? nil : ^(BOOL finished) {
                
                if(_vc.stopAutoScroll) { _vc.setupScrollview = YES; return; }
                MysticWait(openDuration-.4, ^{
                    
                    if(_vc.stopAutoScroll) { _vc.setupScrollview = YES; return; }
                    [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                        _vc.toolbarNippleView.center = (CGPoint){c.x, c.y};
                    }];
                    [MysticUIView animateWithDuration:durationClose delay:0  options:UIViewAnimationCurveEaseInOut animations:^{
                        _vc.scrollView.contentOffset = (CGPoint){0,_vc.scrollView.offsetAnchor.y};
                    } completion:^(BOOL finished) {
                        _vc.setupScrollview = YES;
                    }];
                });
            }];
        }
    }
}


- (void) shadowBorderToolBarShadow:(MysticBarButton *)sender;
{
    [self subToolbarItemSelected:sender setting:MysticSettingLayerShadow];
}
- (void) shadowBorderToolBarBorder:(MysticBarButton *)sender;
{
    [self subToolbarItemSelected:sender setting:MysticSettingLayerBorder];
}
- (void) shadowBorderToolBarBevel:(MysticBarButton *)sender;
{
    [self subToolbarItemSelected:sender setting:MysticSettingLayerBevel];
}
- (void) shadowBorderToolBarEmboss:(MysticBarButton *)sender;
{
    [self subToolbarItemSelected:sender setting:MysticSettingLayerEmboss];
}
- (void) subToolbarItemSelected:(MysticBarButton *)sender setting:(MysticObjectType)subSetting;
{
    MysticToolType buttonType = MysticToolTypeUnknown;
    switch (subSetting) {
        case MysticSettingLayerBorder: buttonType = MysticToolTypeBorder; break;
        case MysticSettingLayerShadow: buttonType = MysticToolTypeShadow; break;
        case MysticSettingLayerEmboss: buttonType = MysticToolTypeEmboss; break;
        case MysticSettingLayerBevel: buttonType = MysticToolTypeBevel; break;
        default: return;
    }
    [self.subToolbar selectItem:sender ? sender : [self.subToolbar buttonForType:buttonType]];
    if(self.subSetting != subSetting || !self.scrollView)
    {
        self.subSetting = subSetting;
        self.setting = MysticSettingLayerShadow;
        mdispatch_high(^{
            UIView *inputView = [self inputView:MysticIconTypeToolShadowAndBorder];
            mdispatch(^{
                [self changeInputView:[inputView autorelease]];
            });
        });
    
        
    }
    self.subSetting = subSetting;
    self.setting = MysticSettingLayerShadow;
    [self updateToolbarNipple:sender updateOffset:sender!=nil];
}
#pragma mark - InputView

- (void) changeInputView:(UIView *)newView;
{
    self.switchingKeyboard = YES;
    self.lastResponder = self.hiddenTextField;
    self.hiddenTextField.inputView = newView;
    [self.hiddenTextField reloadInputViews];
    releaseHiddenText = NO;
    self.inputView = newView;
}
- (CGRect) previewFrame;
{
    CGRect previewf = self.presentView ? self.presentView.frame : CGRectSize([MysticUI screen]);
    return CGRectMake(0, 0, previewf.size.width, previewf.size.height - self.keyboardRect.size.height - (MYSTIC_UI_PANEL_BORDER*2));
}
- (CGRect) previewFrameInset; {  return UIEdgeInsetsInsetRect(CGRectInset(self.previewFrame, 60, 60),self.layerView.layerInsets); }
- (void) resetPreviousInputView:(MysticIconType)iconType;
{
    switch (iconType) {
        case MysticIconTypeToolShadowAndBorder: break;
        default:
        {
            self.opacitySlider = nil;
            self.blurSlider = nil;
            self.choicesScrollView = nil;
            self.packsScrollView = nil;
            self.subToolbar = nil;
            self.scrollView = nil;
            self.widthSlider = nil;
            self.toolbarNippleView = nil;
            break;
        }
    }
}
- (UIView *) inputView:(MysticIconType)iconType;
{
    settingUpInput = YES;

    __unsafe_unretained __block MysticLayerEditViewController *weakSelf = self;

    __block UIView *inputView = [[UIView alloc] initWithFrame:(CGRect){0,0, [MysticUI screen].width, self.keyboardRect.size.height- MYSTIC_UI_TOOLBAR_ACCESSORY_HEIGHT}];
    __block CGFloat titleSpacing = 3;
    __block MysticSlider *slider;
    __block SubBarButton *sliderLeftView;
    __block UILabel *sliderLabel;
    __block CGFloat h = CGRectH(inputView.frame)/3;
    __block CGFloat sliderWidth = CGRectW(inputView.frame)-140;
    __block CGFloat sliderX = (80 + sliderWidth) + 15;
    __block CGSize sliderLabelSize = (CGSize){CGRectW(inputView.frame)-sliderX,35};
    __block CGFloat sliderLabelY = (h - sliderLabelSize.height)/2;
    __block CGRect chipFrame = CGRectWidthHeight(inputView.frame, CGRectW(inputView.frame)-80, 80);
    __block CGRect sliderLabelFrame = CGRectSizeXY(sliderLabelSize, sliderX, 0);
    [self resetPreviousInputView:iconType];
    inputView.backgroundColor = [UIColor hex:@"201F1F"];
    self.touchView.touchMoved = nil;
    switch (iconType) {
            
#pragma mark - InputView - Shadow, Border, Bevel, Emboss, etc...
        case MysticIconTypeFontShadow:
        case MysticIconTypeToolShadowAndBorder:
        {
            mdispatch(^{
                if(!self.subToolbar)
                {
                    self.scrollView = [[[MysticInputScrollView alloc] initWithFrame:CGRectSize(inputView.frame.size)] autorelease];
                    _scrollView.controlDelegate = self;
                    _scrollView.delegate = self;
                    _scrollView.delaysContentTouches = NO;
                    NSArray *items = @[@(MysticToolTypeStaticHeader),
                                       @(MysticToolTypeFlexible),

                                       @{@"toolType": @(MysticToolTypeBorder),
                                         @"eventAdded": @YES,
                                         @"selected": _subSetting == MysticSettingLayerBorder  || _subSetting==MysticObjectTypeUnknown ? @YES : @NO,
                                         @"view": [MysticCategoryButton button:@"BORDER" target:self sel:@selector(shadowBorderToolBarBorder:)],
                                         @"contentMode": @(UIViewContentModeCenter),
                                         @"objectType":@(self.option.type)},
                                       
                                      @{@"toolType": @(MysticToolTypeStatic), @"width":@(20)},
                                       
                                       @{@"toolType": @(MysticToolTypeShadow),
                                         @"eventAdded": @YES,
                                         @"selected": _subSetting == MysticSettingLayerShadow ? @YES : @NO,
                                         @"view": [MysticCategoryButton button:@"SHADOW" target:self sel:@selector(shadowBorderToolBarShadow:)],
                                         @"contentMode": @(UIViewContentModeCenter),
                                         @"objectType":@(self.option.type)},
                                       
                                       @{@"toolType": @(MysticToolTypeStatic), @"width":@(20)},
                                       
                                       @{@"toolType": @(MysticToolTypeBevel),
                                         @"eventAdded": @YES,
                                         @"selected": _subSetting == MysticSettingLayerBevel ? @YES : @NO,
                                         @"view": [MysticCategoryButton button:@"BEVEL" target:self sel:@selector(shadowBorderToolBarBevel:)],
                                         @"contentMode": @(UIViewContentModeCenter),
                                         @"objectType":@(self.option.type)},
                                       
                                       @{@"toolType": @(MysticToolTypeStatic), @"width":@(20)},
                                       
                                       @{@"toolType": @(MysticToolTypeEmboss),
                                         @"eventAdded": @YES,
                                         @"selected": _subSetting == MysticSettingLayerEmboss ? @YES : @NO,
                                         @"view": [MysticCategoryButton button:@"EMBOSS" target:self sel:@selector(shadowBorderToolBarEmboss:)],
                                         @"contentMode": @(UIViewContentModeCenter),
                                         @"objectType":@(self.option.type)},
                                       
                                       @(MysticToolTypeFlexible),
                                       @(MysticToolTypeStaticFooter)
                                       ];
                    
                    UIView *bgView = [[UIView alloc] initWithFrame:CGRectXY(CGRectHeight(inputView.frame, CGRectH(inputView.frame)/2), 0, 3-(CGRectH(inputView.frame)/2))];
                    bgView.backgroundColor = [UIColor hex:@"3F3834"];
                    bgView.tag = MysticViewTypeBackground;
                    [self.scrollView addSubview:[bgView autorelease]];
                    
                    self.subToolbar = [MysticLayerToolbar toolbarWithItems:nil delegate:self height:50];
                    self.subToolbar.frame = CGRectXY(self.subToolbar.frame, 0, -MYSTIC_UI_PANEL_BORDER);

                    [self.subToolbar useItems:items];
                    self.subToolbar.backgroundColor = bgView.backgroundColor;
                    [self.scrollView addSubview:self.subToolbar];
                    self.scrollView.offsetAnchor = (CGPoint){0, self.subToolbar.frame.size.height};
                    self.scrollView.contentInset = UIEdgeInsetsMake(-MYSTIC_UI_PANEL_BORDER, 0, 0, 0);
                    self.toolbarNippleView = [[[MysticNippleView alloc] initWithFrame:(CGRect){0,0,20,10} image:@(MysticIconTypeNippleTop) color:inputView.backgroundColor] autorelease];
                    self.toolbarNippleView.frame = CGRectAlign(self.toolbarNippleView.frame, self.subToolbar.frame, MysticAlignTypeBottom);
                    self.toolbarNippleView.center = (CGPoint){self.nippleView.center.x, self.toolbarNippleView.center.y + MYSTIC_UI_PANEL_BORDER*1.5};
                    [self.scrollView addSubview:self.toolbarNippleView];

                }
                else
                {
                    [self.scrollView removeSubviewsExcept:@[self.subToolbar, self.toolbarNippleView, @(MysticViewTypeBackground)]];
                    [inputView release];
                    inputView = [self.inputView retain];
                }
                CGFloat toolY = self.subToolbar.frame.origin.y + self.subToolbar.frame.size.height;
                int rows = 3;
                switch (self.subSetting) {
                    case MysticSettingLayerBevel:
                    case MysticSettingLayerBorder: rows = 5; break;
                    case MysticSettingLayerEmboss: rows = 4; break;
                    default: break;
                }
                self.subSetting == MysticSettingLayerBorder ? 5 : 3;
                chipFrame = UIEdgeInsetsInsetRect(chipFrame, UIEdgeInsetsMake(15, 0, 15, 15));
                chipFrame.origin.x = 80 - 4;
                chipFrame.origin.y = toolY;
                __block MysticColorsScrollView *colors = [[MysticColorsScrollView alloc] initWithFrame:chipFrame];
                colors.tileOrigin = (CGPoint){0, (chipFrame.size.height-colors.tileSize.height)/2};
                colors.controlDelegate = self;
                colors.showsControlAccessory = NO;
                NSArray *theColors = [[Mystic core] colorsForOption:self.option option:MysticOptionColorTypeBackground setting:MysticSettingFontColor];
                PackPotionOptionColor *selectedColor = nil;
                int selectedIndex = MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX;
                int i = 0;
                for (PackPotionOptionColor *c in theColors) {
                    c.selectedSize = (CGSize){29,29};
                    c.unselectedSize = (CGSize){20,20};
                    c.borderWidth = 4;
                    BOOL equalColors;
                    switch (self.subSetting) {
                        case MysticSettingLayerBorder:
                        {
                            equalColors = [c.color isEqualToColor:[[UIColor colorWithCGColor:self.contentView.layer.borderColor] opaque]];
                            equalColors = equalColors ?  YES : (self.choice.borderColor ? [c.color isEqualToColor:[self.choice.borderColor opaque]] : [c.color isEqualToColor:[UIColor blackColor]]);
                            break;
                        }
                        case MysticSettingLayerShadow:
                        {
                            equalColors = [c.color isEqualToColor:[[UIColor colorWithCGColor:self.contentView.layer.shadowColor] opaque]];
                            equalColors = equalColors ?  YES : (self.choice.shadowColor ? [c.color isEqualToColor:self.choice.shadowColor] : [c.color isEqualToColor:[UIColor blackColor]]);
                            break;
                        }
                        default:
                            break;
                    }
                    if(selectedIndex == MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX && equalColors) selectedIndex = i;
                    i++;
                }
                [colors loadControls:theColors selectIndex:selectedIndex animated:NO complete:^{
                    EffectControl *selectedControl = (EffectControl *)colors.selectedItem;
                    if(selectedControl)
                    {
                        [selectedControl.effect updateLabel:nil control:selectedControl selected:YES];
                    }
                    else
                    {
                        for (EffectControl *ec in colors.subviews) [ec.effect updateLabel:nil control:ec selected:NO];
                    }
                }];
                CGPoint c = colors.center;
                c.y = h/2 + toolY;
                colors.center = c;
                colors.showsHorizontalScrollIndicator=NO;
                colors.showsVerticalScrollIndicator=NO;
                colors.directionalLockEnabled = YES;
                [self.scrollView addSubview:colors];
                inputView.backgroundColor = [UIColor hex:@"201F1F"];

                MysticBorderView *border = [[MysticBorderView alloc] initWithFrame:(CGRect){0,toolY,CGRectW(inputView.frame), h*rows}];
                border.numberOfDivisions = rows;
                border.borderColor = [inputView.backgroundColor lighter:0.05];
                border.borderWidth = 1;
                border.dashSize = (CGSize){border.borderWidth, 5};
                border.borderColor = [UIColor hex:@"473F3C"];
                border.dashed = YES;
                border.borderOffset = (CGPoint){0, 1};
                border.showBorder = YES;
                border.tag = MysticViewTypeBackgroundBorder;
                border.userInteractionEnabled = NO;
                [self.scrollView insertSubview:border atIndex:0];
                
                self.scrollView.contentSize = (CGSize){CGRectW(inputView.frame), CGRectH(border.frame) + toolY};
                
                switch (self.subSetting) {
                        
    #pragma mark - InputView - Shadow

                    case MysticSettingLayerShadow:
                    {
                        
                        slider = [MysticSlider sliderWithFrame:(CGRect){80,h + toolY,sliderWidth, h}];
                        slider.tag = 102;
                        [slider addTarget:self action:@selector(blurSliderChanged:) forControlEvents:UIControlEventValueChanged];
                        slider.minimumValue = 0;
                        slider.maximumValue = 20;
                        slider.lowerHandleHidden = YES;
                        slider.defaultValue = 0;
                        slider.value = isnan(_shadowRadius) ? self.choice.shadowRadius ? self.choice.shadowRadius : slider.defaultValue : _shadowRadius;
                        slider.lowerValue = 0;
                        slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
                        slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                        slider.onlyTouchControls = YES;
                        [self.scrollView addSubview:slider];
                        self.blurSlider = slider;
                        _shadowRadius = slider.value;
                        
                        slider = [MysticSlider sliderWithFrame:(CGRect){80,h*2+ toolY,sliderWidth, h}];
                        slider.tag = 103;
                        slider.onlyTouchControls = YES;
                        [slider addTarget:self action:@selector(alphaSliderChanged:) forControlEvents:UIControlEventValueChanged];
                        slider.minimumValue = 0;
                        slider.maximumValue = 1;
                        slider.lowerHandleHidden = YES;
                        slider.defaultValue = 1;
                        if(self.choice.hasShadow)
                        {
                            slider.value = self.choice.shadowAlpha;
                        }
                        else
                        {
                            slider.value = slider.defaultValue;
                        }
                        slider.lowerValue = 0;
                        slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
                        slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                        [self.scrollView addSubview:slider];
                        self.opacitySlider = slider;
                        _shadowAlpha = slider.value;
                        
                        
                        
                        sliderLeftView = [[SubBarButton alloc] initWithFrame:(CGRect){15, (h*2)+((h-35)/2)+ toolY + 2, 50,35} showTitle:YES];
                        sliderLeftView.tag = 122;
                        sliderLeftView.titleIconSpacing = titleSpacing;
                        sliderLeftView.imageEdgeInsets = UIEdgeInsetsMakeFrom(0);
                        sliderLeftView.imageView.contentMode = UIViewContentModeCenter;
                        [sliderLeftView setImage:[MysticImage image:@(MysticIconTypeLayerShadowAlpha) size:(CGSize){23,18} color:nil] forState:UIControlStateDisabled];
                        sliderLeftView.titleLabel.font = [[[sliderLeftView class] labelFont] fontWithSize:8];
                        [sliderLeftView setTitle:@"OPACITY" forState:UIControlStateDisabled];
                        sliderLeftView.enabled = NO;
                        [self.scrollView addSubview:[sliderLeftView autorelease]];
                        
                        sliderLeftView = [[SubBarButton alloc] initWithFrame:(CGRect){15, (h*1)+((h-35)/2)+ toolY + 2, 50,35} showTitle:YES];
                        sliderLeftView.tag = 123;
                        sliderLeftView.titleIconSpacing = titleSpacing;
                        sliderLeftView.imageEdgeInsets = UIEdgeInsetsMakeFrom(0);
                        sliderLeftView.imageView.contentMode = UIViewContentModeCenter;
                        [sliderLeftView setImage:[MysticImage image:@(MysticIconTypeLayerShadowBlur) size:(CGSize){23,18} color:nil] forState:UIControlStateDisabled];
                        sliderLeftView.titleLabel.font = [[[sliderLeftView class] labelFont] fontWithSize:8];
                        [sliderLeftView setTitle:@"BLUR" forState:UIControlStateDisabled];
                        sliderLeftView.enabled = NO;
                        [self.scrollView addSubview:[sliderLeftView autorelease]];
                        
                        sliderLeftView = [[SubBarButton alloc] initWithFrame:(CGRect){15, (h*0)+((h-35)/2)+ toolY + 2, 50,35} showTitle:YES];
                        sliderLeftView.tag = 124;
                        sliderLeftView.titleIconSpacing = titleSpacing;
                        sliderLeftView.imageEdgeInsets = UIEdgeInsetsMakeFrom(0);
                        sliderLeftView.imageView.contentMode = UIViewContentModeCenter;
                        [sliderLeftView setImage:[MysticImage image:@(MysticIconTypeLayerShadowColor) size:(CGSize){23,18} color:nil] forState:UIControlStateDisabled];
                        sliderLeftView.titleLabel.font = [[[sliderLeftView class] labelFont] fontWithSize:8];
                        [sliderLeftView setTitle:@"COLOR" forState:UIControlStateDisabled];
                        sliderLeftView.enabled = NO;

                        [self.scrollView addSubview:[sliderLeftView autorelease]];
                        
                        
                        
                        
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:CGRectY(sliderLabelFrame, (h*2)+sliderLabelY+ toolY)];
                        sliderLabel.tag = 1233;
                        sliderLabel.font = [MysticFont fontBold:11];
                        sliderLabel.userInteractionEnabled = NO;
                        sliderLabel.textAlignment = NSTextAlignmentLeft;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        sliderLabel.text = [NSString stringWithFormat:@"%2.0f%%", self.opacitySlider.value*100];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:CGRectY(sliderLabelFrame, (h*1)+sliderLabelY+ toolY)];
                        sliderLabel.tag = 1235;
                        sliderLabel.userInteractionEnabled = NO;
                        sliderLabel.font = [MysticFont fontBold:11];
                        sliderLabel.textAlignment = NSTextAlignmentLeft;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        sliderLabel.text = [NSString stringWithFormat:@"%2.1f", self.blurSlider.value];
                        
                        break;
                    }
                        
    #pragma mark - InputView - Border
                        
                        
                    case MysticSettingLayerBorder:
                    {
                        
                        slider = [MysticSlider sliderWithFrame:(CGRect){80,h*1 + toolY,sliderWidth, h}];
                        slider.tag = 102;
                        [slider addTarget:self action:@selector(widthSliderChanged:) forControlEvents:UIControlEventValueChanged];
                        [slider addTarget:self action:@selector(widthSliderEnded:) forControlEvents:UIControlEventEditingDidEnd];
                        slider.setting = MysticSettingLayerBorder;
                        slider.minimumValue = 0;
                        slider.maximumValue = 20;
                        slider.lowerHandleHidden = YES;
                        slider.onlyTouchControls = YES;
                        slider.defaultValue = 0;
                        slider.value = self.choice.borderWidth ? self.choice.borderWidth : slider.defaultValue;
                        slider.lowerValue = 0;
                        slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
                        slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                        slider.minimumValueChange = 0.1;
                        
                        [self.scrollView addSubview:slider];
                        self.widthSlider = slider;
                        _shadowRadius = slider.value;
                        
                        slider = [MysticSlider sliderWithFrame:(CGRect){80,h*2+ toolY,sliderWidth, h}];
                        slider.tag = 103;
                        [slider addTarget:self action:@selector(alphaSliderChanged:) forControlEvents:UIControlEventValueChanged];
                        slider.minimumValue = 0;
                        slider.maximumValue = 1;
                        slider.lowerHandleHidden = YES;
                        slider.onlyTouchControls = YES;
                        slider.defaultValue = 1;
                        if(self.choice.borderAlpha)
                        {
                            slider.value = self.choice.borderAlpha;
                        }
                        else
                        {
                            slider.value = slider.defaultValue;
                        }
                        slider.lowerValue = 0;
                        slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
                        slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                        [self.scrollView addSubview:slider];
                        self.opacitySlider = slider;
                        _shadowAlpha = slider.value;
                        
                        
                        
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*2)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 122;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.text = @"OPACITY";
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*1)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 123;
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.text = @"WIDTH";
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*0)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 124;
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.text = @"COLOR";
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*3)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 125;
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.text = @"ALIGN";
                        [self.scrollView addSubview:[sliderLabel autorelease]];

                        
                        
                        
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:CGRectY(sliderLabelFrame, (h*2)+sliderLabelY+ toolY)];
                        sliderLabel.tag = 1233;
                        sliderLabel.userInteractionEnabled = NO;
                        sliderLabel.font = [MysticFont fontBold:11];
                        sliderLabel.textAlignment = NSTextAlignmentLeft;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        sliderLabel.text = [NSString stringWithFormat:@"%2.0f%%", self.opacitySlider.value*100];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:CGRectY(sliderLabelFrame, (h*1)+sliderLabelY+ toolY)];
                        sliderLabel.tag = 1232;
                        sliderLabel.userInteractionEnabled = NO;
                        sliderLabel.font = [MysticFont fontBold:11];
                        sliderLabel.textAlignment = NSTextAlignmentLeft;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        sliderLabel.text = [NSString stringWithFormat:@"%2.1f", self.widthSlider.value];
                        
                        MysticBlockSender action = ^(MysticButton *sender) {
                            [sender setSiblingsToSelected:NO];
                            sender.selected = YES;
                            MysticPosition b = weakSelf.choice.borderPosition;
                            float bw = weakSelf.choice.borderWidth;
                            UILabel *label = [sender.superview viewWithTag:1236];
                            switch (sender.tag) {
                                case MysticViewTypeButtonAlignMiddle:
                                    weakSelf.choice.borderPosition = MysticPositionMiddle;
                                    sliderLabel.text = @"CENTER";
                                    break;
                                case MysticViewTypeButtonAlignOutside:
                                    weakSelf.choice.borderPosition = MysticPositionOutside;
                                    sliderLabel.text = @"OUTER";
                                    break;
                                    
                                case MysticViewTypeButtonAlignInside:
                                    weakSelf.choice.borderPosition = MysticPositionInside;
                                    sliderLabel.text = @"INNER";
                                    break;
                                default: break;
                            }
                            weakSelf.stopAutoScroll = YES;
                            if(weakSelf.choice.borderPosition != b) {
                                if(bw != weakSelf.choice.borderWidth && weakSelf.widthSlider)
                                {
                                    weakSelf.widthSlider.blockEvents = YES;  [weakSelf.widthSlider setUpperValue:weakSelf.choice.borderWidth animated:YES]; weakSelf.widthSlider.blockEvents = NO;
                                    UILabel *label = (id)[weakSelf.widthSlider.superview viewWithTag:1232];
                                    if(label) label.text = [NSString stringWithFormat:@"%2.1f", weakSelf.choice.borderWidth];
                                }
                                [weakSelf updateViews];
                            }
                        };
                        
               
                        MysticButtonBorderAlign *alignBtn = [MysticButtonBorderAlign button:nil action:action];
                        alignBtn.frame = (CGRect){93, toolY + h*3 + h/2 - 25, 50, 50};
                        alignBtn.contentMode = UIViewContentModeCenter;
                        [alignBtn setImage:[MysticImage image:@(MysticIconTypeBorderAlignMiddle) size:(CGSize){30,30} color:nil] forState:UIControlStateNormal];
                        [alignBtn setImage:[MysticImage image:[alignBtn imageForState:UIControlStateNormal] size:(CGSize){30,30} color:@(MysticColorTypePink)] forState:UIControlStateSelected];
                        alignBtn.tag = MysticViewTypeButtonAlignMiddle;
                        alignBtn.selected = self.choice.borderPosition != MysticPositionOutside && self.choice.borderPosition != MysticPositionInside;
                        
                        [self.scrollView addSubview:alignBtn];
                        
                        alignBtn = [MysticButtonBorderAlign button:nil action:action];
                        alignBtn.frame = (CGRect){183, toolY + h*3 + h/2 - 25, 50, 50};
                        alignBtn.tag = MysticViewTypeButtonAlignInside;
                        alignBtn.contentMode = UIViewContentModeCenter;
                        [alignBtn setImage:[MysticImage image:@(MysticIconTypeBorderAlignInside) size:(CGSize){30,30} color:nil] forState:UIControlStateNormal];
                        [alignBtn setImage:[MysticImage image:[alignBtn imageForState:UIControlStateNormal] size:(CGSize){30,30} color:@(MysticColorTypePink)] forState:UIControlStateSelected];
                        alignBtn.selected = self.choice.borderPosition == MysticPositionInside;
                        [self.scrollView addSubview:alignBtn];
                        
                        alignBtn = [MysticButtonBorderAlign button:nil action:action];
                        alignBtn.frame = (CGRect){272, toolY + h*3 + h/2 - 25, 50, 50};
                        alignBtn.tag = MysticViewTypeButtonAlignOutside;
                        alignBtn.contentMode = UIViewContentModeCenter;
                        [alignBtn setImage:[MysticImage image:@(MysticIconTypeBorderAlignOutside) size:(CGSize){30,30} color:nil] forState:UIControlStateNormal];
                        [alignBtn setImage:[MysticImage image:[alignBtn imageForState:UIControlStateNormal] size:(CGSize){30,30} color:@(MysticColorTypePink)] forState:UIControlStateSelected];
                        alignBtn.selected = self.choice.borderPosition == MysticPositionOutside;
                        [self.scrollView addSubview:alignBtn];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){CGRectW(inputView.frame) - 15 - 50, (h*3)+((h-40)/2)+ toolY, 50, 40}];
                        sliderLabel.tag = 1236;
                        sliderLabel.userInteractionEnabled = NO;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.numberOfLines = 2;
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        int atag = [(MysticButtonBorderAlign *)alignBtn.selectedSibling tag];
                        sliderLabel.text = atag == MysticViewTypeButtonAlignInside ?  @"INNER" : atag == MysticViewTypeButtonAlignOutside ?  @"OUTER" : @"CENTER";
                        float w = (CGRectW(inputView.frame) - 180)/3;
                        float bh = 30;
                        __block float selectedBorderAlpha = 0.35;
                        
                        
                        
                        MysticToggleButton *capBtn = [MysticToggleButton button:@"CAP" action:nil];
                        capBtn.iconStyle = MysticIconTypeNone;
                        capBtn.minToggleState = 0;
                        capBtn.maxToggleState = 3;
                        if(weakSelf.choice.lineCap && [weakSelf.choice.lineCap isEqualToString:kCALineCapButt])
                        {
                            capBtn.toggleState = 1;
                        }
                        else if([weakSelf.choice.lineCap isEqualToString:kCALineCapRound])
                        {
                            capBtn.toggleState = 2;
                        }
                        else if([weakSelf.choice.lineCap isEqualToString:kCALineCapSquare])
                        {
                            capBtn.toggleState = 3;
                        }
                        else
                        {
                            capBtn.toggleState = 0;
                        }
                        capBtn.onToggle = ^(MysticToggleButton *toggler)
                        {
                            switch (toggler.toggleState) {
                                case 3:
                                    weakSelf.choice.lineCap = kCALineCapSquare;
                                    [toggler setTitle:@"SQUARE" forState:UIControlStateNormal];
                                    [toggler setTitle:@"SQUARE" forState:UIControlStateSelected];
                                    [toggler setTitle:@"SQUARE" forState:UIControlStateHighlighted];
                                    break;
                                case 2:
                                    weakSelf.choice.lineCap = kCALineCapRound;
                                    [toggler setTitle:@"ROUND" forState:UIControlStateNormal];
                                    [toggler setTitle:@"ROUND" forState:UIControlStateSelected];
                                    [toggler setTitle:@"ROUND" forState:UIControlStateHighlighted];
                                    break;
                                case 1:
                                    weakSelf.choice.lineCap = kCALineCapButt;
                                    [toggler setTitle:@"END" forState:UIControlStateNormal];
                                    [toggler setTitle:@"END" forState:UIControlStateSelected];
                                    [toggler setTitle:@"END" forState:UIControlStateHighlighted];
                                    break;
                                case 0:
                                default:
                                    weakSelf.choice.lineCap = nil;
                                    [toggler setTitle:@"CAP" forState:UIControlStateNormal];
                                    [toggler setTitle:@"CAP" forState:UIControlStateSelected];
                                    [toggler setTitle:@"CAP" forState:UIControlStateHighlighted];
                                    break;
                            }
                            toggler.selected = toggler.toggleState > 0;
                            MBorder(toggler, toggler.selected ? [[toggler titleColorForState:UIControlStateSelected] alpha:selectedBorderAlpha] : [UIColor hex:@"332F2D"], 2);
                            [weakSelf updateViews];
                        };
                        capBtn.backgroundColor = [UIColor clearColor];
                        [capBtn setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
                        [capBtn setBackgroundColor:[UIColor clearColor] forState:UIControlStateSelected];
                        [capBtn setTitleColor:sliderLabel.textColor forState:UIControlStateNormal];
                        [capBtn setTitleColor:[UIColor hex:@"EFDECC"] forState:UIControlStateSelected];
                        capBtn.selected = capBtn.toggleState > 0;
                        capBtn.layer.cornerRadius = 11;
                        capBtn.font = sliderLabel.font;
                        capBtn.textAlignment = NSTextAlignmentCenter;
                        MBorder(capBtn, capBtn.selected ? [[capBtn titleColorForState:UIControlStateSelected] alpha:selectedBorderAlpha] : [UIColor hex:@"332F2D"], 2);
                        capBtn.frame = (CGRect){30, toolY + h*4 + h/2 - bh/2, w, bh};
                        capBtn.center = (CGPoint){CGRectGetMidX(inputView.frame) - 30 - w, capBtn.center.y};

                        [self.scrollView addSubview:capBtn];
                        
                        MysticToggleButton *lineJoinBtn = [MysticToggleButton button:@"JOIN" action:nil];
                        lineJoinBtn.canSelect = YES;
                        lineJoinBtn.iconStyle = MysticIconTypeNone;
                        lineJoinBtn.minToggleState = 0;
                        lineJoinBtn.maxToggleState = 3;
                        if(weakSelf.choice.lineJoin && [weakSelf.choice.lineJoin isEqualToString:kCALineJoinMiter])
                        {
                            lineJoinBtn.toggleState = 1;
                        }
                        else if([weakSelf.choice.lineJoin isEqualToString:kCALineCapRound])
                        {
                            lineJoinBtn.toggleState = 2;
                        }
                        else if([weakSelf.choice.lineJoin isEqualToString:kCALineJoinBevel])
                        {
                            lineJoinBtn.toggleState = 3;
                        }
                        else
                        {
                            lineJoinBtn.toggleState = 0;
                        }
                        lineJoinBtn.onToggle = ^(MysticToggleButton *toggler)
                        {
                            switch (toggler.toggleState) {
                                case 3:
                                    weakSelf.choice.lineJoin = kCALineJoinBevel;
                                    [toggler setTitle:@"BEVEL" forState:UIControlStateNormal];
                                    [toggler setTitle:@"BEVEL" forState:UIControlStateSelected];
                                    [toggler setTitle:@"BEVEL" forState:UIControlStateHighlighted];
                                    break;
                                case 2:
                                    weakSelf.choice.lineJoin = kCALineJoinRound;
                                    [toggler setTitle:@"ROUND" forState:UIControlStateNormal];
                                    [toggler setTitle:@"ROUND" forState:UIControlStateSelected];
                                    [toggler setTitle:@"ROUND" forState:UIControlStateHighlighted];
                                    break;
                                case 1:
                                    weakSelf.choice.lineJoin = kCALineJoinMiter;
                                    [toggler setTitle:@"AUTO" forState:UIControlStateNormal];
                                    [toggler setTitle:@"AUTO" forState:UIControlStateSelected];
                                    [toggler setTitle:@"AUTO" forState:UIControlStateHighlighted];
                                    break;
                                
                                case 0:
                                    weakSelf.choice.lineJoin = nil;
                                    [toggler setTitle:@"JOIN" forState:UIControlStateNormal];
                                    [toggler setTitle:@"JOIN" forState:UIControlStateSelected];
                                    [toggler setTitle:@"JOIN" forState:UIControlStateHighlighted];
                                default: break;

                            }
                            toggler.selected = toggler.toggleState > 0;
                            MBorder(toggler, toggler.selected ? [[toggler titleColorForState:UIControlStateSelected] alpha:selectedBorderAlpha] : [UIColor hex:@"332F2D"], 2);
                            [weakSelf updateViews];

                        };
                        lineJoinBtn.backgroundColor = [UIColor clearColor];
                        [lineJoinBtn setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
                        [lineJoinBtn setBackgroundColor:[UIColor clearColor] forState:UIControlStateSelected];

                        [lineJoinBtn setTitleColor:sliderLabel.textColor forState:UIControlStateNormal];
                        [lineJoinBtn setTitleColor:[UIColor hex:@"EFDECC"] forState:UIControlStateSelected];

                        lineJoinBtn.layer.cornerRadius = capBtn.layer.cornerRadius;
                        lineJoinBtn.selected = lineJoinBtn.toggleState > 0;

                        lineJoinBtn.font = sliderLabel.font;
                        lineJoinBtn.textAlignment = NSTextAlignmentCenter;
                        MBorder(lineJoinBtn, lineJoinBtn.selected ? [[lineJoinBtn titleColorForState:UIControlStateSelected] alpha:selectedBorderAlpha] : [UIColor hex:@"332F2D"], 2);
                        lineJoinBtn.frame = (CGRect){15, toolY + h*4 + h/2 - bh/2, w, bh};
                        lineJoinBtn.center = (CGPoint){CGRectGetMidX(inputView.frame) + 30, lineJoinBtn.center.y};
                        [self.scrollView addSubview:lineJoinBtn];
                        break;
                    }
                        
    #pragma mark - InputView - Bevel

                    case MysticSettingLayerBevel:
                    {
                        slider = [MysticSlider sliderWithFrame:(CGRect){80,h*2+ toolY,sliderWidth, h}];
                        slider.tag = 103;
                        [slider addTarget:self action:@selector(blurSliderChanged:) forControlEvents:UIControlEventValueChanged];
                        slider.minimumValue = 0;
                        slider.maximumValue = 1;
                        slider.lowerHandleHidden = YES;
                        slider.onlyTouchControls = YES;
                        slider.defaultValue = 0;
                        slider.value = !isnanOrZero(self.choice.bevelBlur) ? self.choice.bevelBlur : slider.defaultValue;
                        slider.lowerValue = 0;
                        slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
                        slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                        [self.scrollView addSubview:slider];
                        self.blurSlider = slider;
                        
                        slider = [MysticSlider sliderWithFrame:(CGRect){80,h*1 + toolY,sliderWidth, h}];
                        slider.tag = 102;
                        [slider addTarget:self action:@selector(widthSliderChanged:) forControlEvents:UIControlEventValueChanged];
                        slider.minimumValue = 0;
                        slider.maximumValue = 20;
                        slider.lowerHandleHidden = YES;
                        slider.onlyTouchControls = YES;
                        slider.defaultValue = 0;
                        slider.value = !isnanOrZero(self.choice.bevelRadius) ? self.choice.bevelRadius : slider.defaultValue;
                        slider.lowerValue = 0;
                        slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
                        slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                        slider.minimumValueChange = 0.1;
                        [self.scrollView addSubview:slider];
                        self.widthSlider = slider;
                        
                        slider = [MysticSlider sliderWithFrame:(CGRect){80,h*3+ toolY,sliderWidth, h}];
                        slider.tag = 103;
                        [slider addTarget:self action:@selector(alphaSliderChanged:) forControlEvents:UIControlEventValueChanged];
                        slider.minimumValue = 0;
                        slider.maximumValue = 1;
                        slider.lowerHandleHidden = YES;
                        slider.onlyTouchControls = YES;
                        slider.defaultValue = 1;
                        slider.value = self.choice.bevelColor ? self.choice.bevelColor.alpha : slider.defaultValue;
                        slider.lowerValue = 0;
                        slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
                        slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                        [self.scrollView addSubview:slider];
                        self.opacitySlider = slider;
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*0)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 124;
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.text = @"COLOR";
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*2)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 122;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.text = @"BLUR";
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*1)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 123;
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.text = @"WIDTH";
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*3)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 122;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.text = @"OPACITY";
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                       
                        sliderLabel = [[UILabel alloc] initWithFrame:CGRectY(sliderLabelFrame, (h*2)+sliderLabelY+ toolY)];
                        sliderLabel.tag = 1235;
                        sliderLabel.userInteractionEnabled = NO;
                        sliderLabel.font = [MysticFont fontBold:11];
                        sliderLabel.textAlignment = NSTextAlignmentLeft;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                        
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        sliderLabel.text = [NSString stringWithFormat:@"%2.1f", self.blurSlider.value];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:CGRectY(sliderLabelFrame, (h*1)+sliderLabelY+ toolY)];
                        sliderLabel.tag = 1232;
                        sliderLabel.userInteractionEnabled = NO;
                        sliderLabel.font = [MysticFont fontBold:11];
                        sliderLabel.textAlignment = NSTextAlignmentLeft;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        sliderLabel.text = [NSString stringWithFormat:@"%2.1f", self.widthSlider.value];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:CGRectY(sliderLabelFrame, (h*3)+sliderLabelY+ toolY)];
                        sliderLabel.tag = 1233;
                        sliderLabel.userInteractionEnabled = NO;
                        sliderLabel.font = [MysticFont fontBold:11];
                        sliderLabel.textAlignment = NSTextAlignmentLeft;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        sliderLabel.text = [NSString stringWithFormat:@"%2.0f%%", self.opacitySlider.value*100];
                        break;
                    }
                        
    #pragma mark - InputView - Emboss
                        
                    case MysticSettingLayerEmboss:
                    {
                        chipFrame = UIEdgeInsetsInsetRect(chipFrame, UIEdgeInsetsMake(15, 0, 15, 15));
                        chipFrame.origin.x = 80 - 4;
                        chipFrame.origin.y = toolY + 80;
                        chipFrame.size = colors.frame.size;
                        __block MysticColorsScrollView *colors2 = [[MysticColorsScrollView alloc] initWithFrame:chipFrame];
                        colors2.tileOrigin = (CGPoint){0, (chipFrame.size.height-colors2.tileSize.height)/2};
                        colors2.controlDelegate = self;
                        colors2.showsControlAccessory = NO;
                        colors2.tag = MysticViewTypeScrollView2;
                        NSArray *theColors = [[Mystic core] colorsForOption:self.option option:MysticOptionColorTypeBackground setting:MysticSettingLayerEmboss];
                        PackPotionOptionColor *selectedColor = nil;
                        int selectedIndex = MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX;
                        int i = 0;
                        for (PackPotionOptionColor *c in theColors) {
                            c.selectedSize = (CGSize){29,29};
                            c.unselectedSize = (CGSize){20,20};
                            c.borderWidth = 4;
                            BOOL equalColors;
                            equalColors = [c.color isEqualToColor:[self.choice.embossColor opaque]];
                            equalColors = equalColors ?  YES : self.choice.color ? [c.color isEqualToColor:[self.choice.color lighter:0.5]] : NO;
                            if(selectedIndex == MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX && equalColors) selectedIndex = i;
                            i++;
                        }
                        [colors2 loadControls:theColors selectIndex:selectedIndex animated:NO complete:^{
                            EffectControl *selectedControl = (EffectControl *)colors2.selectedItem;
                            if(selectedControl)
                            {
                                [selectedControl.effect updateLabel:nil control:selectedControl selected:YES];
                            }
                            else
                            {
                                for (EffectControl *ec in colors2.subviews) [ec.effect updateLabel:nil control:ec selected:NO];
                            }
                        }];
                        CGPoint c = colors2.center;
                        c.y = h/2 + toolY + 88 - colors2.tileSize.height/2;
                        colors2.center = c;
                        colors2.showsHorizontalScrollIndicator=NO;
                        colors2.showsVerticalScrollIndicator=NO;
                        colors2.directionalLockEnabled = YES;
                        [self.scrollView addSubview:colors2];
                        
                        
                        slider = [MysticSlider sliderWithFrame:(CGRect){80,h*2 + toolY,sliderWidth, h}];
                        slider.tag = 102;
                        [slider addTarget:self action:@selector(widthSliderChanged:) forControlEvents:UIControlEventValueChanged];
                        slider.minimumValue = 0;
                        slider.maximumValue = 20;
                        slider.lowerHandleHidden = YES;
                        slider.onlyTouchControls = YES;
                        slider.defaultValue = 0;
                        slider.value = !isnanOrZero(self.choice.embossRadius) ? self.choice.embossRadius : slider.defaultValue;
                        slider.lowerValue = 0;
                        slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
                        slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                        slider.minimumValueChange = 0.1;
                        [self.scrollView addSubview:slider];
                        self.widthSlider = slider;
                        
                        slider = [MysticSlider sliderWithFrame:(CGRect){80,h*3+ toolY,sliderWidth, h}];
                        slider.tag = 103;
                        [slider addTarget:self action:@selector(blurSliderChanged:) forControlEvents:UIControlEventValueChanged];
                        slider.minimumValue = 0;
                        slider.maximumValue = 20;
                        slider.lowerHandleHidden = YES;
                        slider.onlyTouchControls = YES;
                        slider.defaultValue = 0;
                        slider.value = !isnanOrZero(self.choice.embossBlur) ? self.choice.embossBlur : slider.defaultValue;
                        slider.lowerValue = 0;
                        slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
                        slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                        [self.scrollView addSubview:slider];
                        self.blurSlider = slider;
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*0)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 124;
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.text = @"LIGHT";
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*1)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 125;
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.text = @"DARK";
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*2)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 123;
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.text = @"WIDTH";
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){15, (h*3)+((h-35)/2)+ toolY, 50,35}];
                        sliderLabel.tag = 122;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeTabTitle];
                        sliderLabel.font = [[[SubBarButton class] labelFont] fontWithSize:8];
                        sliderLabel.textAlignment = NSTextAlignmentCenter;
                        sliderLabel.text = @"BLUR";
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:CGRectY(sliderLabelFrame, (h*2)+sliderLabelY+ toolY)];
                        sliderLabel.tag = 1232;
                        sliderLabel.userInteractionEnabled = NO;
                        sliderLabel.font = [MysticFont fontBold:11];
                        sliderLabel.textAlignment = NSTextAlignmentLeft;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        sliderLabel.text = [NSString stringWithFormat:@"%2.1f", self.widthSlider.value];
                        
                        sliderLabel = [[UILabel alloc] initWithFrame:CGRectY(sliderLabelFrame, (h*3)+sliderLabelY+ toolY)];
                        sliderLabel.tag = 1235;
                        sliderLabel.userInteractionEnabled = NO;
                        sliderLabel.font = [MysticFont fontBold:11];
                        sliderLabel.textAlignment = NSTextAlignmentLeft;
                        sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                        [self.scrollView addSubview:[sliderLabel autorelease]];
                        sliderLabel.text = [NSString stringWithFormat:@"%2.1f", self.blurSlider.value];
                        break;
                    }
                    default: break;
                }
                [self.scrollView bringSubviewToFront:self.toolbarNippleView];

                if(![inputView.subviews containsObject:self.scrollView]) [inputView addSubview:self.scrollView];
                self.updateContent = YES;
                __unsafe_unretained __block MysticLayerEditViewController *weakSelf = self;
                switch (self.subSetting) {
                    case MysticSettingLayerShadow:
                    {
                        self.touchView.touchMoved = ^(NSSet *touches, UIEvent *event, MysticTouchView *touchView)
                        {
                            CGSize shadowOffset = weakSelf.transView.layer.shadowOffset;
                            shadowOffset.width -= touchView.changePoint.x;
                            shadowOffset.height -= touchView.changePoint.y;
                            weakSelf.shadowOffset = shadowOffset;
                        };
                        break;
                    }
                    case MysticSettingLayerEmboss:
                    {
                        self.touchView.touchMoved = ^(NSSet *touches, UIEvent *event, MysticTouchView *touchView)
                        {
                            CGSize embossSize = CGSizeIsUnknown(weakSelf.choice.embossSize) ? CGSizeZero : weakSelf.choice.embossSize;
                            CGSize embossDarkSize = CGSizeIsUnknown(weakSelf.choice.embossDarkSize) ? (CGSize){-embossSize.width, embossSize.height} : weakSelf.choice.embossDarkSize;
                            CGSize _embossSize = embossSize;
                            CGSize _embossDarkSize = embossDarkSize;
                            CGSize emb = embossSize;
                            embossSize.width -= touchView.changePoint.x;
                            embossSize.height -= touchView.changePoint.y;
                            embossDarkSize.width = embossDarkSize.width-touchView.changePoint.x;
                            embossDarkSize.height = embossDarkSize.height-touchView.changePoint.y;
                            [weakSelf.choice effect:MysticChoiceEmboss changed:!CGSizeEqual(embossSize, weakSelf.choice.embossSize)];
                            [weakSelf.choice effect:MysticChoiceEmboss changed:!CGSizeEqual(embossDarkSize, weakSelf.choice.embossDarkSize)];
                            weakSelf.choice.embossSizeChange = CGSizeMake(touchView.totalChangePoint.x, touchView.totalChangePoint.y);
                            weakSelf.choice.embossSize = embossSize;
                            weakSelf.choice.embossDarkSize = embossDarkSize;
                            [weakSelf updateViews];
                        };
                    
                        break;
                    }
                    case MysticSettingLayerBevel:
                    {
                        self.touchView.touchMoved = ^(NSSet *touches, UIEvent *event, MysticTouchView *touchView)
                        {
                            float bevelAngle = weakSelf.choice.bevelAngle;
                            bevelAngle = CGPointAngle(touchView.startPoint, touchView.endPoint);
                            [weakSelf.choice effect:MysticChoiceBevel changed:weakSelf.choice.bevelAngle != -bevelAngle];

                            weakSelf.choice.bevelAngle = -radianToDegrees(bevelAngle);
                            [weakSelf updateViews];
                        };
                        break;
                    }
                    case MysticSettingLayerInnerBevel:
                    {
                        self.touchView.touchMoved = ^(NSSet *touches, UIEvent *event, MysticTouchView *touchView)
                        {
                            float bevelAngle = weakSelf.choice.innerBevelAngle;
                            bevelAngle = CGPointAngle(touchView.startPoint, touchView.endPoint);
                            [weakSelf.choice effect:MysticChoiceInnerBevel changed:weakSelf.choice.innerBevelAngle != -bevelAngle];

                            weakSelf.choice.innerBevelAngle = -radianToDegrees(bevelAngle);
                            [weakSelf updateViews];
                        };
                        break;
                    }
                    case MysticSettingLayerExtrude:
                    {
                        self.touchView.touchMoved = ^(NSSet *touches, UIEvent *event, MysticTouchView *touchView)
                        {
                            float bevelAngle = weakSelf.choice.extrudeAngle;
                            bevelAngle = CGPointAngle(touchView.startPoint, touchView.endPoint);
                            [weakSelf.choice effect:MysticChoiceExtrude changed:weakSelf.choice.extrudeAngle != -bevelAngle];
                            weakSelf.choice.extrudeAngle = -radianToDegrees(bevelAngle);
                            [weakSelf updateViews];
                        };
                        break;
                    }
                    case MysticSettingLayerInnerShadow:
                    {
                        self.touchView.touchMoved = ^(NSSet *touches, UIEvent *event, MysticTouchView *touchView)
                        {
                            CGSize shadowOffset = weakSelf.choice.innerShadowSize;
                            shadowOffset.width -= touchView.changePoint.x;
                            shadowOffset.height -= touchView.changePoint.y;
                            [weakSelf.choice effect:MysticChoiceInnerShadow changed:!CGSizeEqual(shadowOffset, weakSelf.choice.innerShadowSize)];
                            weakSelf.choice.innerShadowSize = shadowOffset;
                            [weakSelf updateViews];
                        };
                        break;
                    }
                    default:
                    {
                        self.touchView.touchMoved = nil; break;
                    }
                }
                [self fadeOutBgColor:YES sender:nil];
            });
            break;
        }
            
#pragma mark - InputView - Color
        case MysticIconTypeToolFontColor:
        case MysticIconTypeToolColor:
        {
            chipFrame = CGRectInsets(inputView.frame, 15);
            __block MysticColorsScrollView *colors = [[MysticColorsScrollView alloc] initWithFrame:CGRectS(chipFrame, CGSizeWithHeight(chipFrame.size, 32))];
            colors.controlDelegate = self;
            colors.showsControlAccessory = NO;
            NSArray *theColors = [[Mystic core] colorsForOption:self.option option:MysticOptionColorTypeForeground setting:MysticSettingFontColor];
            for (PackPotionOptionColor *c in theColors) {
                c.selectedSize = (CGSize){29,29};
                c.unselectedSize = (CGSize){20,20};
                c.borderWidth = 4;
            }
            [colors loadControls:theColors selectIndex:MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX animated:NO complete:^{
                EffectControl *selectedControl = (EffectControl *)colors.selectedItem;
                if(selectedControl) [selectedControl.effect updateLabel:nil control:selectedControl selected:YES];
                else for (EffectControl *ec in colors.subviews) [ec.effect updateLabel:nil control:ec selected:NO];
            }];
            colors.showsHorizontalScrollIndicator=NO;
            colors.showsVerticalScrollIndicator=NO;
            colors.directionalLockEnabled = YES;
            [inputView addSubview:colors];
            chipFrame.origin.y += kColorPickerSpacing + colors.frame.size.height;
            chipFrame.size.height = (CGRectH(inputView.frame) - 45) - chipFrame.origin.y ;
            mdispatch(^{

                ILColorPickerView *picker = [[ILColorPickerView alloc] initWithFrame:chipFrame];
                picker.backgroundColor = inputView.backgroundColor;
                picker.delegate = (id <ILPickerDelegate>)self;
                picker.color = self.choice.color;
                [picker setNeedsDisplay];
                [inputView addSubview:picker];
                self.colorPicker = [picker autorelease];
                
                [self fadeOutBgColor:YES sender:nil];
                [colors release];
                
                slider = [MysticSlider sliderWithFrame:(CGRect){50,CGRectH(inputView.frame) - 45,sliderWidth+30, 45}];
                slider.tag = 103;
                [slider addTarget:self action:@selector(opacitySliderChanged:) forControlEvents:UIControlEventValueChanged];
                [slider addTarget:self action:@selector(sliderBegin:) forControlEvents:UIControlEventEditingDidBegin];
                [slider addTarget:self action:@selector(sliderEnd:) forControlEvents:UIControlEventEditingDidEnd];
                
                slider.minimumValue = 0;
                slider.maximumValue = 1;
                slider.lowerHandleHidden = YES;
                slider.defaultValue = 1;
                slider.value = self.colorAlpha;
                slider.lowerValue = 0;
                slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
                slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                [inputView addSubview:slider];
                self.opacitySlider = slider;
                
                sliderLeftView = [[SubBarButton alloc] initWithFrame:(CGRect){15, slider.center.y - CGRectH(sliderLabelFrame)/2, 20,CGRectH(sliderLabelFrame)} showTitle:NO];
                sliderLeftView.tag = 123;
                sliderLeftView.enabled = NO;
                sliderLeftView.imageEdgeInsets = UIEdgeInsetsMakeFrom(0);
                sliderLeftView.imageView.contentMode = UIViewContentModeCenter;
                [sliderLeftView setImage:[MysticImage image:@(MysticIconTypeIntensity) size:(CGSize){15,15} color:@(MysticColorTypeInputAccessoryIconSelected)] forState:UIControlStateDisabled];
                [inputView addSubview:[sliderLeftView autorelease]];
                
                sliderLabel = [[UILabel alloc] initWithFrame:CGRectY(sliderLabelFrame, slider.center.y - CGRectH(sliderLabelFrame)/2)];
                sliderLabel.tag = 1233;
                sliderLabel.font = [MysticFont fontBold:11];
                sliderLabel.userInteractionEnabled = NO;
                sliderLabel.textAlignment = NSTextAlignmentLeft;
                sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                [inputView addSubview:[sliderLabel autorelease]];
                sliderLabel.text = [NSString stringWithFormat:@"%2.0f%%", self.opacitySlider.value*100];
                
            });
            
            break;
        }
            
#pragma mark - InputView - MysticIconTypeToolContent

        case MysticIconTypeToolContent:
        {
            CGRect scrollFrame = inputView.bounds;
            scrollFrame.origin.y = 0;
            MysticChoicesScrollView *scrollView = [[MysticChoicesScrollView alloc] initWithFrame:scrollFrame];
            scrollView.showsHorizontalScrollIndicator=NO;
            scrollView.showsVerticalScrollIndicator=NO;
            scrollView.directionalLockEnabled = YES;
            scrollView.backgroundColor = inputView.backgroundColor;
            scrollView.cacheControlEnabled = YES;
            scrollView.layoutStyle = MysticLayoutStyleGrid;
            scrollView.scrollDirection = MysticScrollDirectionVertical;
            scrollView.bufferItemsPerRow = 0;
            scrollView.contentInset = UIEdgeInsetsMake(-MYSTIC_UI_PANEL_BORDER, 0, 0, 0);
            scrollView.tileSize = (CGSize){scrollFrame.size.width/(float)MYSTIC_CHOICES_SCROLLVIEW_COLUMNS, (scrollFrame.size.height/(roundf(scrollFrame.size.height/(scrollFrame.size.width/(float)MYSTIC_CHOICES_SCROLLVIEW_COLUMNS))))};
            scrollView.gridSize = (MysticTableLayout){(int)(ceilf(scrollFrame.size.height/scrollView.tileSize.height)), MYSTIC_CHOICES_SCROLLVIEW_COLUMNS};
            scrollView.shouldSelectControlBlock = (^BOOL(MysticChoice *choiceControl){
                return weakSelf.content && [weakSelf.choice.name isEqualToString:choiceControl.name];
            });
            self.choicesScrollView = [scrollView autorelease];
            MysticPacksScrollView *packsScrollView = [[MysticPacksScrollView alloc] initWithFrame:CGRectMake(0, -MYSTIC_UI_PANEL_BORDER, CGRectW(inputView.frame), 50)];
            packsScrollView.tag = MysticViewTypeScrollView2 + MysticViewTypePanel;
            packsScrollView.autoresizesSubviews = YES;
            packsScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            packsScrollView.showsHorizontalScrollIndicator = NO;
            packsScrollView.showsVerticalScrollIndicator = NO;
            packsScrollView.controlDelegate = self;
            packsScrollView.margin = 20;
            packsScrollView.viewClass = [MysticCategoryButton class];
            packsScrollView.scrollDirection = MysticScrollDirectionHorizontal;
            self.packsScrollView = [packsScrollView autorelease];
            self.choicesScrollView.tileOrigin = (CGPoint){0,self.packsScrollView.frame.size.height};
            UIView *bgView = [[UIView alloc] initWithFrame:(CGRect){0, self.choicesScrollView.tileOrigin.y - self.choicesScrollView.frame.size.height/2, self.choicesScrollView.frame.size.width, self.choicesScrollView.frame.size.height/2}];
            bgView.backgroundColor = [UIColor hex:@"3F3834"];
            [self.choicesScrollView addSubview:[bgView autorelease]];
            [self.choicesScrollView addSubview:self.packsScrollView];
            self.choicesScrollView.extraContentSize = (CGSize){0,self.packsScrollView.frame.size.height};
            [inputView addSubview:self.choicesScrollView];
            
            // setup pack category buttons
            CGRect lastCategoryFrame = (CGRect){self.packsScrollView.margin,0,0,0};
            __block NSInteger x = 0;
            __block int tag = 1;
            __unsafe_unretained __block MysticLayerEditViewController *weakSelf = self;
            NSArray *packs = [MysticOptionsDataSourceShapes packs];
            __block MysticCategoryButton *lastCategoryButton = nil, *selectedCategoryBtn = nil;
            for (int i = 0; i < packs.count; i++) {
                MysticPack *pack = [packs objectAtIndex:i];
                MysticCategoryButton *categoryBtn = [MysticCategoryButton buttonWithTitle:pack.title target:self sel:@selector(packButtonTouched:)];
                categoryBtn.pack = pack;
                lastCategoryFrame.size = categoryBtn.frame.size;
                lastCategoryFrame.size.height = packsScrollView.frame.size.height;
                categoryBtn.frame = lastCategoryFrame;
                categoryBtn.tag = packsScrollView.tag + tag;
                lastCategoryButton = categoryBtn;
                lastCategoryFrame.origin.x += categoryBtn.frame.size.width + self.packsScrollView.margin;
                if((!self.pack && !selectedCategoryBtn) || (!selectedCategoryBtn && self.pack && [pack.title isEqualToString:self.pack.title])) selectedCategoryBtn = categoryBtn;
                [self.packsScrollView addSubview:categoryBtn];
                tag++;
                if(i == packs.count-1)
                {
                    self.packsScrollView.contentSize = (CGSize){lastCategoryFrame.origin.x, self.packsScrollView.frame.size.height};
                    weakSelf.choicesScrollView.contentOffset = (CGPoint){0, weakSelf.choicesScrollView.tileOrigin.y};
                    if(selectedCategoryBtn) [weakSelf packButtonTouched:selectedCategoryBtn];
                    weakSelf.choicesScrollView.contentOffset = (CGPoint){0, weakSelf.choicesScrollView.tileOrigin.y};
                }
            }
            mdispatch(^{
                
            
                [self.choicesScrollView scrollViewDidScroll:self.choicesScrollView];
                [self fadeInBgColor:YES sender:nil];
            });
            break;
        }
            
#pragma mark - InputView - MysticIconTypeToolEffects

        case MysticIconTypeToolEffects:
        {
            inputView.backgroundColor = [UIColor hex:@"201F1F"];
            [self fadeInBgColor:YES sender:nil];
            MysticBorderView *border = [[MysticBorderView alloc] initWithFrame:CGRectSize(inputView.frame.size)];
            border.borderPosition = MysticPositionThirdsHorizontal;
            border.borderColor = [inputView.backgroundColor lighter:0.05];
            border.borderWidth = 1;
            border.dashSize = (CGSize){border.borderWidth, 5};
            border.borderColor = [UIColor hex:@"473F3C"];
            border.dashed = YES;
            border.showBorder = YES;
            [inputView insertSubview:border atIndex:0];
            
            slider = [MysticSlider sliderWithFrame:(CGRect){80,h*2,sliderWidth, h}];
            slider.tag = 103;
            [slider addTarget:self action:@selector(opacitySliderChanged:) forControlEvents:UIControlEventValueChanged];
            [slider addTarget:self action:@selector(sliderBegin:) forControlEvents:UIControlEventEditingDidBegin];
            [slider addTarget:self action:@selector(sliderEnd:) forControlEvents:UIControlEventEditingDidEnd];
            slider.minimumValue = 0;
            slider.maximumValue = 1;
            slider.lowerHandleHidden = YES;
            slider.defaultValue = 1;
            slider.value = self.colorAlpha;
            slider.lowerValue = 0;
            slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
            slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
            [inputView addSubview:slider];
            self.opacitySlider = slider;
            
            sliderLeftView = [[SubBarButton alloc] initWithFrame:(CGRect){15, (h*2)+((h-35)/2), 50,35} showTitle:YES];
            sliderLeftView.tag = 123;
            sliderLeftView.enabled = NO;
            sliderLeftView.titleIconSpacing = titleSpacing;
            sliderLeftView.imageEdgeInsets = UIEdgeInsetsMakeFrom(0);
            sliderLeftView.imageView.contentMode = UIViewContentModeCenter;
            [sliderLeftView setImage:[MysticImage image:@(MysticIconTypeIntensity) size:(CGSize){18,18} color:@(MysticColorTypeInputAccessoryIconSelected)] forState:UIControlStateDisabled];
            sliderLeftView.titleLabel.font = [[[sliderLeftView class] labelFont] fontWithSize:8];
            [sliderLeftView setTitle:@"OPACITY" forState:UIControlStateDisabled];
            [inputView addSubview:[sliderLeftView autorelease]];
            
            sliderLabel = [[UILabel alloc] initWithFrame:CGRectY(sliderLabelFrame, (h*2)+sliderLabelY)];
            sliderLabel.tag = 1233;
            sliderLabel.userInteractionEnabled = NO;
            sliderLabel.font = [MysticFont fontBold:11];
            sliderLabel.textAlignment = NSTextAlignmentCenter;
            sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
            [inputView addSubview:[sliderLabel autorelease]];
            mdispatch(^{

                [weakSelf opacitySliderChanged:slider];
            });
            break;
        }
        default: break;
    }
    settingUpInput = NO;
    return inputView;
}
#pragma mark - ScrollView Delegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    self.stopAutoScroll = YES;
    scrollView.contentOffset = scrollView.contentOffset;
    [self updateToolbarNipple:self.subToolbar.selectedButton updateOffset:NO];
}
- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
{
    CGPoint targetOffset = (CGPoint){targetContentOffset->x,targetContentOffset->y};
    if(!(CGPointIsZero(targetOffset) || targetContentOffset->y == [(MysticInputScrollView *)scrollView offsetAnchor].y || CGPointEqual([(MysticInputScrollView *)scrollView offsetZero], targetOffset)))
    {
        [self.userInfo setObject:[NSValue point:*targetContentOffset] forKey:[NSString format:@"%d-%d-lastOffset", (int)self.previousSetting, (int)self.previousSubSetting]];
    }
}

#pragma mark - Done

- (void) toolbarDone:(id)sender;
{
    [self doneTouched:sender];
}
- (IBAction)doneTouched:(UIButton *)sender
{

    self.contentSizeChangeScale = CGScaleOfSizes(self.endSize, self.startSize).size;
    if(self.option)
    {
        self.option.color = self.choice.colorOrDefault;
        self.option.intensity = self.choice.alpha;
    }
    [self.delegate layerEditViewController:self didChooseContent:self.content];
}

#pragma mark - Keyboard Notifications
- (void) keyboardWillShow:(NSNotification *)n;
{
    MysticKeyboardInfo k = MysticKeyboardNotification(n);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
- (void) keyboardDidShow:(NSNotification *)n;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}
- (void) keyboardDidHide:(NSNotification *)n;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}
- (void) keyboardWillHide:(NSNotification *)n;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    if(!self.switchingKeyboard) return;
    MysticKeyboardInfo userInfo = MysticKeyboardNotification(n);
    [UIView beginAnimations:@"kwh" context:nil];
    [UIView setAnimationCurve:userInfo.curve];
    [UIView setAnimationDuration:userInfo.time];
    [self fadeOutBgColor:NO sender:nil];
    [UIView commitAnimations];
}

#pragma mark - Present In View

- (void) presentInView:(UIView *)inView fromView:(MysticLayerBaseView *)fv;
{
    __unsafe_unretained __block MysticLayerEditViewController *ws = self;
    self.presentView = [[UIView alloc] initWithFrame:inView.frame];
    self.presentView.userInteractionEnabled = YES;
    self.clipView = [[[UIView alloc] initWithFrame:[inView convertRect:[MysticController controller].imageView.imageView.frame fromView:[MysticController controller].imageView]] autorelease];
    self.clipView.clipsToBounds = YES;
    self.originalClipViewFrame = self.clipView.bounds;
    self.transView = [[[MysticTransView alloc] initWithFrame:CGRectz(self.layerView.contentView.frame)] autorelease];
    self.transView.contentView.frame = self.transView.frame;
    self.choice.frame = self.transView.contentView.bounds;
    self.transView.transform = CGAffineTransformScaleSize(CGAffineTransformIdentity, [MysticController controller].imageView.transformSize);
    self.transView.alpha = self.colorAlpha;
    self.transView.hidden = YES;
    self.hiddenTextField = [[[MysticHiddenTextField alloc] initWithFrame:CGRectMake(-1000, 0, 10, 10)] autorelease];
    self.hiddenTextField.inputAccessoryView = [self makeInputAccessoryView];
    [self.presentView addSubview:self.hiddenTextField];
    [self.clipView addSubview:self.transView];
    [self.presentView addSubview:self.clipView];
    [inView addSubview:self.presentView];

    self.touchView = [[[MysticTouchView alloc] initWithFrame:self.presentView.bounds] autorelease];
    self.touchView.tap = ^(UITouch *t, UIEvent *e, MysticTouchView *v){[ws toggleFadeBgColor:YES sender:t]; };
    [self.presentView addSubview:self.touchView];
    _setupPresentView = YES;
    self.originalTransform = CGAffineTransformRotateReset(self.transView.transform);
    self.transitionScale = CGScaleOfRects(CGRectFit(self.transView.frame, UIEdgeInsetsInsetRect(self.originalClipViewFrame, self.layerView.layersView.maxLayerInsets)), self.transView.frame);

    CGAffineTransform transform = CGScaleTransform(self.transView.transform, CGScaleInverseSize([MysticController controller].imageView.transformSize));
    CGAffineTransform newTransform = CGScaleTransform(transform, self.transitionScale);

    self.transView.frameAndCenter = CGRectz(CGRectTransform(self.transView.frame, transform));
    [self.choice resetScale:CGScaleInverse(CGScaleFromTransform(newTransform))];
    [self.choice updateView:self.transView];
    [self.transView updateLayout:YES];
    self.endSize = [self.transView resizeToSmallestSubview].size;
    [self.transView updateLayout:YES];
    self.transView.shouldUpdateContent = YES;
    self.startSize = CGRectTransform(CGRectSize(self.endSize), self.originalTransform).size;
    self.transView.center = [self.transView.superview convertPoint:self.layerView.transView.center fromView:self.layerView.transView.superview];
    self.transView.transform = CGAffineTransformConcat(self.layerView.transform, transform);
    
    self.lastResponder = [self.hiddenTextField becomeFirstResponder] ? self.hiddenTextField : nil;
    switch (self.setting) {
        case MysticSettingLayerColor: [self toolbarColor:nil]; break;
        case MysticSettingLayerShadow: [self toolbarShadow:nil]; break;
        case MysticSettingLayerEffect: [self toolbarEffects:nil]; break;
        default: [self toolbarContent:nil]; break;
    }

    self.transView.hidden = NO;
    self.layerView.hidden = YES;
    
#pragma mark - Start Transition
    

    CGPoint mc = CGPointDiff(CGPointCenter(self.previewFrame),[self.presentView convertPoint:self.clipView.center fromView:self.clipView.superview]);
    CGRect newClipFrame = CGRectz(CGRectTransform(CGRectHeight(self.previewFrame, MAX(CGRectH(self.transView.frame) * 1.1, self.clipView.frame.size.height)), CGAffineTransformMakeTranslation(0, mc.y)));
    CGPoint c = CGPointAdd(self.transView.center, CGPointDiff(CGPointCenter(newClipFrame),self.transView.center));
    
    [MysticUIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if(ws.animationIn) ws.animationIn(), ws.animationIn=nil;
        ws.transView.center = c;
        ws.transView.transform = newTransform;
        ws.clipView.bounds = newClipFrame;
        ws.clipView.transform = CGAffineTransformMakeTranslation(0, mc.y);
        [ws fadeInBgColor:NO sender:nil];
    } completion:^(BOOL f) {
        CGPoint p = CGPointMid(ws.transView.frame);
        ws.transView.transform = CGAffineTransformTranslateReset(ws.transView.transform);
        ws.transView.center = p;
        [ws.choice resetScale];
    }];
}


#pragma mark - Dismiss

- (void) dismissToView:(MysticLayerBaseView *)fromView animations:(MysticBlockAnimationInfo)animations complete:(MysticBlockBOOL)finished;
{
    __unsafe_unretained __block MysticLayerEditViewController *ws = self;
    CGScaleOfView t = [self.choice scaleOfView:fromView fromView:self.transView];
    if(!CGAffineTransformHasRotation(t.transform) && self.layerView.rotation!=0)  t.transform = CGAffineTransformRotate(t.transform, self.layerView.rotation);
    __unsafe_unretained __block MysticBlockBOOL _finished = finished ? Block_copy(finished) : nil;
    [MysticUIView animateWithDuration:.25 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        animations();
        if(ws.animationOut) ws.animationOut(), ws.animationOut=nil;
        [ws fadeOutBgColor:NO sender:@YES];
        ws.transView.transform = t.transform;
        ws.transView.center = t.offset;
        if(ws.clipView)
        {
            ws.clipView.transform = CGAffineTransformIdentity;
            ws.clipView.bounds = ws.originalClipViewFrame;
        }
    } completion:^(BOOL f) {
        [[NSNotificationCenter defaultCenter] removeObserver:ws];
        if(ws.transView) [ws.transView removeFromSuperview];
        if(ws.clipView) [ws.clipView removeFromSuperview];
        [ws.presentView removeFromSuperview];
        if(_finished) { _finished(f); Block_release(_finished); }
    }];
}




#pragma mark - Make Input Accessory View

- (UIView *) makeInputAccessoryView;
{
    if(self.toolbar) return self.toolbar.superview;
    MysticLayerToolbar *toolbar = [MysticLayerToolbar toolbarWithDelegate:self height:MYSTIC_UI_TOOLBAR_ACCESSORY_HEIGHT];
    CGSize toolbarIconSize = (CGSize){35,35};
    MysticBlockButtonItem confirmBlock = (^MysticButton *(MysticButton *button, MysticBarButtonItem *item){
//        item.width = 60;
        return button;
    });
    
    MysticBlockObj *b = [[MysticBlockObj alloc] init];
    b.buttonBlock = confirmBlock;
    [toolbar useItems:@[
                        @{@"toolType": @(MysticToolTypeStatic), @"width":@(-10) },
                        
                        @{@"toolType": @(MysticToolTypeContent),
                          @"target": self,
                          @"action": @"toolbarContent:",
                          @"iconType":@(MysticIconTypeToolContent),
                          @"eventAdded": @YES,
                          @"selected": _setting == MysticSettingLayerContent || _setting==MysticObjectTypeUnknown ? @YES : @NO,
                          @"color":@(MysticColorTypeInputAccessoryIcon),
                          @"colorHighlighted":@(MysticColorTypeInputAccessoryIconHighlighted),
                          @"colorSelected":@(MysticColorTypeInputAccessoryIconSelected),
                          @"contentMode": @(UIViewContentModeCenter),
                          @"iconSize": [NSValue valueWithCGSize:(CGSize){18,15}],
                          @"objectType":@(self.option.type)},
                        
                        @(MysticToolTypeFlexible),
                        
                        @{@"toolType": @(MysticToolTypeColor),
                          @"target": self,
                          @"action": @"toolbarColor:",
                          @"iconType":@(MysticIconTypeLayerColor),
                          @"eventAdded": @YES,
                          @"selected": _setting == MysticSettingLayerColor  ? @YES : @NO,
                          @"color":@(MysticColorTypeNone),
                          @"colorHighlighted":@(MysticColorTypeInputAccessoryIconHighlighted),
                          @"colorSelected":@(MysticColorTypeInputAccessoryIconSelected),
                          @"colorDisabled":@(MysticColorTypeInputAccessoryIconDisabled),
                          @"contentMode": @(UIViewContentModeCenter),
                          @"iconSize": [NSValue valueWithCGSize:(CGSize){15,15}],
                          @"objectType":@(self.option.type)},
                        
                        @(MysticToolTypeFlexible),
                        
                        @{@"toolType": @(MysticToolTypeLayerShadow),
                          @"target": self,
                          @"action": @"toolbarShadow:",
                          @"iconType":@(MysticIconTypeToolShadowAndBorder),
                          @"eventAdded": @YES,
                          @"selected": _setting == MysticSettingLayerShadow  ? @YES : @NO,
                          @"color":@(MysticColorTypeInputAccessoryIcon),
                          @"colorHighlighted":@(MysticColorTypeInputAccessoryIconHighlighted),
                          @"colorSelected":@(MysticColorTypeInputAccessoryIconSelected),
                          @"contentMode": @(UIViewContentModeCenter),
                          @"iconSize": [NSValue valueWithCGSize:(CGSize){23,18}],
                          @"objectType":@(self.option.type)},

                        @(MysticToolTypeFlexible),
                        
                        @{@"toolType": @(MysticToolTypeConfirm),
                          @"target": self,
                          @"action": @"toolbarDone:",
                          @"iconType":@(MysticIconTypeConfirmFat),
                          @"eventAdded": @YES,
                          @"colorHighlighted": @(MysticColorTypeInputAccessoryIconSelected),
                          @"color":@(MysticColorTypeInputAccessoryIconHighlighted),
                          @"block": [[confirmBlock copy] autorelease],
                          @"contentMode": @(UIViewContentModeCenter),
                          @"iconSize": [NSValue valueWithCGSize:(CGSize){18,14}],
                          @"width":@(60),
                          @"objectType":@(self.option.type)},
                        
                        
                        @{@"toolType": @(MysticToolTypeStatic), @"width":@(-17) },
                        ]];
    toolbar.backgroundColor = [UIColor hex:@"141412"];
    toolbar.opaque = YES;
    
    
    MysticBorderView *bview = [[MysticBorderView alloc] initWithFrame:(CGRect){0,0,toolbar.frame.size.width, toolbar.frame.size.height+(MYSTIC_UI_PANEL_BORDER*2)}];
    bview.borderPosition = MysticPositionBottom;
    bview.borderWidth = MYSTIC_UI_PANEL_BORDER*2;
    bview.borderInsets = UIEdgeInsetsMake(0, 0, -bview.borderWidth/2, 0);
    bview.borderColor = [UIColor hex:@"3F3834"];
    bview.showBorder = YES;
    bview.autoresizesSubviews = NO;
    [bview addSubview:toolbar];
    self.nippleView = [[[MysticNippleView alloc] initWithFrame:(CGRect){0,0,20,10} image:@(MysticIconTypeNippleTop) color:bview.borderColor] autorelease];
    self.nippleView.frame = CGRectX(CGRectAlign(self.nippleView.frame, bview.frame, MysticAlignTypeBottom), 21);
    [bview addSubview:self.nippleView];
    bview.frame = CGRectAlign(bview.frame, self.presentView.bounds, MysticAlignPositionBottom);
    _nipplePoint = self.nippleView.center;
    self.toolbar = toolbar;
    return [bview autorelease];
}
- (CGRect) inputFrame;
{
    return  CGRectWidthHeight(CGRectZero, self.previewFrame.size.width, self.keyboardRect.size.height + (self.hiddenTextField && self.hiddenTextField.inputAccessoryView ? self.hiddenTextField.inputAccessoryView.frame.size.height :  MYSTIC_UI_TOOLBAR_ACCESSORY_HEIGHT + MYSTIC_UI_PANEL_BORDER*2));
}
#pragma mark - Fade Bg Color
- (BOOL) toggleFadeBgColor:(BOOL)animated sender:(id)sender;
{
    BOOL ut = self.userTappedBg;
    if(sender) self.userTappedBg = NO;
    if(self.presentView.backgroundColor.alpha) [self fadeOutBgColor:animated sender:sender]; else [self fadeInBgColor:animated sender:sender];
    if(sender) self.userTappedBg = !ut;
    return self.presentView.backgroundColor.alpha == 0;
}

- (void) fadeOutBgColor:(BOOL)animated sender:(id)sender;
{
    if(self.presentView.backgroundColor.alpha == 0 || self.userTappedBg) return;
    if(animated)
    {
        [MysticUIView animateWithDuration:0.2 animations:^{
            self.toolbar.backgroundColor = [UIColor hex:@"141412"];
            self.presentView.backgroundColor= [[UIColor hex:@"161614"] alpha:0];
        }];
    }
    else
    {
        self.toolbar.backgroundColor = [UIColor hex:@"141412"];
        self.presentView.backgroundColor= [[UIColor hex:@"161614"] alpha:0];
    }
}
- (void) fadeInBgColor:(BOOL)animated sender:(id)sender;
{
    if(self.presentView.backgroundColor.alpha == 0.9 || self.userTappedBg) return;
    if(animated)
    {
        [MysticUIView animateWithDuration:0.2 animations:^{
            self.toolbar.backgroundColor = [UIColor hex:@"161613"];
            self.presentView.backgroundColor= [[UIColor hex:@"161614"] alpha:0.9];
        }];
    }
    else
    {
        self.toolbar.backgroundColor = [UIColor hex:@"161613"];
        self.presentView.backgroundColor= [[UIColor hex:@"161614"] alpha:0.9];
    }
}

- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;
{
    
}
- (void) effectControlDidTouchUp:(UIControl *)effectControl effect:(MysticControlObject *)effect;
{
    self.stopAutoScroll = YES;
    PackPotionOptionColor*color = (id)effect;
    self.colorPicker.color = color.color;
    [self colorPicked:color.color forPicker:(id)effectControl];
    [(MysticScrollView *)effectControl.superview centerOnView:effectControl animate:YES complete:nil];
}

#pragma mark - Color Picked

-(void)colorPicked:(UIColor *)color forPicker:(ILColorPickerView *)picker;
{
    self.stopAutoScroll = YES;
    if(settingUpInput) return;

    int colorType = picker && ![picker isKindOfClass:[ILColorPickerView class]] ? picker.superview.tag : 0;
    switch (self.setting)
    {
        case MysticSettingLayerColor:
        case MysticSettingFontColor:
        {
            [self.choice effect:MysticChoiceFill changed:![color isEqualToColor:self.choice.color]];
            self.color = color;
            [self updateViews];
            break;
        }
        case MysticSettingLayerShadow:
        {
            switch (self.subSetting) {
                case MysticSettingLayerShadow:
                {
                    [self.choice effect:MysticChoiceShadow changed:![color isEqualToColor:self.choice.shadowColor]];
                    self.choice.shadowColor= color;
                    [self updateViews];
                    break;
                }
                case MysticSettingLayerBorder:
                {
                    self.choice.borderAlpha = isnan(self.choice.borderAlphaValue) ? self.opacitySlider ? self.opacitySlider.value : 0 : self.choice.borderAlphaValue;
                    [self.choice effect:MysticChoiceBorder changed:![color isEqualToColor:[self.choice.borderColorOrDefault opaque]]];
                    self.choice.borderColor = color;
                    [self updateViews];
                    break;
                }
                case MysticSettingLayerBevel:
                {
                    switch (colorType) {
                        case MysticViewTypeScrollView2:
                        {
                            float a = self.choice.bevelColor ? self.choice.bevelColor.alpha : 1;
                            [self.choice effect:MysticChoiceBevel changed:!self.choice.bevelColor || ![[color alpha:a] isEqualToColor:self.choice.bevelColor]];
                            self.choice.bevelColor = [color alpha:a];
                            [self updateViews];
                            break;
                        }
                        default:
                        {
                            float a1 = self.choice.bevelColor ? self.choice.bevelColor.alpha : 1;
                            float a = self.choice.bevelShadowColor ? self.choice.bevelShadowColor.alpha : a1;
                            [self.choice effect:MysticChoiceBevel changed:!self.choice.bevelShadowColor || ![[color alpha:a] isEqualToColor:self.choice.bevelShadowColor]];
                            self.choice.bevelShadowColor = [color alpha:a];
                            [self updateViews];
                            break;
                        }
                    }
                    break;
                }
                case MysticSettingLayerEmboss:
                {
                    switch (colorType) {
                        case MysticViewTypeScrollView2:
                        {
                            float a1 = self.choice.embossColor ? self.choice.embossColor.alpha : 1;
                            float a = self.choice.embossDarkColor ? self.choice.embossDarkColor.alpha : a1;
                            [self.choice effect:MysticChoiceEmboss changed:!self.choice.embossDarkColor || ![[color alpha:a] isEqualToColor:self.choice.embossDarkColor]];
                            self.choice.embossDarkColor = [color alpha:a];
                            [self updateViews];
                            break;
                        }
                            
                        default:
                        {
                            float a = self.choice.embossColor ? self.choice.embossColor.alpha : 1;
                            [self.choice effect:MysticChoiceEmboss changed:!self.choice.embossColor || ![[color alpha:a] isEqualToColor:self.choice.embossColor]];
                            self.choice.embossColor = [color alpha:a];
                            [self updateViews];
                            break;
                        }
                    }
                    break;
                }
                default: break;
            }
            break;
        }
        default: break;
    }
}
#pragma mark - Opacity & Opacity Slider


- (void) sliderBegin:(MysticSlider *)slider;
{
    self.stopAutoScroll = YES;
    [self fadeOutBgColor:YES sender:nil];
    
}
- (void) opacitySliderChanged:(MysticSlider *)slider;
{
    self.stopAutoScroll = YES;
    UILabel *sliderLabel = (id)[slider.superview viewWithTag:1233];
    if(sliderLabel) sliderLabel.text = [NSString stringWithFormat:@"%2.0f%%", slider.value*100];
    self.colorAlpha = slider.value;
}
- (void) sliderEnd:(MysticSlider *)slider;
{
    [self fadeInBgColor:YES sender:nil];
}
- (void) sliderEditingDidEnd:(MysticSlider *)slider;
{
    [self updateViews];
}

- (void) setColorAlpha:(float)colorAlpha;
{
    _colorAlpha = colorAlpha;
    [self.choice effect:MysticChoiceFill changed:colorAlpha != self.choice.alpha];
    self.choice.alpha = colorAlpha;
    if(self.updateContent) [self updateViews];
    
}


#pragma mark - Shadow
- (void) setColor:(UIColor *)value;
{
    if(_color && value && ([_color isEqual:value] || [_color isEqualToColor:value])) return;
    if(_color) [_color release], _color=nil;
    _color = value ? [value retain] : nil;
    [self.choice effect:MysticChoiceFill changed:![[value opaque] isEqualToColor:[self.choice.colorOrDefault opaque]]];
    self.option.color = [_color alpha:self.colorAlpha];
    if(self.updateContent) self.choice.color = _color;
}
- (void) widthSliderChanged:(MysticSlider *)slider;
{
    self.stopAutoScroll = YES;
    UILabel *sliderLabel = (id)[slider.superview viewWithTag:1232];
    if(sliderLabel) sliderLabel.text = [NSString stringWithFormat:@"%2.1f", slider.value];
    switch (self.subSetting) {
        case MysticSettingLayerBorder:
        {
            [self.choice effect:MysticChoiceBorder changed:slider.value != self.choice.borderWidth];
            [self.choice setBorderWidth:slider.value sender:slider];
            if(self.updateContent) { [self updateViews]; }

            break;
        }
        case MysticSettingLayerBevel:
        {
            [self.choice effect:MysticChoiceBevel changed:slider.value != self.choice.bevelRadius];
            [self.choice setBevelRadius:slider.value];
            if(self.updateContent) { [self updateViews]; }
            
            break;
        }
        case MysticSettingLayerEmboss:
        {
            [self.choice effect:MysticChoiceEmboss changed:slider.value != self.choice.embossRadius];
            [self.choice setEmbossRadius:slider.value];
            if(self.updateContent) { [self updateViews]; }
            
            break;
        }
        
            
        default: break;
    }
    
}
- (void) widthSliderEnded:(MysticSlider *)slider;
{
//    self.shouldResizeContent = YES;
//    [self updateViews:@[self.contentView] debug:nil];
}
- (void) alphaSliderChanged:(MysticSlider *)slider;
{
    self.stopAutoScroll = YES;

    UILabel *sliderLabel = (id)[slider.superview viewWithTag:1233];
    if(sliderLabel) sliderLabel.text = [NSString stringWithFormat:@"%2.0f%%", slider.value*100];
    switch (self.subSetting) {
        case MysticSettingLayerBorder:
        {
            [self.choice effect:MysticChoiceBorder changed:slider.value != self.choice.borderAlpha];
            self.choice.borderAlpha = slider.value;
            [self updateViews];

            break;
        }
        case MysticSettingLayerShadow:
        {
            [self.choice effect:MysticChoiceShadow changed:slider.value != self.choice.shadowAlpha];
            self.shadowAlpha = slider.value;
            [self updateViews];

            break;
        }
        case MysticSettingLayerBevel:
        {
            UIColor *theColor = [(UIColor *)(self.choice.bevelColor ? self.choice.bevelColor : [self.choice.color lighter:0.5]) alpha:slider.value];
            [self.choice effect:MysticChoiceBevel changed:!self.choice.bevelColor || ![theColor isEqualToColor:self.choice.bevelColor]];
            self.choice.bevelColor = [theColor alpha:slider.value];
            
            [self updateViews];

            break;
        }

            
        default: break;
    }
}
- (void) blurSliderChanged:(MysticSlider *)slider;
{
    self.stopAutoScroll = YES;

    UILabel *sliderLabel = (id)[slider.superview viewWithTag:1235];
    if(sliderLabel) sliderLabel.text = [NSString stringWithFormat:@"%2.1f", slider.value];
    switch (self.subSetting) {
        case MysticSettingLayerEmboss:
        {
            [self.choice effect:MysticChoiceEmboss changed:slider.value != self.choice.embossBlur];
            self.choice.embossBlur = slider.value;
            [self updateViews];
            
            break;
        }
        case MysticSettingLayerBevel:
        {
            [self.choice effect:MysticChoiceBevel changed:slider.value != self.choice.bevelBlur];
            self.choice.bevelBlur = slider.value;
            [self updateViews];
            
            break;
        }
        case MysticSettingLayerShadow:
        {
            [self.choice effect:MysticChoiceShadow changed:slider.value != self.choice.shadowRadius];
            self.choice.shadowRadius = slider.value;
            [self updateViews];
            break;
        }
            
        default: break;
    }
}
- (CGPathRef) shadowPath;
{
    return self.transView.layer.shadowPath;
}
- (void) setShadowColor:(UIColor *)shadowColor;
{
    if(_shadowColor && shadowColor && ([_shadowColor isEqual:shadowColor] || [_shadowColor isEqualToColor:shadowColor])) return;
    if(_shadowColor) [_shadowColor release], _shadowColor=nil;
    _shadowColor =  shadowColor ? [shadowColor retain] : nil;

    if(self.updateContent) { self.choice.shadowColor = _shadowColor;  [self updateViews]; }
}
- (void) setShadowAlpha:(float)shadowAlpha;
{
    _shadowAlpha = shadowAlpha;
    
    if(self.updateContent) { self.choice.shadowAlpha = shadowAlpha;  [self updateViews]; }
    
}
- (void) setShadowRadius:(float)shadowRadius;
{
    _shadowRadius = shadowRadius;
    if(self.updateContent) { self.choice.shadowRadius = shadowRadius; [self updateViews]; }
    
    
}
- (void) setShadowOffset:(CGSize)shadowOffset;
{
    _shadowOffset = shadowOffset;
    if(self.updateContent) {
        [self.choice effect:MysticChoiceShadow changed:!CGSizeEqual(shadowOffset, self.choice.shadowOffset)];
        self.choice.shadowOffset = shadowOffset;
        [self updateViews];
    }
}

- (void) setStartSize:(CGSize)startSize;
{
    _startSize = startSize;
    if(CGSizeIsUnknownOrZero(startSize))
    {
        int i = 0;
        
        i = 1;
    }
}
- (BOOL) updateContent;
{
    return settingUpInput ? NO : _updateContent;
}
- (UIView *) contentView; { return self.transView; }
- (void) updateViews;
{
    if(self.contentView) [self updateViews:@[self.contentView] debug:nil];
}
- (void) updateViews:(NSArray *)views debug:(id)debug;
{
    
    self.choice.bevel = @(!isnanOrZero(self.choice.bevelRadius) || !isnanOrZero(self.choice.bevelBlur));
    self.choice.emboss = @(!CGSizeIsUnknown(self.choice.embossSize) || !CGSizeIsUnknown(self.choice.embossDarkSize) || !isnanOrZero(self.choice.embossBlur) || !isnanOrZero(self.choice.embossRadius));
    self.choice.innerShadow = @(!isnanOrZero(self.choice.innerShadowBlur) || !CGSizeIsUnknownOrZero(self.choice.innerShadowSize) || self.choice.innerShadowColor);

    UIView *_view;
    for (UIView *view in views) if(view.superview && !view.hidden) { _view = view; break; }
    BOOL updateViews = NO;
    float realOpacity = !self.choice.hasShadow && self.choice.shadowAlpha == 0 && self.opacitySlider && self.subSetting == MysticSettingLayerShadow && self.opacitySlider.value != 0 ? self.opacitySlider.value : self.choice.shadowAlpha;
    if(self.choice.hasShadow || realOpacity > 0)
    {
        self.choice.shadowOffset = CGSizeIsUnknown(self.choice.shadowOffset) ? (CGSize){0,0} : self.choice.shadowOffset;
        self.choice.shadowRadius = self.choice.shadowRadius != 0 ? self.choice.shadowRadius : self.blurSlider && self.subSetting == MysticSettingLayerShadow ? self.blurSlider.value : 0;
        self.choice.shadowAlpha = self.choice.shadowAlpha == 0 ? self.opacitySlider && self.subSetting == MysticSettingLayerShadow ? self.opacitySlider.value : 0 : self.choice.shadowAlpha;
        self.choice.shadowColor = self.choice.shadowColor ? self.choice.shadowColor : [UIColor blackColor];
        updateViews = YES;
    }
    else
    {
        self.choice.shadowOffset = CGSizeUnknown;
        self.choice.shadowColor = nil;
        self.choice.shadowAlpha = NAN;
        self.choice.shadowRadius = NAN;
        updateViews = YES;
    }
    CGRect tf = self.transView.frame;

    if(_setupPresentView)
    {
        for (UIView *view in views) {
            if(!view.superview || view.hidden) continue;
            if([view isKindOfClass:[MysticTransView class]] && self.shouldResizeContent)
            {
                self.choice.refitFrame = YES;
                view.frameAndCenter = self.choice.attributedString ? CGRectSize(self.choice.size) : CGRectScaleWithScale(CGRectFit(CGRectSize(self.choice.size), UIEdgeInsetsInsetRect(self.originalClipViewFrame, self.layerView.layersView.maxLayerInsets)), CGScaleFromTransform(self.transView.transform));
                [self.choice updateView:(id)view debug:debug];
                [(MysticTransView *)view updateLayout:YES];
                self.endSize = [(MysticTransView *)view resizeToSmallestSubview].size;
                [(MysticTransView *)view updateLayout:YES];
                [(MysticTransView *)view setShouldUpdateContent:YES];
                view.center = CGPointCenter(self.clipView.frame);
                CGRect finalRect = CGRectTransform(self.transView.bounds, self.transView.transform);
                self.transView.transform = CGAffineTransformIdentity;
                self.transView.frameAndCenter = finalRect;
                self.endSize = finalRect.size;
                self.startSize = CGRectTransform(CGRectSize(self.endSize), self.originalTransform).size;
            }
            else [self.choice updateView:(id)view debug:debug];

        }
    }
    self.shouldResizeContent = NO;

    if(self.subSetting == MysticSettingLayerShadow && self.opacitySlider) { self.opacitySlider.blockEvents = YES; [self.opacitySlider setUpperValue:_view.layer.shadowOpacity animated:NO]; self.opacitySlider.blockEvents = NO; }
    if(self.subSetting == MysticSettingLayerShadow && self.blurSlider) { self.blurSlider.blockEvents = YES;  [self.blurSlider setUpperValue:_view.layer.shadowRadius animated:NO]; self.blurSlider.blockEvents = NO;  }
    
    if(self.subSetting == MysticSettingLayerBorder) { self.opacitySlider.blockEvents = YES; [self.opacitySlider setUpperValue:self.choice.borderAlpha animated:NO]; self.opacitySlider.blockEvents = NO; }
    if(self.subSetting == MysticSettingLayerBorder && self.choice.drawEffectsOnViewLayer) { self.widthSlider.blockEvents = YES;  [self.widthSlider setUpperValue:self.choice.borderWidth animated:NO]; self.widthSlider.blockEvents = NO;  }
}

#pragma mark - Pack button touched

- (void) packButtonTouched:(MysticCategoryButton *)sender;
{
    __unsafe_unretained __block  MysticPacksScrollView *scrollView = (id)sender.superview;
    __unsafe_unretained __block  MysticLayerEditViewController *weakSelf = (id)self;
    
    [scrollView deselectAll];
    sender.selected = YES;
    [scrollView revealItem:sender animated:!settingUpInput complete:nil];
    self.pack = sender.pack;
    for (UIView *v in self.choicesScrollView.subviews) {
        if([v isKindOfClass:[MysticButton class]]) [v removeFromSuperview];
    }
    [sender.pack packOptions:^(NSArray *controls, MysticDataState dataState) {
        if(dataState & MysticDataStateComplete && controls && controls.count)
        {
            MysticChoice *choice;
            __block MysticChoice *selectedChoice = nil;
            NSInteger selectedChoiceIndex = MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX;
            NSInteger i = 0;
            NSMutableArray *choices = [NSMutableArray array];
            for (NSDictionary *info in controls) {
                MysticChoice *choice = [MysticChoice choiceWithInfo:info key:info[@"key"] type:sender.pack.groupType];
                if(self.content && !selectedChoice && [choice.name isEqualToString:self.choice.name])
                {
                    selectedChoice = choice;
                    selectedChoiceIndex = i;
                }
                i++;
                
                [choices addObject:choice];
            }
            

            __block MysticChoiceButton *choiceButton = nil;
            weakSelf.choicesScrollView.shouldSelectControlBlock = (^BOOL(PackPotionOption *o){
                return YES;
            });
            weakSelf.choicesScrollView.enableControls = YES;
            __block CGRect f = CGRectSize((CGSize){weakSelf.choicesScrollView.frame.size.width/4, weakSelf.choicesScrollView.frame.size.width/4});
            __block int x = 0;
            __block int column = 0;
            __block int row = 0;
        
            
            [weakSelf.choicesScrollView.controlsData replaceObjectsInRange:NSMakeRange(0, weakSelf.choicesScrollView.controlsData.count) withObjectsFromArray:(id)choices];
            weakSelf.choicesScrollView.makeTileBlock = weakSelf.choicesScrollView.makeTileBlock ? weakSelf.choicesScrollView.makeTileBlock : ^ id (int index, MysticChoice *choice, CGRect choiceFrame, MysticScrollView *scrollView)
            {
                BOOL selected = !isNotFoundOrAuto(scrollView.selectedItemIndex) && index == scrollView.selectedItemIndex;
                choice.isThumbnail = YES;
                UIImage *img = [choice image:CGRectInset(f, 32, 32).size color:[UIColor hex:@"6A5E55"] scale:0 quality:kCGInterpolationLow contentMode:UIViewContentModeScaleAspectFit];
                choiceButton = [MysticChoiceButton buttonWithImage:img target:weakSelf sel:@selector(choiceSelected:)];
                choice.image = img;
                choice.selectedImage = [MysticImage image:img withColor:[UIColor color:MysticColorTypePink]];
                [choiceButton setImage:choice.selectedImage forState:UIControlStateSelected];
                choiceButton.enabled = YES;
                choiceButton.canSelect = YES;
                choiceButton.position = index;
                choiceButton.frame = choiceFrame;
                choiceButton.effect = choice;
                [choiceButton showAsSelected:selected];
                return choiceButton;
            };
            weakSelf.choicesScrollView.updateTileBlock = weakSelf.choicesScrollView.updateTileBlock ? weakSelf.choicesScrollView.updateTileBlock : ^ void (int index, MysticChoice *choice, MysticChoiceButton *tile, BOOL selected, MysticScrollView *scrollView)
            {
                selected = selected ? selected : !isNotFoundOrAuto(scrollView.selectedItemIndex)  && index == scrollView.selectedItemIndex;
                if(!choice.image)
                {
                    choice.image = [choice image:CGRectInset(f, 32, 32).size color:[UIColor hex:@"6A5E55"] scale:0 quality:kCGInterpolationLow contentMode:UIViewContentModeScaleAspectFit];
                    choice.selectedImage = [MysticImage image:choice.image withColor:[UIColor color:MysticColorTypePink]];
                }
                [tile removeTarget:weakSelf action:@selector(choiceSelected:) forControlEvents:UIControlEventTouchUpInside];
                [tile addTarget:weakSelf action:@selector(choiceSelected:) forControlEvents:UIControlEventTouchUpInside];
                tile.canSelect = YES;
                tile.effect = choice;
                tile.enabled = YES;
                [tile setImage:choice.image forState:UIControlStateNormal];
                [tile setImage:choice.selectedImage forState:UIControlStateSelected];
                [tile showAsSelected:selected];
                [tile setNeedsDisplay];
            };
            int stag = selectedChoice ? [choices indexOfObject:selectedChoice] : -999;
            
            [weakSelf.choicesScrollView loadControls:choices selectIndex:selectedChoiceIndex animated:YES complete:nil];
            if(weakSelf.choicesScrollView.contentSize.height < weakSelf.choicesScrollView.frame.size.height)
            {
                weakSelf.choicesScrollView.contentSize = (CGSize){weakSelf.choicesScrollView.frame.size.width, weakSelf.choicesScrollView.frame.size.height+ weakSelf.choicesScrollView.extraContentSize.height};
                [weakSelf.choicesScrollView setContentOffset:CGPointZero animated:YES];
            }

        }
    }];
}

#pragma mark - Choice Selected & Content

- (void) choiceSelected:(MysticScrollViewControl *)choiceButton;
{
    if(settingUpInput) return;
    [self.transView resetContent];
    if(choiceButton.effect) self.content = choiceButton.effect;
    for (MysticScrollViewControl *btn in choiceButton.superview.subviews) {
        if([btn isKindOfClass:[choiceButton class]] && ![btn isEqual:choiceButton]) [btn showAsSelected:NO];
    }
    self.choicesScrollView.selectedItemIndex = choiceButton.tag;
    [choiceButton showAsSelected:YES];
    
}
- (MysticChoice *) choice;
{
    return _content && [_content isKindOfClass:[MysticChoice class]] ? (id)_content : nil;
}
- (void) setChoice:(MysticChoice *)choice;
{
    self.content = choice;
}
- (void) setContent:(id)content;
{
    BOOL changed = YES;
    if(content && (!_content || ![content isEqual:_content]))
    {
        changed = !(_content && [(MysticChoice *)_content isSame:content]);
        if([content isKindOfClass:[NSString class]])
        {
            if(_content)
            {
                [[(MysticChoice *)_content info] setObject:[[content copy] autorelease] forKey:@"content"];
                [(MysticChoice *)_content setKey:content];
                [(MysticChoice *)_content setType:self.pack.groupType];
                [(MysticChoice *)_content updateTag];
            }
            else
            {
                _content = [[MysticChoice choiceWithInfo:@{@"content":[[content copy] autorelease]} key:nil type:self.pack.groupType] retain];
            }
        }
        else
        {
            if(_content && [content isKindOfClass:[MysticChoice class]])
            {
                content = [[content copy] autorelease];
                [(MysticChoice *)content addChoice:_content resetInfo:NO];
                [(MysticChoice *)_content addChoice:content];
                [_content release], _content=nil;
                _content = [content retain];
            }
            else if(_content && [content isKindOfClass:[NSDictionary class]])
            {
                [[(MysticChoice *)_content info] removeAllObjects];
                [(MysticChoice *)_content setInfo:(id)content];
                [(MysticChoice *)_content updateTag];
            }
            else if(!_content)
            {
                _content = [[MysticChoice choiceWithInfo:[[content copy] autorelease] key:nil type:self.pack.groupType] retain];
            }
        }
    }
    
    
    if(_content)
    {
        if(changed) self.choice.originalContentFrame = CGRectUnknown;
        self.updateContent = NO;
        [self.choice setPath:nil];
        self.choice.rebuildFrame = YES;
        self.shouldResizeContent = YES;

        @autoreleasepool {
            
            MysticChoice *c = _content;
            if(self.transImageDrawView)
            {
                self.transImageDrawView.drawBlock = nil;
                self.transImageDrawView.choice = _content;
                [self.transImageDrawView setNeedsDisplay];
            }
            [self updateViews];
        }
        
    }
    else if(self.transImageDrawView)
    {
        self.transImageDrawView.drawBlock = nil;
        self.transImageDrawView.choice = nil;
    }
    self.updateContent = YES;
    
}
@end
