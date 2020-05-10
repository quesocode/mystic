//
//  MysticPackPickerViewController.h
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticImagesCollectionViewController.h"
#import "Mystic.h"
#import "MysticPackPickerGridCellSectionHeader.h"

@class MysticPackPickerViewController;

@protocol MysticPackPickerDelegate <NSObject>

@optional

- (void) packPicker:(MysticPackPickerViewController *)pickerController didSelectPack:(MysticPack *)pack option:(PackPotionOption *)option;
- (void) packPicker:(MysticPackPickerViewController *)pickerController didSelectPack:(MysticPack *)pack;

- (void) packPickerDidCancel:(MysticPackPickerViewController *)pickerController;
@end

@interface MysticPackPickerViewController : MysticImagesCollectionViewController <MysticPackPickerGridCellSectionHeaderDelegate>

@property (nonatomic, assign) MysticCollectionFilter filters;
@property (nonatomic, copy) MysticBlock cancelBlock;
@property (nonatomic, copy) MysticBlockObjObjBOOL selectedBlock;
@property (nonatomic, assign) MysticLayoutStyle layoutStyle;
@property (nonatomic, assign) MysticObjectSelectionType selectionType;
@property (nonatomic, retain) NSArray *packTypes;
@property (nonatomic, retain) PackPotionOption *selectedOption;
@property (nonatomic, retain) MysticPack *selectedPack;
@property (nonatomic, assign) id<MysticPackPickerDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *selectIndexPath;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil layout:(MysticLayoutStyle)layoutStyle types:(NSArray *)theTypes;

@end
