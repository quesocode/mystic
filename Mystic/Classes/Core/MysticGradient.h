//
//  MysticGradient.h
//  Mystic
//
//  Created by Me on 11/14/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MysticGradient : NSObject
@property (nonatomic, retain) NSArray *colorsInfo;
@property (nonatomic, retain) NSArray *colors;
@property (nonatomic, retain) NSArray *locations;
@property (nonatomic, readonly) NSArray *colorsArray;

+ (id) gradientWithColors:(NSArray *)colorsInfo;


+ (id) gradientWithColors:(NSArray *)colors locations:(NSArray *)locations;

- (UIImage *) imageForSize:(CGSize)size scale:(CGFloat)scale;

@end
