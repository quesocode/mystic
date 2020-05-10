//
//  MysticRoundView.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/18/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MysticRoundView : UIView

@property (nonatomic, weak) UIColor *borderColor;
@property (nonatomic, strong) UIColor *originalBackgroundColor;

@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) BOOL blur;
@end
