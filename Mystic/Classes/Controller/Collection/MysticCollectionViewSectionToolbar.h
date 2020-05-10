//
//  MysticCollectionViewSectionToolbar.h
//  Mystic
//
//  Created by Me on 5/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mystic.h"
#import "MysticLayerToolbar.h"

@class MysticCollectionViewSectionToolbar, MysticLayerToolbar;

@protocol MysticCollectionToolbarDelegate <NSObject>

@optional
- (void) collectionToolbar:(MysticCollectionViewSectionToolbar *)toolbar didCancel:(id)sender;
- (void) collectionToolbar:(MysticCollectionViewSectionToolbar *)toolbar didTouch:(id)sender type:(MysticToolType)toolType;
- (void) collectionToolbar:(MysticCollectionViewSectionToolbar *)toolbar didSelect:(id)sender type:(MysticToolType)toolType;

@end






@interface MysticCollectionViewSectionToolbar : UICollectionViewCell <MysticLayerToolbarDelegate>

@property (nonatomic, retain) NSDictionary *info;
@property (nonatomic, assign) id<MysticCollectionToolbarDelegate> delegate;
@property (nonatomic, retain) MysticLayerToolbar *toolbar;
@property (nonatomic, assign) NSArray *items;
+ (NSString *) cellIdentifier;
+ (NSArray *) defaultItemsForFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame items:(NSArray *)theItems;
- (void) setItems:(NSArray *)theItems animated:(BOOL)animated;
- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;



@end
