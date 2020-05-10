//
//  MysticHUD.m
//  Mystic
//
//  Created by travis weerts on 9/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticHUD.h"

@implementation MysticHUD

static BDKNotifyHUD *_notify;

+ (BDKNotifyHUD *)notify; {
    return _notify;
}

+ (BDKNotifyHUD *) notify:(NSString *)text icon:(id)someCustomView superview:(UIView *)superview;
{
    return [self notify:text icon:someCustomView superview:superview speed:MYSTIC_HUD_SPEED duration:MYSTIC_HUD_DURATION];
}
+ (BDKNotifyHUD *) notify:(NSString *)text icon:(id)someCustomView superview:(UIView *)superview speed:(float)speed duration:(float)duration;
{
    if (_notify != nil) { [_notify cancel]; [_notify removeFromSuperview]; _notify = nil; }
    
    if([someCustomView isKindOfClass:[UIImage class]])
    {
        someCustomView = [[UIImageView alloc] initWithImage:someCustomView];
    }
    else if([someCustomView isKindOfClass:[NSString class]])
    {
        someCustomView = [[UIImageView alloc] initWithImage:[MysticIcon imageNamed:someCustomView colorType:MysticColorTypeHUDIcon]];
    }
    _notify = [BDKNotifyHUD notifyHUDWithView:someCustomView
                                                   text:NSLocalizedString(text, nil)];
    _notify.center = CGPointMake(superview.center.x, superview.center.y);
    
    
    [superview addSubview:_notify];
    [_notify presentWithDuration:duration speed:speed inView:superview completion:^{
        [_notify removeFromSuperview];
        _notify = nil;
    }];
    someCustomView = nil;
    return _notify;
}
+ (Class) class;
{
    return [BDKNotifyHUD class];
}

@end
