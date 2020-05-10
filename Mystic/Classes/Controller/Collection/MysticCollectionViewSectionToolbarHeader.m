//
//  MysticCollectionViewSectionToolbarHeader.m
//  Mystic
//
//  Created by Me on 5/7/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewSectionToolbarHeader.h"



@interface MysticCollectionViewSectionToolbarHeader ()
{
    
}


@end



@implementation MysticCollectionViewSectionToolbarHeader

+ (NSString *) cellIdentifier;
{
    static NSString *MysticCollectionViewSectionToolbarHeaderId = @"MysticCollectionViewSectionToolbarHeader";
    return MysticCollectionViewSectionToolbarHeaderId;
}


+ (NSArray *) defaultItemsForFrame:(CGRect)frame;
{
    
    id icnSize = [NSValue valueWithCGSize:CGSizeMake(40, 40)];
    NSArray *theItems = @[
                          @{@"toolType": @(MysticToolTypeStatic),
                            //@"width":@(-15)},
                            @"width":@(30)},
                          

                          
                          @(MysticToolTypeFlexible),

                          
                          @{@"toolType": @(MysticToolTypeAll),
                            @"iconType":@(MysticIconTypeToolBarAll),
                            @"selected": @YES,
                            @"canSelect": @YES,
                            @"color":@(MysticColorTypeCollectionToolbarIcon),
                            @"colorSelected": @(MysticColorTypeCollectionToolbarIconSelected),
                            @"colorHighlighted":@(MysticColorTypeCollectionToolbarIconHighlighted),
                            @"iconSize": icnSize,
                            @"width":@(frame.size.height+10),},
                          
                          
                          @(MysticToolTypeFlexible),
                          
                          
                          
                          @{@"toolType": @(MysticToolTypeRecents),
                            @"iconType":@(MysticIconTypeToolBarRecents),
                            @"color":@(MysticColorTypeCollectionToolbarIcon),
                            @"canSelect": @YES,
                            @"colorHighlighted":@(MysticColorTypeCollectionToolbarIconHighlighted),
                            @"colorSelected": @(MysticColorTypeCollectionToolbarIconSelected),
                            @"iconSize": icnSize,
                            @"width":@(frame.size.height+10),},
                          
                          
                          @(MysticToolTypeFlexible),

                          
                          @{@"toolType": @(MysticToolTypeStatic),
                            //@"width":@(-15)},
                            @"width":@(30)},

                          
                          ];
    return theItems;
}

- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;
{
    [super toolbar:toolbar itemTouched:sender toolType:toolType event:event];

//    switch (toolType)
//    {
//        case MysticToolTypeAll:
//        {
//            DLog(@"all touched: %@", MBOOL(sender.selected));
//            break;
//        }
//        case MysticToolTypeRecents:
//        {
//            DLog(@"recents touched: %@ | can: %@", MBOOL(sender.selected), MBOOL(sender.canSelect));
//            break;
//        }
//            
//        default:
//            break;
//    }
    

}

- (void) toolBarCanceledOption:(id)sender;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(collectionToolbar:didCancel:)])
    {
        [self.delegate collectionToolbar:self didCancel:YES];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
