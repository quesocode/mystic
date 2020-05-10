// NVgalleryViewController.m
//
// Copyright (c) 2013 Nazar Kanaev (nkanaev@live.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NVGalleryViewController.h"

static CGFloat const kImageDistance = MYSTIC_UI_GALLERY_IMAGE_PADDING;

static CGSize CGSizeResizeToHeight(CGSize size, CGFloat height) {
    size.width *= height / size.height;
    size.height = height;
    return size;
}

@interface NVGalleryViewController ()


- (CGSize)setFramesToImageViews:(NSArray *)imageViews toFitSize:(CGSize)frameSize;
- (void)deviceOrientationChange;
@end

@implementation NVGalleryViewController

- (id)init;
{
    self = [super init];
    if(self)
    {
        self.numberOfImages = NSNotFound;
    }
    return self;
}
- (id)initWithImages:(NSArray *)images {
    if (self = [self init]) {
        self.images = images;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.contentView = [[MysticScrollView alloc] initWithFrame:self.view.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.contentView];
    [self placeImages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)placeImages {
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    self.contentView.contentOffset = CGPointZero;
    NSMutableArray *imageViews = [NSMutableArray array];
    NSInteger i = 0;
    self.numberOfImages = self.numberOfImages == NSNotFound ? self.images.count : self.numberOfImages;
    for (i = 0; i<self.numberOfImages; i++) {
        UIImageView *imageView;
        
        if([self.delegate respondsToSelector:@selector(galleryViewController:viewForIndex:)])
        {
            imageView = [self.delegate galleryViewController:self viewForIndex:i];
        }
        else
        {
            imageView = [[UIImageView alloc] initWithImage:[self.images objectAtIndex:i]];
        }
        
        
        imageView.tag = MysticViewTypeImage + i;
        [imageViews addObject:imageView];
    }
    
    CGSize newSize = [self setFramesToImageViews:imageViews toFitSize:self.contentView.frame.size];
    self.contentView.contentSize = newSize;
    for (UIImageView *imageView in imageViews) {
        if([self.contentView.subviews containsObject:imageView]) continue;
        [self.contentView addSubview:imageView];
    }
}

- (void)deviceOrientationChange {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(placeImages) object:nil];
    [self performSelector:@selector(placeImages) withObject:nil afterDelay:1];
}

#pragma mark

- (CGSize)setFramesToImageViews:(NSArray *)imageViews toFitSize:(CGSize)frameSize {
    /**
     Linear Partition
     */
    

    
//    if(imageViews.count) return frameSize;
    int N = imageViews.count;
    if(N ==0) return frameSize;
    
    
    CGRect newFrames[N];
    float ideal_height = MAX(frameSize.height, frameSize.width) / 4;
    float seq[N];
    float total_width = 0;
    if(imageViews.count >= 1)
    {
        for (int i = 0; i < imageViews.count; i++) {
            UIImage *image = (id)[[imageViews objectAtIndex:i] image];
            CGSize newSize = CGSizeResizeToHeight(image.size, ideal_height);
            newFrames[i] = (CGRect) {{0, 0}, newSize};
            seq[i] = newSize.width;
            total_width += newSize.width;
        }
        
        int K = (int)roundf(total_width / frameSize.width);
        
        float M[N][K];
        float D[N][K];
        
        if(N >= 1)
        {
            for (int i = 0 ; i < N; i++)
                for (int j = 0; j < K; j++)
                    D[i][j] = 0;
            
            
            for (int i = 0; i < K; i++)
                M[0][i] = seq[0];
            
            for (int i = 0; i < N; i++)
                M[i][0] = seq[i] + (i ? M[i-1][0] : 0);
            
            float cost;
            for (int i = 1; i < N; i++) {
                for (int j = 1; j < K; j++) {
                    M[i][j] = INT_MAX;
                    
                    for (int k = 0; k < i; k++) {
                        cost = MAX(M[k][j-1], M[i][0]-M[k][0]);
                        if (M[i][j] > cost) {
                            M[i][j] = cost;
                            D[i][j] = k;
                        }
                    }
                }
            }
        }
        
        /**
         Ranges & Resizes
         */
        int k1 = K-1;
        int n1 = N-1;
        int ranges[N][2];
        while (k1 >= 0) {
            ranges[k1][0] = D[n1][k1]+1;
            ranges[k1][1] = n1;
            
            n1 = D[n1][k1];
            k1--;
        }
        ranges[0][0] = 0;
        
        float cellDistance = kImageDistance;
        float heightOffset = cellDistance, widthOffset;
        float frameWidth;
        for (int i = 0; i < K; i++) {        
            float rowWidth = 0;
            frameWidth = frameSize.width - ((ranges[i][1] - ranges[i][0]) + 2) * cellDistance;
            
            for (int j = ranges[i][0]; j <= ranges[i][1]; j++) {
                rowWidth += newFrames[j].size.width;
            }
            
            float ratio = frameWidth / rowWidth;
            widthOffset = 0;
            
            for (int j = ranges[i][0]; j <= ranges[i][1]; j++) {
                newFrames[j].size.width *= ratio;
                newFrames[j].size.height *= ratio;
                newFrames[j].origin.x = widthOffset + (j - (ranges[i][0]) + 1) * cellDistance;
                newFrames[j].origin.y = heightOffset;
                
                widthOffset += newFrames[j].size.width;
            }
            heightOffset += newFrames[ranges[i][0]].size.height + cellDistance;
        }
            
        for (int i = 0; i < N; i++) {
            UIImageView *imgView = imageViews[i];
            imgView.frame = newFrames[i];
            [self.contentView addSubview:imgView];
        }
        
        return CGSizeMake(frameSize.width, heightOffset);
    }
    return frameSize;
}

@end
