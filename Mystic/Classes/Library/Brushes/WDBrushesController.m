//
//  WDBrushesController.m
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2011-2013 Steve Sprang
//

#import "WDActiveState.h"
#import "WDBar.h"
#import "WDBarSlider.h"
#import "WDBrush.h"
#import "WDBrushController.h"
#import "WDBrushesController.h"
#import "WDBrushCell.h"
#import "UIImage+Additions.h"
#import "MysticIcon.h"
#import "MysticCommon.h"

#define kRowHeight 100

@interface WDBrushesController ()
{
    CGFloat cellHeight;
}
- (void) configureNavBar;
- (void) selectActiveBrush;
@end

@implementation WDBrushesController

@synthesize brushTable;
@synthesize brushCell;
@synthesize delegate;
@synthesize topBar;
@synthesize bottomBar;
@synthesize brushSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (!self) {
        return nil;
    }
    
    //self.title = NSLocalizedString(@"Brushes", @"Brushes");
    
    [self configureNavBar];
    
    return self;
}

- (void) done:(id)sender
{
    self.swipeDuplicateBtn = nil;
    self.swipeEditBtn = nil;
    self.swipeDeleteButton = nil;
    if(self.hud)
    {
        [self.hud hide:NO];
        self.hud = nil;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissViewController:)]) {
        [self.delegate performSelector:@selector(dismissViewController:) withObject:self];
    }
}

- (void) configureNavBar
{
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                            target:self
                                                                            action:@selector(deleteBrush:)];
    self.navigationItem.leftBarButtonItem = delete;
    
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addBrush:)];
    
    UIBarButtonItem *duplicate = [[UIBarButtonItem alloc] initWithImage:[UIImage relevantImageNamed:@"duplicate.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(duplicateBrush:)];
    
    self.navigationItem.rightBarButtonItems = @[add, duplicate];
}

- (void) scrollToSelectedRowIfNotVisible
{
    UITableViewCell *selected = [brushTable cellForRowAtIndexPath:[brushTable indexPathForSelectedRow]];
    
    // if the cell is nil or not completely visible, we should scroll the table
    if (!selected || !CGRectIntersectsRect(selected.frame, brushTable.bounds)) {
        [brushTable scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

- (void) selectActiveBrush
{
    NSUInteger  activeRow = [[WDActiveState sharedInstance] indexOfActiveBrush];
    
    if ([[brushTable indexPathForSelectedRow] isEqual:[NSIndexPath indexPathForRow:activeRow inSection:0]]) {
        [self scrollToSelectedRowIfNotVisible];
        return;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:activeRow inSection:0];
    // in selectRowAtIndex, "None" means no scrolling; in scrollToNearest, "None" means do minimal scrolling
    [brushTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [brushTable scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:NO];
}

- (void) brushDeleted:(NSNotification *)aNotification
{
    NSNumber *index = [aNotification userInfo][@"index"];
    NSUInteger row = [index integerValue]; // add one to account for the fact that the model already deleted the entry
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    [brushTable beginUpdates];
    [brushTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [brushTable endUpdates];
    
    self.navigationItem.leftBarButtonItem.enabled = [[WDActiveState sharedInstance] canDeleteBrush];
}

- (void) brushAdded:(NSNotification *)aNotification
{    
    NSNumber *index = [aNotification userInfo][@"index"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index.integerValue inSection:0];
    
    [brushTable beginUpdates];
    [brushTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [brushTable endUpdates];
    
    [self performSelector:@selector(selectActiveBrush) withObject:nil afterDelay:0];
    
    self.navigationItem.leftBarButtonItem.enabled = [[WDActiveState sharedInstance] canDeleteBrush];
}

- (void) deleteBrush:(id)sender
{
    [[WDActiveState sharedInstance] deleteActiveBrush];
}

- (void) addBrush:(id)sender
{
    [[WDActiveState sharedInstance] addBrush:[WDBrush randomBrush]];
}

- (void) duplicateBrush:(id)sender
{
    WDBrush *duplicate = [[WDActiveState sharedInstance].brush copy];

    [[WDActiveState sharedInstance] addBrush:duplicate];
    
}

#pragma mark - Table Delegate/Data Source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return cellHeight;
}
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [WDActiveState sharedInstance].brushesCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"BrushCell";
    WDBrush *brush = [[WDActiveState sharedInstance] brushAtIndex:indexPath.row];
    
    WDBrushCell *cell = (WDBrushCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"BrushCell" owner:self options:nil];
        cell = brushCell;
        brushCell = nil;
        cell.leftSwipeSettings.allowSwipeDuringEditing = YES;
        cell.rightSwipeSettings.allowSwipeDuringEditing = YES;
        cell.showsReorderControl = NO;
//        UIImageView *iv = [[UIImageView alloc] initWithImage:[MysticIcon iconForType:MysticIconTypeAccessoryDrag size:(CGSize){14,7} color:[UIColor colorWithRed:0.16 green:0.16 blue:0.15 alpha:1.00]]];
//        iv.frame = (CGRect){0,0,30,30};
//        iv.highlightedImage = [MysticIcon iconForType:MysticIconTypeAccessoryDrag size:(CGSize){14,7} color:[UIColor colorWithRed:0.41 green:0.36 blue:0.33 alpha:1.00]];
//        iv.contentMode = UIViewContentModeLeft;
//        cell.editingAccessoryView = iv;
//        cell.editingAccessoryView.userInteractionEnabled = NO;
    }
    cell.number.text = [NSString stringWithFormat:@"%d", (int)indexPath.item+1];
    cell.brush = brush;
    cell.table = brushTable;
//    cell.delegate = self;
//    CGSize actionSize = (CGSize){20,20};
//    CGSize actionSizeDelete = (CGSize){16,16};
//
//    CGFloat padding = 30;
//    CGFloat paddingDelete = 10;
//
//    __unsafe_unretained __block WDBrushesController *weakSelf = self;
//    __unsafe_unretained __block NSIndexPath *_ip = indexPath;
    cell.delegate = self;
//    MGSwipeButton *deleteBtn = [MGSwipeButton buttonWithTitle:@"" icon:[MysticIcon iconForType:MysticIconTypeRemove size:actionSizeDelete color:[UIColor hex:@"8f8a82"]] backgroundColor:[UIColor hex:@"1e1c1b"] padding:paddingDelete callback:^BOOL(MGSwipeTableCell * sender){
//        [weakSelf deleteBrush:sender];
//        return YES;
//    }];
//    
//    MGSwipeButton *editBtn = [MGSwipeButton buttonWithTitle:@"" icon:[MysticIcon iconForType:MysticIconTypeSettings size:actionSize color:[UIColor hex:@"e9e0d3"]] backgroundColor:[UIColor hex:@"a83e4e"] padding:padding callback:^BOOL(MGSwipeTableCell * sender){
//        [weakSelf tableView:weakSelf.brushTable accessoryButtonTappedForRowWithIndexPath:_ip];
//        return YES;
//    }];
//    MGSwipeButton *duplicateBtn = [MGSwipeButton buttonWithTitle:@"" icon:[MysticIcon iconForType:MysticIconTypeToolDuplicate size:actionSize color:[UIColor hex:@"8f8a82"]] backgroundColor:[UIColor hex:@"2b2724"] padding:padding callback:^BOOL(MGSwipeTableCell * sender){
//        [weakSelf duplicateBrush:sender];
//        
//        return YES;
//    }];
//    cell.rightButtons = @[deleteBtn,editBtn,duplicateBtn];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{    
    [[WDActiveState sharedInstance] selectBrushAtIndex:newIndexPath.row];
    [self done:nil];
}

- (void) brushChanged:(NSNotification *)aNotification
{
    [self selectActiveBrush];
    brushSlider.value = [WDActiveState sharedInstance].brush.weight.value;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if(self.swipeEditBtn)
    {
        self.swipeEditBtn.enabled = NO;
    }
    if(self.swipeDeleteButton)
    {
        self.swipeDeleteButton.enabled = NO;
    }
    if(self.swipeDuplicateBtn)
    {
        self.swipeDuplicateBtn.enabled = NO;
    }
    if(!self.hud)
    {
        MysticProgressHUD *hud = [[MysticProgressHUD alloc] initWithView:self.view];
        hud.mode = MysticProgressHUDModeIndeterminate;
        hud.removeFromSuperViewOnHide = YES;
        self.hud = hud;
        [self.view addSubview:hud];
        [self.hud show:YES];
        
    }
    [[WDActiveState sharedInstance] selectBrushAtIndex:indexPath.row];
    __unsafe_unretained __block WDBrushesController *weakSelf = self;
    mdispatch_high(^{
        WDBrushController *brushController = [[WDBrushController alloc] initWithNibName:@"Brush" bundle:nil];
        brushController.brush = [[WDActiveState sharedInstance] brushAtIndex:indexPath.row];
        mdispatch(^{
            [weakSelf.navigationController pushViewController:brushController animated:YES];

        });
    });
    
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {    
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSUInteger srcIndex = sourceIndexPath.row;
    NSUInteger destIndex = destinationIndexPath.row;
    
    [[WDActiveState sharedInstance] moveBrushAtIndex:srcIndex toIndex:destIndex];
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.swipeDuplicateBtn)
    {
        self.swipeDuplicateBtn.enabled = YES;
        self.swipeDeleteButton.enabled = YES;
        self.swipeEditBtn.enabled = YES;

    }
    if(self.hud)
    {
        [self.hud hide:NO];
        self.hud = nil;
    }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self.navigationController setNavigationBarHidden:YES];
        [self configureForOrientation:self.orientation];
    }
    
    [self selectActiveBrush];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
//    self.swipeDuplicateBtn = nil;
//    self.swipeEditBtn = nil;
//    self.swipeDeleteButton = nil;
    [[WDActiveState sharedInstance] saveBrushes];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.swipeDuplicateBtn)
    {
        self.swipeDuplicateBtn.enabled = YES;
        self.swipeDeleteButton.enabled = YES;
        self.swipeEditBtn.enabled = YES;
        
    }
    if(self.hud)
    {
        [self.hud hide:NO];
        self.hud = nil;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushChanged:) name:WDActiveBrushDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushAdded:) name:WDBrushAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushDeleted:) name:WDBrushDeletedNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) doubleTapped:(id)sender
{
    [self done:sender];
}

- (WDBar *) topBar
{
//    if (!topBar) {
//        WDBar *aBar = [WDBar topBar];
//        CGRect frame = aBar.frame;
//        frame.size.width = CGRectGetWidth(self.view.bounds);
//        aBar.frame = frame;
//        
//        [self.view addSubview:aBar];
//        self.topBar = aBar;
//    }
    
    return topBar;
}

- (WDBar *) bottomBar
{
    if (!bottomBar) {
        WDBar *aBar = [WDBar bottomBar];
        CGRect frame = aBar.frame;
        frame.origin.y  = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(aBar.frame);
        frame.size.width = CGRectGetWidth(self.view.bounds);
        aBar.frame = frame;
        aBar.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.07 alpha:1.00];
        [self.view addSubview:aBar];
        self.bottomBar = aBar;
    }
    
    return bottomBar;
}

- (NSArray *) bottomBarItems
{
    
    UIImage *dissmissImg = [MysticImage image:@(MysticIconTypeSketchHide) size:CGSizeMake(MYSTIC_BRUSH_ICON_BOTTOMBAR, MYSTIC_BRUSH_ICON_BOTTOMBAR) color:[UIColor colorWithRed:0.84 green:0.82 blue:0.75 alpha:1.00]];
    UIImage *addImg = [MysticImage image:@(MysticIconTypeSketchBrushAdd) size:CGSizeMake(MYSTIC_BRUSH_ICON_BOTTOMBAR, MYSTIC_BRUSH_ICON_BOTTOMBAR) color:[UIColor colorWithRed:0.84 green:0.82 blue:0.75 alpha:1.00]];
    
    
    WDBarItem *dismiss = [WDBarItem barItemWithImage:dissmissImg
                                      landscapeImage:dissmissImg
                                              target:self
                                              action:@selector(done:)];
    WDBarItem *add = [WDBarItem barItemWithImage:addImg target:self action:@selector(addBrush:)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,150,55)];
    MysticAttrString *str = [MysticAttrString string:@"BRUSH" style:MysticStringStyleToolbarTitle];
    label.attributedText = str.attrString;
    WDBarItem *labelItem = [WDBarItem barItemWithView:label];
    return @[add,[WDBarItem flexibleItem],labelItem,[WDBarItem flexibleItem], dismiss];
    
}
- (NSArray *) barItems
{
    WDBarItem *delete = [WDBarItem barItemWithImage:[UIImage imageNamed:@"trash.png"] target:self action:@selector(deleteBrush:)];
    WDBarItem *add = [WDBarItem barItemWithImage:[UIImage imageNamed:@"add.png"] target:self action:@selector(addBrush:)];
    WDBarItem *duplicate = [WDBarItem barItemWithImage:[UIImage imageNamed:@"duplicate.png"] target:self action:@selector(duplicateBrush:)];
    
    return @[delete, [WDBarItem flexibleItem], duplicate, add];
}

- (void) decrementBrushSize:(id)sender
{
    [[WDActiveState sharedInstance].brush.weight decrement];
    brushSlider.value = [WDActiveState sharedInstance].brush.weight.value;
}

- (void) incrementBrushSize:(id)sender
{
    [[WDActiveState sharedInstance].brush.weight increment];
    brushSlider.value = [WDActiveState sharedInstance].brush.weight.value;
}

- (void) takeBrushSizeFrom:(WDBarSlider *)sender
{
    [WDActiveState sharedInstance].brush.weight.value = sender.value;
}


- (void)viewDidLoad
{
    [super viewDidLoad];    
 
    self.view.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.06 alpha:1.00];
    
    brushTable.rowHeight = kRowHeight;
    brushTable.backgroundColor = nil;
    brushTable.editing = YES;
    brushTable.separatorInset = UIEdgeInsetsZero;
    brushTable.layoutMargins = UIEdgeInsetsZero;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] init];
    doubleTap.numberOfTapsRequired = 2;
    [doubleTap addTarget:self action:@selector(done:)];
    [brushTable addGestureRecognizer:doubleTap];
    brushTable.separatorColor = [UIColor hex:@"252525"];
    self.preferredContentSize = self.view.frame.size;
    self.navigationItem.leftBarButtonItem.enabled = [[WDActiveState sharedInstance] canDeleteBrush];
    int visibleRows = 7;
    cellHeight = ceilf(([MysticUI screen].height-(visibleRows-1))/visibleRows);
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {

        self.bottomBar.ignoreTouches = NO;
        self.bottomBar.items = [self bottomBarItems];
        cellHeight = ceilf(([MysticUI screen].height - CGRectGetHeight(self.bottomBar.frame) )/visibleRows);

    }
    
    brushTable.frame = CGRectAddXH(brushTable.frame, 0, -CGRectGetHeight(self.bottomBar.frame));
    [self brushChanged:nil];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [brushTable addGestureRecognizer:longPress];
}
#pragma mark - Long Press

- (void)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:brushTable];
    NSIndexPath *indexPath = [brushTable indexPathForRowAtPoint:location];
    
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                WDBrushCell *cell = [brushTable cellForRowAtIndexPath:indexPath];
                if(![indexPath isEqual:brushTable.indexPathForSelectedRow])
                {
                    cell.draggingSelected=NO;
                }
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [brushTable addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                //                [self.objects exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [brushTable moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            WDBrushCell *cell = [brushTable cellForRowAtIndexPath:sourceIndexPath];
            if(![indexPath isEqual:brushTable.indexPathForSelectedRow])
            {
                cell.draggingSelected=NO;
            }
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                cell.hidden = NO;
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            
            break;
        }
    }
}
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}
- (void) viewDidUnload
{
    [super viewDidUnload];
    
    bottomBar = nil;
    topBar = nil;
}

- (void) configureForOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
//    [self.topBar setOrientation:toInterfaceOrientation];
    [self.bottomBar setOrientation:toInterfaceOrientation];
    
//    float barHeight = CGRectGetHeight(topBar.frame);
//    brushTable.contentInset = UIEdgeInsetsMake(barHeight, 0, barHeight, 0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self configureForOrientation:toInterfaceOrientation];
}

- (UIView *) rotatingHeaderView
{
    return self.topBar;
}

- (UIView *) rotatingFooterView
{
    return self.bottomBar;
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}
-(void) swipeTableCellWillBeginSwiping:(MGSwipeTableCell *) cell;
{
    if(self.swipeDuplicateBtn)
    {
        self.swipeDuplicateBtn.enabled = YES;
        self.swipeDeleteButton.enabled = YES;
        self.swipeEditBtn.enabled = YES;
    }
}
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    __unsafe_unretained __block WDBrushesController *weakSelf = self;
    CGSize actionSize = (CGSize){MYSTIC_BRUSH_ICON_CELL,MYSTIC_BRUSH_ICON_CELL};
    CGSize actionSizeDelete = (CGSize){MYSTIC_BRUSH_ICON_CELL,MYSTIC_BRUSH_ICON_CELL};
    CGFloat padding = 30;
    CGFloat paddingDelete = 10;
//    expansionSettings.buttonIndex = 0;
    swipeSettings.transition = MGSwipeTransitionBorder;

    if (direction == MGSwipeDirectionRightToLeft) {

        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        MGSwipeButton *deleteBtn = [MGSwipeButton buttonWithTitle:nil icon:[MysticIcon iconForType:MysticIconTypeSketchBrushDelete size:actionSizeDelete color:[UIColor hex:@"8f8a82"]] backgroundColor:[UIColor hex:@"1e1d1c"] padding:paddingDelete callback:^BOOL(MGSwipeTableCell * sender){
            [sender hideSwipeAnimated:YES];

            [weakSelf deleteBrush:sender];
            return YES;
        }];
        
        MGSwipeButton *editBtn = [MGSwipeButton buttonWithTitle:nil icon:[MysticIcon iconForType:MysticIconTypeSketchBrushEdit size:actionSize color:[UIColor hex:@"e9e0d3"]] backgroundColor:[UIColor hex:@"a83e4e"] padding:padding callback:^BOOL(MGSwipeTableCell * sender){
            
            [weakSelf tableView:weakSelf.brushTable accessoryButtonTappedForRowWithIndexPath:[weakSelf.brushTable indexPathForCell:sender]];
            [sender hideSwipeAnimated:YES];

            return YES;
        }];
        MGSwipeButton *duplicateBtn = [MGSwipeButton buttonWithTitle:nil icon:[MysticIcon iconForType:MysticIconTypeSketchBrushDuplicate size:actionSize color:[UIColor hex:@"8f8a82"]] backgroundColor:[UIColor hex:@"272523"] padding:padding callback:^BOOL(MGSwipeTableCell * sender){
            [weakSelf duplicateBrush:sender];
            [sender hideSwipeAnimated:YES];

            return YES;
        }];
        self.swipeEditBtn = editBtn;
        self.swipeDeleteButton = deleteBtn;
        self.swipeDuplicateBtn = duplicateBtn;
        return @[editBtn, duplicateBtn, deleteBtn];
        
    }
    return nil;
    
}

@end
