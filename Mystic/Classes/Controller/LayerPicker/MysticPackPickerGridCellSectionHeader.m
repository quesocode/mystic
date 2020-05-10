//
//  MysticPackPickerGridCellSectionHeader.m
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPackPickerGridCellSectionHeader.h"
#import "MysticPackPickerGridItem.h"

@interface MysticPackPickerGridCellSectionHeader ()
{
    
}

@end



@implementation MysticPackPickerGridCellSectionHeader

- (void) commonStyle;
{
    [super commonStyle];
    
//    MysticLayerToolbar *toolbar = [MysticLayerToolbar toolbarWithItems:nil delegate:self height:self.frame.size.height];
//    self.toolbar = toolbar;
//    [self addSubview:toolbar];
    
}
- (void) setCollectionItem:(MysticPackPickerGridItem *)collectionItem;
{
    [super setCollectionItem:collectionItem];
    
    /*
    
    CGRect fframe = self.frame;
    id icnSize = [NSValue valueWithCGSize:CGSizeMake(30, 30)];
    NSArray *theItems = @[
                          @{@"toolType": @(MysticToolTypeStatic),
                            @"width":@(-15)},
                          
                          
                          
                          
                          
                          @{@"toolType": @(MysticToolTypeList),
                            @"iconType":@(MysticIconTypeSkinnyMenu),
                            @"color":@(MysticColorTypeCollectionToolbarIcon),
                            @"colorSelected": @(MysticColorTypeCollectionToolbarIconSelected),
                            @"colorHighlighted":@(MysticColorTypeCollectionToolbarIconHighlighted),
                            @"iconSize": icnSize,
                            @"width":@(fframe.size.height+10),},
                          
                          
                          @(MysticToolTypeFlexible),
                          
                          
                          
                          @{@"toolType": @(MysticToolTypeCancel),
                            @"iconType":@(MysticIconTypeSkinnyX),
                            @"color":@(MysticColorTypeCollectionToolbarIcon),
                            @"colorHighlighted":@(MysticColorTypeCollectionToolbarIconHighlighted),
                            @"colorSelected": @(MysticColorTypeCollectionToolbarIconSelected),
                            @"iconSize": icnSize,
                            @"width":@(fframe.size.height+10),},
                          
                          
                          
                          
                          @{@"toolType": @(MysticToolTypeStatic),
                            @"width":@(-15)},
                          
                          ];
    
    [self.toolbar setItemsInput:[self.toolbar items:theItems addSpacing:NO]];
    
    */
    
}

//- (void) setShowBorder:(BOOL)showBorder;
//{
//    [super setShowBorder:showBorder];
//    CGRect tbFrame = self.toolbar.frame;
//    
//    tbFrame = self.titleLabel.frame;
//    self.toolbar.frame = tbFrame;
//}
- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;
{
    if([self.delegate respondsToSelector:@selector(collectionToolbar:didTouch:type:)])
    {
        [self.delegate collectionToolbar:(id)self didTouch:sender type:toolType];
    }
}

- (void) didTouch:(id)sender;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(collectionViewDidSelectHeader:sender:atIndexPath:)])
    {
        [self.delegate collectionViewDidSelectHeader:self sender:sender atIndexPath:self.indexPath];
    }
}
@end
