//
//  SettingsViewController.m
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "SettingsViewController.h"
#import "MBProgressHUD.h"
#import "TitleView.h"

@interface SettingsViewController ()
{
    UIImageView *nippleView, *bottomNippleView;
    UIButton *colorButton;
    UIButton *effectsButton;
    UIButton *lightingButton;
    UIButton *framesButton;
    CGFloat lightingValue, colorValue, gammaValue, exposureValue;
    MBProgressHUD *HUD;
    BOOL showHUD;
    MysticSlider *extraSlider;
    CGPoint startPoint, endPoint, lastPoint;
    BOOL reloadingImage;
    MysticObjectType currentSetting;
    
}
@end

@implementation SettingsViewController

@synthesize imageView=_imageView, photoView=_photoView, imageBackgroundView=_imageBackgroundView, controlScrollView=_controlScrollView, bottomBar=_bottomBar, imageToolBar=_imageToolBar, sliderView=_sliderView, slider=_slider, bottomToolbar=_bottomToolbar;

- (void) dealloc
{
    if(nippleView) [nippleView release], nippleView = nil;
    if(bottomNippleView) [bottomNippleView release], bottomNippleView = nil;
    if(_imageView) [_imageView release], _imageView = nil;
    if(_photoView) [_photoView release], _photoView = nil;
    if(_imageBackgroundView) [_imageBackgroundView release], _imageBackgroundView = nil;
    if(_controlScrollView) [_controlScrollView release], _controlScrollView = nil;
    if(_bottomBar) [_bottomBar release], _bottomBar = nil;
    if(_imageToolBar) [_imageToolBar release], _imageToolBar = nil;
    if(_sliderView) [_sliderView release], _sliderView = nil;
    if(_slider) [_slider release], _slider = nil;
    if(colorButton) [colorButton release], colorButton=nil;
    if(effectsButton) [effectsButton release], effectsButton=nil;
    if(lightingButton) [lightingButton release], lightingButton=nil;
    if(framesButton) [framesButton release], framesButton=nil;
    
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        lightingValue = [UserPotion potion].brightness;
        colorValue = [UserPotion potion].colorAlpha;
        exposureValue = [UserPotion potion].exposure;
        gammaValue = [UserPotion potion].gamma;
        showHUD = YES;
        reloadingImage=NO;
        currentSetting = MysticSettingFilter;
        
        
        UIButton *fwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fwdButton.frame = CGRectMake(0, 0, 50, 33);
        UIImage *backNormal = [UIImage imageNamed:@"button-back-bg.png"];
        if([backNormal respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            backNormal = [backNormal resizableImageWithCapInsets:UIEdgeInsetsMake(3, 6, 3, 6) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            backNormal = [backNormal resizableImageWithCapInsets:UIEdgeInsetsMake(3, 6, 3, 6)];
        }
        UIImage *backHighlighted = [UIImage imageNamed:@"button-back-bg-highlighted.png"];
        if([backHighlighted respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)])
        {
            backHighlighted = [backHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(3, 6, 3, 6) resizingMode:UIImageResizingModeStretch];
        }
        else
        {
            backHighlighted = [backHighlighted resizableImageWithCapInsets:UIEdgeInsetsMake(3, 6, 3, 6)];
        }
        [fwdButton setImageEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        [fwdButton setBackgroundImage:backNormal forState:UIControlStateNormal];
        [fwdButton setBackgroundImage:backHighlighted forState:UIControlStateHighlighted];
        [fwdButton setImage:[UIImage imageNamed:@"check-highlighted.png"] forState:UIControlStateNormal];
        [fwdButton setImage:[UIImage imageNamed:@"check-highlighted.png"] forState:UIControlStateHighlighted];
        [fwdButton addTarget:self action:@selector(fwdButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *customFwdButtonBar = [[UIBarButtonItem alloc] initWithCustomView:fwdButton];
        self.navigationItem.leftBarButtonItem = customFwdButtonBar;
        self.navigationItem.hidesBackButton = YES;
        [customFwdButtonBar release];
        
        
        TitleView *titleView = [[TitleView alloc] initWithFrame:CGRectMake(0, 0, 253, 50)];
        
        
        CGFloat paddingX = 23;
        CGRect controlFrame = CGRectMake(20, 0, 40, 50);
        
        colorButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        effectsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        lightingButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        framesButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        
        colorButton.frame = controlFrame;
        controlFrame.origin.x = controlFrame.origin.x + 40 + paddingX;
        effectsButton.frame = controlFrame;
        controlFrame.origin.x = controlFrame.origin.x + 40 + paddingX;
        lightingButton.frame = controlFrame;
        controlFrame.origin.x = controlFrame.origin.x + 40 + paddingX;
        framesButton.frame = controlFrame;
        
        [colorButton setImage:[UIImage imageNamed:@"color-selected.png"] forState:UIControlStateNormal];
        [colorButton setImage:[UIImage imageNamed:@"color-highlighted.png"] forState:UIControlStateHighlighted];
        [colorButton setImage:[UIImage imageNamed:@"color-selected.png"] forState:UIControlStateSelected];
        colorButton.adjustsImageWhenDisabled = NO;
        
        
        [effectsButton setImage:[UIImage imageNamed:@"effects.png"] forState:UIControlStateNormal];
        [effectsButton setImage:[UIImage imageNamed:@"effects-highlighted.png"] forState:UIControlStateHighlighted];
        [effectsButton setImage:[UIImage imageNamed:@"effects-selected.png"] forState:UIControlStateSelected];
        effectsButton.adjustsImageWhenDisabled = NO;
        
        [lightingButton setImage:[UIImage imageNamed:@"lighting.png"] forState:UIControlStateNormal];
        [lightingButton setImage:[UIImage imageNamed:@"lighting-highlighted.png"] forState:UIControlStateHighlighted];
        [lightingButton setImage:[UIImage imageNamed:@"lighting-selected.png"] forState:UIControlStateSelected];
        lightingButton.adjustsImageWhenDisabled = NO;
        
        [framesButton setImage:[UIImage imageNamed:@"frames.png"] forState:UIControlStateNormal];
        [framesButton setImage:[UIImage imageNamed:@"frames-highlighted.png"] forState:UIControlStateHighlighted];
        [framesButton setImage:[UIImage imageNamed:@"frames-selected.png"] forState:UIControlStateSelected];
        framesButton.adjustsImageWhenDisabled = NO;
        
        [colorButton addTarget:self action:@selector(colorTouched:) forControlEvents:UIControlEventTouchUpInside];
        [effectsButton addTarget:self action:@selector(effectsTouched:) forControlEvents:UIControlEventTouchUpInside];
        [lightingButton addTarget:self action:@selector(lightingTouched:) forControlEvents:UIControlEventTouchUpInside];
        [framesButton addTarget:self action:@selector(framesTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        [titleView addSubview:colorButton];
        [titleView addSubview:effectsButton];
        [titleView addSubview:lightingButton];
        [titleView addSubview:framesButton];
        nippleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, 19, 11)];
        nippleView.image = [UIImage imageNamed:@"nipple.jpg"];
        [titleView addSubview:nippleView];
        
        CGRect nippleFrame = nippleView.frame;
        nippleFrame.origin.x = colorButton.frame.origin.x + CGRectGetWidth(colorButton.frame)/2 - CGRectGetWidth(nippleView.frame)/2;
        nippleView.frame = nippleFrame;
        
        
        
        
        self.navigationItem.titleView = titleView;
        [titleView release];
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    CGRect bnframe = CGRectMake(0, 3, 19, 11);
    bottomNippleView = [[UIImageView alloc] initWithFrame:bnframe];
    bottomNippleView.image = [UIImage imageNamed:@"nipple-bottom.jpg"];
    [self.bottomToolbar addSubview:bottomNippleView];
    [self colorTouched:nil];
    //[self reloadImage];
    self.imageView.image = [UserPotion potion].finalImage;
}


- (void) reloadImage
{
    [self reloadImage:YES];
}
- (void) reloadImage:(BOOL)useHUD
{
    if(HUD)
    {
        [MBProgressHUD hideHUDForView:self.photoView animated:NO];
    }
    reloadingImage = YES;
    [UserPotion render:self.imageView.bounds.size start:^{
        if(useHUD)
        {
            HUD = [MBProgressHUD showHUDAddedTo:self.photoView animated:YES];
        }
    } complete:^(UIImage *image, NSIndexSet *levels, NSIndexSet *cachedLevels) {
        self.imageView.image = image;
        if(useHUD) [MBProgressHUD hideHUDForView:self.photoView animated:YES];
        reloadingImage = NO;
    }];
}

- (void) moveNippleTo:(UIButton *)button
{
    CGFloat x = button.frame.origin.x + CGRectGetWidth(button.frame)/2 - CGRectGetWidth(nippleView.frame)/2;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect nippleFrame = nippleView.frame;
        nippleFrame.origin.x = x;
        nippleView.frame = nippleFrame;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void) moveBottomNippleTo:(UIButton *)button
{
    CGRect bnframe = CGRectMake(0, 3, 19, 11);
    if(button==nil)
    {
        
        bnframe.origin.x = CGRectGetMidX(self.bottomToolbar.frame) - CGRectGetWidth(bnframe)/2;
        
    }
    else
    {
        bnframe.origin.x = button.frame.origin.x + CGRectGetWidth(button.frame)/2 - CGRectGetWidth(bottomNippleView.frame)/2;
    }
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        bottomNippleView.frame = bnframe;
    } completion:^(BOOL finished) {
        
    }];
    
}
- (void) backButtonTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) fwdButtonTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)sliderValueChanged:(UISlider *)sender
{
    if(!lightingButton.enabled)
    {
        showHUD = NO;
        lightingValue = self.slider.value;
        [UserPotion potion].brightness = lightingValue;
        [self reloadImage:YES];
    }
    else if(!colorButton.enabled)
    {
        colorValue = self.slider.value;
        [UserPotion potion].colorAlpha = colorValue;
        [self reloadImage:YES];
    }
}

- (void) colorTouched:(id)sender
{
    
    currentSetting = MysticSettingFilter;
    colorButton.selected = YES;
    effectsButton.selected = NO;
    lightingButton.selected = NO;
    framesButton.selected = NO;
    
    colorButton.enabled = NO;
    effectsButton.enabled = YES;
    lightingButton.enabled = YES;
    framesButton.enabled = YES;
    
    [colorButton setImage:[UIImage imageNamed:@"color-selected.png"] forState:UIControlStateNormal];
    [effectsButton setImage:[UIImage imageNamed:@"effects.png"] forState:UIControlStateNormal];
    [lightingButton setImage:[UIImage imageNamed:@"lighting.png"] forState:UIControlStateNormal];
    [framesButton setImage:[UIImage imageNamed:@"frames.png"] forState:UIControlStateNormal];
//    CGRect sliderFrame = self.sliderView.frame;
//    sliderFrame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.sliderView.frame);
//    self.sliderView.frame = sliderFrame;
    self.sliderView.hidden = NO;
    self.slider.minimumValueImage = [UIImage imageNamed:@"color-transparent.png"];
    self.slider.maximumValueImage = [UIImage imageNamed:@"lighting-dark.png"];
    self.slider.value = colorValue;
    self.slider.minimumValue = 0.0;
    self.slider.maximumValue = 1.0;
    
    
    [self moveNippleTo:colorButton];
    [self moveBottomNippleTo:nil];
    if([self.imageToolBar.subviews count])
    {
        [self removeControls:self.imageToolBar except:[NSArray arrayWithObject:bottomNippleView]];
        self.imageToolBar.userInteractionEnabled = NO;
        self.imageToolBar.hidden = YES;
    }
    
    if(extraSlider)
    {
        [extraSlider removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
        [extraSlider removeFromSuperview];
        [extraSlider release], extraSlider = nil;
    }
    
    [self loadControls:[UserPotion potion].potion.filterOptions type:MysticObjectTypeFilter scrollView:self.controlScrollView sender:nil];
    
    
    
}
- (void) effectsTouched:(id)sender
{
    
    
    self.sliderView.hidden = YES;
    
    colorButton.enabled = YES;
    effectsButton.enabled = NO;
    lightingButton.enabled = YES;
    framesButton.enabled = YES;
    
    colorButton.selected = NO;
    effectsButton.selected = YES;
    lightingButton.selected = NO;
    framesButton.selected = NO;
    
    [colorButton setImage:[UIImage imageNamed:@"color.png"] forState:UIControlStateNormal];
    [effectsButton setImage:[UIImage imageNamed:@"effects-selected.png"] forState:UIControlStateNormal];
    [lightingButton setImage:[UIImage imageNamed:@"lighting.png"] forState:UIControlStateNormal];
    [framesButton setImage:[UIImage imageNamed:@"frames.png"] forState:UIControlStateNormal];
    
    [self moveNippleTo:effectsButton];
    [self removeControls:self.imageToolBar except:[NSArray arrayWithObject:bottomNippleView]];
    
    UIButton *textSubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *colorSubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *badgeSubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *vignetteSubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat paddingX = 10;
    CGRect controlFrame = CGRectMake(7, 7, 44, 44);
    
    
    textSubButton.frame = controlFrame;
    controlFrame.origin.x = controlFrame.origin.x + CGRectGetWidth(controlFrame) + paddingX;
    colorSubButton.frame = controlFrame;
    controlFrame.origin.x = controlFrame.origin.x + CGRectGetWidth(controlFrame) + paddingX;
    badgeSubButton.frame = controlFrame;
    controlFrame.origin.x = controlFrame.origin.x + CGRectGetWidth(controlFrame) + paddingX;
    vignetteSubButton.frame = controlFrame;
    controlFrame.origin.x = controlFrame.origin.x + CGRectGetWidth(controlFrame) + paddingX;
    
    [textSubButton setImage:[UIImage imageNamed:@"subtext.png"] forState:UIControlStateNormal];
    [textSubButton setImage:[UIImage imageNamed:@"subtext-highlighted.png"] forState:UIControlStateSelected];
    
    
    [colorSubButton setImage:[UIImage imageNamed:@"subcolor.png"] forState:UIControlStateNormal];
    [colorSubButton setImage:[UIImage imageNamed:@"subcolor-highlighted.png"] forState:UIControlStateSelected];

    [badgeSubButton setImage:[UIImage imageNamed:@"subbadges.png"] forState:UIControlStateNormal];
    [badgeSubButton setImage:[UIImage imageNamed:@"subbadges-highlighted.png"] forState:UIControlStateSelected];
    
    [vignetteSubButton setImage:[UIImage imageNamed:@"mask.png"] forState:UIControlStateNormal];
    [vignetteSubButton setImage:[UIImage imageNamed:@"mask-selected.png"] forState:UIControlStateSelected];
    
    
    
    
    [textSubButton addTarget:self action:@selector(subTextTouched:) forControlEvents:UIControlEventTouchUpInside];
    [colorSubButton addTarget:self action:@selector(subColorTouched:) forControlEvents:UIControlEventTouchUpInside];
    [badgeSubButton addTarget:self action:@selector(subBadgeTouched:) forControlEvents:UIControlEventTouchUpInside];
    [vignetteSubButton addTarget:self action:@selector(subMaskTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imageToolBar addSubview:textSubButton];
    [self.imageToolBar addSubview:colorSubButton];
    [self.imageToolBar addSubview:badgeSubButton];
    [self.imageToolBar addSubview:vignetteSubButton];
    self.imageToolBar.hidden = NO;
    self.imageToolBar.userInteractionEnabled = YES;
    
    if(extraSlider)
    {
        [extraSlider removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
        [extraSlider removeFromSuperview];
        [extraSlider release], extraSlider = nil;
    }
    
    [self subTextTouched:textSubButton];
    
    
    
}
- (void) lightingTouched:(id)sender
{
    currentSetting = MysticSettingBrightness;
    
    colorButton.enabled = YES;
    effectsButton.enabled = YES;
    lightingButton.enabled = NO;
    framesButton.enabled = YES;
    
    colorButton.selected = NO;
    effectsButton.selected = NO;
    lightingButton.selected = YES;
    framesButton.selected = NO;
    
    [colorButton setImage:[UIImage imageNamed:@"color.png"] forState:UIControlStateNormal];
    [effectsButton setImage:[UIImage imageNamed:@"effects.png"] forState:UIControlStateNormal];
    [lightingButton setImage:[UIImage imageNamed:@"lighting-selected.png"] forState:UIControlStateNormal];
    [framesButton setImage:[UIImage imageNamed:@"frames.png"] forState:UIControlStateNormal];
    
//    CGRect sliderFrame = self.sliderView.frame;
//    sliderFrame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.sliderView.frame);
//    self.sliderView.frame = sliderFrame;
    
    
    self.slider.minimumValueImage = [UIImage imageNamed:@"lighting-dark.png"];
    self.slider.maximumValueImage = [UIImage imageNamed:@"lighting-bright.png"];
    self.slider.minimumValue = -0.9;
    self.slider.maximumValue = 0.9;
    self.slider.value = lightingValue;
    
    
    
    [self moveNippleTo:lightingButton];
    [self moveBottomNippleTo:nil];
    
    if(extraSlider)
    {
        [extraSlider removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
        [extraSlider removeFromSuperview];
        [extraSlider release], extraSlider = nil;
    }
    if([self.imageToolBar.subviews count])
    {
        [self removeControls:self.imageToolBar except:[NSArray arrayWithObject:bottomNippleView]];
        self.imageToolBar.userInteractionEnabled = NO;
        self.imageToolBar.hidden = YES;
    }
    
    //[self removeOptionControls:self.controlScrollView];
    [self hideControls:self.controlScrollView completed:^{
        self.sliderView.hidden = NO;
    }];
}
- (void) framesTouched:(id)sender
{
    //self.sliderView.userInteractionEnabled = NO;
    colorButton.enabled = YES;
    effectsButton.enabled = YES;
    lightingButton.enabled = YES;
    framesButton.enabled = NO;
    
    colorButton.selected = NO;
    effectsButton.selected = NO;
    lightingButton.selected = NO;
    framesButton.selected = YES;
    
    [colorButton setImage:[UIImage imageNamed:@"color.png"] forState:UIControlStateNormal];
    [effectsButton setImage:[UIImage imageNamed:@"effects.png"] forState:UIControlStateNormal];
    [lightingButton setImage:[UIImage imageNamed:@"lighting.png"] forState:UIControlStateNormal];
    [framesButton setImage:[UIImage imageNamed:@"frames-selected.png"] forState:UIControlStateNormal];
    self.sliderView.hidden = YES;
    
    [self moveNippleTo:framesButton];
    [self removeControls:self.imageToolBar except:[NSArray arrayWithObject:bottomNippleView]];
    
    
    
    UIButton *framesSubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *texturesSubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *lightSubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat paddingX = 10;
    CGRect controlFrame = CGRectMake(7, 7, 44, 44);
    
    
    framesSubButton.frame = controlFrame;
    controlFrame.origin.x = controlFrame.origin.x + CGRectGetWidth(controlFrame) + paddingX;
    texturesSubButton.frame = controlFrame;
    controlFrame.origin.x = controlFrame.origin.x + CGRectGetWidth(controlFrame) + paddingX;
    lightSubButton.frame = controlFrame;
    
    [framesSubButton setImage:[UIImage imageNamed:@"subframes.png"] forState:UIControlStateNormal];
    [framesSubButton setImage:[UIImage imageNamed:@"subframes-selected.png"] forState:UIControlStateSelected];
    
    
    [texturesSubButton setImage:[UIImage imageNamed:@"texture.png"] forState:UIControlStateNormal];
    [texturesSubButton setImage:[UIImage imageNamed:@"texture-selected.png"] forState:UIControlStateSelected];
    
    [lightSubButton setImage:[UIImage imageNamed:@"sublight.png"] forState:UIControlStateNormal];
    [lightSubButton setImage:[UIImage imageNamed:@"sublight-highlighted.png"] forState:UIControlStateSelected];

    
    
    [framesSubButton addTarget:self action:@selector(subFramesTouched:) forControlEvents:UIControlEventTouchUpInside];
    [texturesSubButton addTarget:self action:@selector(subTexturesTouched:) forControlEvents:UIControlEventTouchUpInside];
    [lightSubButton addTarget:self action:@selector(subLightTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imageToolBar addSubview:framesSubButton];
    [self.imageToolBar addSubview:texturesSubButton];
    [self.imageToolBar addSubview:lightSubButton];
    self.imageToolBar.hidden = NO;
    self.imageToolBar.userInteractionEnabled = YES;
    [self subFramesTouched:framesSubButton];
    
}

- (void) subFramesTouched:(UIButton *)sender
{
    currentSetting = MysticSettingFrame;
    
    [self moveBottomNippleTo:sender];
    for (UIButton *siblingButton in sender.superview.subviews) {
        if(![siblingButton isEqual:sender]) siblingButton.selected = NO;
    }
    sender.selected = YES;
    [self loadControls:[UserPotion potion].potion.frameOptions type:MysticObjectTypeFrame scrollView:self.controlScrollView sender:nil];
    
    if(extraSlider)
    {
        [extraSlider removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
        [extraSlider removeFromSuperview];
        [extraSlider release], extraSlider = nil;
    }
}
- (void) subTexturesTouched:(UIButton *)sender
{
    currentSetting = MysticSettingTexture;
    [self moveBottomNippleTo:sender];
    for (UIButton *siblingButton in sender.superview.subviews) {
        if(![siblingButton isEqual:sender]) siblingButton.selected = NO;
    }
    sender.selected = YES;
    [self loadControls:[UserPotion potion].potion.textureOptions type:MysticObjectTypeTexture scrollView:self.controlScrollView sender:nil];
    
    if(!extraSlider)
    {
        extraSlider = [[MysticSlider alloc] initWithFrame:CGRectMake(0, 0, 100, 23)];
        [self.imageToolBar addSubview:extraSlider];
    }
    [extraSlider removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
    [extraSlider addTarget:self action:@selector(subTexturesSliderChanged:) forControlEvents:UIControlEventValueChanged];
    extraSlider.continuous = NO;
    extraSlider.minimumValue = 0;
    extraSlider.maximumValue = 1;
    extraSlider.value = 1;
    extraSlider.frame = CGRectMake(170, 18, 140, 23);
    
}

-(void)subTexturesSliderChanged:(UISlider *)sender
{
    [UserPotion potion].textureAlpha = sender.value;
    [self reloadImage:YES];
}

- (void) subLightTouched:(UIButton *)sender
{
    currentSetting = MysticSettingLighting;
    [self moveBottomNippleTo:sender];
    for (UIButton *siblingButton in sender.superview.subviews) {
        if(![siblingButton isEqual:sender]) siblingButton.selected = NO;
    }
    sender.selected = YES;
    [self loadControls:[UserPotion potion].potion.lightOptions type:MysticObjectTypeLight scrollView:self.controlScrollView sender:nil];
    
    if(!extraSlider)
    {
        extraSlider = [[MysticSlider alloc] initWithFrame:CGRectMake(0, 0, 100, 23)];
        [self.imageToolBar addSubview:extraSlider];
    }
    [extraSlider removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
    [extraSlider addTarget:self action:@selector(subLightSliderChanged:) forControlEvents:UIControlEventValueChanged];
    extraSlider.continuous = NO;
    extraSlider.minimumValue = 0;
    extraSlider.maximumValue = 1;
    extraSlider.value = 1;
    extraSlider.frame = CGRectMake(170, 18, 140, 23);
}

-(void)subLightSliderChanged:(UISlider *)sender
{
    [UserPotion potion].lightingAlpha = sender.value;
    [self reloadImage:YES];
}



- (void) subTextTouched:(UIButton *)sender
{
    currentSetting = MysticSettingText;
    [self moveBottomNippleTo:sender];
    for (UIButton *siblingButton in sender.superview.subviews) {
        if(![siblingButton isEqual:sender]) siblingButton.selected = NO;
    }
    sender.selected = YES;
    [self loadControls:[UserPotion potion].potion.textOptions type:MysticObjectTypeText scrollView:self.controlScrollView sender:nil];
}

- (void) subColorTouched:(UIButton *)sender
{
    currentSetting = MysticSettingTextColor;
    [self moveBottomNippleTo:sender];
    for (UIButton *siblingButton in sender.superview.subviews) {
        if(![siblingButton isEqual:sender]) siblingButton.selected = NO;
    }
    sender.selected = YES;
    [self loadControls:[UserPotion potion].potion.textColorOptions type:MysticObjectTypeTextColor scrollView:self.controlScrollView sender:nil];
}

- (void) subBadgeColorTouched:(UIButton *)sender
{
    currentSetting = MysticSettingBadgeColor;
    [self moveBottomNippleTo:sender];
    for (UIButton *siblingButton in sender.superview.subviews) {
        if(![siblingButton isEqual:sender]) siblingButton.selected = NO;
    }
    sender.selected = YES;
    [self loadControls:[UserPotion potion].potion.badgeColorOptions type:MysticObjectTypeTextColor scrollView:self.controlScrollView sender:nil];
}

- (void) subFrameColorTouched:(UIButton *)sender
{
    currentSetting = MysticSettingFrameColor;
    [self moveBottomNippleTo:sender];
    for (UIButton *siblingButton in sender.superview.subviews) {
        if(![siblingButton isEqual:sender]) siblingButton.selected = NO;
    }
    sender.selected = YES;
    [self loadControls:[UserPotion potion].potion.frameBackgroundColorOptions type:MysticObjectTypeTextColor scrollView:self.controlScrollView sender:nil];
}

- (void) subBadgeTouched:(UIButton *)sender
{
    currentSetting = MysticSettingBadge;
    [self moveBottomNippleTo:sender];
    for (UIButton *siblingButton in sender.superview.subviews) {
        if(![siblingButton isEqual:sender]) siblingButton.selected = NO;
    }
    sender.selected = YES;
    [self loadControls:[UserPotion potion].potion.badgeOptions type:MysticObjectTypeText scrollView:self.controlScrollView sender:nil];
}

- (void) subMaskTouched:(UIButton *)sender
{
    currentSetting = MysticSettingMask;
    [self moveBottomNippleTo:sender];
    for (UIButton *siblingButton in sender.superview.subviews) {
        if(![siblingButton isEqual:sender]) siblingButton.selected = NO;
    }
    sender.selected = YES;
    
    [self loadControls:[UserPotion potion].potion.maskOptions type:MysticObjectTypeMask scrollView:self.controlScrollView sender:nil];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *theTouch = [touches anyObject];
    CGPoint touchPoint = [theTouch locationInView:self.view];
    if(CGRectContainsPoint(self.imageView.frame, touchPoint))
    {
        CGRect newRect = [UserPotion potion].transformTextRect;
        lastPoint = newRect.origin;
        startPoint = [theTouch locationInView:self.imageView];
        PLog(@"START point", startPoint);
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *theTouch = [touches anyObject];
    
    CGPoint midPoint = [theTouch locationInView:self.imageView];
    PLog(@"MID point", midPoint);
    
    
    CGFloat cx = midPoint.x - startPoint.x;
    CGFloat cy = midPoint.y - startPoint.y;
    CGFloat ax = 0;
    CGFloat ay = 0;
    if(cx > 0)
    {
        ax = 1- (startPoint.x/midPoint.x);
    }
    else
    {
        ax = (1-(midPoint.x/startPoint.x))*-1;
    }
    
    if(cy > 0)
    {
        ay = 1-(startPoint.y/midPoint.y);
    }
    else
    {
        ay = (1-(midPoint.y/startPoint.y))*-1;
    }
    
    
    
    
    CGRect newRect = CGRectZero;
    
    switch (currentSetting) {
        case MysticSettingText:
            newRect = [UserPotion potion].transformTextRect;
            break;
        case MysticSettingBadge:
            newRect = [UserPotion potion].transformBadgeRect;
            break;
        default:
            break;
    }
    
    newRect.origin.x+=ax;
    newRect.origin.y+=ay;
    
    if(!reloadingImage && !CGPointEqualToPoint(newRect.origin, lastPoint))
    {
        DLog(@"moved: x: %2.1f y: %2.1f - ax: %2.1f ay: %2.1f", cx, cy, ax, ay);
        switch (currentSetting) {
            case MysticSettingText:
                [UserPotion potion].transformTextRect = newRect;
                break;
            case MysticSettingBadge:
                [UserPotion potion].transformBadgeRect = newRect;
                break;
            default:
                break;
        }
    }
    else
    {
        DLog(@"skipping...");
    }
    lastPoint = newRect.origin;
    startPoint = midPoint;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //detect touch
    UITouch *theTouch = [touches anyObject];

    endPoint = [theTouch locationInView:self.imageView];
    PLog(@"END point", endPoint);
    
    
    CGFloat cx = endPoint.x - startPoint.x;
    CGFloat cy = endPoint.y - startPoint.y;
    CGFloat ax = 0;
    CGFloat ay = 0;
    if(cx > 0)
    {
        ax = 1- (startPoint.x/endPoint.x);
    }
    else
    {
        ax = (1-(endPoint.x/startPoint.x))*-1;
    }
    
    if(cy > 0)
    {
        ay = 1-(startPoint.y/endPoint.y);
    }
    else
    {
        ay = (1-(endPoint.y/startPoint.y))*-1;
    }
    
    DLog(@"moved: x: %2.1f y: %2.1f - ax: %2.1f ay: %2.1f", cx, cy, ax, ay);
    
    
    CGRect newRect=CGRectZero;
    
    switch (currentSetting) {
        case MysticSettingText:
            newRect = [UserPotion potion].transformTextRect;
            break;
        case MysticSettingBadge:
            newRect = [UserPotion potion].transformBadgeRect;
            break;
        default:
            break;
    }
    newRect.origin.x+=ax;
    newRect.origin.y+=ay;
    switch (currentSetting) {
        case MysticSettingText:
            [UserPotion potion].transformTextRect = newRect;
            break;
        case MysticSettingBadge:
            [UserPotion potion].transformBadgeRect = newRect;
            break;
        default:
            break;
    }
    
    
    
    
    [self reloadImage:NO];

    
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - EffectControlDelegate methods

- (void) userFinishedEffectControlSelections:(UIControl *)effectControl effect:(MysticControlObject *)effect;
{
    
    [super userFinishedEffectControlSelections:effectControl effect:effect];
    
    [self reloadImage];
    
}


@end
