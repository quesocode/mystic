//
//  MysticLayerPanelBaseView.h
//  Mystic
//
//  Created by Me on 2/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MysticConstants.h"
#import "MysticLayerToolbar.h"
#import "MysticPanelView.h"

@class PackPotionOption, MysticPanelObject;

@interface MysticLayerPanelBaseView : MysticPanelView

- (void) updateWithTargetOption:(PackPotionOption *)option;
+ (NSArray *) sectionsForOption:(PackPotionOption *)theOption;
+ (NSArray *) tabsForOption:(PackPotionOption *)theOption;
+ (NSArray *) tabsForOption:(PackPotionOption *)option type:(MysticObjectType)objectType;
+ (MysticPanelType) sectionTypeForSetting:(MysticObjectType)setting option:(PackPotionOption *)option;

+ (NSArray *) toolbarItemsForSection:(MysticPanelObject *)section type:(MysticObjectType)objectType target:(id)target toolbar:(MysticLayerToolbar *)toolbar;


+ (NSInteger) activeTabForOption:(PackPotionOption *)theOption;
+ (void) resetToolbarForSection:(MysticPanelObject *)section target:(id)target toolbar:(MysticLayerToolbar *)toolbar;

@end
