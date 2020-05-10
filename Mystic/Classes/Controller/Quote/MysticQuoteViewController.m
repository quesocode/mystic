
//
//  MysticQuoteViewController.m
//  Mystic
//
//  Created by Me on 3/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticQuoteViewController.h"
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
#import "MysticAttrString.h"


@interface MysticQuoteViewController () <UITextViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MysticLayerToolbarDelegate, ILPickerDelegate, EffectControlDelegate>
{
    float _lastInputOffsetY;
    BOOL startedOffsetAnim, settingContentOffset, _setupInputView;
}
@property (retain, nonatomic) MysticButton *doneButton;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) IBOutlet UITextView *quoteInput, *textInput;
@property (retain, nonatomic) IBOutlet MysticBorderView *quotesView;
@property (retain, nonatomic) IBOutlet MysticBorderView *quoteView;
@property (retain, nonatomic) IBOutlet MysticBorderView *authorView;
@property (nonatomic, assign) NSInteger lastSelectedQuoteIndex;
@property (retain, nonatomic) UITextField* lastResponder, *lastInputResponder;
@property (nonatomic, assign) float textInputFontSizeScaled;
@property (nonatomic, assign) BOOL switchingKeyboard, hasDoneDeepView;
@property (nonatomic, assign) MysticPathView *pathView;
@property (nonatomic, retain) ILColorPickerView *colorPicker;
@property (retain, nonatomic) UILabel *transitionLabel;
@property (nonatomic, readonly) BOOL hasMultilineText;
@property (nonatomic, assign) CGSize originalTextContainerSize;
@property (nonatomic, assign) UIEdgeInsets originalTextContainerInsets;
@end

@implementation MysticQuoteViewController

@synthesize quoteText=_quoteText;

- (void)dealloc {
    
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_colorPicker release];
    [_quotes release];
    [_tableView release];
    [_doneButton release];
    [_quoteText release];
    [_textInput release];
    [_fontOption release];
    [_quoteView release];
    [_quotesView release];
    [_authorView release];
    [_fontView release];
    [_transitionLabel release];
    [_lastResponder release];
    [_lastInputResponder release];
    _lineHeightSlider = nil;
    _textSpacingSlider = nil;
}

- (id) initWithQuote:(NSString *)quoteText;
{
    self = [super init];
    if(self)
    {
        releaseHiddenText = YES;
        _updateLayerShadow = YES;
        _lastInputOffsetY = NAN;
        self.quoteText = quoteText;
        self.quotes = @[];
        self.keyboardRect = (CGRect){0,0,[MysticUI screen].width, 266};
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        _content = [[MysticChoice choiceWithInfo:@{@"quote": @YES} key:nil type:MysticObjectTypeFont] retain];
        self.updateContent = YES;
    }
    return self;
}

#pragma mark - View Controller
- (void) commonInit;
{
    [super commonInit];
    self.colorInputOptions =MysticColorInputOptionLibrary|MysticColorInputOptionRecent|MysticColorInputOptionAlpha;
    self.lastSelectedQuoteIndex = NSNotFound;
    self.lineHeight = -99;
    self.textAlignment = NSTextAlignmentCenter;
    self.spacing = -99;
    _hasDoneDeepView = NO;
    _setupInputView=NO;
}
- (void)viewDidLoad
{
    _lastInputOffsetY = NAN;
    _setupPresentView = NO;
    self.colorInputOptions =MysticColorInputOptionLibrary|MysticColorInputOptionRecent|MysticColorInputOptionAlpha;
    self.colorAlpha = 1;
    self.lastSelectedQuoteIndex = NSNotFound;
    self.lineHeight = -99;
    self.textAlignment = NSTextAlignmentCenter;
    self.spacing = -99;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.quoteInput.text = self.quoteText;
    self.quoteInput.keyboardAppearance = UIKeyboardAppearanceDark;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.doneButton.font = [MysticUI fontBold:16];
    [self.doneButton setTitleColor:[UIColor color:MysticColorTypeWhite] forState:UIControlStateNormal];
    [self.doneButton setBackgroundColor:@(MysticColorTypeBackgroundBlack) forState:UIControlStateNormal];
    [self.doneButton setBackgroundColor:@(MysticColorTypePink) forState:UIControlStateHighlighted];
    self.quoteView.backgroundColor = [UIColor color:MysticColorTypeWhite];
    self.authorView.backgroundColor = self.quoteView.backgroundColor;
    self.quotesView.backgroundColor = self.quoteView.backgroundColor;
    self.authorView.borderWidth = 1;
    self.authorView.borderColor = [UIColor color:MysticColorTypeBorderOnLight];
    self.authorView.showBorder = YES;
    self.authorView.borderPosition = MysticPositionTop;
    self.quotesView.borderPosition = MysticPositionLeft;
    self.quotesView.borderWidth = self.authorView.borderWidth;
    self.quotesView.borderColor = self.authorView.borderColor;
    self.quotesView.showBorder = self.authorView.showBorder;
    self.quoteView.showBorder = NO;
    self.tableView.backgroundColor = self.quoteView.backgroundColor;
    _updateLayerShadow = YES;
    __unsafe_unretained __block MysticQuoteViewController *weakSelf = self;
    NSString *bundledPath = [[NSBundle mainBundle] pathForResource:@"quotes" ofType:@"plist"] ;
    [MysticDictionaryDownloader removeCacheForURL:[NSURL URLWithString:MYSTIC_QUOTES_URL]];
    [MysticDictionaryDownloader dictionaryWithURL:[NSURL URLWithString:MYSTIC_QUOTES_URL] orDictionary:bundledPath state:^(id data, MysticDataState dataState) {
        if(dataState & MysticDataStateNew && !(dataState & MysticDataStateError))
        {
            weakSelf.quotes = data && [data isKindOfClass:[NSDictionary class]] ? [(id)data objectForKey:@"Quotes"] : weakSelf.quotes;
            [weakSelf.tableView reloadData];
        }
    }];
    
    
    [self.tableView reloadData];
    
    
}

- (CGRect) previewFrame;
{
    return CGRectAddYH([super previewFrame], 0, -10);
}
- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UITextField *) findLastResponder;
{
    if(self.textInput.isFirstResponder) self.lastResponder = (id)self.textInput;
    else if(self.hiddenTextField.isFirstResponder) self.lastResponder = (id)self.hiddenTextField;
    else if(self.quoteInput.isFirstResponder) self.lastResponder = (id)self.quoteInput;
    else self.lastResponder = nil;
    return self.lastResponder;
}

- (void) toolbarKeyboard:(MysticBarButton *)sender;
{
    sender = sender ? sender : [self.toolbar buttonForType:MysticToolTypeText];
    if(![self findLastResponder]) return;
    [self updateChoiceValues];
    [self.toolbar selectItem:sender];
    self.setting = MysticSettingFontEdit;
    [self moveNipple:[self.toolbar convertPoint:sender.center toView:self.lastResponder.inputAccessoryView].x completion:nil];
    [self changeInputView:nil];
    [self updateInputAccessoryView];
    self.choice.attributedString.textAlignment = self.textAlignment;
    self.textInput.attributedText = self.choice.attributedString.attrString;
    self.textInput.textAlignment = self.textAlignment;
    CGSize textDiff = CGSizeDiff(self.textInput.frame.size, self.choice.attributedString.size);
    self.textInput.textContainerInset = UIEdgeInsetsMake(10, textDiff.width/2-10, 10, textDiff.width/2-10);
    self.textInput.frame = self.previewFrame;
    _lastInputOffsetY = -(MAX(0, ([self.textInput bounds].size.height - [self.textInput contentSize].height * [self.textInput zoomScale])/2.0));
    self.textInput.contentOffset = (CGPoint){.x = 0, .y = _lastInputOffsetY};
}
- (void) toolbarFont:(MysticBarButton *)sender;
{
    sender = sender ? sender : [self.toolbar buttonForType:MysticToolTypeFonts];
    if(![self findLastResponder]) return;
    [self updateChoiceValues];
    [self.toolbar selectItem:sender];
    self.setting = MysticSettingFontStyle;
    mdispatch_high(^{
        UIView *inputView = [self inputView:MysticIconTypeToolFont];
        mdispatch(^{
            [self changeInputView:[inputView autorelease]];
            [self moveNipple:[self.toolbar convertPoint:sender.center toView:self.lastResponder.inputAccessoryView].x completion:nil];
            [self updateInputAccessoryView];
        });
    });
    
    
}
- (void) toolbarFontColor:(MysticBarButton *)sender;
{
    sender = sender ? sender : [self.toolbar buttonForType:MysticToolTypeColor];
    if(![self findLastResponder]) return;
    [self updateChoiceValues];
    [self.toolbar selectItem:sender];
    self.setting = MysticSettingFontColor;
    mdispatch_high(^{
        UIView *inputView = [self inputView:MysticIconTypeToolFontColor];
        mdispatch(^{
            [self changeInputView:[inputView autorelease]];
            [self moveNipple:[self.toolbar convertPoint:sender.center toView:self.lastResponder.inputAccessoryView].x completion:nil];
            [self updateInputAccessoryView];
        });
    });
}
- (void) toolbarFontAlign:(MysticFontAlignButton *)sender;
{
    if(!sender.enabled) return;
    if(self.textInput && !self.hasMultilineText)
    {
        sender.toggleState = sender.defaultToggleState;
        self.lastResponder.textAlignment = textAlignmentValue(sender.toggleState);
        self.textAlignment = self.textInput.textAlignment;
        return;
    }
    sender = sender ? sender : (id)[self.toolbar buttonForType:MysticToolTypeTextAlign];
    [self.toolbar selectItem:sender];
    switch (sender.textAlignment) {
        case NSTextAlignmentLeft:
        {
            self.lastResponder.textAlignment = NSTextAlignmentLeft;
            if(self.textInput) self.textInput.textAlignment = NSTextAlignmentLeft;
            break;
        }
        case NSTextAlignmentRight:
        {
            self.lastResponder.textAlignment = NSTextAlignmentRight;
            if(self.textInput) self.textInput.textAlignment = NSTextAlignmentRight;
            break;
        }
        default:
        {
            self.lastResponder.textAlignment = NSTextAlignmentCenter;
            if(self.textInput) self.textInput.textAlignment = NSTextAlignmentCenter;
            break;
        }
    }
    
    self.textAlignment = sender.textAlignment;
    [self updateInputAccessoryView];
    MysticAttrString *attrStr = [MysticAttrString string:self.textInput.attributedText];
    attrStr.textAlignment = self.textAlignment;
    self.choice.attributedString = attrStr;
    [self updateViews];

}
- (void) toolbarEffects:(MysticBarButton *)sender;
{
    sender = sender ? sender : [self.toolbar buttonForType:MysticToolTypeSettings];
    if(![self findLastResponder]) return;
    [self updateChoiceValues];
    [self.toolbar selectItem:sender];
    self.setting = MysticSettingFontEffect;
    mdispatch_high(^{
        UIView *inputView = [self inputView:MysticIconTypeToolFontEffect];
        [self fixTextInputText:YES];
        mdispatch(^{
            [self changeInputView:[inputView autorelease]];
            [self moveNipple:[self.toolbar convertPoint:sender.center toView:self.lastResponder.inputAccessoryView].x completion:nil];
            [self updateInputAccessoryView];
        });
    });
    
}
- (void) updateChoiceValues;
{
    self.choice.attributedString.textAlignment = self.textAlignment;
}
#pragma mark - Input Accessory View

- (UIView *) makeInputAccessoryView;
{
    if(self.toolbar) return self.toolbar.superview;
    
    MysticLayerToolbar *toolbar = [MysticLayerToolbar toolbarWithDelegate:self height:MYSTIC_UI_TOOLBAR_ACCESSORY_HEIGHT];
    CGSize toolbarIconSize = (CGSize){35,35};
    
    MysticBlockButtonItem confirmBlock = (^MysticButton *(MysticButton *button, MysticBarButtonItem *item){
        item.width = 60;
        return button;
    });
    
    [toolbar useItems:@[
                        @{@"toolType": @(MysticToolTypeStatic),
                          @"width":@(-10)},
                        
                        
                        @{@"toolType": @(MysticToolTypeText),
                          @"target": self,
                          @"action": @"toolbarKeyboard:",
                          @"iconType":@(MysticIconTypeToolKeyboard),
                          @"eventAdded": @YES,
                          @"selected": self.setting == MysticSettingFontEdit || self.setting==MysticObjectTypeUnknown ? @YES : @NO,
                          @"color":@(MysticColorTypeInputAccessoryIcon),
                          @"colorHighlighted":@(MysticColorTypeInputAccessoryIconHighlighted),
                          @"colorSelected":@(MysticColorTypeInputAccessoryIconSelected),
                          
                          @"contentMode": @(UIViewContentModeCenter),
                          @"iconSize": [NSValue valueWithCGSize:(CGSize){18,15}],
                          @"objectType":@(MysticObjectTypeFont)},
                        
                        @(MysticToolTypeFlexible),
                        
                        
                        
                        
                        
                        @{@"toolType": @(MysticToolTypeFonts),
                          @"target": self,
                          @"action": @"toolbarFont:",
                          @"iconType":@(MysticIconTypeToolFont),
                          @"eventAdded": @YES,
                          @"selected": self.setting == MysticSettingFontStyle  ? @YES : @NO,
                          @"color":@(MysticColorTypeInputAccessoryIcon),
                          @"colorHighlighted":@(MysticColorTypeInputAccessoryIconHighlighted),
                          @"colorSelected":@(MysticColorTypeInputAccessoryIconSelected),
                          @"contentMode": @(UIViewContentModeCenter),
                          @"iconSize": [NSValue valueWithCGSize:(CGSize){23,15}],
                          @"objectType":@(MysticObjectTypeFont)},
                        
                        
                        @(MysticToolTypeFlexible),
                        
                        
                        @{@"toolType": @(MysticToolTypeColor),
                          @"target": self,
                          @"action": @"toolbarFontColor:",
                          @"iconType":@(MysticIconTypeFontColor),
                          @"eventAdded": @YES,
                          @"selected": self.setting == MysticSettingFontColor  ? @YES : @NO,
                          @"color":@(MysticColorTypeNone),
                          @"colorHighlighted":@(MysticColorTypeInputAccessoryIconHighlighted),
                          @"colorSelected":@(MysticColorTypeInputAccessoryIconSelected),
                          @"colorDisabled":@(MysticColorTypeInputAccessoryIconDisabled),
                          
                          @"contentMode": @(UIViewContentModeCenter),
                          @"iconSize": [NSValue valueWithCGSize:(CGSize){15,15}],
                          @"objectType":@(MysticObjectTypeFont)},
                        
                        
                        
                        @(MysticToolTypeFlexible),
                        
                        
                        
                        @{@"toolType": @(MysticToolTypeSettings),
                          @"target": self,
                          @"action": @"toolbarEffects:",
                          @"iconType":@(MysticIconTypeFontLineHeight),
                          @"eventAdded": @YES,
                          @"selected": self.setting == MysticSettingFontEffect  ? @YES : @NO,
                          
                          @"color":@(MysticColorTypeInputAccessoryIcon),
                          @"colorHighlighted":@(MysticColorTypeInputAccessoryIconHighlighted),
                          @"colorSelected":@(MysticColorTypeInputAccessoryIconSelected),
                          
                          @"contentMode": @(UIViewContentModeCenter),
                          @"iconSize": [NSValue valueWithCGSize:(CGSize){19,18}],
                          @"objectType":@(MysticObjectTypeFont)},
                        
                        @(MysticToolTypeFlexible),
                        
//                        @{@"toolType": @(MysticToolTypeLayerShadow),
//                          @"target": self,
//                          @"action": @"toolbarShadow:",
//                          @"iconType":@(MysticIconTypeFontShadow),
//                          @"eventAdded": @YES,
//                          @"selected": self.setting == MysticSettingLayerShadow  ? @YES : @NO,
//                          @"color":@(MysticColorTypeInputAccessoryIcon),
//                          @"colorHighlighted":@(MysticColorTypeInputAccessoryIconHighlighted),
//                          @"colorSelected":@(MysticColorTypeInputAccessoryIconSelected),
//                          @"contentMode": @(UIViewContentModeCenter),
//                          @"iconSize": [NSValue valueWithCGSize:(CGSize){18,18}],
//                          @"objectType":@(self.option.type)},
//                        
//                        @(MysticToolTypeFlexible),
                        
                        @{@"toolType": @(MysticToolTypeTextAlign),
                          @"target": self,
                          @"action": @"toolbarFontAlign:",
                          @"color":@(MysticColorTypeInputAccessoryIcon),
                          @"colorHighlighted":@(MysticColorTypeInputAccessoryIconHighlighted),
                          @"colorSelected":@(MysticColorTypeInputAccessoryIconSelected),
                          @"eventAdded": @YES,
                          @"enabled": self.hasMultilineText ? @YES : @NO,
                          @"selected": self.setting == MysticSettingFontAlign  ? @YES : @NO,
                          @"contentMode": @(UIViewContentModeCenter),
                          @"iconSize": [NSValue valueWithCGSize:(CGSize){15,11}],
                          @"objectType":@(MysticObjectTypeFont)},
                        
                        
                        @(MysticToolTypeFlexible),
                        
                        @{@"toolType": @(MysticToolTypeConfirm),
                          @"target": self,
                          @"action": @"toolbarDone:",
                          @"iconType":@(MysticIconTypeConfirm),
                          @"eventAdded": @YES,
                          @"colorHighlighted": @(MysticColorTypeInputAccessoryIconSelected),
                          @"color":@(MysticColorTypeInputAccessoryIconHighlighted),
                          @"block": [[confirmBlock copy] autorelease],
                          @"contentMode": @(UIViewContentModeCenter),
                          @"iconSize": [NSValue valueWithCGSize:(CGSize){18,14}],
                          @"objectType":@(MysticObjectTypeFont)},
                        
                        
                        @{@"toolType": @(MysticToolTypeStatic),
                          @"width":@(-17),
                          @"objectType":@(MysticObjectTypeFont)},
                        
                        
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
    self.nippleView.frame = CGRectX(CGRectAlign(self.nippleView.frame, bview.frame, MysticAlignTypeBottom), 25);
    [bview addSubview:self.nippleView];
    self.toolbar = toolbar;
    [self updateInputAccessoryView];
    bview.frame = CGRectAlign(bview.frame, self.presentView.bounds, MysticAlignPositionBottom);
    return [bview autorelease];
}



#pragma mark - InputView


- (UIView *) inputView:(MysticIconType)iconType;
{
    UIView *inputView = [[UIView alloc] initWithFrame:(CGRect){0,0, [MysticUI screen].width, self.keyboardRect.size.height- 40}];
    _setupInputView = YES;
    self.colorAlpha = self.textInput.textColor.alpha;
    switch (iconType) {
        case MysticIconTypeToolFont:
        case MysticIconTypeToolEffects:
        case MysticIconTypeToolFontEffect:
        {
            mdispatch(^{
                inputView.backgroundColor = [UIColor hex:@"201F1F"];
            });
            [self resetPreviousInputView:iconType];
            break;
        }
        default: break;
    }
    switch (iconType) {
        case MysticIconTypeToolFont:
        {
            MysticFontListScrollView *scrollView = [[MysticFontListScrollView alloc] initWithFrame:inputView.bounds];
            scrollView.showsHorizontalScrollIndicator=NO;
            scrollView.showsVerticalScrollIndicator=NO;
            scrollView.directionalLockEnabled = YES;
            scrollView.backgroundColor = inputView.backgroundColor;
            __block CGRect f = CGRectMake(0, 0, inputView.bounds.size.width, 42);
            __block NSInteger i = 0;
            mdispatch_high(^{
                NSArray *theFonts = [[NSMutableArray arrayWithArray:[Mystic core].fonts] retain];
                scrollView.tileSize = f.size;
                scrollView.scrollDirection  =MysticScrollDirectionVertical;
                scrollView.layoutStyle = MysticLayoutStyleVertical;
                scrollView.makeTileBlock = ^id (int index, id data, CGRect frame, MysticScrollView *scrollView)
                {
//                    MysticBorderView *fontBorder = [[MysticBorderView  alloc] initWithFrame:CGRectz(frame)];
//                    fontBorder.borderWidth = 1;
//                    fontBorder.borderPosition = MysticPositionBottom;
//                    fontBorder.borderInsets = UIEdgeInsetsMake(0, 14, 0, 14);
//                    fontBorder.dashSize = (CGSize){fontBorder.borderWidth, 5};
//                    fontBorder.borderColor = [UIColor hex:@"473F3C"];
//                    fontBorder.dashed = YES;
//                    UIEdgeInsets e = UIEdgeInsetsMake(0, 0, fontBorder.borderWidth, 0);

                    PackPotionOptionFont *font = data;
                    MysticScrollViewControl *fontBtn = [[MysticScrollViewControl alloc] initWithFrame:frame];
                    fontBtn.backgroundColor = inputView.backgroundColor;
                    [fontBtn setTitleColor:[UIColor color:MysticColorTypeMenuText] forState:UIControlStateNormal];
                    [fontBtn setTitleColor:[UIColor color:MysticColorTypePink] forState:UIControlStateSelected];
                    [fontBtn setTitleColor:[UIColor color:MysticColorTypeMenuText] forState:UIControlStateHighlighted];
                    [fontBtn setBackgroundColor:scrollView.backgroundColor forState:UIControlStateHighlighted];
                    fontBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 26, 0, 0);
                    fontBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, -10);
                    fontBtn.font = [font.font fontWithSize:15];
                    fontBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
                    fontBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    [fontBtn setImage:[MysticImage image:@(MysticIconTypeConfirm) size:(CGSize){10,8} color:scrollView.backgroundColor] forState:UIControlStateNormal];
                    [fontBtn setImage:[MysticImage image:@(MysticIconTypeConfirm) size:(CGSize){10,8} color:@(MysticColorTypeMenuText)] forState:UIControlStateSelected];
                    [fontBtn addTarget:self action:@selector(fontSelected:) forControlEvents:UIControlEventTouchUpInside];
                    [fontBtn setTitle:font.name forState:UIControlStateNormal];
//                    fontBtn.tag = MysticViewTypeButton1 + i;
//                    [fontBtn addSubview:fontBorder];
                    return fontBtn;
                };
                
                
                mdispatch(^{
                    MysticButton *selectedFont = nil;
                    [scrollView loadControls:theFonts selectIndex:NSNotFound animated:NO complete:nil];
                    
//                    for (PackPotionOptionFont *font in theFonts) {
//                        
//                        MysticBorderView *fontBorder = [[MysticBorderView  alloc] initWithFrame:f];
//                        fontBorder.borderWidth = 1;
//                        fontBorder.borderPosition = MysticPositionBottom;
//                        fontBorder.borderInsets = UIEdgeInsetsMake(0, 14, 0, 14);
//                        fontBorder.dashSize = (CGSize){fontBorder.borderWidth, 5};
//                        fontBorder.borderColor = [UIColor hex:@"473F3C"];
//                        fontBorder.dashed = YES;
//                        
//                        UIEdgeInsets e = UIEdgeInsetsMake(0, 0, fontBorder.borderWidth, 0);
//                        MysticButton *fontBtn = [[MysticButton alloc] initWithFrame:UIEdgeInsetsInsetRect(fontBorder.bounds, e)];
//                        fontBtn.backgroundColor = inputView.backgroundColor;
//                        [fontBtn setTitleColor:[UIColor color:MysticColorTypeMenuText] forState:UIControlStateNormal];
//                        [fontBtn setTitleColor:[UIColor color:MysticColorTypePink] forState:UIControlStateSelected];
//                        [fontBtn setTitleColor:[UIColor color:MysticColorTypeMenuText] forState:UIControlStateHighlighted];
//                        [fontBtn setBackgroundColor:scrollView.backgroundColor forState:UIControlStateHighlighted];
//                        fontBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 26, 0, 0);
//                        fontBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, -10);
//                        fontBtn.font = [font.font fontWithSize:15];
//                        fontBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
//                        fontBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//                        [fontBtn setImage:[MysticImage image:@(MysticIconTypeConfirm) size:(CGSize){10,8} color:scrollView.backgroundColor] forState:UIControlStateNormal];
//                        [fontBtn setImage:[MysticImage image:@(MysticIconTypeConfirm) size:(CGSize){10,8} color:@(MysticColorTypeMenuText)] forState:UIControlStateSelected];
//                        [fontBtn addTarget:self action:@selector(fontSelected:) forControlEvents:UIControlEventTouchUpInside];
//                        [fontBtn setTitle:font.name forState:UIControlStateNormal];
//                        fontBtn.tag = MysticViewTypeButton1 + i;
//                        [fontBorder addSubview:fontBtn];
//                        [scrollView addSubview:[fontBorder autorelease]];
//                        
//                        if(!selectedFont && [self.textInput.font.fontName isEqualToString:fontBtn.font.fontName])
//                        {
//                            self.fontOption = font;
//                            selectedFont = fontBtn;
//                        }
//                        
//                        f.origin.y = f.origin.y+ f.size.height;
//                        i++;
//                        
//                    }
//                    scrollView.contentSize = (CGSize){scrollView.frame.size.width, f.origin.y};
//                    
                    if(selectedFont)
                    {
                        selectedFont.selected = YES;
                        [scrollView scrollRectToVisible:selectedFont.frame animated:YES];
                    }
                    [inputView addSubview:scrollView];
                    [self fadeInBgColor:YES sender:nil];
                });
            });
            
            break;
        }
        case MysticIconTypeToolFontEffect:
        {
            mdispatch(^{
                CGFloat h = inputView.frame.size.height/3;
                
                inputView.backgroundColor = [UIColor hex:@"201F1F"];
                
                MysticBorderView *border = [[MysticBorderView alloc] initWithFrame:CGRectz(inputView.frame)];
                border.numberOfDivisions = 3;
                border.borderColor = [inputView.backgroundColor lighter:0.05];
                border.borderWidth = 1;
                border.dashSize = (CGSize){border.borderWidth, 5};
                border.borderColor = [UIColor hex:@"473F3C"];
                border.dashed = YES;
                border.borderOffset = (CGPoint){0, 1};
                border.showBorder = YES;
                border.tag = MysticViewTypeBackgroundBorder;
                border.userInteractionEnabled = NO;
                [inputView insertSubview:border atIndex:0];
                
                
                CGFloat sliderWidth = 140;
                MysticSlider *slider = [MysticSlider sliderWithFrame:(CGRect){80,0,inputView.frame.size.width-sliderWidth, h}];
                slider.tag = 101;
                [slider addTarget:self action:@selector(lineHeightSliderChanged:) forControlEvents:UIControlEventValueChanged];
                slider.useProportionalValues = YES;
                slider.proportionLowerValue = MYSTIC_DEFAULT_RESIZE_LABEL_LINEHEIGHT_SCALE;
                slider.minimumValue = 0.01;
                slider.maximumValue = 10;
                slider.defaultValue = MYSTIC_DEFAULT_RESIZE_LABEL_LINEHEIGHT_SCALE;
                slider.value = self.lineHeight;
                slider.minimumRange = slider.minimumValue - slider.proportionLowerValue;
                slider.lowerHandleHidden = NO;
                slider.lowerValue = slider.defaultValue;
                
                
                slider.upperHandleImageNormal = [UIImage imageNamed:@"slider-handle-light-dull"];
                slider.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                slider.lowerHandleImageNormal = [UIImage imageNamed:@"slider-handle-mid-pink"];
                slider.lowerHandleImageHighlighted = slider.lowerHandleImageNormal;
                
                [inputView addSubview:slider];
                self.lineHeightSlider = slider;
                
                MysticSlider *slider1 = [MysticSlider sliderWithFrame:(CGRect){80,h,inputView.frame.size.width-sliderWidth, h}];
                slider1.tag = 102;
                [slider1 addTarget:self action:@selector(textSpacingSliderChanged:) forControlEvents:UIControlEventValueChanged];
                
                slider1.useProportionalValues = YES;
                slider1.proportionLowerValue = 0;
                slider1.minimumValue = -10;
                slider1.maximumValue = 50;
                slider1.minimumRange = slider1.minimumValue;
                slider1.lowerHandleHidden = NO;
                slider1.defaultValue = slider1.proportionLowerValue;
                slider1.value = self.spacing;
                slider1.lowerValue = slider1.proportionLowerValue;
                slider1.lowerHandleImageNormal = slider.lowerHandleImageNormal;
                slider1.lowerHandleImageHighlighted = slider.lowerHandleImageNormal;
                slider1.upperHandleImageNormal = slider.upperHandleImageNormal;
                slider1.upperHandleImageHighlighted = slider.upperHandleImageNormal;
                [inputView addSubview:slider1];
                self.textSpacingSlider = slider1;
                
                
                MysticSlider *slider2 = [MysticSlider sliderWithFrame:(CGRect){80,h*2,inputView.frame.size.width-sliderWidth, h}];
                slider2.tag = 103;
                [slider2 addTarget:self action:@selector(opacitySliderChanged:) forControlEvents:UIControlEventValueChanged];
                [slider2 addTarget:self action:@selector(opacitySliderBegin:) forControlEvents:UIControlEventEditingDidBegin];
                [slider2 addTarget:self action:@selector(opacitySliderEnd:) forControlEvents:UIControlEventEditingDidEnd];
                
                slider2.minimumValue = 0;
                slider2.maximumValue = 1;
                slider2.lowerHandleHidden = YES;
                //            slider2.minimumRange = 0;
                slider2.defaultValue = 1;
                slider2.value = self.color.alpha;
                slider2.lowerValue = 0;
                slider2.upperHandleImageNormal = slider.upperHandleImageNormal;
                slider2.upperHandleImageHighlighted = slider.lowerHandleImageNormal;
                
                [inputView addSubview:slider2];
                self.opacitySlider = slider2;
                
                
                CGFloat titleSpacing = 3;
                
                SubBarButton *subButton = [[SubBarButton alloc] initWithFrame:(CGRect){15, (h*0)+((h-35)/2)+2, 50,35} showTitle:YES];
                subButton.tag = 121;
                subButton.titleIconSpacing = titleSpacing;
                subButton.imageEdgeInsets = UIEdgeInsetsMakeFrom(0);
                subButton.imageView.contentMode = UIViewContentModeCenter;
                [subButton setImage:[MysticImage image:@(MysticIconTypeFontLineHeight) size:(CGSize){16.5,20} color:@(MysticColorTypeInputAccessoryIconSelected)] forState:UIControlStateNormal];
                subButton.titleLabel.font = [[[subButton class] labelFont] fontWithSize:8];
                [subButton setTitle:@"HEIGHT" forState:UIControlStateNormal];
                [inputView addSubview:[subButton autorelease]];
                
                
                
                subButton = [[SubBarButton alloc] initWithFrame:(CGRect){15, (h*1)+((h-35)/2)+2, 50,35} showTitle:YES];
                subButton.tag = 122;
                subButton.titleIconSpacing = titleSpacing;
                subButton.imageEdgeInsets = UIEdgeInsetsMakeFrom(0);
                subButton.imageView.contentMode = UIViewContentModeCenter;
                [subButton setImage:[MysticImage image:@(MysticIconTypeFontSpacing) size:(CGSize){21,20} color:@(MysticColorTypeInputAccessoryIconSelected)] forState:UIControlStateNormal];
                subButton.titleLabel.font = [[[subButton class] labelFont] fontWithSize:8];
                [subButton setTitle:@"SPACE" forState:UIControlStateNormal];
                [inputView addSubview:[subButton autorelease]];
                
                
                subButton = [[SubBarButton alloc] initWithFrame:(CGRect){15, (h*2)+((h-35)/2)+2, 50,35} showTitle:YES];
                subButton.tag = 123;
                subButton.titleIconSpacing = titleSpacing;
                subButton.imageEdgeInsets = UIEdgeInsetsMakeFrom(0);
                subButton.imageView.contentMode = UIViewContentModeCenter;
                [subButton setImage:[MysticImage image:@(MysticIconTypeIntensity) size:(CGSize){18,18} color:@(MysticColorTypeInputAccessoryIconSelected)] forState:UIControlStateNormal];
                subButton.titleLabel.font = [[[subButton class] labelFont] fontWithSize:8];
                [subButton setTitle:@"OPACITY" forState:UIControlStateNormal];
                [inputView addSubview:[subButton autorelease]];
                
                
                CGFloat sliderX = (slider2.frame.origin.x + slider2.frame.size.width);
                CGSize sliderLabelSize = (CGSize){(inputView.frame.size.width - sliderX),35};
                CGFloat sliderLabelX = sliderX;
                CGFloat sliderLabelY = (h - sliderLabelSize.height)/2;
                
                
                UILabel *sliderLabel = [[UILabel alloc] initWithFrame:(CGRect){sliderLabelX, (h*0)+sliderLabelY, sliderLabelSize.width, sliderLabelSize.height}];
                sliderLabel.tag = 1231;
                sliderLabel.font = [MysticFont fontBold:11];
                sliderLabel.textAlignment = NSTextAlignmentCenter;
                sliderLabel.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                [inputView addSubview:[sliderLabel autorelease]];
                
                UILabel *sliderLabel2 = [[UILabel alloc] initWithFrame:(CGRect){sliderLabelX, (h*1)+sliderLabelY, sliderLabelSize.width, sliderLabelSize.height}];
                sliderLabel2.tag = 1232;
                sliderLabel2.font = [MysticFont fontBold:11];
                sliderLabel2.textAlignment = NSTextAlignmentCenter;
                sliderLabel2.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                [inputView addSubview:[sliderLabel2 autorelease]];
                
                UILabel *sliderLabel3 = [[UILabel alloc] initWithFrame:(CGRect){sliderLabelX, (h*2)+sliderLabelY, sliderLabelSize.width, sliderLabelSize.height}];
                sliderLabel3.tag = 1233;
                sliderLabel3.font = [MysticFont fontBold:11];
                sliderLabel3.textAlignment = NSTextAlignmentCenter;
                sliderLabel3.textColor = [UIColor color:MysticColorTypeInputAccessoryIconSelected];
                [inputView addSubview:[sliderLabel3 autorelease]];
            
                [self textSpacingSliderChanged:slider1];
                [self lineHeightSliderChanged:slider];
                [self opacitySliderChanged:slider2];
                [self fadeInBgColor:YES sender:nil];
            });
            break;
        }
        default: {
            [inputView release]; inputView = [super inputView:iconType]; break; }
    }
    _setupInputView = NO;
    return inputView;
}


- (void) resetPreviousInputView:(MysticIconType)iconType;
{
    [super resetPreviousInputView:iconType];
    self.lineHeightSlider = nil;
    self.textSpacingSlider = nil;
    self.opacitySlider = nil;
}
- (void) changeInputView:(UIView *)inputView;
{
    self.switchingKeyboard = YES;
    if(inputView == nil) [self.lastResponder resignFirstResponder];
    if(!inputView)
    {
        self.transView.hidden = YES;
        self.textInput.hidden = NO;
        self.transView.alpha = 1;
        self.lastResponder.inputView = nil;
        self.lineHeightSlider = nil;
        self.textSpacingSlider = nil;
        self.opacitySlider = nil;
        if(self.hiddenTextField && self.lastResponder == self.hiddenTextField) self.lastResponder = (id)(self.textInput ? self.textInput : self.quoteInput);
        if(!self.lastResponder.isFirstResponder) [self.lastResponder becomeFirstResponder];
        [self.lastResponder reloadInputViews];
    }
    else
    {
        int n2 = self.choice.attributedString.numberOfLines;
        CGFloat xy = n2 > 1 ? -2.66 : -0;
        self.transView.center = CGPointAddXY(self.textInput.center,0,xy);
        self.transView.hidden = NO;
        self.transView.alpha = 1;
        self.textInput.hidden = YES;
        self.hiddenTextField.inputAccessoryView = self.lastResponder.inputAccessoryView;
        self.hiddenTextField.inputView = inputView;
        if(!self.hiddenTextField.isFirstResponder) [self.hiddenTextField becomeFirstResponder];
        [self.hiddenTextField reloadInputViews];
        [self updateViews];
    }
    self.inputView = inputView;
    releaseHiddenText = NO;
}



- (UITextField *) lastInputResponder;
{
    if(self.textInput || (self.hiddenTextField && [self.lastResponder isEqual:self.hiddenTextField])) return (id)self.textInput;
    return self.lastResponder;
}

#pragma mark - Done

- (void) toolbarDone:(id)sender;
{
    [self doneTouched:sender];
}
- (IBAction)doneTouched:(UIButton *)sender {
    
    
    [self removeObserversForTextInput];
    MysticAttrString *txt = [MysticAttrString string:self.textInput.attributedText];
    

    if(self.textInputFontSizeScaled != 1)
    {
        txt.fontSize = txt.fontSize*self.textInputFontSizeScaled;
    }
    txt.textAlignment = self.textAlignment;
    txt.color = self.color ? self.color :  txt.color;

    self.choice.attributedString.textAlignment = self.textAlignment;
    self.choice.color = self.color;
    
    if(self.textInput.hidden)
    {
        txt =self.choice.attributedString;
    }
//    else {
//        self.choice.attributedString = txt;
//    }
    
//    self.endSize = txt.size;
    self.contentSizeChangeScale = (CGSize){self.endSize.width/self.startSize.width, self.endSize.height/self.startSize.height};

    if(self.fontOption)
    {
        self.fontOption.font = self.lastInputResponder.font;
        self.fontOption.text = txt.string;
        self.fontOption.textAlignment = self.textAlignment;
        self.fontOption.attributedString = txt.attrString;
        self.fontOption.color = self.color;
        self.fontOption.lineHeightScale = self.lineHeight != -99 ? self.lineHeight : self.fontOption.lineHeightScale;
        self.fontOption.spacing = self.spacing != -99 ? self.spacing : self.fontOption.spacing;
        self.fontOption.intensity = self.lastInputResponder.textColor.alpha;
    }
    if(self.fontView)
    {
        
        self.fontView.font = self.lastInputResponder.font;
        self.fontView.color = self.color;
        self.fontView.textAlignment = self.textAlignment;
        self.fontView.lineHeightScale = self.lineHeight != -99 ? self.lineHeight : self.fontView.lineHeightScale;
        self.fontView.textSpacing = self.spacing != -99 ? self.spacing : self.fontView.textSpacing;
        self.fontView.text = txt.string;
    }

    
    // possible hidden text dealloc bug happens here
//    releaseHiddenText = NO;
//    [Mystic resignFirstResponder];
    NSString *q1 = self.choice.attributedString.description;
    NSString *q2 = txt.description;
    
//    DLog(@"q1 ==q2 == %@\n\nChoice Str:\n\n%@\n\nInput Str: \n\n%@\n\nDifference:\n\n%@", b([q1 isEqualToString:q2]), ColorWrap(q1, COLOR_BLUE), ColorWrap(q2,COLOR_GREEN_BRIGHT), ColorWrap([q1.description difference:q2.description], COLOR_RED));
//    DLog(@"q1 ==q2 == %@", b([q1 isEqualToString:q2]));

//    NSLog(@"q1 ==q2 == %@\n\nChoice Str:\n\n%@\n\nInput Str: \n\n%@\n\nDifference:\n\n%@", b([q1 isEqualToString:q2]), q1, q2,[q1.description difference:q2.description]);

    
    if(!self.textInput.hidden) self.choice.attributedString = txt;
//    [self updateViews];
    
    
    [(id <MysticQuoteViewControllerDelegate>)self.delegate quoteViewController:self didChooseQuote:self.choice];
}

- (void) setQuoteText:(NSString *)quoteText;
{
    quoteText = quoteText && [quoteText isEqualToString:@""] ? nil : quoteText;
    
    if(_quoteText) [_quoteText release];
    _quoteText = quoteText ? [quoteText retain] : quoteText;
    self.quoteInput.text = quoteText ? quoteText : @"";
}
- (NSString *) quoteText;
{
    return self.quoteInput.text;
}



#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; { return 35.f; }


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.quotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *useIdentifier = @"QuoteCellIdentifier";
    
    Class cellClass = [UITableViewCell class];
    
    UITableViewCellStyle cellStyle = UITableViewCellStyleDefault;
    if([NSStringFromClass(cellClass) isEqualToString:@"MysticLayerTableViewCell"])
    {
        cellStyle = UITableViewCellStyleSubtitle;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:useIdentifier];
    if (cell == nil) {
        cell = [[[cellClass alloc] initWithStyle:cellStyle reuseIdentifier:useIdentifier] autorelease];
    }
    NSArray *categories = self.quotes;
    cell.backgroundColor = [UIColor color:MysticColorTypeWhite];
    cell.textLabel.text = [[[categories objectAtIndex:indexPath.row] objectForKey:@"title"] uppercaseString];
    cell.textLabel.textColor = [UIColor color:MysticColorTypeBackground];
    cell.textLabel.font = [MysticUI fontBold:13];
    __unsafe_unretained __block MysticQuoteViewController *weakSelf = self;
    __unsafe_unretained __block NSIndexPath *_indexPath = [indexPath retain];
    MysticButton *button = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeShuffle) size:CGSizeMake(16, 16) color:@(MysticColorTypePink)] action:^{
        
    }];
    
    cell.accessoryView = button;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *thequotes = [[self.quotes objectAtIndex:indexPath.row] objectForKey:@"quotes"];
    NSDictionary *randomQuoteObj = [thequotes objectAtRandomIndexExcept:self.lastSelectedQuoteIndex];
    
    self.lastSelectedQuoteIndex = [[randomQuoteObj objectForKey:@"index"] integerValue];
    NSDictionary *randomQuote = [randomQuoteObj objectForKey:@"value"];
    
    self.quoteText = [randomQuote objectForKey:@"text"];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}




- (void) keyboardWillHide:(NSNotification *)notification;
{
    if(!(self.textInput && !self.switchingKeyboard)) return;
    MysticKeyboardInfo userInfo = MysticKeyboardNotification(notification);
    [UIView beginAnimations:@"keyboardquote2" context:nil];
    [UIView setAnimationCurve:userInfo.curve];
    [UIView setAnimationDuration:userInfo.time];
    [self fadeOutBgColor:NO sender:nil];
    [UIView commitAnimations];
}




#pragma mark - Present In View

- (void) presentInView:(UIView *)inView fromView:(MysticLayerTypeView *)fromView;
{
    __unsafe_unretained __block MysticQuoteViewController *weakSelf = self;
    _lastInputOffsetY = NAN;
    startedOffsetAnim = NO;
    _setupPresentView = NO;
    self.presentView = [[[UIView alloc] initWithFrame:inView.frame] autorelease];
    self.presentView.userInteractionEnabled = YES;
    CGRect txtFrame = (CGRect){0,0,inView.frame.size.width, inView.frame.size.height - self.keyboardRect.size.height};
    self.textInput = [[[UITextView alloc] initWithFrame:self.previewFrame] autorelease];
    MysticLayerTypeView *fv = (id)fromView;
    self.textAlignment = self.fontView.textAlignment;
    MysticAttrString *rasterAttrStr = self.fontView.attributedTextRastered;
    self.textInputFontSizeScaled = rasterAttrStr.scale;
    self.textInput.attributedText = rasterAttrStr.attrString;
    self.textInput.inputAccessoryView = nil;
    self.textInput.backgroundColor = [UIColor clearColor];
    self.textInput.keyboardAppearance = UIKeyboardAppearanceDark;
    self.textInput.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textInput.spellCheckingType = UITextSpellCheckingTypeYes;
    self.textInput.allowsEditingTextAttributes = YES;
    self.textInput.selectable = YES;
    self.textInput.editable = YES;
    self.textInput.secureTextEntry = YES;
    self.textInput.tintColor = [UIColor color:MysticColorTypePink];
    self.textInput.textContainer.lineFragmentPadding = 0;
    self.textInput.textContainerInset = UIEdgeInsetsMakeFrom(10);
    self.textInput.alpha = 0;
    self.textInput.textAlignment = self.fontView.textAlignment;
    self.textInput.delegate = self;
    _lastInputOffsetY = -(MAX(0, ([self.textInput bounds].size.height - [self.textInput contentSize].height * [self.textInput zoomScale])/2.0));
    self.textInput.contentOffset = (CGPoint){.x = 0, .y = _lastInputOffsetY};
    [self.presentView addSubview:self.textInput];
    self.startSize = self.textInput.attributedText.size;
    CGSize photoTrans = [MysticController controller].imageView.transformSize;
    self.transView = [[[MysticTransView alloc] initWithFrame:CGRectz(fromView.contentView.frame)] autorelease];
    self.transView.transform = CGAffineTransformScale(fromView.transform, photoTrans.width, photoTrans.height);
    self.originalTransform = CGAffineTransformRotateReset(self.transView.transform);
    self.endSize = [self.transView resizeToSmallestSubview].size;
    self.startSize = self.transView.frame.size;

    self.transView.contentView.userInteractionEnabled = NO;
    self.transView.contentView.bounds = fv.contentView.layoutView.bounds;
    self.transView.contentView.transform = fv.contentView.layoutView.transform;
    self.choice.attributedString = self.fontView.attributedText;
    self.transView.frame = [[self.choice resetScale] updateView:self.transView debug:nil].bounds;

    if(!CGScaleIsEqual(CGScaleMax(CGScaleOfSizes(fromView.contentView.frame.size, self.textInput.attributedText.size))))
    {
        MysticAttrString *str = [MysticAttrString string:self.textInput.attributedText];
        [str scaleToSize:CGRectApplyAffineTransform(self.transView.frame, CGAffineTransformInvert(self.transView.transform)).size];
        str.textAlignment = self.fontView.textAlignment;
        self.textInput.attributedText = str.attrString;
        self.textInput.font = str.font;
    }
    
    
    self.transView.userInteractionEnabled = NO;
    self.transView.center = [inView convertPoint:fv.center fromView:fv.superview];
    [self.presentView addSubview:self.transView];
    fv.hidden = YES;
    self.textInput.inputAccessoryView = [self makeInputAccessoryView];
    self.hiddenTextField = [[[MysticHiddenTextField alloc] initWithFrame:CGRectMake(-1000, 0, 10, 10)] autorelease];
    [self.presentView addSubview:self.hiddenTextField];
    [inView addSubview:self.presentView];
    _setupPresentView = YES;
    self.touchView.doubleTap = ^(UITouch *touch, UIEvent *event, MysticTouchView *touchView)
    {
        [weakSelf fadeInBgColor:YES sender:nil];
        [weakSelf toolbarKeyboard:nil];
    };
    [self fadeOutBgColor:NO sender:nil];
    [self.textInput becomeFirstResponder];
    [self findLastResponder];
    
    CGAffineTransform newTransform = CGAffineTransformScale(CGAffineTransformRotate(self.transView.transform, self.fontView.rotation * -1), 1/photoTrans.width, 1/photoTrans.height);
    CGPoint newCenter = CGPointDiff(self.textInput.center, (CGPoint){0,[self.textInput.text equals:@""] ? -1 : 0});
    self.transView.contentView.center = CGPointCenter(self.transView.bounds);
    self.transView.hidden = NO;
    self.transView.alpha = 1;
    [self updateViews];
    int n2 = self.choice.attributedString.numberOfLines;
    newCenter.y+=n2 > 1 ? -2.66 : -0;
    self.originalTextContainerSize = self.textInput.textContainer.size;
    self.originalTextContainerInsets = self.textInput.textContainerInset;
    CGSize textDiff = CGSizeDiff(self.textInput.frame.size, self.textInput.attributedText.size);
    self.textInput.textContainerInset = UIEdgeInsetsMake(10, textDiff.width/2-10, 10, textDiff.width/2-10);
    self.originalTextContainerInsets = self.textInput.textContainerInset;
    __unsafe_unretained __block MysticQuoteViewController *ws = self;
    [MysticUIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        if(ws.animationIn) ws.animationIn(), ws.animationIn=nil;
        [ws fadeInBgColor:NO sender:nil];
        ws.transView.transform = newTransform;
        ws.transView.center = newCenter;
    } completion:^(BOOL finished) {
        [ws updateViews];
        ws.transView.alpha = 0;
        ws.textInput.alpha = 1;
        _lastInputOffsetY = -MAX(0,([ws.textInput bounds].size.height - [ws.textInput contentSize].height * [ws.textInput zoomScale])/2.0);
        ws.textInput.contentOffset = (CGPoint){.x = 0, .y = _lastInputOffsetY};
        ws.textInput.secureTextEntry = NO;
        [ws addObserversForInput:ws.textInput];
    }];

    switch (self.setting) {
        case MysticSettingFontStyle: [self toolbarFont:nil]; break;
        case MysticSettingFontColor: [self toolbarFontColor:nil]; break;
        case MysticSettingFontAlign: [self toolbarFontAlign:nil]; break;
        case MysticSettingFontEffect: [self toolbarEffects:nil]; break;
        default: break;
    }
}

#pragma mark - Dismiss
- (void) dismissToView:(MysticLayerBaseView *)fromView animations:(MysticBlockAnimationInfo)animations complete:(MysticBlockBOOL)finished;
{
    [self removeObserversForTextInput];
    __unsafe_unretained __block MysticQuoteViewController *ws = self;
    CGScaleOfView t = [self.choice scaleOfView:fromView fromView:self.transView];
    self.textInput.hidden = YES;
    self.transView.hidden = NO;
    self.transView.alpha=1;
    [self updateViews];
    if(!CGAffineTransformHasRotation(t.transform) && self.fontView.rotation!=0)  t.transform = CGAffineTransformRotate(t.transform, self.fontView.rotation);
    __unsafe_unretained __block MysticBlockBOOL _finished = finished ? Block_copy(finished) : nil;
    ws.transView.alpha = 0 ;
    [MysticUIView animateWithDuration:.25 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        animations();
        if(ws.animationOut) ws.animationOut(), ws.animationOut=nil;
        [ws fadeOutBgColor:NO sender:@YES];
//        ws.transView.transform = t.transform;
//        ws.transView.center = t.offset;
        
    } completion:^(BOOL f) {
        [[NSNotificationCenter defaultCenter] removeObserver:ws];
        [ws.transView removeFromSuperview];
        if(ws.presentView) [ws.presentView removeFromSuperview];
        ws.hiddenTextField = nil;
        [ws.textInput removeFromSuperview];
        [ws.presentView removeFromSuperview];
        
        ws.presentView = nil;
        ws.textInput = nil;
        ws.fontView.hidden = NO;
        if(ws.transView) [ws.transView removeFromSuperview];
        [ws.presentView removeFromSuperview];
        if(_finished) { _finished(f); Block_release(_finished); }
    }];
}

- (void) addObserversForInput:(UITextView *)textInput;
{
    [textInput addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:self];
    [textInput addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:self];
}
- (void) removeObserversForTextInput;
{
    if(!self.textInput.delegate) return;
    self.textInput.delegate = nil;
    [self.textInput removeObserver:self forKeyPath:@"contentSize"];
    [self.textInput removeObserver:self forKeyPath:@"contentOffset"];
}


#pragma mark - Text View Delegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView; { return YES; }
- (BOOL)textViewShouldEndEditing:(UITextView *)textView; { return YES; }

- (void) setSpacing:(float)spacing;
{
    _spacing = spacing;
    MysticAttrString *attrStr = [MysticAttrString string:self.textInput.attributedText];
    attrStr.kerning = _spacing;
    [self textViewDidChange:(id)self.lastResponder];
}
- (void)textViewDidChange:(UITextView *)textView;
{
    MysticAttrString *attrStr = [MysticAttrString string:self.textInput.attributedText];
    attrStr.kerning = self.spacing;
    CGFloat lh = attrStr.lineHeight;
    int n2 = self.textInput.contentSize.height/lh;
    self.textInput.attributedText = attrStr.attrString;
    BOOL hasMultiLine = n2 > 1;
    if(hasMultiLine) { [self fixTextInputText:NO]; }
    [self observeValueForKeyPath:@"contentSize" ofObject:self.textInput change:@{@"animated": @YES, @"fix":@YES, @"observe":@YES, @"force":@(8888), @"finished":@NO, @"type": @"didChangeKerning"} context:nil];
    [self observeValueForKeyPath:@"contentSize" ofObject:self.textInput change:@{@"animated": @YES, @"fix":@YES, @"finished":@NO,  @"type": @"didChange"} context:nil];
    
}
- (BOOL) hasMultilineText;
{
    return [self.textInput.attributedText.string containsString:@"\n"] || self.textInput.contentSize.height/[(MysticAttrString *)[MysticAttrString string:self.textInput.attributedText] lineHeight] >= 2;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    MysticQuoteViewController *_context = context ? context : nil;
    
    if([keyPath isEqualToString:@"contentSize"])
    {
        NSString *defaultText = MYSTIC_DEFAULT_FONT_TEXT;
        BOOL defaultLonger = defaultText.length > self.textInput.attributedText.string.length;
        BOOL defaultShorter = defaultText.length < self.textInput.attributedText.string.length;
        if(self.textInput.attributedText.string && (defaultShorter || defaultLonger) && ((defaultLonger && [defaultText hasPrefix:self.textInput.attributedText.string]) || (defaultShorter && [self.textInput.attributedText.string hasPrefix:defaultText])))
        {
            NSMutableAttributedString *newStr = nil;
            NSRange range = NSMakeRange(0, self.textInput.attributedText.string.length);
            NSString *replacement = @"";
            if(defaultLonger) {
                newStr = [NSMutableAttributedString attributedStringWithAttributedString:[[self.textInput.attributedText copy] autorelease]];
                [newStr replaceCharactersInRange:range withString:@""];

            }
            else if(defaultShorter)
            {
                newStr = [NSMutableAttributedString attributedStringWithString:[self.textInput.attributedText.string substringFromIndex:defaultText.length]];
                NSRange newRange = NSMakeRange(0, 1);
                NSDictionary *attr = [self.textInput.attributedText attributesAtIndex:0 effectiveRange:&newRange];
                [newStr setAttributes:attr range:NSMakeRange(0, 1)];

            }
            mdispatch(^{ self.textInput.attributedText = newStr; });
        }
        
        
        BOOL observing = _context || (change && change[@"observe"] != nil) || (change && change[NSKeyValueChangeNewKey]);
        BOOL fix = (change && change[@"fix"] != nil && [change[@"fix"] boolValue]);
        BOOL runFinished = change && change[@"finished"] != nil ? [change[@"finished"] boolValue] : NO;
        id forceObserve = (change && change[@"force"] != nil) ? change[@"force"] : nil;
        BOOL animated = !change || !change[@"animated"] || (change[@"animated"] && [change[@"animated"] boolValue]) ? YES : NO;
        NSString *type = change && change[@"type"] ? change[@"type"] : nil;
        UITextView *txtview = self.textInput;
        CGFloat lastInput = _lastInputOffsetY;
        CGFloat currentY = txtview.contentOffset.y;
        CGFloat topoffset = ([txtview bounds].size.height - [txtview contentSize].height * [txtview zoomScale])/2.0;
        topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
        BOOL hasLast = !isnan(_lastInputOffsetY);
        BOOL isDiff = -topoffset != lastInput;
        BOOL isTextInputActive = self.textInput.isFirstResponder;
        NSString *typeStr = type ? type : @"---";
        CGFloat ny = -1;
        
        __unsafe_unretained __block MysticQuoteViewController *weakSelf = self;
        MysticBlockAnimationFinished finished = !runFinished ? nil : ^(BOOL finishedAnim)
        {
            if(fix)[weakSelf fixTextInputText:finishedAnim];
            [weakSelf updateInputAccessoryView];

        };
        
        if(runFinished) { finished(YES); return; }
        if(!forceObserve && observing && type && [type isEqualToString:@"didChange"]) observing = NO;
        
        if(observing || (forceObserve != nil))
        {
            ny = forceObserve ? [forceObserve floatValue] : NAN;
            if(!isnan(ny) && ny == 8888) ny = hasLast ? _lastInputOffsetY : -topoffset;
            else if(!isnan(ny) && ny == 9999) ny = -topoffset;
            ny = !isnan(ny) && (ny==8888 || ny==9999) ? -topoffset : ny;
            if(!isnan(ny) && self.textInput.contentOffset.y != ny)
            {
                self.textInput.contentOffset = (CGPoint){.x = 0, .y = ny};
                startedOffsetAnim = NO;
                _lastInputOffsetY = ny;
                if(finished) finished(YES);
            }
            else
            {
                if(!isTextInputActive && self.textInput.contentOffset.y != -topoffset)
                {
                    self.textInput.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
                    startedOffsetAnim = NO;
                    _lastInputOffsetY = -topoffset;
                    if(finished) finished(YES);
                }
            }
        }
        else
        {
            if(hasLast)
            {
                if(!animated)
                {
                    txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
                    startedOffsetAnim = NO;
                    _lastInputOffsetY = -topoffset;
                    if(finished) finished(YES);
                }
                else if(!startedOffsetAnim && isDiff)
                {
                    _lastInputOffsetY = -topoffset;
                    startedOffsetAnim = YES;
                    [MysticUIView animateWithDuration:0.25 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                        txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
                    } completion:^(BOOL finishedAnim) {
                        startedOffsetAnim = NO;
                        if(finished) finished(YES);
                    }];
                }
            }
            else if(isDiff)
            {
                startedOffsetAnim = NO;
                _lastInputOffsetY = -topoffset;
                txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
                if(finished) finished(YES);
            }
            else if(finished) finished(YES);
        }
    }
    else if([keyPath isEqualToString:@"contentOffset"])
    {
        if(!settingContentOffset && self.textInput.contentOffset.y ==0)
        {
            settingContentOffset = YES;
            if(isnan(_lastInputOffsetY))
            {
                CGFloat topoffset = ([self.textInput bounds].size.height - [self.textInput contentSize].height * [self.textInput zoomScale])/2.0;
                topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
                self.textInput.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
            }
            else self.textInput.contentOffset = (CGPoint){.x = 0, .y = _lastInputOffsetY};
            settingContentOffset = NO;
        }
    }
}
#pragma mark - Fix Text

- (void) fixTextInputText:(BOOL)shouldObserve;
{
    BOOL madeChanges = NO;
    CGFloat lineWidth = (self.originalTextContainerSize.width - self.originalTextContainerInsets.left - self.originalTextContainerInsets.right)*(1/self.transView.transform.a);
    CGSize lineSize = CGSizeZero;
    int li = -1;
    NSAttributedString *la = nil;
    NSMutableAttributedString *_ti = [NSMutableAttributedString attributedStringWithAttributedString:self.textInput.attributedText];
    // remove new lines
    for (int i = 0; i < self.textInput.attributedText.length; i++) {
        NSAttributedString *a = [self.textInput.attributedText attributedSubstringFromRange:NSMakeRange(i, 1)];
        NSDictionary *attr = [a attributesAtIndex:0 effectiveRange:NULL];
        if(attr[MysticAttrStringNewLineName])
        {
            a = (NSMutableAttributedString *)attr[MysticAttrStringNewLineName];
            [_ti removeAttribute:MysticAttrStringNewLineName range:NSMakeRange(i, 1)];
            [_ti replaceCharactersInRange:NSMakeRange(i, 1) withAttributedString:a];
        }
    }
    // readd new lines
    NSMutableAttributedString *ti = [NSMutableAttributedString attributedStringWithAttributedString:[[_ti copy] autorelease]];
    for (int i = 0; i < _ti.length; i++) {
        NSAttributedString *a = [_ti attributedSubstringFromRange:NSMakeRange(i, 1)];
        NSDictionary *attr = [a attributesAtIndex:0 effectiveRange:NULL];
        NSString *aString = a.string;
        if(a && ![aString isEqualToString:@"\n"])
        {
            lineSize.width += a.size.width;
            // is the current line wider than the max line width
            if(lineSize.width > lineWidth)
            {
                
                lineSize.width = a.size.width;
                // check if its on the first line
                if(!madeChanges && li < 0 && _ti.length > i+1)
                {
                    NSAttributedString *nextChar = [_ti attributedSubstringFromRange:NSMakeRange(i+1, 1)];
                    if([nextChar.string isEqualToString:@" "])
                    {
                        la = nextChar;
                        NSMutableAttributedString *replacement = [NSMutableAttributedString attributedStringWithString:@"\n"];
                        [ti replaceCharactersInRange:NSMakeRange(i+1, 1) withAttributedString:replacement];
                        [ti addAttribute:MysticAttrStringNewLineName value:la range:NSMakeRange(i+1, 1)];
                        madeChanges = YES;
                        lineSize.width = 0;
                        i = i+1;
                        la = nil;
                        li = -1;
                        continue;
                    }
                    
                }
                else if(la && li > -1)
                {
                    
                    NSMutableAttributedString *replacement = [NSMutableAttributedString attributedStringWithString:@"\n"];
                    [ti replaceCharactersInRange:NSMakeRange(li, 1) withAttributedString:replacement];
                    [ti addAttribute:MysticAttrStringNewLineName value:la range:NSMakeRange(li, 1)];
                    madeChanges = YES;
                    lineSize.width = 0;
                    i = li;
                    la = nil;
                    li = -1;
                    continue;
                }
            }
        }
        else if([aString isEqualToString:@"\n"]) lineSize.width = 0;
        if([a.string isEqualToString:@" "])
        {
            la = a;
            li = i;
        }
    }
    // set new string
    if(madeChanges)
    {
        MysticAttrString *attrStr = [MysticAttrString string:[ti copy]];
        float v = attrStr.lineHeightMultiple;
        float lh1 = attrStr.lineHeightMultiple;
        float lh2 = NAN;
        if((isnan(v) || v == 0) && self.lineHeightSlider.value != 0)
        {
            v = self.lineHeightSlider.value;
            lh2 = v;
        }
        if(!isnan(v) && v != 0) [attrStr setLineHeightMultiple:v];
        attrStr.textAlignment = self.textAlignment;
        mdispatch(^{
            self.textInput.attributedText = attrStr.attrString;
            self.choice.attributedString = attrStr;
        });
    }
    else
    {
        MysticAttrString *attrStr = [MysticAttrString string:ti];
        attrStr.textAlignment = self.textAlignment;
        mdispatch(^{
            self.textInput.attributedText = attrStr.attrString;
            self.choice.attributedString = attrStr;
        });
    }
    
    if(shouldObserve) [self observeValueForKeyPath:@"contentSize" ofObject:self.textInput change:@{@"observe": @YES, @"fix":@NO, @"finished":@NO, @"force":@(9999), @"type": @"fixedInputText"} context:nil];

}

- (void) unloadViews;
{
    
    if(self.transView) [self.transView removeFromSuperview];
    if(self.presentView) [self.presentView removeFromSuperview];
    self.transView = nil;
    self.presentView = nil;
    self.hiddenTextField = nil;
    
}

- (void) updateInputAccessoryView;
{
    for (MysticBarButtonItem *item in self.toolbar.items) {
        if(item.button && item.toolType == MysticToolTypeTextAlign)
        {
            item.button.enabled = self.hasMultilineText;
            item.button.alpha = item.button.enabled ? 1 : 0.32f;
        }
    }
}
- (void) fontSelected:(MysticScrollViewControl *)fontBtn;
{
    if(_setupInputView) return;
    NSInteger i = fontBtn.position;
    self.fontOption = [((MysticScrollView *)fontBtn.superview).controlsData objectAtIndex:i];;
    MysticAttrString *attrStr = [MysticAttrString string:self.textInput.attributedText];
    CGSize bs = attrStr.attrString.size;
    attrStr.font = [self.fontOption.font fontWithSize:self.textInput.font.pointSize];
    self.textInput.font = attrStr.font;
    CGSize as = attrStr.attrString.size;
    if(!CGSizeHeightIsEqualThreshold(bs,as,.07)) [attrStr scaleToSize:CGSizeScale(as,bs.height/as.height)];
    self.textInput.attributedText = attrStr.attrString;
    self.textInput.contentOffset = (CGPoint){.x = 0, .y = _lastInputOffsetY};
    for (MysticScrollViewControl *sibling in fontBtn.siblings) if(sibling.selected) sibling.selected = NO;
    fontBtn.selected = YES;
    self.choice.attributedString = attrStr;
    [self updateViews];
}
- (void) setFont:(UIFont *)font;
{
    MysticAttrString *attrStr = [MysticAttrString string:self.textInput.attributedText];
    CGSize bs = attrStr.attrString.size;
    attrStr.font = [font fontWithSize:self.textInput.font.pointSize];
    self.textInput.font = attrStr.font;
    
    CGSize as = attrStr.attrString.size;
    if(!CGSizeHeightIsEqualThreshold(bs,as,.1)) [attrStr scaleToSize:CGSizeScale(as,bs.height/as.height)];
    self.textInput.attributedText = attrStr.attrString;
    self.textInput.contentOffset = (CGPoint){.x = 0, .y = _lastInputOffsetY};
    self.choice.attributedString = attrStr;
    [self updateViews];
}
- (UIFont *) font;
{
    return self.textInput.font;
}
- (void) fontAlignCenter:(MysticBarButton *)button;
{
    self.textInput.textAlignment = NSTextAlignmentCenter;
}
- (void) fontAlignLeft:(MysticBarButton *)button;
{
    self.textInput.textAlignment = NSTextAlignmentLeft;
    
}
- (void) fontAlignRight:(MysticBarButton *)button;
{
    self.textInput.textAlignment = NSTextAlignmentRight;
    
}

- (void) lineHeightSliderChanged:(MysticSlider *)slider;
{
    UILabel *sliderLabel = (id)[slider.superview viewWithTag:1231];
    if(sliderLabel)
    {
        float value = floorf(slider.value * 10 + 0.5) / 10;
        float value2 = floorf(slider.value * 100 + 0.5) / 100;
        
        float vabs = fabsf(value);
        
        sliderLabel.text = [NSString stringWithFormat:@"%@%2.1f", vabs < 0.1 ? @"" : (value > 0 ? @"+" : @"-"), vabs];
    }
    if(_setupInputView) return;
    
    _lineHeight = slider.value;
    
    
    
    MysticAttrString *attrStr = [MysticAttrString string:self.textInput.attributedText];
    attrStr.textAlignmentValue = self.textAlignment;
    [attrStr setLineHeightMultiple:slider.value lineHeight:0];
    
    CGRect txtFrame = self.textInput.frame;

    UITextView *tv = [[UITextView alloc] initWithFrame:txtFrame];
    tv.attributedText = attrStr.attrString;
    tv.inputAccessoryView = nil;
    tv.backgroundColor = [UIColor clearColor];
    tv.keyboardAppearance = UIKeyboardAppearanceDark;
    tv.autocorrectionType = UITextAutocorrectionTypeNo;
    tv.spellCheckingType = UITextSpellCheckingTypeYes;
    tv.allowsEditingTextAttributes = YES;
    tv.selectable = YES;
    tv.editable = YES;
    tv.inputView = self.textInput.inputView;
    tv.inputAccessoryView = self.textInput.inputAccessoryView;
    tv.tintColor = [UIColor color:MysticColorTypePink];
    tv.textContainer.lineFragmentPadding = 0;
    tv.delegate = self;
    tv.hidden = self.textInput.hidden;
    CGFloat topoffset = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
    _lastInputOffsetY = -topoffset;
    tv.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
    [self.presentView addSubview:tv];
    if([self.lastResponder isEqual:self.textInput]) self.lastResponder = (id)tv;
    [self removeObserversForTextInput];
    [self.textInput removeFromSuperview];
    self.textInput = [tv autorelease];
    [self addObserversForInput:self.textInput];
    
    [self observeValueForKeyPath:@"contentSize" ofObject:self.textInput change:@{@"observe": @YES, @"fix":@YES, @"finished":@YES, @"force":@(9999), @"type": @"lineHeight"} context:nil];
    [self.textInput setNeedsLayout];
    [self.textInput layoutIfNeeded];
    self.choice.attributedString=attrStr;
    [self updateViews];
//    DLog(@"lineHeight changed:  %2.2f  \n\n%@", attrStr.lineHeightMultiple, ColorWrap(attrStr.description, COLOR_DULL));
}
- (void) setTextAlignment:(NSTextAlignment)textAlignment;
{
    _textAlignment = textAlignment;

}
- (void) textSpacingSliderChanged:(MysticSlider *)slider;
{
    if(slider)
    {
        UILabel *sliderLabel = (id)[slider.superview viewWithTag:1232];
        if(sliderLabel) sliderLabel.text = [NSString stringWithFormat:@"%@%2.1f", slider.value==0 ? @"" : (slider.value > 0 ? @"+" : @""), slider.value];
    }
    if(_setupInputView) return;
    if(slider)
    {
        self.spacing = slider.value;
        MysticAttrString *attrStr = [MysticAttrString string:self.textInput.attributedText];
        NSTextAlignment ta = attrStr.textAlignment;
        attrStr.kerning = slider.value;
        attrStr.textAlignment = self.textAlignment;
        self.textInput.attributedText = attrStr.attrString;
        self.choice.attributedString = attrStr;
    }
    [self observeValueForKeyPath:@"contentSize" ofObject:self.textInput change:@{@"observe": @YES, @"fix":@YES, @"finished":@YES, @"force":@(9999), @"type": @"spacing"} context:nil];
    [self updateViews];


}
- (void) opacitySliderChanged:(MysticSlider *)slider;
{
    UILabel *sliderLabel = (id)[slider.superview viewWithTag:1233];
    if(sliderLabel)
    {
        sliderLabel.text = [NSString stringWithFormat:@"%2.0f%%", slider.value*100];
    }
    UIColor *newColor = [self.color colorWithAlphaComponent:[@(slider.value) floatValue]];
    self.colorAlpha = slider.value;
    self.color = newColor;
    self.choice.color = newColor;
    if(_setupInputView) return;
    MysticAttrString *attrStr = [MysticAttrString string:self.textInput.attributedText];
    attrStr.color = newColor;
    self.textInput.attributedText = attrStr.attrString;
    self.choice.attributedString = attrStr;
    [self updateViews:nil debug:nil];
    
}

- (void) opacitySliderBegin:(MysticSlider *)slider;
{
    [self fadeOutBgColor:YES sender:nil];
    
}

- (void) opacitySliderEnd:(MysticSlider *)slider;
{
    [self fadeInBgColor:YES sender:nil];
}

- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;
{
    switch (toolbar.tag) {
        case MysticToolTypeAlign: [toolbar selectItem:sender];  break;
        default: break;
    }
}
- (void) setColor:(UIColor *)color;
{
    [super setColor:color];
    self.choice.attributedString.color = color;
    self.textInput.attributedText = self.choice.attributedString.attrString;
}
- (void) setContent:(id)content;
{
    [super setContent:content];
    self.choice.type = MysticObjectTypeFont;
}


- (UIView *) contentView; { return self.transView; }

#pragma mark - Update Views


- (void) updateViews; { if(self.transView) [self updateViews:@[self.transView] debug:nil]; }
- (void) updateViews:(NSArray *)shadowViews debug:(id)debug;
{
    if(!self.choice.attributedString)
    {
        self.choice.attributedString = [MysticAttrString string:self.textInput.attributedText];
        self.choice.attributedString.textAlignment = self.textAlignment;
    }
    self.choice.rebuildFrame=YES;
    self.choice.refitFrame=YES;
    self.shouldResizeContent=NO;
    self.choice.pathAdjustsFrameSize = YES;
    self.choice.size = CGSizeUnknown;
    self.choice.offset = CGPointZero;
    self.choice.maxWidth = (self.originalTextContainerSize.width - self.originalTextContainerInsets.left - self.originalTextContainerInsets.right)*(1/self.transView.transform.a);

    [super updateViews:shadowViews?shadowViews:@[self.transView] debug:debug];
    [self.transView resizeToBiggestSubview:self.transView.contentView];
    [self.transView updateLayout:YES];
    int n2 = self.choice.attributedString.numberOfLines;
    CGFloat xy = n2 > 1 ? -2.66 : -0;
    self.transView.center = CGPointAddXY(self.textInput.center, 0.5, self.originalTextContainerInsets.top/[MysticUI scale]+xy);
    if(!_hasDoneDeepView)
    {
        CGPoint oldCenter = self.transView.center;
        [self.transView deepCopy:self.fontView.transView];
        self.transView.center = oldCenter;
        _hasDoneDeepView=YES;
    }
}
@end
