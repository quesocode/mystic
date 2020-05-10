//
//  MysticStandardProjectViewCell.m
//  Mystic
//
//  Created by Me on 12/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticStandardProjectViewCell.h"
#import "UIColor+Mystic.h"
#import "MysticCenteredButton.h"

@implementation MysticStandardProjectViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 20)];
        label.font = [MysticUI font:16];
        label.textColor = [UIColor hex:@"8e857c"];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedString(@"Use a Photo from", nil);
        [self addSubview:label];
        [label release];
        
        MysticCenteredButton *photosBtn = (MysticCenteredButton *)[MysticCenteredButton buttonWithImage:[UIImage imageNamed:@"new-photo-icon.png"] target:self sel:@selector(albumButtonTouched:)];
        [photosBtn setTitle:NSLocalizedString(@"Existing Photo", nil) forState:UIControlStateNormal];
        photosBtn.frame = CGRectMake(0, 40, 106, 79);
        [photosBtn setImage:[UIImage imageNamed:@"new-photo-icon.png"] forState:UIControlStateNormal];
        photosBtn.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [photosBtn setTitleColor:[UIColor hex:@"c19156"] forState:UIControlStateNormal];
        photosBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:photosBtn];
        
        MysticCenteredButton *camBtn = (MysticCenteredButton *)[MysticCenteredButton buttonWithImage:[UIImage imageNamed:@"new-cam-icon.png"] target:self sel:@selector(cameraButtonTouched:)];
        camBtn.frame = CGRectMake(106, 40, 106, 79);
        [camBtn setTitle:NSLocalizedString(@"Camera", nil) forState:UIControlStateNormal];
        camBtn.titleLabel.font = photosBtn.titleLabel.font;
        [camBtn setTitleColor:[UIColor hex:@"c19156"] forState:UIControlStateNormal];
        camBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:camBtn];
        

        
        [MysticUI layout:@[photosBtn, camBtn] bounds:self.frame mode:MysticLayoutModeSpacedHorizontally];
    }
    return self;
}

- (void) cameraButtonTouched:(MysticCenteredButton *)sender;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cameraButtonTouched:)])
    {
        [self.delegate performSelector:@selector(cameraButtonTouched:) withObject:sender];
    }
}
- (void) albumButtonTouched:(MysticCenteredButton *)sender;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(albumButtonTouched:)])
    {
        [self.delegate performSelector:@selector(albumButtonTouched:) withObject:sender];
    }
}
- (void) bgButtonTouched:(MysticCenteredButton *)sender;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(bgButtonTouched:)])
    {
        [self.delegate performSelector:@selector(bgButtonTouched:) withObject:sender];
    }
}
- (void) loadTemplates:(NSArray *)templates;
{
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


@end
