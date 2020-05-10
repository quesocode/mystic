//
//  MysticGalleryViewController.h
//  Mystic
//
//  Created by travis weerts on 9/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "NVGalleryViewController.h"
#import "MysticInstagramAPI.h"

@interface MysticGalleryViewController : NVGalleryViewController <MysticGalleryViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *photosData;

- (id) initWithTag:(NSString *)tagName;

@end
