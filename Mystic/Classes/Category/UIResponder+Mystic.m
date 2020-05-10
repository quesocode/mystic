//
//  UIResponder+Mystic.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/23/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "UIResponder+Mystic.h"

@implementation UIResponder (Mystic)

static id currentFirstResponder;

+(id)currentFirstResponder {
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}
-(void)findFirstResponder:(id)sender {
    currentFirstResponder = self;
}

@end
