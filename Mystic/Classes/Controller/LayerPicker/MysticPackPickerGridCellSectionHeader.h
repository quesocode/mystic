//
//  MysticPackPickerGridCellSectionHeader.h
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPackPickerCellSectionHeader.h"
#import "MysticLayerToolbar.h"
#import "MysticCollectionViewSectionToolbar.h"

@protocol MysticPackPickerGridCellSectionHeaderDelegate <NSObject>

@optional
- (void) collectionViewDidSelectHeader:(id)header sender:(id)sender atIndexPath:(NSIndexPath *)indexPath;
@end

@interface MysticPackPickerGridCellSectionHeader : MysticPackPickerCellSectionHeader <MysticLayerToolbarDelegate>
@property (nonatomic, retain) MysticLayerToolbar *toolbar;
@property (nonatomic, assign) id<MysticCollectionToolbarDelegate, MysticPackPickerGridCellSectionHeaderDelegate> delegate;


@end
