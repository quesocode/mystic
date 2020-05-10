//
//  MysticPackPickerGridCell.m
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPackPickerGridCell.h"
#import "MysticPackPickerGridItem.h"
#import "UIImageView+WebCache.h"

@interface MysticPackPickerGridCell ()
{
    
}


@end
@implementation MysticPackPickerGridCell

- (void) dealloc;
{
    if(self.imageView)
    {
        [self.imageView cancelCurrentImageLoad];
    }
    [_imageColor release];
    [_highlightedImageColor release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.highlightedImageColor = [UIColor color:MysticColorTypePink];
        
    }
    return self;
}


- (void) commonStyle;
{
    [super commonStyle];
//    UILabel *theLabel = [[[UILabel alloc] initWithFrame:self.bounds] autorelease];
//    self.label = theLabel;
//    self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//    self.label.textColor = [UIColor whiteColor];
//    self.label.textAlignment = NSTextAlignmentCenter;
//    self.label.font = [MysticUI font:10];
//    self.label.backgroundColor = [UIColor clearColor];
//    self.label.text = @"...";
//    MBorder(self, [UIColor color:MysticColorTypeMainBackground], 1);
    self.imageView.backgroundColor = self.backgroundColor;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect iFrame = self.imageView.frame;
    iFrame = CGRectInset(iFrame, 8, 8);
    self.imageView.frame = iFrame;

//    [self addSubview:self.label];
//    
//    [theLabel release];
    
    
    
}

- (void) prepareForReuse;
{
    [super prepareForReuse];
}

- (void) setSelected:(BOOL)selected;
{
    [super setSelected:selected];
    [self setNeedsDisplay];

//    self.imageView.alpha = 1;
//    MBorder(self, [UIColor color:MysticColorTypePink], selected ? 3 : 0);
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
            overlayView.contentMode = UIViewContentModeCenter;
            self.overlayView = overlayView;
            [overlayView release];
            [self addSubview:self.overlayView];
            
        }
        
        self.overlayView.userInteractionEnabled = NO;
        self.overlayView.backgroundColor = [UIColor clearColor];
        self.overlayView.alpha = 0;
        
        UIColor *checkColor = [UIColor color:MysticColorTypePink];
        
        
        [(UIImageView *)self.overlayView setImage:[MysticImage image:@(MysticIconTypeToolBarConfirm) size:(CGSize){40,40} color:[checkColor darker:0.36]]];
        
        
        
        
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
            [NSTimer wait:0.15 block:^{
                __selectBlock(self, __selected); Block_release(__selectBlock);
            }];
        }
    };
    
    
    if(animated)
    {
        [MysticUIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animBlock completion:finishedBlock];
    }
    else
    {
        animBlock();
        finishedBlock(YES);
    }
    
}


- (void) setCollectionItem:(MysticPackPickerGridItem *)collectionItem
{
//    MysticColorType controlColorType = MysticColorTypeChoice1 + collectionItem.indexPath.section;
//    controlColorType = controlColorType >= MysticColorTypeLastChoice ? (controlColorType - MysticColorTypeLastChoice) + MysticColorTypeChoice1 : controlColorType;
//    
//    self.backgroundColor = [UIColor color:controlColorType];
//
//    self.label.text = collectionItem.option.name;
    __unsafe_unretained __block MysticPackPickerGridCell *weakSelf = self;
    
    [self.imageView setImageWithURL:[NSURL URLWithString:collectionItem.option.thumbURLString] placeholderImage:nil options:0 manager:[MysticCache uiManager] progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

        
//    [self.imageView setImageWithURL:[NSURL URLWithString:collectionItem.option.thumbURLString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        weakSelf.imageView.image = image;
        [weakSelf setNeedsDisplay];

    }];
    
//    self.label.text = [NSString stringWithFormat:@"%d, %d", collectionItem.indexPath.section, collectionItem.indexPath.row];
    
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.backgroundColor setFill];
    CGContextFillRect(context, rect);

    if(self.imageView.image)
    {
        
        if(self.selected)
        {
            [self.highlightedImageColor setFill];
            CGContextFillRect(context, self.imageView.frame);
            [self.imageView.image drawInRect:self.imageView.frame blendMode:kCGBlendModeLuminosity alpha:0.15];

        }
        else
        {
//            ALLog(@"drawing cell", @[@"image", ILogStr(self.imageView.image),
//                                     @"imageView", FLogStr(self.imageView.frame)]);
            [self.imageView.image drawInRect:self.imageView.frame blendMode:kCGBlendModeNormal alpha:1];

        }
        
        
    }

    
    
//    [super drawRect:rect];
}

@end
