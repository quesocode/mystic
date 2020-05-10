//
//  MysticPhotoContainerView.h
//  Mystic
//
//  Created by travis weerts on 3/6/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Mystic.h"
#import "MysticImageViewGallery.h"
#import "MysticGPUImageView.h"
#import "MysticLayerAdjustView.h"
#import "MysticFloodFillImageView.h"
#import "MysticCIViews.h"
#import "MysticRoundView.h"
#import "Mystic-Swift.h"
#import "WDLabel.h"
#import "UIView+Additions.h"

@interface MysticPhotoScrollViewZoomView : UIView

@end
@interface MysticPhotoScrollView : UIScrollView <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    NSTimer                 *imageMessageTimer_;


}
@property (nonatomic, retain) NSTimer *messageTimer;
@property (nonatomic, assign) BOOL preventMessages;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) MysticPhotoScrollViewZoomView *zoomingView;
@property (nonatomic, assign) CGRect centeredFrame;
@property (nonatomic, readonly) CGRect imageViewFrame;
@property (nonatomic, assign)  MysticMessage                 *messageLabel;

@property (nonatomic, assign) id<UIScrollViewDelegate> scrollViewDelegate;
@property (nonatomic, assign) id gestureDelegate;
@property (nonatomic, assign) SEL longpressAction, tapAction;
@property (nonatomic, assign) UITapGestureRecognizer *doubleTapGesture, *singleTapGesture;

- (void)doubleTapped:(UITapGestureRecognizer *)tapGesture;
- (void)longGesture:(UILongPressGestureRecognizer *)gesture;
- (void) resetPosition:(BOOL)animated;
- (void) updateZoomViewFrame:(UIView *)view;
@end

@interface MysticPhotoView : UIView
@property (nonatomic, assign) MysticPhotoScrollView *scrollView;
@end

@interface MysticPhotoOverlaysView : UIView

@end

@interface MysticPhotoContainerView : UIView <UIScrollViewDelegate>
@property (nonatomic, retain) MysticPhotoScrollView *scrollView;
@property (nonatomic, readonly) NSArray *overlays;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) MysticPhotoView *imageView;
@property (nonatomic, readonly) MysticGPUImageView *renderImageView;
@property (nonatomic, retain) MysticGPUImageView *imageViewGPU;
@property (nonatomic, retain) MysticImageView *imageViewPlaceholder;
@property (nonatomic, assign) UIImage *image;
@property (nonatomic, assign) UIColor *debugColor;
@property (nonatomic, readonly) BOOL renderIsHidden, previewIsHidden;
@property (nonatomic, assign) CGSize size, transformSize;
@property (nonatomic, assign) CGRect imageViewFrame, originalImageViewFrame, imageFrame;
@property (nonatomic, assign) CGPoint offset, lastOffset;
@property (nonatomic, assign) CGAffineTransform previousTransform;
@property (nonatomic, assign) CGAffineTransform imageTransform;
@property (nonatomic, assign) UIEdgeInsets centeredInsets;
@property (nonatomic, assign) CGRect previousImageViewFrame;
@property (nonatomic, retain) MysticRoundView *previewOrRenderView;
@property (nonatomic, assign) MysticFloodFillImageView* floodView;
@property (nonatomic, assign) MysticCIView *filterView;
@property (nonatomic, retain) MysticImageView *quickView;
@property (nonatomic, retain) MysticScribbleView *scribbleView;
- (void) hideScribbleView:(NSTimeInterval)duration;
- (void) showScribbleView:(UIImage *)image duration:(NSTimeInterval)duration;

- (void) setImage:(UIImage *)image duration:(NSTimeInterval)dur;

+ (UIEdgeInsets) insets;
+ (void) setInsets:(UIEdgeInsets)insets;
- (CGRect) centerImageView;
- (CGRect) reCenterImageView;
- (CGRect) centerImageView:(UIEdgeInsets)insets;
+ (UIEdgeInsets) defaultInsets;
+ (UIEdgeInsets) resetInsets;
- (void) setSize:(CGSize)size force:(BOOL)force;
- (BOOL) hasSetSize;
- (void) resetFrame;
- (void) destroyRenderImageView;
- (void) destroyPlaceholderImageView;
- (CGRect) centerImageViewFrame:(UIEdgeInsets)insets;
- (CGRect) offsetImageView:(CGPoint)offset;
- (CGRect) removeOffset;
- (UIImageView *) showPlaceholder:(UIImage *)image;
- (MysticImageView *) showPlaceholder:(UIImage *)image duration:(NSTimeInterval)duration;
- (MysticGPUImageView *) showGPUImageView;
- (BOOL) revealRenderImageView;
- (BOOL) revealPlaceholder;
- (void) hideImageViews;
- (void) quickLookAtImage:(UIImage *)image duration:(NSTimeInterval)duration;
- (void) hideQuickLook:(NSTimeInterval)duration;
- (BOOL) revealRenderImageView:(NSTimeInterval)duration;
- (MysticFloodFillImageView *) showFloodView:(UIImage *)image duration:(NSTimeInterval)duration;
- (void) hideFloodView:(NSTimeInterval)duration;
- (void) addView:(UIView *)view;

- (MysticCIView *) showFilterView:(MysticCIType)type image:(UIImage *)image duration:(NSTimeInterval)duration;
- (void) hideFilterView:(NSTimeInterval)duration;
@end

@protocol MysticPhotoContainerViewDelegate

- (void) photoViewContainer:(MysticPhotoContainerView *)container didChangeFrame:(CGRect)frame original:(CGRect)originalFrame;

@end



