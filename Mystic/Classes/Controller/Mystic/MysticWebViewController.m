//
//  MysticWebViewController.m
//  Mystic
//
//  Created by travis weerts on 4/17/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"
#import "MysticWebViewController.h"
#import "MBProgressHUD.h"
#import "MysticLabel.h"
#import "MysticTopBar.h"
#import "MysticToolbar.h"


@interface MysticWebViewController ()
{
    MysticButton *backButton, *forwardButton, *shareButton;
}


@property (nonatomic, retain) MysticToolbar *toolbar;

@end

@implementation MysticWebViewController

@synthesize htmlString=_htmlString, showSpinner, url=_url, showHeader=_showHeader, showTools=_showTools, closeBlock, showNavigation=_showNavigation, showTitle=_showTitle, toolbar=_toolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
//        MysticLabel *btmLabel = [[MysticLabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
//        btmLabel.text = @"Tap Pin It";
//        btmLabel.inNavBar = YES;
//        self.navigationItem.titleView = btmLabel;
//        [btmLabel release];
        _showHeader = NO;
        _showTitle = NO;
        _showNavigation = NO;
        UIView *cview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 52.0f, 36.0f)];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:cview] autorelease];
        [cview release];
    }
    return self;
}

- (void) close:(UIButton *)sender
{
    if([self respondsToSelector:@selector(presentingViewController)])
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            if(self.closeBlock)
            {
                self.closeBlock();
            }
        }];
    }
    else
    {
        
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIWebView *wview = [[UIWebView alloc] initWithFrame:self.view.frame];
    wview.delegate = self;
    
        MysticToolbar *toolbar = [self setupHeader];
        if(toolbar)
        {
            CGSize tsize = [MysticUI size];
            wview.frame = CGRectMake(0, toolbar.frame.size.height, self.view.frame.size.width, tsize.height - toolbar.frame.size.height);
        }

    
    self.webView = wview;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    [wview release];
    if(self.htmlString)
    {
        [self.webView loadHTMLString:self.htmlString baseURL:nil];
    }
    else if(self.url)
    {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
        [self.webView loadRequest:request];
        [request release];
    }
}

- (void) setShowNavigation:(BOOL)showNavigation;
{
    _showNavigation = showNavigation;
    [self setupHeader];
}

- (void) setShowTitle:(BOOL)showTitle;
{
    _showTitle = showTitle;
    [self setupHeader];
}

- (void) setShowHeader:(BOOL)showHeader;
{
    _showHeader = showHeader;
    [self setupHeader];
}


- (MysticToolbar *) setupHeader;
{
    if(!self.showHeader)
    {
        if(self.toolbar)
        {
            [self.toolbar removeFromSuperview];
            self.toolbar = nil;
            
            if(self.webView)
            {
                self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            }
            
        }
        
        return self.toolbar;
    }
    MysticButton *button;
    MysticBarButtonItem *flexItem = [MysticBarButtonItem itemForType:@(MysticToolTypeFlexible) target:self];
    UIColor *disabledColor = [[MysticColor color:@(MysticColorTypeNavBarIconDark)] colorWithAlphaComponent:0.3f];
    NSMutableArray *items = [NSMutableArray array];
    
    
    
    if(self.showNavigation)
    {
        button = [MysticUI clearButtonWithImage:[MysticImage image:@(MysticIconTypeToolLeft) size:CGSizeMake(44, 44) color:@(MysticColorTypeNavBarIcon)] target:self sel:@selector(back:)];
        [button setImage:[MysticImage image:@(MysticIconTypeToolLeft) size:CGSizeMake(44, 44) color:disabledColor] forState:UIControlStateDisabled];
        button.frame = CGRectMake(0, 0, 55, 40);
        button.enabled = NO;
        //        [headerView addSubview:button];
        [items addObject:[MysticBarButtonItem item:button]];
        
        backButton = [button retain];
        
        
        button = [MysticUI clearButtonWithImage:[MysticImage image:@(MysticIconTypeToolRight) size:CGSizeMake(44, 44) color:@(MysticColorTypeNavBarIcon)] target:self sel:@selector(forward:)];
        [button setImage:[MysticImage image:@(MysticIconTypeToolRight) size:CGSizeMake(44, 44) color:disabledColor] forState:UIControlStateDisabled];
        button.frame = CGRectMake(0, 0, 45, 40);
        button.enabled = NO;
        //        [headerView addSubview:button];
        forwardButton = [button retain];
        [items addObject:[MysticBarButtonItem item:button]];
        
    }
    
    
    
    [items addObject:flexItem];
    
    button = [MysticButton clearButtonWithImage:[MysticImage image:@(MysticIconTypeToolX) size:CGSizeMake(44, 44) color:@(MysticColorTypeNavBarIconDark)] target:self sel:@selector(close:)];
    button.frame = CGRectMake(0, 0, 45, 40);
    //        [headerView addSubview:button];
    [items addObject:[MysticBarButtonItem item:button]];
    
    if(!self.toolbar)
    {
        MysticToolbar *atoolbar = [[MysticToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, MYSTIC_UI_TOOLBAR_HEIGHT)];
        atoolbar.backgroundColor = [UIColor hex:@"303030"];
        [self.view addSubview:atoolbar];
        self.toolbar = atoolbar;
        [atoolbar release];
    }
    
    if(self.toolbar)
    {
        [self.toolbar setItems:items animated:NO];
    }

    
   if(backButton) backButton.enabled = NO;
   if(forwardButton) forwardButton.enabled = NO;
    
    return self.toolbar;
}


- (void) viewWillDisappear:(BOOL)animated
{
    [self.webView stopLoading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void) setHtmlString:(NSString *)htmlString
//{
//    
//}
- (void) back:(id)sender
{
    [self.webView goBack];
}

- (void) forward:(id)sender
{
    [self.webView goForward];
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    if(self.showSpinner)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
    }
}
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    if(self.showSpinner)
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }
    
    if([webView canGoBack] && self.showHeader)
    {
        backButton.enabled = YES;
    }
    else if(backButton)
    {
        backButton.enabled = NO;
    }
    if([webView canGoForward] && self.showHeader)
    {
        forwardButton.enabled = YES;
    }
    else if(forwardButton)
    {
        forwardButton.enabled = NO;
    }
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if(self.showSpinner)
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }
}

- (void)dealloc {
    [_webView release];
    [_url release];
    [_toolbar release];
    if(backButton) [backButton release], backButton=nil;
    if(forwardButton) [forwardButton release], forwardButton=nil;
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}
@end
