//
//  MysticImageViewGallery.h
//  Mystic
//
//  Created by travis weerts on 3/6/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MysticImageViewGallery;

@protocol MysticImageViewGalleryDelegate <NSObject>

@optional

- (void) mysticImageView:(MysticImageViewGallery *)imageView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (void) mysticImageView:(MysticImageViewGallery *)imageView touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

- (void) mysticImageView:(MysticImageViewGallery *)imageView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface MysticImageViewGallery : UIImageView
{
    UIImageView *mOriginalImageViewContainerView;
    UIImageView *mIntermediateTransitionView;
}
@property (nonatomic, retain) UIImageView *originalImageViewContainerView;
@property (nonatomic, retain) UIImageView *intermediateTransitionView;
@property (nonatomic, assign) id <MysticImageViewGalleryDelegate> delegate;
#pragma mark -
#pragma mark Animation methods
-(void)setImage:(UIImage *)inNewImage withTransitionAnimation:(BOOL)inAnimation;



@end
