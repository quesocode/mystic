//
//  MysticBarButtonItem.h
//  Mystic
//
//  Created by Travis on 10/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "Mystic.h"

@interface MysticBarButtonItem : UIBarButtonItem

@property (nonatomic) MysticToolType toolType;
@property (nonatomic) MysticObjectType objectType;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) BOOL selected;
@property(nonatomic, retain) MysticBarButton *customView;
@property (nonatomic, readonly) MysticBarButton *button;
@property (nonatomic, readonly) BOOL flexible;
@property (nonatomic, readonly) CGFloat frameWidth;
+ (MysticIconType) iconColor:(MysticIconType)iconType;
+ (MysticIconType) iconColorHighlighted:(MysticIconType)iconType;
+ (MysticIconType) iconColorSelected:(MysticIconType)iconType;

+ (MysticBarButtonItem *) itemForType:(id)toolTypeOrOptions target:(id)target;
+ (MysticBarButtonItem *) item:(id)customView;

+ (MysticBarButtonItem *) buttonItem:(id)customView;
+ (MysticBarButtonItem *) buttonItemWithIconType:(MysticIconType)iconType color:(id)color action:(MysticBlockSender) action;

+ (MysticBarButtonItem *) moreButtonItem:(MysticBlockSender)action;
+ (MysticBarButtonItem *) moreButtonItem:(id)target action:(SEL)action;
+ (MysticBarButtonItem *) barButtonItem:(ActionBlock) action;
+ (MysticBarButtonItem *) barButtonItemWithTitle:(NSString *)title action:(ActionBlock)action;
+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title target:(id)target sel:(SEL)action;
+ (MysticBarButtonItem *) confirmButtonItem:(MysticBlockSender) action;
+ (MysticBarButtonItem *) cancelButtonItem:(MysticBlockSender) action;
+ (MysticBarButtonItem *) barButtonItemWithImage:(UIImage *)image action:(ActionBlock) action;
+ (MysticBarButtonItem *) backButtonItem:(id)titleOrImg action:(ActionBlock)action;
+ (MysticBarButtonItem *) forwardButtonItem:(ActionBlock)action;
+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title action:(ActionBlock)action;
+ (MysticBarButtonItem *) forwardButtonItem:(id)titleOrImg action:(ActionBlock)action;
+ (MysticBarButtonItem *) backButtonItem:(ActionBlock) action;
+ (MysticBarButtonItem *) backButtonItemWithTarget:(id)target action:(SEL)action;
+ (MysticBarButtonItem *) barButtonItemWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
+ (MysticBarButtonItem *) buttonItemWithTitle:(NSString *)title senderAction:(MysticBlockSender)action;
+ (MysticBarButtonItem *) buttonItem:(id)titleOrImg senderAction:(MysticBlockSender)action;
+ (MysticBarButtonItem *) confirmButtonItemWithTarget:(id)target sel:(SEL)action;
+ (MysticBarButtonItem *) cancelButtonItemWithTarget:(id)target sel:(SEL)action;
+ (MysticBarButtonItem *) clearButtonItemWithImage:(UIImage *)image action:(ActionBlock)action;
+ (MysticBarButtonItem *) clearSwitchButtonItemTurned:(BOOL)isOn onImage:(UIImage *)onImage offImage:(UIImage *)offImage action:(MysticBlockSender)action;
+ (MysticBarButtonItem *) slideOutButtonItem:(ActionBlock)action;
+ (MysticBarButtonItem *) emptyItem;
+ (MysticBarButtonItem *) closeButtonItem:(ActionBlock)action;
+ (MysticBarButtonItem *) camButtonItem:(ActionBlock)action;
+ (MysticBarButtonItem *) infoButtonItem:(MysticBlockSender)action;
+ (MysticBarButtonItem *) questionButtonItem:(MysticBlockSender)action;



@end
