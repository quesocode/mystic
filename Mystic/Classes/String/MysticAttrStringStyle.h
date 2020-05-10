//
//  MysticAttrStringStyle.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/3/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MysticAttrString.h"

@interface MysticAttrStringStyle : NSObject

+ (MysticAttrString *) string:(id)string style:(MysticStringStyle) style;
+ (MysticAttrString *) string:(id)string style:(MysticStringStyle) style state:(int)state;

@end
