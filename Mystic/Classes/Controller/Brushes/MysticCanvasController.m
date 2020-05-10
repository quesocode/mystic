//
//  MysticCanvasController.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/21/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticCanvasController.h"
#import "MysticController.h"
#import "WDAddImage.h"
#import "WDPaintingManager.h"
#import "MysticLayerPanelView.h"
#import "MysticTabBar.h"
#import "MysticController.h"
#import "MysticFont.h"
#import "WDActiveState.h"
#import "WDBrush.h"
#import "MysticAttrString.h"
#import "UIView+Mystic.h"
#import "MysticUser.h"

@interface MysticCanvasController ()

@end

@implementation MysticCanvasController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) setupView;
{
    [self buildViews];
    [self.canvas scaleDocumentToFit:YES];
    
}
- (void) opacitySliderChanged:(MysticSlider *)slider;
{
    [MysticUser set:@(slider.value) key:@"brush-opacity"];

    [WDActiveState sharedInstance].brush.intensity.value = slider.value;
    [self.sliderDisplay update:[NSString stringWithFormat:@"%2.0f%%", ((slider.value/slider.maximumValue)*100)] mode:0 value:slider.value];

}
- (void) weightSliderChanged:(MysticSlider *)slider;
{

    [MysticUser set:@(roundf(slider.value)) key:@"brush-weight"];

    [WDActiveState sharedInstance].brush.weight.value = roundf(slider.value);
    [self.sliderDisplay update:[NSString stringWithFormat:@"%2.0f%%", ((slider.value/slider.maximumValue)*100)] mode:1 value:(slider.value/slider.maximumValue)];
}
- (void) opacitySliderEnded:(MysticSliderBrush *)slider;
{
    self.brushWeightSlider.hidden = NO;

    [self sliderEnded:slider];

}
- (void) weightSliderEnded:(MysticSliderBrush *)slider;
{
    self.brushOpacitySlider.hidden = NO;

    [self sliderEnded:slider];

}
- (void) opacitySliderBegan:(MysticSliderBrush *)slider;
{
    self.brushWeightSlider.hidden = YES;
    [self sliderBegan:slider];
    [self.sliderDisplay update:[NSString stringWithFormat:@"%2.0f%%", ((slider.value/slider.maximumValue)*100)] mode:0 value:slider.value];
}
- (void) weightSliderBegan:(MysticSliderBrush *)slider;
{
    self.brushOpacitySlider.hidden = YES;
    [self sliderBegan:slider];
    [self.sliderDisplay update:[NSString stringWithFormat:@"%2.0f%%", ((slider.value/slider.maximumValue)*100)] mode:1 value:(slider.value/slider.maximumValue)];

}
- (void) sliderBegan:(MysticSliderBrush *)slider;
{
    if(!self.sliderDisplay && slider.upperHandle.highlighted)
    {
        self.sliderDisplay = [[[MysticCanvasSliderDisplay alloc] initWithFrame:self.view.bounds] autorelease];
        [self.view insertSubview:self.sliderDisplay belowSubview:slider];
    }
//    self.controller.layerPanelView.hidden = YES;

}
- (void) sliderEnded:(MysticSliderBrush *)slider;
{
    if(self.sliderDisplay)
    {
        [MysticUIView animate:0.25 animations:^{
            self.sliderDisplay.alpha = 0;
        } completion:^(BOOL finished) {
            [self.sliderDisplay removeFromSuperview];
            self.sliderDisplay = nil;
        }];
        
    }
    self.controller.layerPanelView.hidden = NO;

}
- (void) registerNotifications;
{
    [super registerNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushPropertyChanged:) name:WDPropertyChangedNotification object:nil];
}
- (void) createDocument:(UIImage *)sourceImage size:(CGSize)size finished:(MysticBlockObject)finished;
{
    __unsafe_unretained __block MysticCanvasController *weakSelf = [self retain];
    __unsafe_unretained __block MysticBlockObject _f = finished ? Block_copy(finished) : nil;
//    __unsafe_unretained __block UIImage *photo_ = sourceImage ? [sourceImage retain] : nil;
    [[WDPaintingManager sharedInstance] createNewPaintingWithBackgroundImage:sourceImage complete:^(WDDocument *document) {
        // set the document before setting the editing flag
        weakSelf.document = document;
        weakSelf.editing = YES;
        if(_f)
        {
            _f(document);
            Block_release(_f);
        }
        [weakSelf release];
        
    }];
}
- (void) undoStatusDidChange:(NSNotification *)aNotification
{
    [super undoStatusDidChange:aNotification];
    if(!self.brushWeightSlider) return;
    MysticBarButton * undo = [self.controller.layerPanelView.toolbar itemViewWithTag:MysticViewTypeUndo];
    MysticBarButton * redo = [self.controller.layerPanelView.toolbar itemViewWithTag:MysticViewTypeRedo];
    undo.enabled = [self.painting.undoManager canUndo];
    redo.enabled = [self.painting.undoManager canRedo];

}
- (void) setInterfaceMode:(WDInterfaceMode)inInterfaceMode force:(BOOL)force;
{
    
    [super setInterfaceMode:inInterfaceMode force:force];
    self.controller.layerPanelView.hidden = NO;
    self.view.frame = CGRectXY(self.view.frame, 0, -54+18);
    self.canvas.frame = CGRectXY(self.canvas.frame, 0, 0);
    if(inInterfaceMode == WDInterfaceModeEdit)
    {
        if(!self.brushWeightSlider)
        {
            NSNumber *w = [MysticUser get:@"brush-weight"];
            NSNumber *o = [MysticUser get:@"brush-opacity"];
            
            MysticSliderBrush *opacity = [MysticSliderBrush sliderWithFrame:(CGRect){0,0,40,250}];
            MysticSliderBrush *weight = [MysticSliderBrush sliderWithFrame:(CGRect){0,0,40,250}];
            opacity.maximumValue = 1;
            opacity.minimumValue = 0;
            CGFloat ov = o ? o.floatValue : [WDActiveState sharedInstance].brush.intensity.value;
            weight.maximumValue = 384;
            weight.minimumValue = 0;
            CGFloat wv = w ? w.floatValue : [WDActiveState sharedInstance].brush.weight.value;
            
            ov = ov == 0 ? 1 : ov;
            wv = wv == 0 ? 192 : wv;
            weight.upperValue = wv;
            opacity.upperValue = ov;
            
            [WDActiveState sharedInstance].brush.intensity.value = ov;
            [WDActiveState sharedInstance].brush.weight.value = wv;
            weight.center = CGPointMake(20,self.view.frame.size.height/2);
            opacity.center = CGPointMake(self.view.frame.size.width-20,self.view.frame.size.height/2);
            opacity.horizontalAlignment = MysticPositionRight;
            [weight addTarget:self action:@selector(weightSliderChanged:) forControlEvents:UIControlEventValueChanged];
            [opacity addTarget:self action:@selector(opacitySliderChanged:) forControlEvents:UIControlEventValueChanged];
            [opacity addTarget:self action:@selector(opacitySliderEnded:) forControlEvents:UIControlEventEditingDidEnd];
            [weight addTarget:self action:@selector(weightSliderEnded:) forControlEvents:UIControlEventEditingDidEnd];
            [opacity addTarget:self action:@selector(opacitySliderBegan:) forControlEvents:UIControlEventEditingDidBegin];
            [weight addTarget:self action:@selector(weightSliderBegan:) forControlEvents:UIControlEventEditingDidBegin];

            self.brushWeightSlider = weight;
            self.brushOpacitySlider = opacity;
            [self.view addSubview:self.brushOpacitySlider];
            [self.view addSubview:self.brushWeightSlider];
            [MysticUser set:@(self.brushWeightSlider.upperValue) key:@"brush-weight"];
            [MysticUser set:@(self.brushOpacitySlider.upperValue) key:@"brush-opacity"];
        }
        self.brushWeightSlider.hidden = NO;
        self.brushOpacitySlider.hidden = NO;
    }
    else if (inInterfaceMode == WDInterfaceModeHidden || inInterfaceMode == WDInterfaceModeHiddenExceptToolbar) {
        self.controller.layerPanelView.hidden = inInterfaceMode == WDInterfaceModeHidden;
        self.brushWeightSlider.hidden = YES;
        self.brushOpacitySlider.hidden = YES;
        if(inInterfaceMode == WDInterfaceModeHidden)
        {
            self.view.frame = CGRectXY(self.view.frame, 0, 0);
            self.canvas.frame = CGRectXY(self.canvas.frame, 0, -54+18);
        }
        
    }

}

- (void) setBrushTool:(id)sender;
{
    [super setBrushTool:sender];
//    DLogRender(@"brush was set");
    [self brushPropertyChanged:nil];
}
- (void) brushPropertyChanged:(NSNotification *)aNotification
{
    [MysticUser set:@([WDActiveState sharedInstance].brush.weight.value) key:@"brush-weight"];
    [MysticUser set:@([WDActiveState sharedInstance].brush.intensity.value) key:@"brush-opacity"];
//    DLogDebug(@"Brush Changed opacity: %2.2f  weight: %2.2f    %2.2f / %2.2f", [WDActiveState sharedInstance].brush.intensity.value, [WDActiveState sharedInstance].brush.weight.value, self.brushOpacitySlider.upperValue, self.brushWeightSlider.upperValue);

}
#pragma mark - Pinch
//- (void) handlePinchGesture:(UIPinchGestureRecognizer *)sender
//{
////    if(self.canvas.zoomScale == 0 || isnan(self.canvas.zoomScale)) return;
////    float realScale = self.canvas.zoomScale/self.canvas.fitScale;
////    CGAffineTransform t = CGAffineTransformMakeScale(realScale, realScale);
////    CGRect realFrame = CGRectApplyAffineTransform(self.canvas.frame, t);
//////    DLog(@"canvas pinch: fit: %2.2f  zoom: %2.2f  /  %2.2f   =  %2.2f  %@  %@", self.canvas.fitScale, self.canvas.zoomScale, self.canvas.displayableScale, realScale, f(realFrame), f(self.canvas.bounds));
////    self.canvasContainer.bounds = realFrame;
////    
////    self.canvas.center = CGPointMake(realFrame.size.width/2, realFrame.size.height/2);
//    //self.canvasContainer.frame = CGRectXY(realFrame, self.view.bounds.size.width/2 - realFrame.size.width/2, self.view.bounds.size.height/2 - realFrame.size.height/2);
//}
#pragma mark - Rotation
//- (void) handleRotationGesture:(UIRotationGestureRecognizer *)sender;
//{
////    self.canvas.currentTransform = snapRotation45and90(CGAffineTransformRotate(self.canvas.currentTransform, sender.rotation));
////    self.canvas.currentTransform = (CGAffineTransformRotate(self.canvas.currentTransform, sender.rotation));
////
////////    self.canvas.transform = snapRotation45and90(CGAffineTransformRotate(self.canvas.transform, sender.rotation));
////////    super.canvasContainer.transform = (CGAffineTransformRotate(super.canvasContainer.transform, sender.rotation));
//////
////    sender.rotation = 0;
////
//}

- (void) deleteDocument;
{
    [[WDPaintingManager sharedInstance] deletePainting:self.document];
}
- (void) destroyControls;
{
    if(!self.brushWeightSlider) return;
    [self.brushWeightSlider removeTarget:self action:@selector(weightSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.brushOpacitySlider removeTarget:self action:@selector(opacitySliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.brushOpacitySlider removeTarget:self action:@selector(opacitySliderEnded:) forControlEvents:UIControlEventEditingDidEnd];
    [self.brushWeightSlider addTarget:self action:@selector(weightSliderEnded:) forControlEvents:UIControlEventEditingDidEnd];
    [self.brushOpacitySlider removeTarget:self action:@selector(opacitySliderBegan:) forControlEvents:UIControlEventEditingDidBegin];
    [self.brushWeightSlider addTarget:self action:@selector(weightSliderBegan:) forControlEvents:UIControlEventEditingDidBegin];
    [self.brushWeightSlider removeFromSuperview];
    self.brushWeightSlider = nil;
    [self.brushOpacitySlider removeFromSuperview];
    self.brushOpacitySlider = nil;
}
- (void) close;
{
//    [self opacitySliderChanged:self.brushOpacitySlider];
//    [self weightSliderChanged:self.brushWeightSlider];
    [self destroyControls];
//    DLogSuccess(@"CLOSE opacity: %2.2f  weight: %2.2f", [WDActiveState sharedInstance].brush.intensity.value, [WDActiveState sharedInstance].brush.weight.value);

//    [self deleteDocument];
}
- (BOOL) hasSketched;
{
    return self.canvas.hasSketched;
}
- (UIImage *)image;
{
    return self.painting.image;
}
- (void) updateLayersButton;
{
    [super updateLayersButton];
    MysticTabBar *tabBar = self.controller.layerPanelView.replacementTabBar;
    MysticTabButton *layersBtn = [tabBar tabForType:MysticSettingSketchLayers];
    if(layersBtn)
    {
        NSUInteger index = [self.painting indexOfActiveLayer];
        index = (index == NSNotFound) ? 1 : (index + 1);
        
        UILabel *layersLabel = [layersBtn viewWithTag:1235345];
        if(!layersLabel)
        {
            layersLabel = [[[UILabel alloc] initWithFrame:CGRectXY(layersBtn.bounds, 0, 1)] autorelease];
            layersLabel.tag =1235345;
            layersLabel.textColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.00];
            layersLabel.font = [MysticFont gothamBold:12];
            layersLabel.textAlignment = NSTextAlignmentCenter;
            layersLabel.backgroundColor = UIColor.clearColor;
            layersLabel.userInteractionEnabled = NO;
            [layersBtn addSubview:layersLabel];
        }
        layersLabel.text = [NSString stringWithFormat:@"%d", (int)index];
        
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end

@implementation MysticCanvasSliderDisplay

- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(!self) return nil;
    
    UIVisualEffectView *bg = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    bg.frame = self.bounds;
    [self addSubview:bg];
    [self sendSubviewToBack:bg];
    self.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.07 alpha:0.15];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:(CGRect){0,0,250, 100}] autorelease];
    label.backgroundColor = UIColor.clearColor;
    label.center = CGPointMake(self.bounds.size.width/2, (self.bounds.size.height/2 + 50) + label.frame.size.height/2);
    self.label = label;
    [self addSubview:label];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){0,0,384,384}];
    imageView.center = CGPointMake(self.label.center.x, (self.bounds.size.height/2 + 50) - imageView.frame.size.height/2 + 135);
    imageView.backgroundColor = UIColor.clearColor;
    imageView.clipsToBounds = NO;
    imageView.contentMode = UIViewContentModeCenter;
    self.brushView = [imageView autorelease];
    [self addSubview:self.brushView];
//    MBorder(self.brushView, [UIColor redColor], 1);
//    MBorder(self.label, [UIColor greenColor], 1);

    return self;
}
- (void) update:(NSString *)str mode:(int)mode value:(float)value;
{
    self.label.attributedText = [[MysticAttrString string:str style:MysticStringStyleBrushSliderLabel] attrString];
    if(mode==0)
    {
        self.brushView.alpha = value;
    }
    else
    {
        self.brushView.transform = CGAffineTransformMakeScale(value, value);
    }
    if(self.brushView.alpha > 0 && !self.brushView.image)
    {
        __unsafe_unretained __block UIImageView *_bp = [self.brushView retain];
            CGSize previewSize = CGSizeScale((CGSize)_bp.bounds.size, 0.3);
            UIImage *brushPreview = [[[WDActiveState sharedInstance].brush previewImageWithSize:previewSize] retain];
            dispatch_async(dispatch_get_main_queue(), ^{
                _bp.image = [brushPreview autorelease];
                [_bp release];
            });
        
    }
}

@end
