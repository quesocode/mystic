//
//  MysticShapesDecorativeKit.h
//  ProjectName
//
//  Created by Travis Weerts on 12/4/15.
//  Copyright (c) 2015 Mystic. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MysticDrawKit.h"
#import "MysticChoice.h"

@interface MysticShapesDecorativeKit : MysticDrawKit

// Drawing Methods
+ (NSDictionary *)drawAntlersWithOptions: (MysticChoice*)choice;
+ (NSDictionary *)drawBannerWithOptions: (MysticChoice*)choice;
+ (NSDictionary *)drawBanner2WithOptions: (MysticChoice*)choice;
+ (NSDictionary *)drawSquirelyWithOptions: (MysticChoice*)choice;
+ (NSDictionary *)drawTreeWithOptions: (MysticChoice*)choice;
+ (NSDictionary *)drawHandStarWithOptions: (MysticChoice*)choice;

@end