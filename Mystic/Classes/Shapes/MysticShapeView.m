//
//  MysticShapeView.m
//  Mystic
//
//  Created by Me on 11/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticShapeView.h"
#import "PackPotionOptionShape.h"

@interface MysticShapeView ()



@end
@implementation MysticShapeView

@dynamic option;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (MysticResizeableImageView *)imageView;
{
    return (MysticResizeableImageView *)self.contentView;
}
- (void) setOption:(PackPotionOptionShape *)newOption;
{
    if(super.option)
    {
        PackPotionOptionShape *oldOption = super.option;
        newOption.view = oldOption.view;
        newOption.shapesView = oldOption.shapesView;
        [newOption.colorTypes addEntriesFromDictionary:oldOption.colorTypes];
        newOption.intensity = oldOption.intensity;
        oldOption.view = nil;
        oldOption.shapesView = nil;
        
    }
    [super setOption:newOption];
    MysticResizeableImageView *imageView = self.imageView;
    
    if(!imageView)
    {
        imageView = [[[MysticResizeableImageView alloc] initWithFrame:self.bounds] autorelease];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        if(!self.contentView)
        {
            self.contentView = [[[MysticLayerContentView alloc] initWithFrame:self.bounds] autorelease];
        }
        
        self.contentView.view = imageView;

    }
    MysticBlockReturnsImage resizeImageBlock = ^ UIImage * (CGSize newSize)
    {
        return (UIImage *) [newOption sourceImageAtSize:newSize];
    };
    
    [imageView setResizeImageBlock:resizeImageBlock];
    [self resize];
}
- (void) resize;
{
    [super resize];
    [self.imageView resize:self.bounds];
}

- (NSString *) description;
{
    return [NSString stringWithFormat:@"%@ <%p> Option: %@", [self class], self, self.option];
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
