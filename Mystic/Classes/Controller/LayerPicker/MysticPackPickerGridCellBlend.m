//
//  MysticPackPickerGridCellBlend.m
//  Mystic
//
//  Created by Me on 6/16/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPackPickerGridCellBlend.h"
#import "MysticPackPickerGridItem.h"
@interface MysticPackPickerGridCellBlend ()


@end
@implementation MysticPackPickerGridCellBlend


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageColor = [UIColor hex:@"e6e1d8"];
        self.highlightedImageColor = [UIColor color:MysticColorTypePink];

    }
    return self;
}

- (void) setCollectionItem:(MysticPackPickerGridItem *)collectionItem
{
    if(self.imageView.superview) [self.imageView removeFromSuperview];
    __unsafe_unretained __block MysticPackPickerGridCell *weakSelf = [self retain];
    [self.imageView setImageWithURL:[NSURL URLWithString:collectionItem.option.thumbURLString] placeholderImage:nil options:0 manager:[MysticCache uiManager] progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

        
//    [self.imageView setImageWithURL:[NSURL URLWithString:collectionItem.option.thumbURLString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
        
            __unsafe_unretained __block UIImage *img = [[MysticImage maskedColorImage:weakSelf.backgroundColor mask:image] retain];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.image = img;
                [weakSelf setNeedsDisplay];
                [img release];
                [weakSelf autorelease];

            });

        });
    }];
    
}


- (void) didSelect:(MysticBlockObjBOOL)selectBlock animated:(BOOL)animated;
{
    BOOL __selected = self.selected;
    __unsafe_unretained __block MysticBlockObjBOOL __selectBlock = selectBlock ? Block_copy(selectBlock) : nil;
    __unsafe_unretained __block MysticImageAssetCell *weakSelf = self;

    
    [self setNeedsDisplay];
    
    if(__selectBlock)
    {
        [NSTimer wait:0.3 block:^{
            __selectBlock(self, __selected); Block_release(__selectBlock);
        }];
    }
    
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.backgroundColor setFill];
//    [[UIColor red] setFill];
    CGContextFillRect(context, rect);
    
    if(self.imageView.image)
    {
        
        if(self.selected)
        {
            [self.highlightedImageColor setFill];
        }
        else
        {
            [self.imageColor setFill];

        }
        CGContextFillRect(context, CGRectInset(self.imageView.frame, 11, 11));

        [self.imageView.image drawInRect:CGRectInset(self.imageView.frame, 10, 10) blendMode:kCGBlendModeNormal alpha:1];

    }

    
//    [super drawRect:rect];
}


@end
