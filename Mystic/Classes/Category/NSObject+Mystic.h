//
//  NSObject+Mystic.h
//  Mystic
//
//  Created by travis weerts on 9/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Mystic)
- (void *)performSelector:(SEL)selector value:(void *)value;
- (void *)performValueSelector:(SEL)selector;

@end
