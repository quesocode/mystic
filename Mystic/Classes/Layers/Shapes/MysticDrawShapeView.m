//
//  MysticDrawShapeView.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/17/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticDrawShapeView.h"
#import "MysticLayerShapeView.h"
#import "MysticChoice.h"
#import "MysticShapesKit.h"

@interface MysticDrawShapeView ()

@property (nonatomic, retain) NSMutableDictionary *images;

@end
@implementation MysticDrawShapeView

+ (CGRect) boundsForContent:(id)content target:(CGSize)targetSize context:(MysticDrawingContext **)_context scale:(CGFloat)scale;
{
    MysticDrawingContext *context = *_context;
    if(!_context)
    {
        MysticDrawingContext *dc = [[[MysticDrawingContext alloc] init] autorelease];
        dc.minimumScaleFactor = 0.5;
        dc.fontSizePointFactor = 0.5;
        dc.sizeOptions = MysticSizeOptionMatchDefault;
        dc.minimumRatio = (CGSize){0.7,0.7};
        context = dc;
        *_context = dc;
    }
    context.minimumRatio = (CGSize){0.7,0.7};
    context.totalSize =targetSize;
    context.targetSize = targetSize;
    return CGRectSize(targetSize);
}

- (MysticLayerShapeView *) shapeView; { return (id)self.layerView; }
- (UIImage *) contentImage:(CGSize)imageSize;
{
    UIImage *image;
    NSString *key = [[SLogStrd(imageSize, 0) stringByAppendingFormat:@"%@%@", self.shapeView.choice.content, self.shapeView.color ? [NSString stringWithFormat:@"_rgb_%d-%d-%d", self.shapeView.color.red255, self.shapeView.color.green255, self.shapeView.color.blue255] : @""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if([self.images objectForKey:key])
    {
        image = [UIImage imageWithContentsOfFile:[self.images objectForKey:key]];
        if(image) return image;
    }
    NSString *tag = key;
    image = [UserPotionManager getProjectImageForSize:imageSize layerLevel:0 tag:tag type:MysticImageTypePNG cacheType:MysticCacheTypeProject];
    if(image) return image;
        
    image = [MysticImage image:self.shapeView.choice.content size:imageSize color:self.shapeView.color backgroundColor:nil];
    __unsafe_unretained __block MysticDrawShapeView *weakSelf = [self retain];
    if(!weakSelf.images) weakSelf.images = [NSMutableDictionary dictionary];
    [UserPotionManager setImage:image layerLevel:0 tag:tag type:MysticImageTypePNG cacheType:MysticCacheTypeProject finishedPath:^(NSString *imagePath) {
        [weakSelf.images setObject:imagePath forKey:key];
        [weakSelf autorelease];
    }];
    
    return image;
}
- (void) drawWithRect:(CGRect)rect;
{
    [super drawWithRect:rect];
    if(self.shapeView.content)
    {
         CGRect r = self.renderRect;
        if(self.shapeView.choice.usesCustomDrawing)
        {
            if(CGRectIsZero(self.renderRect))
            {
                r = CGRectSize(CGSizeFloor(self.bounds.size));
                r.size = CGSizeCeil(r.size);
                
                CGSize s = self.shapeView.choice.size;
                if(!CGSizeIsUnknown(s))
                {
                    r = CGRectWithContentMode(CGRectSize(s), self.bounds, self.contentMode);
                }
            }
            self.renderRect = r;
            self.shapeView.choice.frame = self.renderRect;
            self.shapeView.choice.bounds = self.bounds;
            if([[[MysticShapesKit kit] class] respondsToSelector:self.shapeView.choice.customDrawingSelector]) [[[MysticShapesKit kit] class] performSelector:self.shapeView.choice.customDrawingSelector withObject:self.shapeView.choice];
        }
        else
        {
            CGRect imageRect;
            UIImage *image;
            if(CGRectIsZero(self.renderRect))
            {
                CGRect renderRect = CGRectSize(CGSizeFloor(self.bounds.size));
                imageRect = renderRect;
                imageRect.size = CGSizeMakeUnknown(CGSizeCeil(imageRect.size));
                image = [self contentImage:imageRect.size];
                r = CGRectWithContentMode(CGRectSize(image.size), self.bounds, self.contentMode);
                r.size = CGSizeCeil(r.size);
            }
            else
            {
                imageRect = self.renderRect;
                r = self.renderRect;
                image = [self contentImage:r.size];
            }
            self.renderRect = r;
            if(image) [image drawInRect:r];
        }
    }
}

@end
