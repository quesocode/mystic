//
//  MysticApplication.m
//  Mystic
//
//  Created by travis weerts on 9/11/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticApplication.h"

@implementation MysticApplication
- (BOOL) canOpenURL:(NSURL *)url;
{
    return [url.absoluteString hasPrefix:@"tel:"] ? NO : [super canOpenURL:url];
}
- (void) setStatusBarHidden:(BOOL)statusBarHidden;
{
    [super setStatusBarHidden:statusBarHidden];
}
- (void) setStatusBarHidden:(BOOL)statusBarHidden withAnimation:(UIStatusBarAnimation)animation;
{

    [super setStatusBarHidden:statusBarHidden withAnimation:animation];
}
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle;
{
    [super setStatusBarStyle:statusBarStyle];
    //DLog(@"setting status bar style");
}
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated;
{
    [super setStatusBarStyle:statusBarStyle animated:NO];
}
@end
