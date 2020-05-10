//
//  MysticLeftTableViewCell.m
//  Mystic
//
//  Created by travis weerts on 8/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticLeftTableViewCell.h"
#import "Mystic.h"
#import "MysticIcon.h"
#import <QuartzCore/QuartzCore.h>


@implementation MysticLeftTableViewCellBackgroundView




+ (CGFloat) borderWidth;
{
    return MYSTIC_UI_DRAWER_CELL_BORDER;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {

        self.showBorder = NO;
        self.backgroundColor = [UIColor color:MysticColorTypeDrawerBackgroundCell];
        self.borderColor = [UIColor colorWithType:MysticColorTypeDrawerBackgroundCellBorder];
        self.borderWidth = [[self class] borderWidth];
        self.dashed = NO;
        self.dashSize = (CGSize){1,0};
    }
    return self;
}
- (void) resetBackground;
{
    self.backgroundColor = [UIColor color:MysticColorTypeDrawerBackgroundCell];
    self.borderColor = [UIColor colorWithType:MysticColorTypeDrawerBackgroundCellBorder];
    self.borderWidth = [[self class] borderWidth];
    self.dashed =NO;
    self.dashSize = (CGSize){1,0};
}
- (void) setBackgroundColor:(UIColor *)value;
{
    if(value==nil)
    {
        
        value = [UIColor color:MysticColorTypeDrawerBackgroundCell];
    }
    super.backgroundColor = value;

}


@end

@interface MysticLeftTableViewCell ()
{
    BOOL didShowBorder;
}

@end
@implementation MysticLeftTableViewCell

@dynamic backgroundView;

+ (Class) backgroundViewClass;
{
    return [MysticLeftTableViewCellBackgroundView class];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.textLabel.textColor = [UIColor color:MysticColorTypeDrawerText];
        self.textLabel.highlightedTextColor = [MysticColor colorWithType:MysticColorTypePink];
        self.textLabel.font = [MysticUI gothamBook:15];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        if([[self class] backgroundViewClass])
        {
            UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
            bgView.backgroundColor = [UIColor clearColor];
            self.selectedBackgroundView = bgView;
            
            self.backgroundView = [[[[self class] backgroundViewClass] alloc] initWithFrame:CGRectMake(0, 0, 170, 50)] ;
            self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        }
        else
        {
            self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
            self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            self.backgroundView.backgroundColor = [UIColor color:MysticColorTypeDrawerBackgroundCell];
        }
        
        didShowBorder = NO;
        self.imageView.backgroundColor = [UIColor clearColor];
        
        
//        self.accessoryView = [MysticIcon indicatorWithColor:[UIColor hex:@"63524b"]];
        
    }
    return self;
}
- (void) draw:(UIView *)cell size:(CGSize)size context:(CGContextRef)context;
{
    [cell.layer renderInContext:context];
    [[UIColor color:MysticColorTypeDrawerBackgroundCell] setFill];
//    [[UIColor color:MysticColorTypePink] setFill];

    CGContextFillRect(context, (CGRect){0,size.height - 4, size.width, 8});
}
- (void) willBeginLongPress;
{
    if(![self.backgroundView respondsToSelector:@selector(showBorder)]) return;
    
    didShowBorder = [(MysticLeftTableViewCellBackgroundView *)self.backgroundView showBorder];
    [(MysticLeftTableViewCellBackgroundView *)self.backgroundView setShowBorder:NO];
    [self.backgroundView setNeedsDisplay];
}
- (void) willEndLongPress;
{
    if(![self.backgroundView respondsToSelector:@selector(showBorder)]) return;
    [(MysticLeftTableViewCellBackgroundView *)self.backgroundView setShowBorder:didShowBorder];

    [self.backgroundView setNeedsDisplay];
    [self setNeedsDisplay];

}
+ (CGSize) imageViewSize;
{
    return (CGSize){MYSTIC_DRAWER_LAYER_ICON_WIDTH,MYSTIC_DRAWER_LAYER_ICON_HEIGHT};
}
- (CGPoint) layoutPadding; { return (CGPoint) { MYSTIC_DRAWER_LAYER_CELL_LAYOUT_PADDING_LEFT, MYSTIC_DRAWER_LAYER_CELL_LAYOUT_PADDING_TOP }; }

//- (UIEdgeInsets) layoutImageInsets;
//{
//    return UIEdgeInsetsMake(self.layoutPadding.y, self.layoutPadding.x, self.layoutPadding.y, self.layoutPadding.x);
//}
//- (CGPoint) layoutPadding;
//{
//    CGFloat width = self.frame.size.height;
//    CGFloat height = self.frame.size.height;
//    CGSize imgSize = [[self class] imageViewSize];
//    CGPoint imgPadding = CGPointMake((height - imgSize.width)/3, (height - imgSize.width)/2);
//    imgPadding = CGPointIntegral(imgPadding);
//    imgPadding.x = MAX(imgPadding.x, 0);
//    imgPadding.y = MAX(imgPadding.y, 0);
//    return imgPadding;
//}

- (UIEdgeInsets) layoutImageInsets;
{
    return UIEdgeInsetsMake(MYSTIC_DRAWER_LAYER_CELL_LAYOUT_PADDING_TOP,
                            MYSTIC_DRAWER_LAYER_CELL_LAYOUT_PADDING_LEFT + MYSTIC_DRAWER_LAYER_CELL_LAYOUT_OFFSET_LEFT,
                            MYSTIC_DRAWER_LAYER_CELL_LAYOUT_PADDING_BOTTOM,
                            MYSTIC_DRAWER_LAYER_CELL_LAYOUT_PADDING_RIGHT);
}


- (void) layoutSubviews;
{
    [super layoutSubviews];
    CGFloat width = self.frame.size.height;
    CGFloat height = self.frame.size.height;
    CGSize imgSize = [[self class] imageViewSize];
    CGPoint imgPadding = self.layoutPadding;
    UIEdgeInsets limgInsets = self.layoutImageInsets;
    self.imageView.frame = CGRectMake(limgInsets.left, limgInsets.top, imgSize.width, imgSize.height);
    if(self.backgroundView)
    {
        self.backgroundView.frame = self.bounds;
    }
    CGRect lframe = self.textLabel.frame;
    lframe.origin.y = imgPadding.y + 2;
    lframe.origin.x = self.imageView.frame.origin.x + imgSize.width + limgInsets.right;
    
    if(self.detailTextLabel)
    {
        CGRect dFrame = self.detailTextLabel.frame;
        CGRect cRect = CGRectMake(lframe.origin.x, lframe.origin.y, lframe.size.width, lframe.size.height + dFrame.size.height + MYSTIC_DRAWER_LAYER_CELL_LAYOUT_TITLE_SPACE_Y);
        cRect.origin.y = (height-cRect.size.height)/2;
        
        lframe.origin.y = cRect.origin.y;
        
        dFrame.origin.y = cRect.origin.y + cRect.size.height - dFrame.size.height;
        
        self.detailTextLabel.frame = dFrame;
        
    }
    
    self.textLabel.frame = lframe;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
