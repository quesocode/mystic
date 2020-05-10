//
//  MysticNewProjectViewController.m
//  Mystic
//
//  Created by Me on 12/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticNewProjectViewController.h"
#import "MysticPickerViewController.h"
#import "MBProgressHUD.h"
#import "MysticController.h"
#import "MysticBackgroundView.h"
#import "MysticCenteredButton.h"
#import "MysticProjectViewCell.h"
#import "MysticStandardProjectViewCell.h"
#import "MysticProjectSectionView.h"
#import "MysticNavigationViewController.h"
#import "Mystic.h"

@interface MysticNewProjectViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;
@end

@implementation MysticNewProjectViewController

@synthesize tableView=_tableView, sections=_sections;

- (void) dealloc;
{
    [_tableView release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"New Project", nil);
        self.navigationItem.hidesBackButton = YES;
        __unsafe_unretained __block MysticNewProjectViewController *weakSelf = self;
        self.navigationItem.leftBarButtonItem = [MysticBarButtonItem backButtonItem:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        NSString *myPlistFilePath = [[NSBundle mainBundle] pathForResource: @"templates" ofType: @"plist"];

        NSDictionary *sectionsData = [NSDictionary dictionaryWithContentsOfFile:myPlistFilePath];
        self.sections = [sectionsData objectForKey:@"sections"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor hex:@"303030"];
    
    MysticBackgroundView *bgView = [[MysticBackgroundView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:bgView];
    [bgView release];
    
    UITableView *newTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    newTableView.delegate = self;
    newTableView.dataSource = self;
    [self.view addSubview:newTableView];
    self.tableView = newTableView;
    self.tableView.backgroundColor = [UIColor clearColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
    [newTableView release];
}
- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Section Data


- (NSDictionary *) section:(NSInteger)section;
{
    return [self.sections objectAtIndex:section];
}
- (NSDictionary *) sectionRow:(NSIndexPath *) indexPath;
{
    return [[self sectionRows:indexPath] objectAtIndex:indexPath.row];
}
- (NSArray *) sectionRows:(NSIndexPath *) indexPath;
{
    return [[self section:indexPath.section] objectForKey:@"rows"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return self.sections.count;
}
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    NSMutableArray *a = [NSMutableArray array];
//    for (NSDictionary *section in self.sections) {
//        [a addObject:[section objectForKey:@"title"]];
//    }
//    return a;
//}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSDictionary *sectionData = [self section:section];
    NSString *title = [sectionData objectForKey:@"title"];
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellInfo = [self sectionRow:indexPath];
    
    
//    int numberOfSections = [self numberOfSectionsInTableView:self.tableView];
//    int numberOfRows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    BOOL useStandard = indexPath.section ==0;
    static NSString *CellIdentifier = @"ProjectViewCell";
    static NSString *CellIdentifierStandard = @"StandardProjectViewCell";
    
    Class cellClass = useStandard ? [MysticStandardProjectViewCell class] : [MysticProjectViewCell class];
    NSString *useIdentifier = useStandard ? CellIdentifierStandard : CellIdentifier;
    MysticProjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:useIdentifier];
    if (cell == nil) {
        cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:useIdentifier] autorelease];
    }
 
    // Configure the cell...
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell loadTemplates:[cellInfo objectForKey:@"templates"]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    CGRect sectionFrame = CGRectMake(0, 0, self.tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section]);
    
    MysticProjectSectionView *sectionTitleView = [[MysticProjectSectionView alloc] initWithFrame:sectionFrame];
    sectionTitleView.text = sectionTitle;
    
    return [sectionTitleView autorelease];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    BOOL useStandard = indexPath.section ==0;
    return useStandard ? 150 : 95;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    BOOL useStandard = section ==0;
    return useStandard ? 0 : 40;
}

- (IBAction)cameraButtonTouched:(MysticButton *)sender
{
    sender.enabled = NO;
    __unsafe_unretained __block  MysticNewProjectViewController *weakSelf = self;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self openCam:self animated:YES mode:MysticObjectTypeImage source:MysticPickerSourceTypeCameraOrPhotoLibrary complete:^{
            
        }];
    }
    else
    {
        [MysticAlert notice:@"No Camera" message:@"Your device doesn't have a camera, so you'll have to choose a photo from your album instead." action:^(id object, id o2) {
            [weakSelf albumButtonTouched:sender];
            
        } options:@{@"button":@"Choose Photo"}];
        
    }
}
- (IBAction)bgButtonTouched:(MysticButton *)sender
{
    [self openCam:self animated:YES mode:MysticObjectTypeImage source:MysticPickerSourceTypePhotoLibrary complete:^{
        
    }];
}

- (IBAction)albumButtonTouched:(MysticButton *)sender
{
    [self openCam:self animated:YES mode:MysticObjectTypeImage source:MysticPickerSourceTypePhotoLibrary complete:^{
        
    }];
}


- (void) openCam:(id)delegate animated:(BOOL)animated mode:(MysticObjectType)mode source:(MysticPickerSourceType)sourceType complete:(void (^)())finished;
{
    @autoreleasepool {
        
        MysticPickerViewController *picker ;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            picker = [[[NSBundle mainBundle] loadNibNamed:@"MysticPickerViewController" owner:nil options:nil] lastObject];
        } else {
            picker = [[[NSBundle mainBundle] loadNibNamed:@"MysticPickerViewController_iPad" owner:nil options:nil] lastObject];
        }
        [picker setup];
        picker.sourceType = sourceType;
        picker.imagePickerDelegate = (delegate ? delegate : self);
        
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        picker.modalPresentationStyle = UIModalPresentationCurrentContext;
        [picker present:picker.sourceType viewController:picker animated:NO finished:nil];
        if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            __unsafe_unretained __block  MysticPickerViewController *weakPicker = picker;
            [self presentViewController:picker animated:animated completion:^{
                [weakPicker viewDidPresent:animated];
                if(finished) finished();
            }];
        }
        else
        {
            [self presentModalViewController:picker animated:animated];
            [picker viewDidPresent:animated];
            if(finished) finished();
        }
        
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
    }
}
- (void) closeCam:(void (^)())finished;
{
    @autoreleasepool {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
        
        __unsafe_unretained __block  MysticPickerViewController *picker = nil;
        
        BOOL animated = YES;
        if([self respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            picker = (MysticPickerViewController *)self.presentedViewController;
            NavLog(@"Close Cam: %@  |  Controllers: %d  %@", picker, picker.viewControllers.count, picker.viewControllers);
            [self dismissViewControllerAnimated:animated completion:^{
                //                [picker finished];
                if(finished) finished();
            }];
        }
        else
        {
            picker = (MysticPickerViewController *)self.modalViewController;
            NavLog(@"Close Cam: %@  |  Controllers: %d  %@", picker, picker.viewControllers.count, picker.viewControllers);
            [self dismissModalViewControllerAnimated:animated];
            //            [picker finished];
            if(finished) finished();
        }
        
        
    }
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    __unsafe_unretained __block  MysticNewProjectViewController *weakSelf = self;
    MysticNavigationViewController *nav = (MysticNavigationViewController *)self.navigationController;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"mystifying", nil);
    
    MysticController *viewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewController = [[MysticController alloc] initWithNibName:@"MysticController" images:nil];
    } else {
        viewController = [[MysticController alloc] initWithNibName:@"MysticController_iPad" images:nil];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController info:[NSMutableArray arrayWithArray:info] ready:^(MysticController *editController){
            [editController setInfo:nil finished:^{
                editController.photoInfo = nil;
                [weakSelf.navigationController setViewControllers:@[editController] animated:NO];
            }];
        }];
        
        weakSelf.navigationController.navigationBarHidden = NO;
        [nav pushViewController:viewController animated:NO];
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf closeCam:nil];
        
        
    });
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //
    //        [nav popToRootViewControllerAnimated:NO];
    //    });
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self closeCam:^{
        
    }];
}

@end
