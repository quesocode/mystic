//
//  MysticCustomAlbumPickerController.m
//  Mystic
//
//  Created by Me on 5/2/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "Mystic.h"
#import "MysticCustomAlbumPickerController.h"
#import "MysticView.h"
#import "MysticNavigationViewController.h"
#import "MysticAlbumDataSource.h"

@interface MysticCustomAlbumPickerController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) MysticLayerToolbar *layerToolbar;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) NSInteger numberOfSections, numberOfRows;
@property (nonatomic, retain) NSArray *groups;
@end

@implementation MysticCustomAlbumPickerController

- (void) dealloc;
{
    [_layerToolbar release], _layerToolbar=nil;
    [_tableView release], _tableView=nil;
    [_groups release], _groups=nil;
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _numberOfSections = 1;
        _numberOfRows = 1;
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGSize buttonSize = (CGSize){MYSTIC_NAVBAR_ICON_WIDTH_CANCEL,MYSTIC_NAVBAR_ICON_HEIGHT_CANCEL};
    CGSize button2Size = CGSizeMake(39, 39);
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = nil;
    self.title = nil;
    MysticToolbarTitleButton *button = [[[MysticToolbarTitleButton alloc] initWithFrame:CGRectMake(0, 0, 56, 60)] autorelease];
    
    [button.button setImage:[MysticImage image:@(MysticIconTypeToolBarX) size:buttonSize color:[UIColor color:MysticColorTypeCollectionNavBarIcon]] forState:UIControlStateNormal];
    
    [button.button setImage:[MysticImage image:@(MysticIconTypeToolBarX) size:buttonSize color:[UIColor color:MysticColorTypeCollectionNavBarHighlighted]] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MysticViewTypeButtonBack;
    
    
    button.buttonPosition = MysticPositionLeft;
    button.button.imageEdgeInsets = UIEdgeInsetsMake(-1, 9, 1, 0);
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    button.frame = CGRectMake(0, 0, 56, 60);
    

    
    int numOfTools = 2;
    CGFloat x = 5;
    CGFloat toolWidth = ((self.view.frame.size.width)/numOfTools) - (20 * (numOfTools)) - x;
    toolWidth = 120;

    
    NSArray *theItems = @[
                          
                          
                          
                          //
                          @{@"toolType": @(MysticToolTypeStatic),
                            @"width":@(-15)},
                          
                          @{@"toolType": @(MysticToolTypeCancel),
          
                            @"view": button,
                            @"width": @(button.frame.size.width),
                            @"eventAdded": @YES,
                            
                            },
                          
                          
                          
                          @{@"toolType": @(MysticToolTypeFlexible),
                            },
                          
                          
                          
                          @{@"toolType": @(MysticToolTypeTitle),
                            @"title": @"ALBUMS",
//                            @"width": @(115)
                            },
                          
                          @{@"toolType": @(MysticToolTypeFlexible),},

                          @{@"toolType": @(MysticToolTypeStatic),
                            @"width": @(button.frame.size.width),
//                            @"view": button2,
//                            @"eventAdded": @YES,
                            },
                          
                          
                          
                          
                          @{@"toolType": @(MysticToolTypeStatic),
                            @"width":@(-15)},
                          
                          
                          
                          ];
    
    MysticLayerToolbar *toolbar = [MysticLayerToolbar toolbarWithItems:theItems delegate:self height:self.navigationController.navigationBar.frame.size.height];
    toolbar.backgroundColor = [UIColor colorWithType:MysticColorTypeTabBarBackground];
    toolbar.margin = 0;
    toolbar.userInteractionEnabled = YES;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    
    CGRect tbFrame = CGRectMake(0, self.view.frame.size.height - toolbar.frame.size.height, self.view.frame.size.width, toolbar.frame.size.height);
    toolbar.frame = tbFrame;
    [self.view addSubview:toolbar];
    self.layerToolbar = toolbar;
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:(CGRect){0,0,self.view.frame.size.width, self.view.frame.size.height - tbFrame.size.height} style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    [self.view insertSubview:tableView belowSubview:self.layerToolbar];
    self.tableView = [tableView autorelease];
    [self reloadData];
    
    // Do any additional setup after loading the view.
}

- (void) reloadData;
{
    MysticAlbumDataSource *dataSource = MysticAlbumDataSource.new;
    __unsafe_unretained __block MysticCustomAlbumPickerController *weakSelf = self;
    [dataSource albums:^(NSArray *obj, NSString *errorMsgToDisplay, BOOL success) {
        
        if(success)
        {
            NSMutableArray *newAlbums = [NSMutableArray arrayWithCapacity:obj.count];
            for (ALAssetsGroup *group in obj) {
                [newAlbums addObject:@{@"title": [group valueForProperty:ALAssetsGroupPropertyName],
                                       @"image": group.posterImage ? [UIImage imageWithCGImage:group.posterImage] : [NSNull null],
                                       @"album":group}];
            }
            weakSelf.groups = newAlbums;
            weakSelf.numberOfRows = weakSelf.groups.count;
        }
        
        [weakSelf.tableView reloadData];
    }];
    
    
    
}

- (void) viewWillAppear:(BOOL)animated;
{
    DLog(@"album view will appeared: %@", MBOOL(animated));
    
    [(MysticNavigationViewController *)self.navigationController hideNavigationBar:YES duration:-1 setHidden:NO complete:nil];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) rightButtonTouched:(id)sender;
{
    
}
- (void) backButtonTouched:(id)sender;
{
    [self.delegate imagePickerControllerDidCancel:(id)self];

}


- (UIImagePickerControllerSourceType) sourceType;
{
    return UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 70;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.numberOfRows;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.numberOfSections;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"alCellMTable";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSDictionary *info = self.groups.count > indexPath.row ? [self.groups objectAtIndex:indexPath.row] : nil;
    if(info)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = info[@"title"];
        cell.imageView.image = info[@"image"];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingAlbum:)])
    {
        [self.delegate performSelector:@selector(imagePickerController:didFinishPickingAlbum:) withObject:self withObject:[self.groups objectAtIndex:indexPath.row][@"album"]];
    }
}


@end
