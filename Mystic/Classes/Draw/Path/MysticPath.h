//
//  MysticPath.h
//  Mystic
//
//  Created by Travis A. Weerts on 12/2/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MysticChoice;

@interface MysticPath : NSObject
@property (nonatomic, assign) MysticChoice *choice;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, retain) UIBezierPath *path;
@property (nonatomic, assign) BOOL geometryFlipped;
- (void) setChoice:(MysticChoice *)choice maxWidth:(CGFloat)maxWidth;
@end
