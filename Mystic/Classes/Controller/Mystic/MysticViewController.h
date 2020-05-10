//
//  MysticViewController.h
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"

@interface MysticViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, assign) BOOL hidesNavBarOnScroll, shouldTrack;
@property (nonatomic, copy) MysticBlockObjBOOL onViewDidAppear;
@property (nonatomic, copy) MysticBlockObjBOOL onViewWillAppear;
@property (nonatomic, copy) MysticBlockObjBOOL onViewWillDisappear;
@property (nonatomic, copy) MysticBlockObjBOOL onViewDidDisappear;

- (IBAction)closeTouched:(id)sender;
- (void) hideNavBar:(BOOL)hide duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay complete:(MysticBlockBOOL)complete;
- (void) hideNavBar:(BOOL)hide track:(BOOL)shouldTrack duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay complete:(MysticBlockBOOL)complete;
- (void) resetScrollViewTracking;
- (BOOL) shouldScrollViewHideNavBar:(UIScrollView *)aScrollView;

@end
