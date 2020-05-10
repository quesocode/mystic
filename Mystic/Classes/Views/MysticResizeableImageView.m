//
//  MysticResizableImageView.m
//  Mystic
//
//  Created by Me on 11/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticResizeableImageView.h"
#import "MysticUI.h"
#import "MysticImage.h"

@implementation MysticResizeableImageView

@synthesize resizeImageBlock=_resizeImageBlock;

- (void) dealloc;
{
    if(_resizeImageBlock)
    {
        Block_release(_resizeImageBlock);
    }
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) removeFromSuperview;
{
    if(_resizeImageBlock)
    {
        Block_release(_resizeImageBlock);
        _resizeImageBlock = nil;
    }
    [super removeFromSuperview];
}

- (void) resize;
{
    [self resize:self.bounds];
}
- (void) resize:(CGRect)rect;
{
    if(self.resizeImageBlock)
    {
        self.image = self.resizeImageBlock(rect.size);
    }

}

//- (void) setFrame:(CGRect)newFrame;
//{
//    if(!CGSizeEqualToSize(newFrame.size, self.frame.size))
//    {
//        if(_resizeImageBlock)
//        {
//            
//            CGSize newImageSize = [MysticUI scaleSize:newFrame.size scale:MYSTIC_RESIZEABLE_IMAGEVIEW_SCALE];
//            SLog(@"new frame size", newFrame.size);
//            SLog(@"new image size", newImageSize);
//            CGSize currentImageSize = self.image ? self.image.size : CGSizeZero;
//            SLog(@"current image size", currentImageSize);
//            
//            if(!self.image || CGSizeLess(currentImageSize, newImageSize))
//            {
//                UIImage *newImage = _resizeImageBlock(newImageSize);
//                self.image = newImage;
//            }
//        }
//    }
//    [super setFrame:newFrame];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
