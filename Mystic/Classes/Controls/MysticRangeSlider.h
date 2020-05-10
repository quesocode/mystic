//
//  MysticRangeSlider.h
//  Mystic
//
//  Created by travis weerts on 1/27/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "NMRangeSlider2.h"



@class  PackPotionOption;

@interface MysticRangeSlider : UIControl
{
    float minimumValue;
    float maximumValue;
    float minimumRange;
    float selectedMinimumValue;
    float selectedMaximumValue;
    float distanceFromCenter;
    
    float _padding;
    
    BOOL _maxThumbOn;
    BOOL _minThumbOn;
    
    UIImageView * _minThumb;
    UIImageView * _maxThumb;
    UIImageView * _track;
    UIImageView * _trackBackground;
}
@property (nonatomic, assign) CGFloat defaultMinValue, defaultMaxValue;

@property(nonatomic) BOOL continuous;
@property(nonatomic) float minimumValue;
@property(nonatomic) float maximumValue;
@property(nonatomic) float minimumRange;
@property(nonatomic) float selectedMinimumValue;
@property(nonatomic) float selectedMaximumValue;
@property (nonatomic, assign) PackPotionOption *targetOption;
@property (nonatomic, assign) MysticObjectType setting;

+ (MysticRangeSlider *) sliderWithFrame:(CGRect)frame;

@end
