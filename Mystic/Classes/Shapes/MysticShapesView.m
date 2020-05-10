//
//  MysticShapesView.m
//  Mystic
//
//  Created by Me on 11/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticShapesView.h"
#import "MysticResizeableImageView.h"
#import "Mystic.h"
#import "UserPotion.h"

@implementation MysticShapesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.shouldShowGridOnOpen = NO;
    }
    return self;
}
- (Class) optionClass;
{
    return [PackPotionOptionShape class];
}

- (MysticObjectType) objectType;
{
    return MysticObjectTypeShape;
}
- (Class) layerClass;
{
    return [MysticShapeView class];
}
- (id) addNewOverlay:(BOOL)add option:(PackPotionOptionView *)newOption;
{
    CGRect newFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame)-50, CGRectGetHeight(self.frame)-50);
//    newFrame.size.width = MIN(newFrame.size.width, newFrame.size.height);
//    newFrame.size.height = newFrame.size.width;
    newFrame.size.width = MYSTIC_SHAPE_START_WIDTH;
    newFrame.size.height = MYSTIC_SHAPE_START_HEIGHT;

    MysticShapeView *shapeView = [self.controller addNewOverlay:NO option:(id)newOption frame:newFrame];
    
    
    
    return shapeView;
}

- (void)layerViewDidClose:(MysticShapeView *)layerView  notify:(BOOL)shouldNotify;
{
    layerView.option.view = nil;
    layerView.option.shapesView = nil;
    layerView.option = nil;
    [self.controller layerViewDidClose:layerView notify:shouldNotify];
}

- (void)layerViewDidResize:(MysticResizeableLayer *)layerView;
{
    MysticShapeView *shapeLayerView = (MysticShapeView *)layerView;
    [shapeLayerView resize];
}



//- (PackPotionOption *) confirmOverlays:(PackPotionOption *)newOption;
//{
//    MysticObjectType optionType = newOption ? newOption.type : [self objectType];
//    PackPotionOption *oldOption = [UserPotion optionForType:optionType];
//    
//    [UserPotion removeOptionForType:optionType cancel:NO];
//    if(newOption)
//    {
//        [newOption setUserChoice:YES];
//        if(oldOption)
//        {
//            [newOption applyAdjustmentsFrom:oldOption];
//        }
//    }
//    return newOption;
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
