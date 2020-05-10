//
//  MysticAssetCollectionCell.m
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticAssetCollectionCell.h"
#import "MysticAssetCollectionItem.h"
#import "Mystic.h"
#import "UIView+Mystic.h"

@implementation MysticAssetCollectionCell

- (void) dealloc;
{
    [_blurOverlayView release], _blurOverlayView=nil;
   
    
    [super dealloc];
}
- (void) setCollectionItem:(MysticAssetCollectionItem *)collectionItem;
{
    self.imageView.image = [UIImage imageWithCGImage:collectionItem.asset.thumbnail];
//
//    __unsafe_unretained __block MysticAssetCollectionCell *weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        ALAssetRepresentation *rep = [collectionItem.asset defaultRepresentation];
//        
//        CGImageRef iref = [rep fullResolutionImage];
//        if (iref)
//        {
//            CGRect screenBounds = [[UIScreen mainScreen] bounds];
//            
//            __block UIImage *previewImage;
////            __block UIImage *largeImage;
//            CGSize previewSize = [MysticUI scaleSize:weakSelf.bounds.size scale:0];
//            if([rep orientation] == ALAssetOrientationUp) //landscape image
//            {
////                largeImage = [[UIImage imageWithCGImage:iref] scaledToWidth:screenBounds.size.width];
//                //previewImage = [[UIImage imageWithCGImage:iref] scaledToWidth:300];
//                CGImageRef _previewImage = [MysticImage newScaledImage:iref withOrientation:UIImageOrientationUp toSize:previewSize withQuality:0.7];
//                previewImage = [[UIImage imageWithCGImage:_previewImage] retain];
//
//            }
//            else  // portrait image
//            {
//                CGImageRef _previewImage = [MysticImage newScaledImage:iref withOrientation:UIImageOrientationRight toSize:previewSize withQuality:0.7];
//                previewImage = [[UIImage imageWithCGImage:_previewImage] retain];
//                
////                previewImage = [[[UIImage imageWithCGImage:iref] scaledToHeight:300] imageRotatedByDegrees:90];
////                largeImage = [[[UIImage imageWithCGImage:iref] scaledToHeight:screenBounds.size.height] imageRotatedByDegrees:90];
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // do what ever you need to do in the main thread here once your image is resized.
//                // this is going to be things like setting the UIImageViews to show your new images
//                // or adding new views to your view hierarchy
//                weakSelf.imageView.image = previewImage;
//                [previewImage release];
//            });
//        }
//    });
    
    
}
- (void) prepareForReuse;
{
    [super prepareForReuse];
    
    if(self.blurOverlayView)
    {
        [self.blurOverlayView removeFromSuperview];
        self.blurOverlayView = nil;
    }
    
}

- (void) didSelect:(MysticBlockObjBOOL)selectBlock animated:(BOOL)animated;
{
    BOOL __selected = self.selected;
    __unsafe_unretained __block MysticBlockObjBOOL __selectBlock = selectBlock ? Block_copy(selectBlock) : nil;
    __unsafe_unretained __block MysticAssetCollectionCell *weakSelf = self;
    
    if(__selected)
    {
        if(!self.blurOverlayView)
        {
            UIView *overlayView = [[UIView alloc] initWithFrame:self.imageView.frame];
            [overlayView enableBlur:YES];
            overlayView.blurStyle = UIViewBlurDarkStyle;
            [overlayView setBlurTintColor:[UIColor color:MysticColorTypeBlack]];
            [overlayView setBlurTintColorIntensity:1];
            self.blurOverlayView = overlayView;
            [self addSubview:self.blurOverlayView];
            [overlayView release];
            
        }
        
        
        self.blurOverlayView.userInteractionEnabled = NO;
        self.blurOverlayView.alpha = 0;
        
        
        if(!self.overlayView)
        {
            UIImageView *overlayView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
            self.overlayView = overlayView;
            self.overlayView.contentMode = UIViewContentModeCenter;
            UIColor *checkColor = [UIColor color:MysticColorTypeWhite];
            [(UIImageView *)self.overlayView setImage:[MysticImage image:@(MysticIconTypeToolBarConfirm) size:(CGSize){24,24} color:checkColor]];
            
            
            [overlayView release];
            [self addSubview:self.overlayView];
            
        }
        
        self.overlayView.userInteractionEnabled = NO;
        self.overlayView.backgroundColor = [[UIColor color:MysticColorTypePink] colorWithAlphaComponent:0.7];
        self.overlayView.alpha = 0;
        
            
        
        
        
        
//        MBorder(self.overlayView, [UIColor color:MysticColorTypePink], 2);
        
        
    }

    
    MysticBlock animBlock = ^{
        weakSelf.imageView.alpha = __selected ? 1 : 1;
        if(!__selected && weakSelf.blurOverlayView)
        {
            weakSelf.blurOverlayView.alpha = 0;
            weakSelf.overlayView.alpha = 0;
        }
        else if(weakSelf.blurOverlayView)
        {
            weakSelf.blurOverlayView.alpha = 1;
            weakSelf.overlayView.alpha = 1;

        }
    };
    
    MysticBlockBOOL finishedBlock = ^(BOOL finished) {
        
        if(!__selected && weakSelf.blurOverlayView)
        {
            [weakSelf.blurOverlayView removeFromSuperview];
            weakSelf.blurOverlayView = nil;
            [weakSelf.overlayView removeFromSuperview];
            weakSelf.overlayView = nil;
        }
        
        if(__selectBlock)
        {
//            [NSTimer wait:0.035 block:^{
                __selectBlock(self, __selected); Block_release(__selectBlock);
//            }];
        }
    };
    
    if(animated)
    {
        [MysticUIView animateWithDuration:0.04 delay:0 options:UIViewAnimationCurveLinear animations:animBlock completion:finishedBlock];
    }
    else
    {
        animBlock();
        finishedBlock(YES);
    }
    
}

@end
