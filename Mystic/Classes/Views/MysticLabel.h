//
//  MysticLabel.h
//  Mystic
//
//  Created by travis weerts on 1/30/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticAnimatedLabel.h"
#import "MysticConstants.h"


@interface MysticLabel : MysticAnimatedLabel {

@private
VerticalAlignment verticalAlignment_;
}

@property (nonatomic, assign) VerticalAlignment verticalAlignment;


@property (nonatomic) BOOL inNavBar;


@end
