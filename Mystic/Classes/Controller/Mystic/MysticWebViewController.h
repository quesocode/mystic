//
//  MysticWebViewController.h
//  Mystic
//
//  Created by travis weerts on 4/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"

@interface MysticWebViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString *htmlString;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) BOOL showSpinner, showTools, showHeader, showTitle, showNavigation;
@property (nonatomic, copy) MysticBlock closeBlock;
@end
