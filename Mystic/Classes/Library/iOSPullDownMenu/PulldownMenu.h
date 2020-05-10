//
//  PulldownMenu.h
//
//  Created by Bernard Gatt
//

#import <UIKit/UIKit.h>

@protocol PulldownMenuDelegate
    -(void)menuItemSelected:(NSIndexPath *)indexPath;
    -(void)pullDownAnimated:(BOOL)open;
-(void)pullDownAnimated:(BOOL)open change:(BOOL)doChange animated:(NSTimeInterval)dur;

@end

@interface PulldownMenu : UIView<UITableViewDataSource, UITableViewDelegate> {
    UITableView *menuList;
    NSMutableArray *menuItems;
    
    UIView *handle;
    UIView *masterView;
    UIPanGestureRecognizer *navigationDragGestureRecognizer;
    UIPanGestureRecognizer *handleDragGestureRecognizer;
    UINavigationController *masterNavigationController;
    UIDeviceOrientation currentOrientation;
    
    float topMargin;
    float tableHeight;
}
@property (nonatomic, assign) NSMutableArray *items;
@property (nonatomic, assign) id<PulldownMenuDelegate> delegate;
@property (nonatomic, retain) UITableView *menuList;
@property (nonatomic, retain) UIView *handle;
@property (nonatomic, retain) UIView *handleContentView;

/* Appearance Properties */
@property (nonatomic, assign) float handleHeight, cellsHeight;
@property (nonatomic, assign) float animationDuration;
@property (nonatomic, assign) float topMarginPortrait;
@property (nonatomic, assign) float topMarginLandscape;
@property (nonatomic, retain) UIColor *cellColor;
@property (nonatomic, retain) UIColor *cellSelectedColor;
@property (nonatomic, retain) UIColor *cellTextColor;
@property (nonatomic, assign) UITableViewCellSelectionStyle cellSelectionStyle;
@property (nonatomic, retain) UIFont *cellFont;
@property (nonatomic, assign) float cellHeight, closeOffset, openOffset;
@property (nonatomic, assign) BOOL fullyOpen;

- (id)initWithNavigationController:(UINavigationController *)navigationController;
- (id)initWithView:(UIView *)view;
- (void)insertButton:(NSString *)title;
- (void)animateDropDown:(BOOL)animated change:(BOOL)doChange;
- (void)loadMenu;
- (void)animateDropDown;
- (NSInteger) sectionForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDictionary *) sectionAtIndexPath:(NSIndexPath *)indexPath;
- (void) reload;
@end
