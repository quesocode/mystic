//
//  PulldownMenu.m
//
//  Created by Bernard Gatt
//

#import "PulldownMenu.h"
#import "Mystic.h"
#import "MysticAttrViewCell.h"

@implementation PulldownMenu

@synthesize menuList,
            handle,
            cellHeight,
            handleHeight,
            animationDuration,
            topMarginLandscape,
            topMarginPortrait,
            cellColor,
            cellFont,
            cellTextColor,
            cellSelectedColor,
            cellSelectionStyle,
            fullyOpen,
            delegate;

- (id)init
{
    self = [super init];
    
    menuItems = [[NSMutableArray alloc] init];
    
    // Setting defaults
    cellHeight = 60.0f;
    handleHeight = 15.0f;
    animationDuration = 0.35f;
    topMarginPortrait = 0;
    topMarginLandscape = 0;
    tableHeight = 0;
    _closeOffset = 0;
    _openOffset = 0;
    cellColor = [UIColor grayColor];
    cellSelectedColor = [UIColor blackColor];
    cellFont = [UIFont fontWithName:@"GillSans-Bold" size:19.0f];
    cellTextColor = [UIColor whiteColor];
    cellSelectionStyle = UITableViewCellSelectionStyleDefault;
    
    return self;
}

- (id)initWithNavigationController:(UINavigationController *)navigationController
{
    self = [self init];
    
    if (self)
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(deviceOrientationDidChange:)
                                                     name: UIDeviceOrientationDidChangeNotification
                                                   object: nil];
        
        masterNavigationController = navigationController;
        
        navigationDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
        navigationDragGestureRecognizer.minimumNumberOfTouches = 1;
        navigationDragGestureRecognizer.maximumNumberOfTouches = 1;
        
        handleDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
        handleDragGestureRecognizer.minimumNumberOfTouches = 1;
        handleDragGestureRecognizer.maximumNumberOfTouches = 1;
        
        [masterNavigationController.navigationBar addGestureRecognizer:navigationDragGestureRecognizer];
        
        masterView = masterNavigationController.view;
    }
    
    return self;
}

- (id)initWithView:(UIView *)view
{
    self = [self init];
    
    if (self)
    {
        topMargin = 0;
        masterView = view;
    }
    
    return self;
}

- (void) reload;
{
    [menuItems removeAllObjects];
    tableHeight = 0;
}
- (NSMutableArray *) items;
{
    return menuItems;
}

- (void)loadMenu
{
    if(tableHeight <= 0)
    {
        tableHeight = ([menuItems count] * cellHeight);
    }
    
    
    
    [self updateValues];
    
    [self setFrame:CGRectMake(0, 0, 0, tableHeight+handleHeight)];
    
    fullyOpen = NO;
    UIColor *c = [UIColor color:MysticColorTypeCollectionSectionHeaderBackground];
    menuList = [[UITableView alloc] init];
    [menuList setRowHeight:cellHeight];
    [menuList setDataSource:self];
    [menuList setDelegate:self];
    if([menuList respondsToSelector:@selector(setSeparatorInset:)])
    {
        menuList.separatorInset = UIEdgeInsetsZero;
    }
    menuList.backgroundColor = self.backgroundColor;
    menuList.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    menuList.separatorColor = c;
    menuList.showsVerticalScrollIndicator = NO;
    menuList.showsHorizontalScrollIndicator = NO;
    menuList.directionalLockEnabled = YES;
    [self addSubview:menuList];
    
    handle = [[UIView alloc] init];
    [handle setBackgroundColor:c];
    if(self.handleContentView)
    {
        [handle addSubview:self.handleContentView];
    }
    
    [self addSubview:handle];
    
    handleDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
    handleDragGestureRecognizer.minimumNumberOfTouches = 1;
    handleDragGestureRecognizer.maximumNumberOfTouches = 1;
    [handle addGestureRecognizer:handleDragGestureRecognizer];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [handle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [menuList setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self createConstraints];
}

- (void)insertButton:(NSString *)title
{
    if(!menuItems) menuItems = [[NSMutableArray alloc] init];
    [menuItems addObject:title];
    
    CGFloat h = [self tableView:menuList heightForRowAtIndexPath:[NSIndexPath indexPathForItem:menuItems.count-1 inSection:0]];
    
    
    tableHeight += h;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate menuItemSelected:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSDictionary *) sectionAtIndexPath:(NSIndexPath *)indexPath;
{
    if(!menuItems.count) return nil;
    NSDictionary *title = [menuItems objectAtIndex:indexPath.item];
    if([title isKindOfClass:[NSDictionary class]])
    {
        return title;
    }
    return @{@"title": title};
}
- (NSInteger) sectionForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    if(!menuItems.count) return indexPath.item;

    NSDictionary *title = [menuItems objectAtIndex:indexPath.item];
    if([title isKindOfClass:[NSDictionary class]])
    {
        if(title[@"section"])
        {
            return [title[@"section"] integerValue];
        }
    }
    return indexPath.item;
    
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDictionary *i = [self sectionAtIndexPath:indexPath];
    if(i[@"height"])
    {
        return [i[@"height"] floatValue];
    }
    if(i[@"header"])
    {
        return [i[@"header"] boolValue] ? cellHeight : 42;
    }
    
    
    return cellHeight;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MysticAttrViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuListCell"];
    
    if (cell == nil) {
        cell = [[MysticAttrViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuListCell"];
    }
    
    cell.backgroundColor = cellColor;
    
    UIView *cellSelectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cellSelectedBackgroundView.backgroundColor = cellSelectedColor;
    cell.selectedBackgroundView = cellSelectedBackgroundView;
    cell.selectionStyle = cellSelectionStyle;
    cell.indentationWidth = 0;
    cell.indentationLevel = 0;
    
    cell.titleLabel.font = cellFont;
    [cell.titleLabel setTextColor:cellTextColor];

    NSString *title = [menuItems objectAtIndex:indexPath.item];
    BOOL isHeader = NO;
    if([title isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *info = (id)title;
        title = info[@"title"];
        isHeader = [info[@"header"] boolValue];
        
        if(info[@"textColor"])
        {
            [cell.titleLabel setTextColor:info[@"textColor"]];
        }
        else
        {
            [cell.titleLabel setTextColor:cellTextColor];

        }
        if(info[@"backgroundColor"])
        {
            cell.backgroundColor = info[@"backgroundColor"];
        }
        else if(isHeader)
        {
//            cell.backgroundColor = [UIColor hex:@"222221"];
            cell.backgroundColor = [UIColor hex:@"191919"];

        }
        else if(!isHeader)
        {
            cell.backgroundColor = [UIColor hex:@"191919"];
        }

    }
    
    
    if([title isKindOfClass:[NSString class]])
    {
        [cell.titleLabel setText:title];


    }
    else if([title isKindOfClass:[NSAttributedString class]])
    {
        [cell.titleLabel setAttributedText:(NSAttributedString *)title];

    }
    
    
    return cell;
}

- (void)dragMenu:(UIPanGestureRecognizer *)sender
{
    if ([sender state] == UIGestureRecognizerStateChanged)
    {
        CGPoint gesturePosition = [sender translationInView:masterNavigationController.navigationBar];
        CGPoint newPosition = gesturePosition;
        
        newPosition.x = self.frame.size.width / 2;
        
        if (fullyOpen)
        {
            if (newPosition.y < 0)
            {
                newPosition.y += ((self.frame.size.height / 2) + topMargin) + _openOffset;
                
                [self setCenter:newPosition];
            }
        }
        else
        {
            newPosition.y += -((self.frame.size.height / 2) - topMargin) + _closeOffset;
            
            if (newPosition.y <= ((self.frame.size.height / 2) + topMargin) + _openOffset)
            {
                [self setCenter:newPosition];
            }
        }
    }
    else if ([sender state] == UIGestureRecognizerStateEnded)
    {
        [self animateDropDown:YES change:YES];
    }
}

- (void)animateDropDown
{
    [self animateDropDown:YES change:NO];
}
- (void)animateDropDown:(BOOL)animated change:(BOOL)doChange;
{
    if(animated)
    {
    [UIView animateWithDuration: animationDuration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (fullyOpen)
                         {
                             
                             self.center = CGPointMake(self.frame.size.width / 2, -((self.frame.size.height / 2) + topMargin) + _closeOffset);
                             fullyOpen = NO;
                         }
                         else
                         {
                             self.center = CGPointMake(self.frame.size.width / 2, ((self.frame.size.height / 2) + topMargin) + _openOffset);
                             fullyOpen = YES;
                         }
                     }
                     completion:^(BOOL finished){
                         [delegate pullDownAnimated:fullyOpen change:doChange animated:animationDuration];
                     }];
    }
    else
    {
        if (fullyOpen)
        {
            
            self.center = CGPointMake(self.frame.size.width / 2, -((self.frame.size.height / 2) + topMargin) + _closeOffset);
            fullyOpen = NO;
        }
        else
        {
            self.center = CGPointMake(self.frame.size.width / 2, ((self.frame.size.height / 2) + topMargin) + _openOffset);
            fullyOpen = YES;
        }
        [delegate pullDownAnimated:fullyOpen change:doChange animated:animationDuration];
    }
}

- (void)createConstraints
{
    
    NSLayoutConstraint *pullDownTopPositionConstraint = [NSLayoutConstraint
                                                         constraintWithItem:self
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                         toItem:masterView
                                                         attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                         constant:-self.frame.size.height];
    
    NSLayoutConstraint *pullDownCenterXPositionConstraint = [NSLayoutConstraint
                                                             constraintWithItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                             toItem:masterView
                                                             attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                             constant:0];
    
    NSLayoutConstraint *pullDownWidthConstraint = [NSLayoutConstraint
                                                   constraintWithItem:self
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:masterView
                                                   attribute:NSLayoutAttributeWidth
                                                   multiplier:1.0
                                                   constant:0];
    
    NSLayoutConstraint *pullDownHeightMaxConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationLessThanOrEqual
                                                       toItem:masterView
                                                       attribute:NSLayoutAttributeHeight
                                                       multiplier:0.5
                                                       constant:0];
    
    pullDownHeightMaxConstraint.priority = 1000;
    
    NSLayoutConstraint *pullDownHeightConstraint = [NSLayoutConstraint
                                                    constraintWithItem:self
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:0
                                                    toItem:nil
                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                    constant:tableHeight+handleHeight];
    
    pullDownHeightConstraint.priority = 900;
    
    NSLayoutConstraint *pullHandleWidthConstraint = [NSLayoutConstraint
                                                     constraintWithItem:handle
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                     toItem:masterView
                                                     attribute:NSLayoutAttributeWidth
                                                     multiplier:1.0
                                                     constant:0];
    
    NSLayoutConstraint *pullHandleHeightConstraint = [NSLayoutConstraint
                                                      constraintWithItem:handle
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:0
                                                      toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                      constant:handleHeight];
    
    NSLayoutConstraint *pullHandleBottomPositionConstraint = [NSLayoutConstraint
                                                              constraintWithItem:handle
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                              constant:0];
    
    NSLayoutConstraint *pullHandleCenterPositionConstraint = [NSLayoutConstraint
                                                              constraintWithItem:handle
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:0
                                                              toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                              constant:0];
    
    NSLayoutConstraint *menuListHeightMaxConstraint = [NSLayoutConstraint
                                                       constraintWithItem:menuList
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationLessThanOrEqual
                                                       toItem:masterView
                                                       attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                       constant:-topMargin];
    
    NSLayoutConstraint *menuListHeightConstraint = [NSLayoutConstraint
                                                    constraintWithItem:menuList
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                    toItem:self
                                                    attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                    constant:-handleHeight];
    
    NSLayoutConstraint *menuListWidthConstraint = [NSLayoutConstraint
                                                   constraintWithItem:menuList
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:self
                                                   attribute:NSLayoutAttributeWidth
                                                   multiplier:1.0
                                                   constant:0];
    
    NSLayoutConstraint *menuListCenterXPositionConstraint = [NSLayoutConstraint
                                                             constraintWithItem:menuList
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                             constant:0];
    
    NSLayoutConstraint *menuListTopPositionConstraint = [NSLayoutConstraint
                                                         constraintWithItem:menuList
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                         toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                         constant:0];
    
    [masterView addConstraint: pullDownTopPositionConstraint];
    [masterView addConstraint: pullDownCenterXPositionConstraint];
    [masterView addConstraint: pullDownWidthConstraint];
    [masterView addConstraint: pullDownHeightConstraint];
    [masterView addConstraint: pullDownHeightMaxConstraint];
    
    [masterView addConstraint: pullHandleHeightConstraint];
    [masterView addConstraint: pullHandleWidthConstraint];
    [masterView addConstraint: pullHandleBottomPositionConstraint];
    [masterView addConstraint: pullHandleCenterPositionConstraint];
    
    [masterView addConstraint: menuListHeightMaxConstraint];
    [masterView addConstraint: menuListHeightConstraint];
    [masterView addConstraint: menuListWidthConstraint];
    [masterView addConstraint: menuListCenterXPositionConstraint];
    [masterView addConstraint: menuListTopPositionConstraint];
    
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || currentOrientation == orientation) {
        return;
    }
    
    currentOrientation = orientation;
    
    [self performSelector:@selector(orientationChanged) withObject:nil afterDelay:0];
}

- (void)orientationChanged
{
    [self updateValues];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((UIDeviceOrientationIsPortrait(currentOrientation) && UIDeviceOrientationIsPortrait(orientation)) ||
        (UIDeviceOrientationIsLandscape(currentOrientation) && UIDeviceOrientationIsLandscape(orientation))) {
        
        currentOrientation = orientation;
        
        if (fullyOpen)
        {
            [self animateDropDown];
        }
        
        return;
    }
}

- (void)updateValues
{
    topMargin = 0;
    
    BOOL isStatusBarShowing = ![[UIApplication sharedApplication] isStatusBarHidden];
    
    if (UIInterfaceOrientationIsLandscape(self.window.rootViewController.interfaceOrientation)) {
        if (isStatusBarShowing) { topMargin = [UIApplication.sharedApplication statusBarFrame].size.width; }
        topMargin += topMarginLandscape;
    }
    else
    {
        if (isStatusBarShowing) { topMargin = [UIApplication.sharedApplication statusBarFrame].size.height; }
        topMargin += topMarginPortrait;
    }
    
    if (masterNavigationController != nil)
    {
        topMargin += masterNavigationController.navigationBar.frame.size.height;
    }
}

@end
