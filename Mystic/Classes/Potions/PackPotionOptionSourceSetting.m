//
//  PackPotionOptionSourceSetting.m
//  Mystic
//
//  Created by Me on 7/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "PackPotionOptionSourceSetting.h"
#import "UIColor+Mystic.h"

@implementation PackPotionOptionSourceSetting

- (BOOL) canTransform; { return NO; }

//- (BOOL) canTransform; { return YES; }
- (BOOL) canChooseCancelColor; { return YES; }
- (BOOL) canFillBackgroundColor; { return YES; }
- (BOOL) canFillTransformBackgroundColor; { return YES; }
- (void) setBackgroundColor:(UIColor *)backgroundColor; { [super setBackgroundColor:backgroundColor]; }

@end
