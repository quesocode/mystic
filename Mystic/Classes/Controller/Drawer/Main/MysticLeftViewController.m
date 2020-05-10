//
//  MysticLeftViewController.m
//  Mystic
//
//  Created by travis weerts on 8/22/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//
#import "MysticLeftViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "Mystic.h"
#import "MysticController.h"
#import "MysticColor.h"
#import "MysticIcon.h"
#import "MysticLeftTableViewCell.h"
#import "MysticInstagramAPI.h"
#import "MysticInspirationViewController.h"

@interface MysticLeftViewController ()

@end

@implementation MysticLeftViewController



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self commonInit];

    }
    return self;
}
- (void) commonInit;
{
    self.navigationItem.titleView = [MysticIcon customIconWithColor:[UIColor color:MysticColorTypeDrawerNavBarLogo] type:MysticIconTypeLogo size:CGSizeMake(30, 30)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    __unsafe_unretained MysticLeftViewController *weakSelf = self;
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
 
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.info = @[@{@"title": @"New",
                    @"image": @"iconMask-camera.png",
                    @"color": [UIColor hex:@"78b7a6"],
                    @"titleColor": [UIColor hex:@"fcfaee"],
                    @"accessory": [MysticIcon iconWithColor:[UIColor hex:@"63524b"] type:MysticIconTypePlus size:CGSizeMake(MYSTIC_ICON_WIDTH, MYSTIC_ICON_HEIGHT)],
                    @"state": [NSNumber numberWithInteger:MysticSettingNewProject],
                    @"closeDrawerFirst": [NSNumber numberWithBool:NO],

                    },
                  
//                  @{@"title": NSLocalizedString(@"Visions", nil),
//                    @"image": @"iconMask-visions.png",
//                    @"color": [UIColor hex:@"e4b559"],
//                    @"titleColor": [UIColor hex:@"fcfaee"],
//                    @"accessory": [MysticIcon indicatorWithColor:[UIColor hex:@"63524b"]],
//                    @"block": ^{
//                        
//                        [[MysticController controller] setStateConfirmed:MysticSettingRecipeProjects animated:YES info:@{@"MysticRecipesType":[NSNumber numberWithInteger:MysticRecipesTypeProject]} complete:nil];
//                    },
//                    @"closeDrawerFirst": [NSNumber numberWithBool:YES],
//
//                    },
                  @{@"title": @"Inspiration",
                    @"image": @"iconMask-heart.png",
                    @"color": [UIColor hex:@"ef818e"],
                    @"titleColor": [UIColor hex:@"fcfaee"],
                    @"accessory": [MysticIcon indicatorWithColor:[UIColor hex:@"63524b"] size:CGSizeMake(MYSTIC_ICON_WIDTH, MYSTIC_ICON_HEIGHT)],
                    @"block": ^{
                        
                        UINavigationController *nav = (UINavigationController *)weakSelf.mm_drawerController.centerViewController;
                        
                        MysticGalleryViewController *inspirationController = [[MysticGalleryViewController alloc] initWithTag:MYSTIC_API_INSTAGRAM_TAG];
                        [nav pushViewController:inspirationController animated:NO];
                        [inspirationController autorelease];
                        

                    },
                    @"closeDrawerFirst": [NSNumber numberWithBool:NO],
                    },
                  @{@"title": @"Settings",
                    @"image": @"iconMask-cog.png",
                    @"color": [UIColor hex:@"f3e0c0"],
                    @"titleColor": [UIColor hex:@"fcfaee"],
                    @"closeDrawerFirst": [NSNumber numberWithBool:YES],
                    @"state": [NSNumber numberWithInteger:MysticSettingPreferences],

                    },
                  @{@"title": @"About",
                    @"image": @"iconMask-mystic.png",
                    @"color": [UIColor hex:@"8e766c"],
                    @"titleColor": [UIColor hex:@"fcfaee"],
                    @"closeDrawerFirst": [NSNumber numberWithBool:YES],
                    @"block": ^{
                        NSURL *url = [NSURL URLWithString:@"http://mysti.ch/story"];
                        
                        if (![[UIApplication sharedApplication] openURL:url])
                            DLog(@"%@%@",@"Failed to open url:",[url description]);
                        
                    }
                    },
                  ];
                  
    

}
- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor hex:@"1f1a17"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.info.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MysticLeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MysticLeftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
    
    switch (indexPath.row) {
            
        default: break;
    }
    
    NSDictionary *cellInfo = [self.info objectAtIndex:indexPath.row];
    cell.textLabel.text = [cellInfo objectForKey:@"title"];
    cell.textLabel.textColor = [cellInfo objectForKey:@"titleColor"];
    cell.imageView.image = [MysticIcon imageNamed:[cellInfo objectForKey:@"image"] color:[cellInfo objectForKey:@"color"]];
    cell.accessoryView = [cellInfo objectForKey:@"accessory"];
    if([cell.backgroundView respondsToSelector:@selector(showBorder)])
    {
        [(MysticLeftTableViewCellBackgroundView *)cell.backgroundView setShowBorder:((indexPath.row+1) != [self tableView:tableView numberOfRowsInSection:indexPath.section])];
    }

    
    // Configure the cell...
    
    return cell;
}
 
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60.f;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL animateState = YES;
    BOOL closeDrawerFirst = YES;
    BOOL animateDrawer = YES;
    BOOL closeDrawer = YES;
    MysticBlock customBlock = nil;
    // Navigation logic may go here. Create and push another view controller.
    MysticObjectType nextState = MysticSettingNone;
    
    NSDictionary *cell = [self.info objectAtIndex:indexPath.row];
    
    closeDrawerFirst = [cell objectForKey:@"closeDrawerFirst"] ? [[cell objectForKey:@"closeDrawerFirst"] boolValue] : closeDrawerFirst;
    nextState = [cell objectForKey:@"state"] ? [[cell objectForKey:@"state"] integerValue] : nextState;
    customBlock = [cell objectForKey:@"block"] ? (MysticBlock)[cell objectForKey:@"block"] : customBlock;
    
    if(closeDrawer && closeDrawerFirst)
    {
        __unsafe_unretained __block  MysticController *weakController = [MysticController controller];
        [self.mm_drawerController
         closeDrawerAnimated:animateDrawer
         completion:^(BOOL finished) {
             if(finished)
             {
                 if(customBlock)
                 {
                     customBlock();
                 }
                 else
                 {
                     [weakController setState:nextState animated:animateState complete:nil];
                 }
             }
         }];
    }
    else
    {

        MysticBlock finishedState = !animateDrawer ? nil : ^{
            [self.mm_drawerController
             closeDrawerAnimated:animateDrawer
             completion:nil];
        };
        finishedState = closeDrawer ? finishedState : nil;
        if(customBlock)
        {
            customBlock();
            finishedState();
        }
        else
        {
            [[MysticController controller] setState:nextState animated:animateState complete:finishedState];
        }
    }
    
}

@end
