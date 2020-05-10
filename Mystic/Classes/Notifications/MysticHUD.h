//
//  MysticHUD.h
//  Mystic
//
//  Created by travis weerts on 9/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "BDKNotifyHUD.h"
#import "Mystic.h"

@interface MysticHUD : BDKNotifyHUD

+ (BDKNotifyHUD *)notify;
+ (BDKNotifyHUD *) notify:(NSString *)text icon:(id)someCustomView superview:(UIView *)superview;
+ (BDKNotifyHUD *) notify:(NSString *)text icon:(id)someCustomView superview:(UIView *)superview speed:(float)speed duration:(float)duration;

@end
