//
//  MysticCIView.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/18/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticCIView.h"
#import "MysticUtility.h"

@implementation MysticCIView

+ (Class) classForCIType:(MysticCIType)type;
{
    switch (type) {
        case MysticCITypeSpotColor: return NSClassFromString(@"MysticSpotColorView");
        default: break;
    }
    return nil;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self) [self setup];
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self) [self setup];
    return self;
}
- (void) setup;
{
    self.filters = nil;
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _previewView = [[GLKView alloc] initWithFrame:self.bounds context:_eaglContext];
    _previewView.enableSetNeedsDisplay = NO;
    _sourceImageScale = 0.55;
    // because the native video image from the back camera is in UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right), we need to apply a clockwise 90 degree transform so that we can draw the video preview as if we were in a landscape-oriented view; if you're using the front camera and you want to have a mirrored preview (so that the user is seeing themselves in the mirror), you need to apply an additional horizontal flip (by concatenating CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)
//    _previewView.transform = CGAffineTransformMakeRotation(M_PI_2);
    _previewView.frame = self.bounds;
    
    // we make our video preview view a subview of the window, and send it to the back; this makes FHViewController's view (and its UI elements) on top of the video preview, and also makes video preview unaffected by device rotation
    [self addSubview:_previewView];
    [self sendSubviewToBack:_previewView];
    
    // create the CIContext instance, note that this must be done after _videoPreviewView is properly set up
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    
    // bind the frame buffer to get the frame buffer width and height;
    // the bounds used by CIContext when drawing to a GLKView are in pixels (not points),
    // hence the need to read from the frame buffer's width and height;
    // in addition, since we will be accessing the bounds in another queue (_captureSessionQueue),
    // we want to obtain this piece of information so that we won't be
    // accessing _videoPreviewView's properties from another thread/queue
    [_previewView bindDrawable];
    _previewViewBounds = CGRectZero;
    _previewViewBounds.size.width = _previewView.drawableWidth;
    _previewViewBounds.size.height = _previewView.drawableHeight;
    [self updateFilters:NO save:NO];
}
- (void) setSourceImage:(UIImage *)sourceImage;
{
    if(_sourceImageScale != 1.0)
    {
        CGSize s1 = CGSizeImage(sourceImage);
        sourceImage = [MysticImage scaleImage:sourceImage scale:_sourceImageScale];
        CGSize s2 = CGSizeImage(sourceImage);
    }
    _sourceImage = sourceImage;
}
- (UIImage *) updateFilters:(BOOL)andDisplay save:(BOOL)save;
{
    return nil;
}
- (UIImage *) display;
{
    return [self display:NO];
}
- (UIImage *) display:(BOOL)save;
{
    return [self drawFilter:self.filters save:save];
}
- (UIImage *) drawFilter:(id)filter save:(BOOL)save;
{
    if(!filter) return nil;
    CIImage *sourceImage = [CIImage imageWithCGImage:self.sourceImage.CGImage];
    CIImage *filteredImage = [self filter:filter source:sourceImage];

    CGRect sourceExtent = sourceImage.extent;

    CGFloat sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
    CGFloat previewAspect = _previewViewBounds.size.width  / _previewViewBounds.size.height;
    
    // we want to maintain the aspect radio of the screen size, so we clip the video image
    CGRect drawRect = sourceExtent;
    
    [_previewView bindDrawable];
    
    if (_eaglContext != [EAGLContext currentContext])
        [EAGLContext setCurrentContext:_eaglContext];
    
    // clear eagl view to grey
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // set the blend mode to "source over" so that CI will use that
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    if (filteredImage) [_ciContext drawImage:filteredImage inRect:_previewViewBounds fromRect:drawRect];
    [_previewView display];
    if(!save) return nil;
    CIContext *context = [CIContext contextWithOptions:nil];
    self.image = [UIImage imageWithCGImage:[context createCGImage:filteredImage fromRect:filteredImage.extent]];
    return self.image;
}

- (CIImage *) filter:(id)filter source:(CIImage *)sourceImage;
{
    if(!filter || !sourceImage) return nil;
    sourceImage = sourceImage ? sourceImage : [CIImage imageWithCGImage:self.sourceImage.CGImage];
    CIImage *currentImage = nil;
    NSMutableArray *activeInputs = [NSMutableArray array];
    NSArray *filters = [filter isKindOfClass:[NSArray class]] ? filter : @[filter];
    for (CIFilter *filter in filters)
    {
        [filter setValue:currentImage ? currentImage : sourceImage forKey:kCIInputImageKey];
        currentImage = filter.outputImage;
        if (currentImage == nil) return nil;
    }
    
    if (CGRectIsEmpty(currentImage.extent))
        return nil;
    return currentImage;
}
//- (UIImage *) image;
//{
//    CIImage *filteredImage = [self filter:self.filters source:nil];
//    DLog(@"making ci image:  %@  filtered: %@  \n\nfilters: \n%@\n\n\nSource: %@\n\n", b(self.filters && [(NSArray *)self.filters count]>0), b(filteredImage != nil), self.filters, ILogStr(self.sourceImage));
//
//    CIContext *context = [CIContext contextWithOptions:nil];
//    
//    return [UIImage imageWithCGImage:[context createCGImage:filteredImage fromRect:filteredImage.extent]];
//}
@end
