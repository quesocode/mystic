//
//  MysticImageAssetCell.m
//  Mystic
//
//  Created by Me on 5/5/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticImageAssetCell.h"
#import "Mystic.h"
#import "MysticCollectionItem.h"
#import "UIImageView+WebCache.h"
@interface MysticImageAssetCell ()



@end
@implementation MysticImageAssetCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) commonStyle;
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor color:MysticColorTypeCollectionSectionBackground];

    MysticView *bgView = [[MysticView alloc] initWithFrame:self.bounds];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    bgView.backgroundColor = self.backgroundColor;
    [self addSubview:bgView];
    self.bgView = bgView;
    [bgView release];
    
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.backgroundColor = self.backgroundColor;
    [self addSubview:imgView];
    self.imageView = imgView;
    self.clipsToBounds = YES;
    

    
    [imgView release];
}

- (void) prepareForReuse;
{
    [super prepareForReuse];
    [self.imageView cancelCurrentImageLoad];
    self.imageView.image = nil;
    self.imageView.alpha = 1;
    if(self.overlayView)
    {
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;
    }

}

//- (void) setSelected:(BOOL)selected;
//{
//    self.imageView.alpha = selected ? 0.05 : 1;
//}

- (void) setCollectionItem:(MysticCollectionItem *)collectionItem
{
    __block MysticImageAssetCell *weakSelf = self;
    switch (collectionItem.type)
    {
        case MysticCollectionItemTypeColor:
        {
            self.bgView.backgroundColor = collectionItem.displayColor;
            self.imageView.alpha = 0;
            break;
        }
        case MysticCollectionItemTypeGradient:
        {
            [self.bgView setBackgroundGradient:collectionItem.gradient];
            self.imageView.alpha = 0;

            break;
        }
        default:
        {
            self.imageView.alpha = 1;

            self.bgView.backgroundColor = [UIColor clearColor];
            if(collectionItem.thumbnailURL)
            {
                [self.imageView setImageWithURL:collectionItem.thumbnailURL placeholderImage:nil options:0 manager:MysticCache.uiManager progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

                    weakSelf.imageView.image = image;
                }];
            }
            
            break;
        }
    }
    [super setCollectionItem:collectionItem];

 
}
- (void) didDeselect:(MysticBlockObjBOOL)selectBlock;
{
    [self didSelect:selectBlock animated:YES];
}

- (void) didSelect:(MysticBlockObjBOOL)selectBlock;
{
    [self didSelect:selectBlock animated:YES];

}
- (void) didSelect:(MysticBlockObjBOOL)selectBlock animated:(BOOL)animated;
{
    BOOL __selected = self.selected;
    __unsafe_unretained __block MysticBlockObjBOOL __selectBlock = selectBlock ? Block_copy(selectBlock) : nil;
    __unsafe_unretained __block MysticImageAssetCell *weakSelf = self;

    if(__selected)
    {
        if(!self.overlayView)
        {
            UIImageView *overlayView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
            self.overlayView = overlayView;
            [overlayView release];
            [self addSubview:self.overlayView];

        }

        self.overlayView.userInteractionEnabled = NO;
        self.overlayView.backgroundColor = [[UIColor color:MysticColorTypePink] colorWithAlphaComponent:0.7];
        self.overlayView.alpha = 0;
//        MBorder(self.overlayView, [UIColor color:MysticColorTypePink], 4);
        
        
    }
    else
    {
//        if(self.overlayView)
//        {
//            
//        }
    }
    
    MysticBlock animBlock = ^{
        weakSelf.imageView.alpha = __selected ? 0.1 : 1;
        if(!__selected && weakSelf.overlayView)
        {
            weakSelf.overlayView.alpha = 0;
        }
        else if(weakSelf.overlayView)
        {
            weakSelf.overlayView.alpha = 1;
        }
    };
    
    MysticBlockBOOL finishedBlock = ^(BOOL finished) {
        
        if(!__selected && weakSelf.overlayView)
        {
            [weakSelf.overlayView removeFromSuperview];
            weakSelf.overlayView = nil;
        }
        
        if(__selectBlock)
        {
            [NSTimer wait:0.1 block:^{
                __selectBlock(self, __selected); Block_release(__selectBlock);
            }];
        }
    };
    
    if(animated)
    {
        [MysticUIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animBlock completion:finishedBlock];
    }
    else
    {
        animBlock();
        finishedBlock(YES);
    }
    
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
