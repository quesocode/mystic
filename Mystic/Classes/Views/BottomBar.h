//
//  BottomBar.h
//  Mystic
//
//  Created by travis weerts on 1/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomBar : UIView

@property (nonatomic, assign) NSString *title;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

@end
