//
//  WDLayerController.h
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2010-2013 Steve Sprang
//

#import "OrientationViewController.h"
#import "WDLayerCell.h"
#import "MGSwipeTableCell.h"
#import "MysticSlider.h"

@class WDActionSheet;
@class WDBar;
@class WDBarItem;
@class WDPainting;
@class WDLayerCell;
@class WDColorSlider;
@class WDBlendModePicker;

@interface WDLayerController : OrientationViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
                                                    WDActionSheetDelegate, WDLayerCellDelegate, MGSwipeTableCellDelegate> {
    IBOutlet UITableView        *layerTable_;
    UITextField                 *activeField_;
    
    // iPhone
    id                          merge_;
    WDBarItem                   *undo_;
    WDBarItem                   *redo_;
    WDBarItem                   *delete_;
    WDBarItem                   *duplicate_;
    WDBarItem                   *add_;

    NSMutableArray              *toolbarItems_;
}

@property (nonatomic, weak) WDPainting *painting;
@property (nonatomic, weak) IBOutlet WDLayerCell *layerCell;
@property (nonatomic, weak) IBOutlet UIView *opacityBorderView;
@property (nonatomic, weak) IBOutlet UIImageView *opacitySliderIcon;
//@property (nonatomic, weak) IBOutlet WDColorSlider *opacitySlider;
@property (nonatomic, weak) IBOutlet MysticSlider *opacitySlider;

@property (nonatomic, weak) IBOutlet UIView *opacityView;
//@property (nonatomic, weak) IBOutlet UILabel *opacityLabel;
@property (nonatomic, weak) IBOutlet WDBlendModePicker *blendModePicker;
@property (nonatomic, readonly) NSMutableSet *dirtyThumbnails;
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) WDBar *topBar;
@property (nonatomic, weak) WDBar *bottomBar;
@property (nonatomic) WDActionSheet *blendModeSheet;
@property (nonatomic, strong) NSIndexPath *previousSelectedIndexPath;
- (void) selectActiveLayer;
- (void) updateOpacity;
- (void) updateBlendMode;
- (void) enableLayerButtons;

@end
