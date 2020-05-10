//
//  UIImage+Launch.h
//  Mystic
//
//  Created by Me on 11/19/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage_Launch : UIImage
+(BOOL)isDeviceiPhone5;
+(BOOL)isDeviceRetina;
+(BOOL)isDeviceiPhone4;
+(BOOL)isDeviceiPhone;
+(NSString*)getLaunchImageName;
@end
