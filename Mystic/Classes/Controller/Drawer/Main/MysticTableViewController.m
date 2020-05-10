 //
//  MysticTableViewController.m
//  Mystic
//
//  Created by Travis on 10/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticTableViewController.h"
#import "MysticLayerTableViewCell.h"
#import "UIViewController+MMDrawerController.h"
#import "MysticController.h"
#import "MysticSectionView.h"
#import "MysticDrawerViewController.h"
#import "MysticDrawerMenuViewController.h"
#import "MysticDrawerNavViewController.h"

@interface MysticTableViewController () <MysticLayerToolbarDelegate>
{
    BOOL _setupTableView;
}

@property (nonatomic, retain) UITableView *tbView;
@end

@implementation MysticTableViewController

@synthesize mTableViewStyle, sections;

- (void) dealloc;
{
    if(self.tbView)
    {
    self.tbView.delegate = nil;
    self.tbView.dataSource = nil;
    }
    if(self.tableView)
    {
        self.tableView.delegate = nil;
        self.tableView.dataSource = nil;
    }
    [sections release], sections=nil;
    [_bottomView release], _bottomView=nil;
    [_tbView release], _tbView = nil;
    [super dealloc];
}
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    
    
    nibNameOrNil = nibNameOrNil ? nibNameOrNil : @"MysticTableViewController";
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
//        self.sections = @[];
        self.mTableViewStyle = style;

        [self commonInit];


    }
    return self;
}

- (void) commonInit;
{
    self.shouldRerenderOnClose = NO;
    _setupTableView = NO;
    self.navigationItem.hidesBackButton = YES;
    self.hidesBottomBarWhenPushed = YES;
    self.showLastBorder = YES;
    self.showFirstBorder = YES;

    [self initData];
}

- (void) editing:(BOOL)editing;
{
    self.tableView.editing = editing;

}
- (void) initData;
{
    self.sections = @[];
}
- (UIViewController *) loadSection:(NSInteger)section;
{
   return [self loadSection:section animated:NO];
}

- (UIViewController *) loadSection:(NSInteger)section animated:(BOOL)animated;
{
    return [(MysticDrawerNavViewController *)self.navigationController loadSection:section animated:animated];
}
- (void) reload;
{
    //[self.tableView reloadData];
}
- (void) loadView;
{
    UIView *cView = [[UIView alloc] initWithFrame:CGRectSize([MysticUI screen])];
    cView.autoresizesSubviews = YES;
    cView.backgroundColor = [UIColor color:MysticColorTypeDrawerBackground];
    BVReorderTableView *tbView = [[BVReorderTableView alloc] initWithFrame:cView.bounds];
    tbView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tbView.backgroundColor = cView.backgroundColor;
    tbView.delegate = self;
    tbView.dataSource = self;
    tbView.showsVerticalScrollIndicator = NO;
    tbView.showsHorizontalScrollIndicator = NO;
    tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
    CGFloat backgroundBorderWidth = ![[MysticLayerTableViewCell class] backgroundViewClass] ? 0 : [[[MysticLayerTableViewCell class] backgroundViewClass] isSubclassOfClass:[MysticBorderView class]] ? [[[MysticLayerTableViewCell class] backgroundViewClass] borderWidth] : 0;
    tbView.contentInset = !self.showFirstBorder ? UIEdgeInsetsMake(backgroundBorderWidth * -1, tbView.contentInset.left, tbView.contentInset.bottom, tbView.contentInset.right) : tbView.contentInset;
    [cView addSubview:tbView];
    self.tbView = [tbView autorelease];
    self.view = [cView autorelease];
}

- (UITableView *)tableView;
{
    return self.tbView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
//    DLog(@"table content inset: %@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}
- (void) setBottomView:(UIView *)bottomView;
{
    if(_bottomView)
    {
        [_bottomView removeFromSuperview];
        [_bottomView release], _bottomView = nil;
    }
    _bottomView = bottomView ? [bottomView retain] : nil;
    CGRect tblViewFrame = self.tableView.frame;

    if(bottomView)
    {
        bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:bottomView];
        
        tblViewFrame.size.height = self.view.frame.size.height - bottomView.frame.size.height;
        self.tableView.frame = tblViewFrame;
        
        
    }
    
    
}
- (void) viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
  //  self.view.backgroundColor = [UIColor color:MysticColorTypeDrawerBackground];
    if(self.bottomView)
    {
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - self.bottomView.frame.size.height);
 
        
    }
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

    return self.sections.count;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSDictionary *sectionData = [self section:section];
    NSString *title = [sectionData objectForKey:@"title"];
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self sectionVisibleRows:[NSIndexPath indexPathForRow:0 inSection:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellInfo = [self sectionRow:indexPath];

    
    int numberOfSections = [self numberOfSectionsInTableView:self.tableView];
    int numberOfRows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    BOOL isFirst = indexPath.row == 0;
    BOOL isLast = indexPath.row == (numberOfRows-1);

    MysticPosition bPosition = !isFirst || self.navigationController.navigationBarHidden ? MysticPositionBottom : MysticPositionBottom|MysticPositionTop;
    BOOL showBorder = (indexPath.row+1) != numberOfRows && numberOfRows > 1 ;
    
    BOOL sshowBorder = !showBorder && indexPath.section+1 == numberOfSections ? YES : showBorder;
    
    BOOL hasAccessory = isM(cellInfo[@"accessory"]);
    
    
    if(!self.showFirstBorder && isFirst && bPosition & MysticPositionBottom)
    {
        if(isLast)
        {
            //bPosition = MysticPositionBottom;
            sshowBorder = YES;
        }
        else  if(numberOfRows > 1)
        {
            sshowBorder = YES;
//            bPosition = MysticPositionBottom;
        }
        else
        {
            sshowBorder = NO;
        }
    }
    if(sshowBorder && !self.showLastBorder && isLast)
    {
        sshowBorder = NO;
    }
    
    
    static NSString *CellIdentifier = @"CellMTable";
    static NSString *CellIdentifierAccessory = @"CellMTableAccessory";
    static NSString *CellIdentifierNoBorder = @"CellMTableNoBorder";
    static NSString *CellIdentifierNoBorderAccessory = @"CellMTableNoBorderAccessory";

    NSString *useIdentifier = [cellInfo objectForKey:@"CellIdentifier"];
    if(!useIdentifier)
    {
        if(sshowBorder && hasAccessory)
        {
            useIdentifier = CellIdentifierAccessory;
        }
        else if(!sshowBorder && hasAccessory)
        {
            useIdentifier = CellIdentifierNoBorderAccessory;
        }
        else if(sshowBorder && !hasAccessory)
        {
            useIdentifier = CellIdentifier;
        }
        else if(!sshowBorder && !hasAccessory)
        {
            useIdentifier = CellIdentifierNoBorder;
        }
    }
    Class cellClass = [MysticLayerTableViewCell class];
    if([cellInfo objectForKey:@"CellClass"])
    {
        cellClass =[cellInfo objectForKey:@"CellClass"];
        useIdentifier = [useIdentifier stringByAppendingString:NSStringFromClass(cellClass)];
    }
    UITableViewCellStyle cellStyle = UITableViewCellStyleDefault;
    if([NSStringFromClass(cellClass) isEqualToString:@"MysticLayerTableViewCell"])
    {
        cellStyle = UITableViewCellStyleSubtitle;
    }
    if(isM(cellInfo[@"identifier"]))
    {
        useIdentifier = [useIdentifier stringByAppendingString:cellInfo[@"identifier"]];
    }
    MysticLayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:useIdentifier];
    if (cell == nil) {
        cell = [[[cellClass alloc] initWithStyle:cellStyle reuseIdentifier:useIdentifier] autorelease];
    }
    
    
    
    if([[cellInfo objectForKey:@"title"] isEqualToString:@"dummy"])
    {
        cell.textLabel.text = @"";
        cell.imageView.image = nil;
        cell.detailTextLabel.text = @"";
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if(cell.backgroundView) cell.backgroundView.backgroundColor = [UIColor blackColor];

    }
    else
    {
        // Configure the cell...
        cell.textLabel.text = [cellInfo objectForKey:@"title"];
        cell.textLabel.textColor = [cellInfo objectForKey:@"titleColor"];
        if([cellInfo objectForKey:@"titleFont"]) cell.textLabel.font = [cellInfo objectForKey:@"titleFont"];

//        CGFloat h = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        BOOL hasImage = [[cellInfo objectForKey:@"image"] isKindOfClass:[UIImage class]];

        
//        if(!hasImage && ![cellInfo objectForKey:@"imageCornerRadius"])
//        {
//            cell.imageView.layer.cornerRadius = MYSTIC_UI_DRAWER_CELL_CORNER_RADIUS;
//        }
        if(!isMEmpty([cellInfo objectForKey:@"image"]))
        {
            UIImage *theImage = [cellInfo objectForKey:@"image"];
            CGSize imageSizeBefore = [cellInfo objectForKey:@"imageSize"] ? [[cellInfo objectForKey:@"imageSize"] CGSizeValue] :  [cellClass imageViewSize];
            CGSize imageSize = imageSizeBefore;
            
            
            
            if((hasImage && theImage.scale < 2))
            {
                imageSize = [MysticUI scaleSize:imageSize scale:0];
            }
            
            CGSize iconImageSize = CGSizeMakeUnknownWidth(imageSize);
            
            
            UIImage *cellImage = [MysticImage image:theImage size:iconImageSize color:[cellInfo objectForKey:@"color"] backgroundColor:nil];
            cell.imageView.image = cellImage;
            UIViewContentMode cMode = [cellInfo objectForKey:@"imageContentMode"] ? [[cellInfo objectForKey:@"imageContentMode"] integerValue] : UIViewContentModeScaleAspectFit;
            cell.imageView.contentMode = hasImage && ![cellInfo objectForKey:@"imageContentMode"] ? UIViewContentModeScaleAspectFill : cMode;
            cell.imageView.layer.masksToBounds = YES;

            
            if([cellInfo objectForKey:@"imageBackground"])
            {
                
                CGSize cellImageViewSize = [cellClass imageViewSize];
                CGRect rect = CGRectSize(cellImageViewSize);
                
                
                UIGraphicsBeginImageContextWithOptions(cellImageViewSize, NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                UIColor *bgColor = [MysticColor color:[cellInfo objectForKey:@"imageBackground"]];
                if(bgColor)
                {
                    [[MysticColor color:bgColor] setFill];
                    CGContextFillRect(context, rect);
                }
                CGRect cellImgDrawRect = MysticPositionRect(CGRectSize(cellImage.size), rect, MysticPositionCenter);
                [cellImage drawInRect:cellImgDrawRect];
                UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                cell.imageView.image = newImage;
                cell.imageView.backgroundColor = bgColor;
                
                
            }
            else
            {
                cell.imageView.backgroundColor = [UIColor clearColor];
            }
            
 
            
            if([cellInfo objectForKey:@"imageBorder"] && [[cellInfo objectForKey:@"imageBorder"] boolValue])
            {
                UIColor *imgBorderColor = [[cellInfo objectForKey:@"imageBorder"] isKindOfClass:[NSNumber class]] && [[cellInfo objectForKey:@"imageBorder"] integerValue] > 1 ? [MysticColor color:[cellInfo objectForKey:@"imageBorder"]] : [UIColor color:MysticColorTypeDrawerIconBorder];
                MBorder(cell.imageView, imgBorderColor, 1.5);
            }
            
            cell.imageView.layer.cornerRadius = hasImage ? MYSTIC_UI_DRAWER_CELL_CORNER_RADIUS : ([cellInfo objectForKey:@"imageCornerRadius"] ? [[cellInfo objectForKey:@"imageCornerRadius"] floatValue] : MYSTIC_UI_DRAWER_CELL_CORNER_RADIUS);
           
        }
        
        
        
        
        if(!isMEmpty([cellInfo objectForKey:@"subtitle"]))
        {
            cell.detailTextLabel.text = [[cellInfo objectForKey:@"subtitle"] uppercaseString];
        }
        
        if(isM(cellInfo[@"accessory"]) && [cellInfo[@"accessory"] isKindOfClass:[UIView class]])
        {
            cell.accessoryView = [cellInfo objectForKey:@"accessory"];
        }
        else if(isM(cellInfo[@"accessory"]))
        {
            UIColor *indicatorColor = [UIColor color:MysticColorTypeDrawerAccessory];
            UIColor *indicatorColorHighlighted = [UIColor color:MysticColorTypeDrawerAccessoryHighlighted];

            id cellAccessory = [cellInfo objectForKey:@"accessory"];
            CGSize accessorySize = [cellInfo objectForKey:@"accessorySize"] ? [[cellInfo objectForKey:@"accessorySize"] CGSizeValue] : CGSizeMake(MYSTIC_LAYER_CELL_ACCESSORY_SIZE, MYSTIC_LAYER_CELL_ACCESSORY_SIZE);

            UIImage *iconImage = cellAccessory;
            if(![cellAccessory isKindOfClass:[UIImage class]])
            {
                iconImage = [MysticImage image:[cellInfo objectForKey:@"accessory"] size:accessorySize color:indicatorColor];
            }
            
            
            MysticButton *button = [MysticButton clearButtonWithImage:iconImage target:self sel:@selector(accessoryButtonTapped:event:)];
            
            id cellAccessoryHighlighted = [cellInfo objectForKey:@"accessoryHighlighted"];
            if(cellAccessoryHighlighted)
            {
                UIImage *iconImageHighlighted = cellAccessoryHighlighted;
                if(![cellAccessoryHighlighted isKindOfClass:[UIImage class]])
                {
                    iconImageHighlighted = [MysticImage image:cellAccessoryHighlighted size:accessorySize color:indicatorColorHighlighted];
                }
                [button setImage:iconImageHighlighted forState:UIControlStateHighlighted];
                button.adjustsImageWhenHighlighted = NO;
            }
            
            
            CGRect bframe = button.frame;
            bframe.size = CGSizeMake(MYSTIC_ICON_BIG_WIDTH, MYSTIC_ICON_BIG_HEIGHT);
            button.frame = bframe;
            button.contentMode = UIViewContentModeCenter;
            cell.accessoryView = button;
        }
//        cell.backgroundView.backgroundColor = nil;
    }
    if(cell.backgroundView && [cell.backgroundView isKindOfClass:[MysticBorderView class]])
    {
        MysticLeftTableViewCellBackgroundView *bgView = (MysticLeftTableViewCellBackgroundView *)cell.backgroundView;
        
        if(indexPath.row == 0) [bgView setBorderInsets:UIEdgeInsetsMake(bgView.borderWidth/2, 0, 0, 0)];
        bgView.borderPosition = bPosition;
        bgView.showBorder = sshowBorder;


    }
    
    UIView *selectionView = [[UIView alloc] initWithFrame:cell.bounds];
    selectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    selectionView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    cell.selectedBackgroundView = [selectionView autorelease];
    
//    cell.backgroundView.borderInsets = UIEdgeInsetsMake(cell.backgroundView.borderInsets.top, cell.layoutPadding.x, 0, -cell.layoutPadding.x);
 
    return cell;
}

- (void)accessoryButtonTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil){
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
//    ALLog(@"height for row", @[@"table", SLogStr(tableView.frame.size),
//                               @"nav view", SLogStr(self.navigationController.view.frame.size),
//                               @"navbar", SLogStr(self.navigationController.navigationBar.frame.size),
//                               @"toolbar", SLogStr(self.navigationController.toolbar.frame.size)]);
    
    CGFloat h = roundf(self.navigationController.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.navigationController.toolbar.frame.size.height)/5.5;
//    ALLog(@"height for row", @[@"table", SLogStr(tableView.frame.size),
//                               @"height", @(h),
                               //                               @"nav view", SLogStr(self.navigationController.view.frame.size),
                               //                               @"navbar", SLogStr(self.navigationController.navigationBar.frame.size),
                               //                               @"toolbar", SLogStr(self.navigationController.toolbar.frame.size)
//                               ]);
    return h;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    CGRect sectionFrame = CGRectMake(0, 0, self.tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section]);
    NSArray *theItems = [[self section:section] objectForKey:@"tools"];
    if(theItems && theItems.count)
    {
        return [[[MysticSectionToolbar alloc] initWithFrame:sectionFrame items:theItems] autorelease];
    }
    MysticSectionView *sectionTitleView = [[MysticSectionView alloc] initWithFrame:sectionFrame];
    sectionTitleView.text = sectionTitle;
    
    return [sectionTitleView autorelease];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSArray *theItems = [[self section:section] objectForKey:@"tools"];
    if(theItems && theItems.count)
    {
        return [MysticSectionToolbar height];
    }
    if(![[self section:section] objectForKey:@"title"]) return 0;
    return [MysticSectionView height];
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if(indexPath.section == MysticDrawerSectionLayers)
    {
        return YES;
    }
    return NO;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSArray *rows = [self sectionVisibleRows:toIndexPath];
    NSMutableArray *newRows = [NSMutableArray arrayWithArray:rows];
    
    id movingItem = [[[newRows objectAtIndex:fromIndexPath.row] retain] autorelease];
    [newRows removeObjectAtIndex:fromIndexPath.row];
    [newRows insertObject:movingItem atIndex:toIndexPath.row];
    
    
    [self reorderSection:fromIndexPath.section rows:newRows];
    [self.tableView reloadData];
    
}
- (void) drawerClosed;
{
    
}
- (void) drawerOpened;
{
    
}
- (void) reorderSection:(NSInteger)section rows:(NSArray *)newRows;
{
    
}

- (void) saveOrder;
{
    
}
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = [self sectionRow:indexPath];
    if([row objectForKey:@"moveable"])
    {
        return [[row objectForKey:@"moveable"] boolValue];
    }
    if(indexPath.section == MysticDrawerSectionLayers)
    {
        return YES;
    }
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSIndexPath *newPath = proposedDestinationIndexPath;
    if(proposedDestinationIndexPath.section > sourceIndexPath.section)
    {
        newPath = [NSIndexPath indexPathForRow:[self sectionVisibleRows:sourceIndexPath].count-1 inSection:sourceIndexPath.section];
    }
    else if(proposedDestinationIndexPath.section < sourceIndexPath.section)
    {
        newPath = [NSIndexPath indexPathForRow:0 inSection:sourceIndexPath.section];
    }
    
    if(![self tableView:self.tableView canMoveRowAtIndexPath:newPath])
    {
        newPath = sourceIndexPath;
    }
    return newPath;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { return NO; }
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSDictionary *cell = [self sectionRow:indexPath];
//    if([cell objectForKey:@"confirm"] && NO)
//    {
//        __unsafe_unretained __block MysticTableViewController *weakSelf = self;
//        __unsafe_unretained __block NSIndexPath *_indexPath = [indexPath retain];
//        __unsafe_unretained __block UITableView *_tableView = [tableView retain];
//
//
//        NSString *cancel = [cell objectForKey:@"confirmCancel"] ? [cell objectForKey:@"confirmCancel"] : @"Cancel";
//        NSString *confirmTitle = [cell objectForKey:@"confirmConfirm"] ? [cell objectForKey:@"confirmConfirm"] : @"OK";
//        NSString *title = [cell objectForKey:@"confirm"] ? [cell objectForKey:@"confirm"] : nil;
//        NSString *alertMessage = [cell objectForKey:@"confirmMessage"] ? [cell objectForKey:@"confirmMessage"] : @"Do you want to continue?";
//        
//       
//        [MysticAlert show:title message:alertMessage action:^(id object, id o2) {
//            [weakSelf tableView:_tableView didSelectRowAtIndexPath:_indexPath confirmed:YES];
//            [_indexPath release];
//            [_tableView release];
//        } cancel:^(id object, id o2) {
//            [_indexPath release];
//            [_tableView release];
//        } options:@{@"button": confirmTitle, @"cancelTitle":cancel}];
//        
//    }
//    else
//    {
        [self tableView:tableView didSelectRowAtIndexPath:indexPath confirmed:YES];
//    }
}

- (void) emptyData;
{
    
}
#pragma mark - Custom Table Methods



- (void) scrollToSectionWithTitle:(NSString *)title;
{
    int section = 0;
    int numberOfSections = [self numberOfSectionsInTableView:self.tableView];
    for (int i=0; i<numberOfSections; i++) {
        NSString *sectionTitle = [self tableView:self.tableView titleForHeaderInSection:i];
        if([title isEqualToString:sectionTitle])
        {
            section = i;
            break;
        }
    }
    [self scrollToSection:section animated:YES];
}
- (void) scrollToSection:(NSInteger)section animated:(BOOL)animated;
{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
//
//    [self.tableView scrollToRowAtIndexPath:indexPath
//                          atScrollPosition:UITableViewScrollPositionTop
//                                  animated:animated];
}



#pragma mark - Table Data Methods

- (NSDictionary *) section:(NSInteger)section;
{
    return [self.sections objectAtIndex:section];
}
- (NSDictionary *) sectionRow:(NSIndexPath *) indexPath;
{
    NSArray *visibleRows = [self sectionVisibleRows:indexPath];
    
    return indexPath.row < visibleRows.count ? [visibleRows objectAtIndex:indexPath.row] : nil;
}
- (NSArray *) sectionRows:(NSIndexPath *) indexPath;
{
    return [[self section:indexPath.section] objectForKey:@"rows"];
}
- (NSArray *) replaceRowAtIndexPath:(NSIndexPath *)indexPath withRow:(NSDictionary *)row;
{
    if(!row) row = @{@"title": @"dummy"};
    NSMutableArray *newSectionRows = [NSMutableArray arrayWithArray:[self sectionRows:indexPath]];
    [newSectionRows replaceObjectAtIndex:indexPath.row withObject:row];
    
    
    
    return [self replaceSectionRowsAtIndexPath:indexPath withRows:newSectionRows];
    
}

- (NSArray *) replaceSectionRowsAtIndexPath:(NSIndexPath *)indexPath withRows:(NSArray *)rows;
{
    
    if(!rows) rows = @[];
    
    NSMutableDictionary *section = [NSMutableDictionary dictionaryWithDictionary:[self section:indexPath.section]];
    [section setObject:rows forKey:@"rows"];
    
    self.sections = @[
//                      [self.sections objectAtIndex:MysticDrawerSectionMain],
                      [NSDictionary dictionaryWithDictionary:section],
//                      [self.sections objectAtIndex:MysticDrawerSectionAdd],
//                      [self.sections objectAtIndex:MysticDrawerSectionAddSpecial]
                      ];
    
    
    return rows;
    
}
- (NSArray *) sectionVisibleRows:(NSIndexPath *)indexPath;
{
    NSArray *rows = [self sectionRows:indexPath];
    if(indexPath.section != MysticDrawerSectionLayers) return rows;
    
    NSMutableArray *_rows = [NSMutableArray array];
    for (NSDictionary *row in rows) {
        PackPotionOption *option = [row objectForKey:@"option"];
        if(option)
        {
            if((!option.showLayerPreview || option.ignoreRender || option.cancelsEffect) && ![row objectForKey:@"visible"]) continue;
        }
        [_rows addObject:row];
    }
    return _rows;

}





// This method is called when starting the re-ording process. You insert a blank row object into your
// data source and return the object you want to save for later. This method is only called once.
- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {

    id row = [self sectionRow:indexPath];
    NSDictionary *dummyRow = @{@"title": @"dummy", @"visible": @YES};
    
    [self replaceRowAtIndexPath:indexPath withRow:dummyRow];
    return row;
}

// This method is called when the selected row is dragged to a new position. You simply update your
// data source to reflect that the rows have switched places. This can be called multiple times
// during the reordering process.
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    NSIndexPath *finalSpotIndexPath = toIndexPath;
    
    NSMutableArray *rows = [NSMutableArray arrayWithArray:[self sectionRows:fromIndexPath]];
    if(finalSpotIndexPath && finalSpotIndexPath.row != NSNotFound && finalSpotIndexPath.row >= 0 && finalSpotIndexPath.row < rows.count)
    {
        id row = [[rows objectAtIndex:fromIndexPath.row] retain];
        [rows removeObjectAtIndex:fromIndexPath.row];
        [rows insertObject:row atIndex:finalSpotIndexPath.row];
        [row release];
        [self replaceSectionRowsAtIndexPath:finalSpotIndexPath withRows:rows];
    }
}


// This method is called when the selected row is released to its new position. The object is the same
// object you returned in saveObjectAndInsertBlankRowAtIndexPath:. Simply update the data source so the
// object is in its new position. You should do any saving/cleanup here.
- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath; {
//    [_objects replaceObjectAtIndex:indexPath.row withObject:object];
    // do any additional cleanup here
    [self replaceRowAtIndexPath:indexPath withRow:object];
    
    [self saveOrder];
    
    [self.tableView reloadData];

}

- (void) updateNavBar;
{

}



#pragma mark - MysticToolbar delegate

- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;
{
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath confirmed:(BOOL)isConfirmed;
{
    BOOL animateState = YES;
    BOOL closeDrawerFirst = YES;
    BOOL animateDrawer = YES;
    BOOL closeDrawer = YES;
    id target;
    SEL action, actionAfter;
    id param;
    MysticBlock customBlock = nil;
    // Navigation logic may go here. Create and push another view controller.
    MysticObjectType nextState = MysticSettingNone;
    
    NSDictionary *cell = [self sectionRow:indexPath];
    
    closeDrawer = [cell objectForKey:@"closeDrawer"] ? [[cell objectForKey:@"closeDrawer"] boolValue] : closeDrawer;
    
    
    NSDictionary *userInfo = [cell objectForKey:@"userInfo"] ? [cell objectForKey:@"userInfo"] : nil;
    target = [cell objectForKey:@"target"] ? [cell objectForKey:@"target"] : nil;
    param = [cell objectForKey:@"param"] ? [cell objectForKey:@"param"] : nil;
    action = [cell objectForKey:@"action"] ? NSSelectorFromString([cell objectForKey:@"action"]) : nil;
    actionAfter = [cell objectForKey:@"actionAfter"] ? NSSelectorFromString([cell objectForKey:@"actionAfter"]) : nil;

    closeDrawerFirst = [cell objectForKey:@"closeDrawerFirst"] ? [[cell objectForKey:@"closeDrawerFirst"] boolValue] : closeDrawerFirst;
    nextState = [cell objectForKey:@"state"] ? [[cell objectForKey:@"state"] integerValue] : nextState;
    customBlock = [cell objectForKey:@"block"] ? (MysticBlock)[cell objectForKey:@"block"] : customBlock;
    
    if(closeDrawer && closeDrawerFirst)
    {
        __unsafe_unretained __block  MysticController *weakController = [MysticController controller];
        __unsafe_unretained __block  MysticTableViewController *weakSelf = self;

        
        [self.mm_drawerController
         closeDrawerAnimated:animateDrawer
         completion:^(BOOL finished) {
             if(finished)
             {
                 if(customBlock)
                 {
                     customBlock();
                 }
                 else if(target && action && [target respondsToSelector:action])
                 {
                     if(param)
                     {
                         [target performSelector:action withObject:param];
                     }
                     else
                     {
                         [target performSelector:action];
                     }
                 }
                 else
                 {
                     [weakController setStateConfirmed:nextState animated:animateState info:userInfo complete:nil];
                 }
                 if(target && actionAfter && [target respondsToSelector:actionAfter])
                 {
                     if(param)
                     {
                         [target performSelector:actionAfter withObject:param];
                     }
                     else
                     {
                         [target performSelector:actionAfter];
                     }
                 }
                 [self emptyData];
             }
         }];
    }
    else if(closeDrawer)
    {
        MysticBlock finishedState = !animateDrawer ? nil : ^{
            [self.mm_drawerController
             closeDrawerAnimated:animateDrawer
             completion:^(BOOL finished) {
                 if(finished)
                 {
                     [self emptyData];
                 }
             }];
        };
        finishedState = closeDrawer ? finishedState : nil;
        if(customBlock)
        {
            customBlock();
            finishedState();
        }
        else if(target && action && [target respondsToSelector:action])
        {
            
            if(param)
            {
                [target performSelector:action withObject:param];
            }
            else
            {
                [target performSelector:action];
            }
            finishedState();
        }
        else
        {
            [[MysticController controller] setStateConfirmed:nextState animated:animateState info:userInfo complete:finishedState];
        }
        if(target && actionAfter && [target respondsToSelector:actionAfter])
        {
            if(param)
            {
                [target performSelector:actionAfter withObject:param];
            }
            else
            {
                [target performSelector:actionAfter];
            }
        }
    }
    else
    {
        if(customBlock)
        {
            customBlock();
        }
        else if(target && action && [target respondsToSelector:action])
        {
            
            if(param)
            {
                [target performSelector:action withObject:param];
            }
            else
            {
                [target performSelector:action];
            }
        }
        if(target && actionAfter && [target respondsToSelector:actionAfter])
        {
            if(param)
            {
                [target performSelector:actionAfter withObject:param];
            }
            else
            {
                [target performSelector:actionAfter];
            }
        }
    }
    
}


@end
