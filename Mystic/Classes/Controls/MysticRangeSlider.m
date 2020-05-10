//
//  MysticRangeSlider.m
//  Mystic
//
//  Created by travis weerts on 1/27/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticRangeSlider.h"
#import "UIColor+Mystic.h"

@interface MysticRangeSlider (PrivateMethods)
-(float)xForValue:(float)value;
-(float)valueForX:(float)x;
-(void)updateTrackHighlight;
@end

@implementation MysticRangeSlider

@synthesize minimumValue, maximumValue, minimumRange, selectedMinimumValue, selectedMaximumValue, continuous, targetOption=_targetOption;

+ (MysticRangeSlider *) sliderWithFrame:(CGRect)frame;
{
    MysticRangeSlider *slider = [[MysticRangeSlider alloc] initWithFrame:frame];
    
    slider.tag = MysticViewTypeSlider;
    
    return [slider autorelease];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _minThumbOn = false;
        _maxThumbOn = false;
        _padding = 0;
        self.continuous = NO;
        UIImage *trackImage = [UIImage imageNamed:@"slider.png"];
        trackImage = [trackImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
        
        _trackBackground = [[[UIImageView alloc] initWithImage:trackImage] autorelease];
        _trackBackground.frame = CGRectMake(0, 0, CGRectGetWidth(frame), trackImage.size.height);
        _trackBackground.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
        [self addSubview:_trackBackground];
        
        UIImage *trackImage2 = [UIImage imageNamed:@"slider-min.png"];
        trackImage2 = [trackImage2 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
        
        _track = [[[UIImageView alloc] initWithImage:trackImage2] autorelease];
        _track.center = CGPointMake(0, CGRectGetHeight(frame)/2);
        [self addSubview:_track];
        
        _minThumb = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider-knob-med.png"] highlightedImage:[UIImage imageNamed:@"slider-knob-med-highlighted.png"]] autorelease];
        _minThumb.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height);
        _minThumb.contentMode = UIViewContentModeCenter;
        [self addSubview:_minThumb];
        
        _maxThumb = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider-knob-med.png"] highlightedImage:[UIImage imageNamed:@"slider-knob-med-highlighted.png"]] autorelease];
        _maxThumb.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height);
        _maxThumb.contentMode = UIViewContentModeCenter;
        [self addSubview:_maxThumb];
        
        
    }
    
    return self;
}


-(void)layoutSubviews
{
    // Set the initial state
    _minThumb.center = CGPointMake([self xForValue:selectedMinimumValue], CGRectGetHeight(self.bounds)/2);
    
    _maxThumb.center = CGPointMake([self xForValue:selectedMaximumValue], CGRectGetHeight(self.bounds)/2);
    
    
    [self updateTrackHighlight];

    
}

-(float)xForValue:(float)value{
    return (self.frame.size.width-(_padding*2))*((value - minimumValue) / (maximumValue - minimumValue))+_padding;
}

-(float) valueForX:(float)x{
    return minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (maximumValue - minimumValue);
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if(!_minThumbOn && !_maxThumbOn){
        return YES;
    }
    
    CGPoint touchPoint = [touch locationInView:self];
    if(_minThumbOn){
        _minThumb.center = CGPointMake(MAX([self xForValue:minimumValue],MIN(touchPoint.x - distanceFromCenter, [self xForValue:selectedMaximumValue - minimumRange])), _minThumb.center.y);
        selectedMinimumValue = [self valueForX:_minThumb.center.x];
        
    }
    if(_maxThumbOn){
        _maxThumb.center = CGPointMake(MIN([self xForValue:maximumValue], MAX(touchPoint.x - distanceFromCenter, [self xForValue:selectedMinimumValue + minimumRange])), _maxThumb.center.y);
        selectedMaximumValue = [self valueForX:_maxThumb.center.x];
    }
    [self updateTrackHighlight];
    [self setNeedsLayout];
    
    if(self.continuous) [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -15, -15);
    return CGRectContainsPoint(bounds, point);
}
-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touch locationInView:self];
    
    if(CGRectContainsPoint(_minThumb.frame, touchPoint)){
        _minThumbOn = true;
        distanceFromCenter = touchPoint.x - _minThumb.center.x;
//        [self sendActionsForControlEvents:UIControlEventEditingDidBegin];

    }
    else if(CGRectContainsPoint(_maxThumb.frame, touchPoint)){
        _maxThumbOn = true;
        distanceFromCenter = touchPoint.x - _maxThumb.center.x;
//        [self sendActionsForControlEvents:UIControlEventEditingDidBegin];

    }
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    _minThumbOn = false;
    _maxThumbOn = false;
    if(!self.continuous)
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }
}

-(void)updateTrackHighlight{
	_track.frame = CGRectMake(
                              _minThumb.center.x,
                              _track.center.y - (_track.frame.size.height/2),
                              _maxThumb.center.x - _minThumb.center.x,
                              _track.frame.size.height
                              );
}

@end
