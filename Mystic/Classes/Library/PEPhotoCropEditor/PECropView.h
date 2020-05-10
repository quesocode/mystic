//
//  PECropView.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface PECropView : UIView

@property (nonatomic) UIImage *image;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic, readonly) UIImage *croppedImage;
@property (nonatomic, readonly) CGRect zoomedCropRect;
@property (nonatomic, readonly) CGAffineTransform rotation;
@property (nonatomic, readonly) BOOL userHasModifiedCropArea;

@property (nonatomic) BOOL keepingCropAspectRatio, flipHorizontal, flipVertical;
@property (nonatomic) CGFloat cropAspectRatio;

@property (nonatomic) CGRect cropRect;
@property (nonatomic) CGSize returnSize;
- (void) resetTransformAndZoom;
- (void)zoomToCropRect:(CGRect)toRect force:(BOOL)force animated:(BOOL)animated;

@end
