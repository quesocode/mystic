//
//  MysticLayerTableViewCell.m
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticLayerTableViewCell.h"
#import "Mystic.h"
@implementation MysticLayerTableViewCellBackgroundView


+ (CGFloat) borderWidth;
{
    return MYSTIC_UI_DRAWER_CELL_BORDER;
}
- (void) dealloc;
{
    [_borderColor release];
    [super dealloc];
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        
//        self.showBorder = NO;
//        self.dashed = YES;
//        self.dashSize = (CGSize){1,6};
        [self resetBackground];
    }
    return self;
}
- (void) resetBackground;
{
    self.backgroundColor = [UIColor color:MysticColorTypeDrawerBackgroundCell];
//    self.dashed = YES;
//    self.dashSize = (CGSize){1,6};
//    self.borderColor = [UIColor colorWithType:MysticColorTypeDrawerMainCellBorder];
//    self.borderWidth = [[self class] borderWidth];
    
}



@end

@implementation MysticLayerTableViewCell
+ (Class) backgroundViewClass;
{
    return [MysticLayerTableViewCellBackgroundView class];
}
- (void) dealloc;
{
    [_imageViewControl release], _imageViewControl = nil;
    [_imageViewBackground release], _imageViewBackground = nil;
    [super dealloc];
}
- (void) prepareForReuse;
{
    [super prepareForReuse];
    self.imageView.image = nil;
    self.imageView.alpha = 1;
    if([self.backgroundView respondsToSelector:@selector(resetBackground)]) [self.backgroundView performSelector:@selector(resetBackground)];
    self.imageViewBackground.layer.borderColor = [[UIColor hex:@"333130"] colorWithAlphaComponent:0].CGColor;
    
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor color:MysticColorTypeDrawerBackgroundCellLayers];
    }
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.textLabel.font = [MysticUI gothamBook:13];

        
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor color:MysticColorTypeDrawerTextSubtitle];
        self.detailTextLabel.highlightedTextColor = [MysticColor colorWithType:MysticColorTypePink];
        self.detailTextLabel.font = [MysticUI gothamBold:9];

        UIButton *imgVb = [[UIButton alloc] initWithFrame:self.imageView.frame];
        imgVb.backgroundColor = [UIColor hex:@"333130"];
        imgVb.layer.borderColor = [imgVb.backgroundColor colorWithAlphaComponent:0].CGColor;
        imgVb.layer.borderWidth = 1;
        self.imageViewBackground = [imgVb autorelease];
        [self.contentView insertSubview:self.imageViewBackground aboveSubview:self.imageView];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = MYSTIC_UI_DRAWER_CELL_CORNER_RADIUS;
        
        UIImage *image = [UIImage imageNamed:@"switch7.png"];
        Switch *mySwitch = [Switch switchWithImage:image
                              visibleWidth:21];
        mySwitch.layer.cornerRadius = 6;
        mySwitch.layer.borderWidth = 1;
        mySwitch.layer.borderColor = [UIColor blackColor].CGColor;


        self.imageViewControl = mySwitch;
        

        
        

    }
    return self;
}

- (void) setImageViewBorderColor:(UIColor *)color;
{
//    if(!self.highlighted && !self.selected)
//    {
    if(self.imageViewBackground.enabled)
    {
        MysticColorHSB hsb = color.hsb;
        
        UIColor *c1 = [UIColor colorWithCGColor:color.CGColor];
        if(hsb.brightness < .25)
        {
            color = [UIColor colorWithHue:hsb.hue saturation:hsb.saturation brightness:hsb.brightness+.25 alpha:color.alpha];
            
            
            
        }
     
    
//    }
    }
    self.imageViewBackground.layer.borderColor = color.CGColor;
}

- (void) draw:(UIView *)cell size:(CGSize)size context:(CGContextRef)context;
{
    [self draw:cell size:size context:context highlighted:YES];
}
- (void) draw:(UIView *)cell size:(CGSize)size context:(CGContextRef)context highlighted:(BOOL)drawHighlighted;
{
    BOOL aHidden = self.accessoryView ? self.accessoryView.hidden : YES;
    UIColor *dtxtColor = self.detailTextLabel.textColor;
    UIColor *txtColor = self.textLabel.textColor;
    UIColor *ivbc = [UIColor colorWithCGColor:self.imageViewBackground.layer.borderColor];
    self.backgroundColor = [UIColor color:MysticColorTypePink];
    self.backgroundView.backgroundColor = self.backgroundColor;
    if([self.backgroundView respondsToSelector:@selector(borderColor)]) [(MysticLeftTableViewCellBackgroundView *)self.backgroundView setBorderColor:self.backgroundColor];

    self.accessoryView.hidden = YES;
    self.textLabel.textColor = [UIColor color:MysticColorTypeWhite];
    if(self.detailTextLabel) self.detailTextLabel.textColor = self.textLabel.textColor;
    
    
    self.imageViewBackground.layer.borderColor = [self.backgroundColor colorWithAlphaComponent:ivbc.alpha].CGColor;
    
    BOOL fixSwitch = self.imageViewControl.enabled && !self.imageViewControl.on ? YES : NO;
    
    [cell.layer renderInContext:context];
//    [[UIColor color:MysticColorTypeDrawerBackgroundCell] setFill];
    [[UIColor color:MysticColorTypePink] setFill];
    
    CGContextFillRect(context, (CGRect){0,size.height - 4, size.width, 8});
    
//    if(fixSwitch)
//    {
        [[[UIColor color:MysticColorTypePink] colorWithAlphaComponent:0.5] setFill];

        CGContextFillRect(context, (CGRect){0,0, self.textLabel.frame.origin.x - 5, size.height});

//    }
    if([self.backgroundView respondsToSelector:@selector(resetBackground)]) [self.backgroundView performSelector:@selector(resetBackground)];

    self.backgroundColor = [UIColor color:MysticColorTypeDrawerBackgroundCellLayers];
    if(self.accessoryView) self.accessoryView.hidden = aHidden;
    if(self.detailTextLabel) self.detailTextLabel.textColor = dtxtColor;
    self.textLabel.textColor = txtColor;
    self.imageViewBackground.layer.borderColor = ivbc.CGColor;

}

- (void) setImageViewControl:(Switch *)imageViewControl;
{
    if(_imageViewControl)
    {
        [_imageViewControl removeFromSuperview];
        [_imageViewControl release], _imageViewControl = nil;
    }
    _imageViewControl = [imageViewControl retain];
    [self.contentView addSubview:_imageViewControl];
    [self setNeedsLayout];
}


- (void) layoutSubviews;
{
    [super layoutSubviews];
    CGFloat padding = 20.0f;
    CGFloat width = self.frame.size.height;
    CGFloat height = self.frame.size.height;
    
    CGRect maxLabelFrame = self.bounds;
    
    CGRect lframe = self.textLabel.frame;
    CGRect dFrame = self.detailTextLabel.frame;
    CGRect aFrame = self.accessoryView.frame;
    aFrame.origin.x = self.bounds.size.width - aFrame.size.width - (self.layoutPadding.x/2);
    aFrame.origin.y = ((self.bounds.size.height - aFrame.size.height)/2)-1;
    maxLabelFrame.size.width = aFrame.origin.x - self.textLabel.frame.origin.x - self.layoutPadding.x;
    lframe.size.width = maxLabelFrame.size.width;
    dFrame.size.width = maxLabelFrame.size.width;
    
    lframe.origin.y -= 1;
    dFrame.origin.y -= 1;
    dFrame.origin.x = lframe.origin.x;

    self.textLabel.frame = lframe;
    self.detailTextLabel.frame = dFrame;
    self.accessoryView.frame = aFrame;
    if(self.imageViewControl)
    {
        //self.imageViewControl.frame = self.imageView.frame;
        self.imageViewControl.origin = (CGPoint){self.imageView.frame.origin.x + ((self.imageView.frame.size.width - self.imageViewControl.visibleWidth)/2), self.imageView.frame.origin.y + (((self.imageView.frame.size.height - self.imageViewControl.frame.size.height)/2))};
    }
    self.imageViewBackground.frame = self.imageView.frame;
    self.imageViewBackground.layer.cornerRadius = self.imageView.layer.cornerRadius;
    

//    MBorder(self.accessoryView, nil, 1);

}

- (BOOL) showsReorderControl;
{
    if([self.textLabel.text isEqualToString:@"Photo"]) return NO;
    return YES;
}
- (UITableViewCellEditingStyle) editingStyle;
{
    return UITableViewCellEditingStyleNone;
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
