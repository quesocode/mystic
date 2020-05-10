//
//  MysticPermissionView.h
//  Mystic
//
//  Created by Travis A. Weerts on 6/2/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticBlurBackgroundView.h"
#import "MysticCommon.h"

@interface MysticPermissionView : MysticBlurBackgroundView
@property (nonatomic, assign) MysticButton *closeBtn, *button;
@property (nonatomic, assign) UILabel *titleLabel, *descriptionLabel;
@property (nonatomic, assign) UIImageView *imageView;
@property (nonatomic, assign) MysticPermissionType type;
@property (nonatomic, assign) UIView *container;
@property (nonatomic, assign) BOOL hasConfirmed;
@property (nonatomic, copy) MysticBlockObjObjBOOL onComplete;
+ (instancetype) showInView:(UIView *)view type:(MysticPermissionType)type animated:(BOOL)animated complete:(MysticBlockObjObjBOOL)finished;
- (void) hide:(BOOL)animated complete:(MysticBlockBOOL)hide;
- (void) showTitle:(NSString *)title description:(NSString *)description icon:(id)iconType iconColor:(UIColor *)iconColor button:(NSString *)buttonTitle action:(MysticBlockSender)action;

- (void) setType:(MysticPermissionType)type complete:(MysticBlockObjBOOL)block;

@end
