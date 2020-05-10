//
//  MysticMainMenuViewCell.m
//  Mystic
//
//  Created by Travis on 10/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticMainMenuViewCell.h"
#import "Mystic.h"
@implementation MysticMainMenuViewCellBackgroundView


+ (CGFloat) borderWidth;
{
    return MYSTIC_UI_DRAWER_CELL_BORDER;
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        
//        self.showBorder = NO;
//        self.dashed = NO;
//        self.dashSize = (CGSize){1,1};
        [self resetBackground];
    }
    return self;
}
- (void) resetBackground;
{
//    [super resetBackground];
//    self.dashed = NO;
//    self.dashSize = (CGSize){1,1};
//    self.borderColor = [UIColor colorWithType:MysticColorTypeDrawerMainCellBorder];
//    self.borderWidth = [[self class] borderWidth];
    self.backgroundColor = [UIColor color:MysticColorTypeDrawerBackgroundCell];

    
}



@end



@implementation MysticMainMenuViewCell
+ (Class) backgroundViewClass;
{
    return nil;
    return [MysticMainMenuViewCellBackgroundView class];

}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.backgroundView.backgroundColor = [UIColor color:MysticColorTypeDrawerBackgroundCellMain];
//        self.backgroundView.borderColor = [UIColor color:MysticColorTypeDrawerMainCellBorder];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [MysticFont gothamMedium:10];
        
    }
    return self;
}

- (void) layoutSubviews;
{
    [super layoutSubviews];
    
    self.textLabel.frame = self.bounds;
}

@end
