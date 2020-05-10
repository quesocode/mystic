//
//  MysticFilterLookup.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/6/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "GPUImage.h"

@interface MysticFilterLookup : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
- (id)initWithImage:(UIImage *)image;

@end
