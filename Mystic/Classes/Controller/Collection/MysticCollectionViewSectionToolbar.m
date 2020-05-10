//
//  MysticCollectionViewSectionToolbar.m
//  Mystic
//
//  Created by Me on 5/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionViewSectionToolbar.h"

@interface MysticCollectionViewSectionToolbar ()

@end


@implementation MysticCollectionViewSectionToolbar


+ (NSString *) cellIdentifier;
{
    static NSString *MysticCollectionViewSectionToolbarHeaderId = @"MysticCollectionViewSectionToolbar";
    return MysticCollectionViewSectionToolbarHeaderId;
}

+ (NSArray *) defaultItemsForFrame:(CGRect)frame;
{
    return nil;
}

- (void) dealloc;
{
    [super dealloc];
    [_info release];
    [_toolbar release];
}
- (id)initWithFrame:(CGRect)frame;
{
    NSArray *theItems = [[self class] defaultItemsForFrame:frame];
//    self = [self initWithFrame:frame items:theItems];
    self = [super initWithFrame:frame];

    if (self) {
        [self commonInitWithItems:theItems];

    }
    return self;
}
- (id)initWithFrame:(CGRect)frame items:(NSArray *)theItems;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInitWithItems:theItems];
    }
    return self;
}

- (void) commonInitWithItems:(NSArray *)theItems;
{
    self.backgroundColor = [UIColor color:MysticColorTypeCollectionToolbarBackground];
    MysticLayerToolbar *toolbar = [MysticLayerToolbar toolbarWithItems:theItems delegate:self height:self.frame.size.height];
    self.toolbar = toolbar;
    [self addSubview:toolbar];
}
- (void) setItems:(NSArray *)theItems;
{
    [self setItems:theItems animated:NO];
}
- (void) setItems:(NSArray *)theItems animated:(BOOL)animated;
{
    [self.toolbar setItemsInput:[self.toolbar items:theItems addSpacing:NO] animated:animated];
}

- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;
{
    switch (toolType) {
        case MysticToolTypeCancel:
        {
            [self toolBarCanceledOption:sender];
            break;
        }
            
        default: break;
    }
    
    if(sender && sender.canSelect)
    {
        [toolbar selectItem:sender];
        if([self.delegate respondsToSelector:@selector(collectionToolbar:didSelect:type:)])
        {
            [self.delegate collectionToolbar:self didSelect:sender type:toolType];
        }
    }
    
    if([self.delegate respondsToSelector:@selector(collectionToolbar:didTouch:type:)])
    {
        [self.delegate collectionToolbar:self didTouch:sender type:toolType];
    }
       
}
- (void) toolBarCanceledOption:(id)sender;
{
    
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
