//
//  PackPotionOptionView.h
//  Mystic
//
//  Created by Me on 12/2/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "PackPotionOptionLayer.h"

@class MysticOverlaysView, MysticLayerBaseView;

@interface PackPotionOptionView : PackPotionOptionLayer
{
    UIColor *_color;
}

@property (nonatomic, retain) MysticLayerBaseView* view;
@property (nonatomic, retain) MysticOverlaysView *overlaysView;
@property (nonatomic, retain) id content;
@property (nonatomic, retain) PackPotionOptionColor *colorOption;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) BOOL isManager;
@property (nonatomic, assign) PackPotionOptionView *manager;
@property (nonatomic, readonly) UIView *theView;
@property (nonatomic, retain) UIImage *viewImage, *previewImage;
@property (nonatomic, assign) MysticAlignPosition alignment;

+ (id) parentOption;
- (id) setupWithOption:(PackPotionOption *)option makeLayer:(BOOL)createNewObject;
- (UIImage *) prepareViewImage;
- (UIImage *) prepareViewImage:(CGSize)atSize;
- (UIImage *) prepareViewImageComplete:(MysticBlockObjObj)completed;
- (UIImage *) prepareViewImage:(CGSize)atSize complete:(MysticBlockObjObj)completed;

@end


