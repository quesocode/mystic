//
//  MysticPackButton.m
//  Mystic
//
//  Created by travis weerts on 9/3/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticPackButton.h"
#import "Mystic.h"


@implementation MysticPackButton

//@synthesize backgroundView, imageView;
@synthesize imageViewAlphaOnSelect, showBorder=_showBorder;
@dynamic objectType;

- (id)initWithFrame:(CGRect)frame type:(MysticObjectType)theType;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.objectType = theType;
        
    }
    return self;
}


- (void) commonInit;
{
    [super commonInit];
    _showBorder = NO;

    self.layer.cornerRadius = MYSTIC_UI_TOPIC_CORNER_RADIUS;
    self.adjustsImageWhenHighlighted = NO;
    self.selected = NO;
    self.imageViewAlphaOnSelect = 1.0f;
    self.titleLabel.font = [MysticUI font:MYSTIC_UI_TOPIC_FONTSIZE];
    self.titleLabel.numberOfLines = 2;
    [self setTitleColor:[UIColor color:MysticColorTypeTopicText] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor color:MysticColorTypeTopicTextHighlighted] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor color:MysticColorTypeTopicTextSelected] forState:UIControlStateSelected];


}

- (void) setShowBorder:(BOOL)showBorder;
{
    _showBorder = showBorder;
    self.layer.borderWidth = _showBorder ? MYSTIC_UI_TOPIC_BORDERWIDTH : 0;
    if(showBorder)
    {
        self.layer.borderColor = [UIColor color:MysticColorTypeTopicBorder].CGColor;
    }
    [self setNeedsDisplay];
}

- (void) setSelected:(BOOL)selected;
{
    [super setSelected:selected];
    
    self.backgroundColor = selected ? [UIColor color:MysticColorTypeTopicBackgroundSelected] : [UIColor color:MysticColorTypeTopicBackground];
    if(self.showBorder)
    {
        self.layer.borderColor = [UIColor color:(selected ? MysticColorTypeTopicBorderSelected : MysticColorTypeTopicBorder)].CGColor;
    }

    
    if(self.imageView)
    {
        self.imageView.alpha = selected ? self.imageViewAlphaOnSelect : 1.0;
        
    }
    [self setNeedsDisplay];
}

- (void) setHighlighted:(BOOL)highlighted;
{
    [super setHighlighted:highlighted];
    if(highlighted)
    {
        self.backgroundColor = [UIColor color:MysticColorTypeTopicBackgroundHighlighted];
    }
    else
    {
        self.backgroundColor = super.selected ? [UIColor color:MysticColorTypeTopicBackgroundSelected] : [UIColor color:MysticColorTypeTopicBackground];

    }
    
    if(self.showBorder)
    {
        self.layer.borderColor = [UIColor color:(highlighted ? MysticColorTypeTopicBorderHighlighted : ((self.selected ? MysticColorTypeTopicBorderSelected : MysticColorTypeTopicBorder)))].CGColor;
    }
    
    
    if(self.imageView)
    {
        self.imageView.alpha = super.selected ? self.imageViewAlphaOnSelect : 1.0;
        
    }
   
    [self setNeedsDisplay];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
