//
//  MysticLayerPanelViewController.h
//  Mystic
//
//  Created by Me on 3/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticViewController.h"
#import "Mystic.h"
#import "MysticLayerPanelView.h"
#import "GPUImage.h"
#import "UserPotion.h"

@interface MysticLayerPanelViewController : MysticViewController


@property (nonatomic, retain) NSMutableDictionary *selectedItemIndexes;
@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) MysticLayerPanelView *layerPanelView;
@property (nonatomic, readonly) MysticController *controller;
@property (nonatomic, assign) BOOL ignoreStateChanges;
@property (nonatomic, readonly) BOOL layerPanelIsVisible;

- (id) initWithFrame:(CGRect)frame delegate:(id)delegate;
- (MysticLayerPanelView *) showLayerPanel:(BOOL)opened info:(NSDictionary *)__options;
- (NSInteger) lastSelectedItemIndexForOption:(PackPotionOption *)option type:(MysticObjectType)objectType;
- (void) setLastSelectedItemIndex;
- (void) removeLastSelectedIndexesForOption:(PackPotionOption *)option;
- (id) buildToolbar;
- (id) toolbarForSection:(MysticPanelObject *)section;
- (id) layerPanel:(MysticLayerPanelView *)panelView sectionDidChange:(MysticPanelObject *)section;
- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionIsReadyBlock:(MysticPanelObject *)section;
- (MysticBlock) layerPanelStateChangeAnimationBlock:(MysticLayerPanelView *)panelView state:(MysticLayerPanelState)state;
- (void) panelClosed;
- (void) updateToolbar:(MysticLayerToolbar *)toolbar panel:(MysticPanelObject *)panelObj option:(PackPotionOption *)option;
- (MysticPanelObject *) pushPanel:(MysticPanelType)sectionType setting:(MysticObjectType)__itemType;

@end
