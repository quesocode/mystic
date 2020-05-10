//
//  LaunchedViewController.m
//  Mystic
//
//  Created by Me on 11/20/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLaunchedViewController.h"
#import "MysticView.h"
#import "MysticUI.h"
#import "UIView+Mystic.h"

@interface MysticLaunchedViewController ()
@end

@implementation MysticLaunchedViewController

-(void)dealloc
{
    [_defaultImageView release];
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self != nil) {

        
        
    }
    return self;
}


-(void)loadView;
{
    CGFloat _width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat _height = [[UIScreen mainScreen] bounds].size.height;
    MysticView *rootView = [[MysticView alloc] initWithFrame:CGRectMake(0, 0, _width, _height)];
    self.view = rootView;
    rootView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
    if (self.defaultImageView == nil) {
        self.defaultImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.defaultImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.defaultImageView setContentMode:UIViewContentModeScaleToFill];
        
        [self.view addSubview:self.defaultImageView];
        [self.defaultImageView autorelease];

    }
    FLog(@"image view", self.defaultImageView.frame);
    [rootView becomeFirstResponder];
    [rootView release];
    [self updateBackground];

}

#pragma mark Remote Control Notifications


#pragma mark - TiRootControllerProtocol
//Background Control
-(void)updateBackground
{
    UIView * ourView = [self view];
    UIColor * chosenColor = [UIColor blackColor];
    [ourView setBackgroundColor:chosenColor];
    [self rotateDefaultImageViewToOrientation:UIDeviceOrientationPortrait];
}
    

- (void) dismissDefaultImage:(MysticBlockAnimationComplete)finished;
{
    __unsafe_unretained __block MysticBlockAnimationComplete _f = finished ? Block_copy(finished) : nil;
    if (self.defaultImageView != nil) {
        [MysticUIView animateWithDuration:1.5 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL f) {
            [self.defaultImageView setHidden:YES];
            [self.defaultImageView removeFromSuperview];
            self.view.hidden = YES;
            [self.view removeFromSuperview];
            if(_f)
            {
                _f(f,nil);
                Block_release(_f);
            }

        }];
        
    }
}

- (UIImage*)defaultImageForOrientation:(UIDeviceOrientation)orientation resultingOrientation:(UIDeviceOrientation *)imageOrientation idiom:(UIUserInterfaceIdiom*) imageIdiom
{
    UIImage* image;
    NSString *imageName = nil;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        
        *imageOrientation = orientation;
        *imageIdiom = UIUserInterfaceIdiomPad;
        // Specific orientation check
        switch (orientation) {
            case UIDeviceOrientationPortrait:
                imageName = @"LaunchImage-Portrait";
                image = [UIImage imageNamed:imageName];
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                imageName = @"LaunchImage-PortraitUpsideDown";

                image = [UIImage imageNamed:imageName];
                break;
            case UIDeviceOrientationLandscapeLeft:
                imageName = @"LaunchImage-LandscapeLeft";

                image = [UIImage imageNamed:imageName];
                break;
            case UIDeviceOrientationLandscapeRight:
                imageName = @"LaunchImage-LandscapeRight";

                image = [UIImage imageNamed:imageName];
                break;
            default:
                image = nil;
        }
        if (image != nil) {
            ILog(@"launch", image);

            DLog(@"image name: %@", imageName);
            return image;
        }
        
        // Generic orientation check
        if (UIDeviceOrientationIsPortrait(orientation)) {
            imageName = @"LaunchImage-Portrait";
            DLog(@"image name: %@", imageName);

            image = [UIImage imageNamed:imageName];
        }
        else if (UIDeviceOrientationIsLandscape(orientation)) {
            imageName = @"LaunchImage-Landscape";
            DLog(@"image name: %@", imageName);

            image = [UIImage imageNamed:imageName];
        }
        
        if (image != nil) {
            DLog(@"image name: %@", imageName);
            ILog(@"launch", image);

            return image;
        }
    }
    *imageOrientation = UIDeviceOrientationPortrait;
    *imageIdiom = UIUserInterfaceIdiomPhone;
    // Default
    image = nil;
    if ([MysticUI isRetinaHDDisplay]) {
        if (UIDeviceOrientationIsPortrait(orientation)) {
            imageName = @"LaunchImage-Portrait";
            DLog(@"image name: %@", imageName);

            image = [UIImage imageNamed:imageName];
        }
        else if (UIDeviceOrientationIsLandscape(orientation)) {
            imageName = @"LaunchImage-Landscape";
            DLog(@"image name: %@", imageName);

            image = [UIImage imageNamed:imageName];
        }
        if (image!=nil) {
            ILog(@"launch", image);
            *imageOrientation = orientation;
            return image;
        }
    }
    if ([MysticUI isRetinaiPhone6]) {
        imageName = @"LaunchImage";
        DLog(@"image name: %@", imageName);

        image = [UIImage imageNamed:imageName];
        ILog(@"launch", image);

        if (image!=nil) {
            return image;
        }
    }
    if ([MysticUI isRetinaFourInch]) {
        imageName = @"LaunchImage";
        DLog(@"image name: %@", imageName);

        image = [UIImage imageNamed:imageName];
        ILog(@"launch", image);

        if (image!=nil) {
            return image;
        }
    }
    imageName = @"LaunchImage";
    DLog(@"image name: %@", imageName);
    ILog(@"launch2", image);

    return [UIImage imageNamed:@"LaunchImage"];
}

-(void)rotateDefaultImageViewToOrientation: (UIInterfaceOrientation)newOrientation;
{
    if (_defaultImageView == nil)
    {
        return;
    }
    UIDeviceOrientation imageOrientation;
    UIUserInterfaceIdiom imageIdiom;
    UIUserInterfaceIdiom deviceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
    /*
     *	This code could stand for some refinement, but it is rarely called during
     *	an application's lifetime and is meant to recreate the quirks and edge cases
     *	that iOS uses during application startup, including Apple's own
     *	inconsistencies between iPad and iPhone.
     */
    
    UIImage * defaultImage = [self defaultImageForOrientation:
                              (UIDeviceOrientation)newOrientation
                                         resultingOrientation:&imageOrientation idiom:&imageIdiom];
    CGFloat imageScale = [defaultImage scale];
    CGRect newFrame = [[self view] bounds];
    CGSize imageSize = [defaultImage size];
    UIViewContentMode contentMode = UIViewContentModeScaleToFill;
    
    if (imageOrientation == UIDeviceOrientationPortrait) {
        if (newOrientation == UIInterfaceOrientationLandscapeLeft) {
            UIImageOrientation imageOrientation;
            if (deviceIdiom == UIUserInterfaceIdiomPad)
            {
                imageOrientation = UIImageOrientationLeft;
            }
            else
            {
                imageOrientation = UIImageOrientationRight;
            }
            defaultImage = [
                            UIImage imageWithCGImage:[defaultImage CGImage] scale:imageScale orientation:imageOrientation];
            imageSize = CGSizeMake(imageSize.height, imageSize.width);
            if (imageScale > 1.5) {
                contentMode = UIViewContentModeCenter;
            }
        }
        else if(newOrientation == UIInterfaceOrientationLandscapeRight)
        {
            defaultImage = [UIImage imageWithCGImage:[defaultImage CGImage] scale:imageScale orientation:UIImageOrientationLeft];
            imageSize = CGSizeMake(imageSize.height, imageSize.width);
            if (imageScale > 1.5) {
                contentMode = UIViewContentModeCenter;
            }
        }
        else if((newOrientation == UIInterfaceOrientationPortraitUpsideDown) && (deviceIdiom == UIUserInterfaceIdiomPhone))
        {
            defaultImage = [UIImage imageWithCGImage:[defaultImage CGImage] scale:imageScale orientation:UIImageOrientationDown];
            if (imageScale > 1.5) {
                contentMode = UIViewContentModeCenter;
            }
        }
    }
    
    if(imageSize.width == newFrame.size.width)
    {
        CGFloat overheight;
        overheight = imageSize.height - newFrame.size.height;
        if (overheight > 0.0) {
            newFrame.origin.y -= overheight;
            newFrame.size.height += overheight;
        }
    }
    [_defaultImageView setContentMode:contentMode];
    [_defaultImageView setImage:defaultImage];
    [_defaultImageView setFrame:newFrame];
}


-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
    [self.view becomeFirstResponder];

    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated
{

    [super viewDidDisappear:animated];
}

@end
