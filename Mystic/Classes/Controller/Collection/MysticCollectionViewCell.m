//
//  MysticCollectionViewCell.m
//  Mystic
//
//  Created by Me on 5/3/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewCell.h"
#import "MysticView.h"

@implementation MysticCollectionViewCell

@synthesize backgroundView=_backgroundView;

- (void)awakeFromNib{
    [super awakeFromNib];
    [self commonStyle];
}

- (void) dealloc;
{
    if(_imageView) [_imageView cancelCurrentImageLoad];
    [_titleLabel release], _titleLabel=nil;
    [_imageView release], _imageView=nil;
    [_overlayView release], _overlayView=nil;
    [_bgView release], _bgView = nil;
    
    [super dealloc];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonStyle];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonStyle];
    }
    return self;
}
- (void) didDeselect:(MysticBlockObjBOOL)selectBlock;
{
    if(selectBlock) selectBlock(self, YES);
}
- (void) didSelect:(MysticBlockObjBOOL)selectBlock;
{
    if(selectBlock) selectBlock(self, YES);
}

- (void) setCollectionItem:(MysticCollectionItem *)collectionItem;
{
}

- (void) commonStyle;
{
    _titleLabel = nil;
    _imageView = nil;
    _backgroundView=nil;
}
@end
