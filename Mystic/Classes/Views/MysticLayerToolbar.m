//
//  MysticLayerToolbar.m
//  Mystic
//
//  Created by Travis on 10/16/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticLayerToolbar.h"
#import "MysticToggleButton.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
@interface MysticLayerToolbar ()
@end
@implementation MysticLayerToolbar

@synthesize delegate=__delegate, objectType=_objectType, oldItems=_oldItems, itemsInput, targetOption=_targetOption, state=_state;
+ (NSArray *) defaultItems;
{
    return [[self class] defaultItemsWithHeight:MYSTIC_UI_TOOLBAR_HEIGHT];
}
+ (NSArray *) defaultItemsWithHeight:(CGFloat)height;
{
    return [[self class] defaultItemsWithDelegate:nil height:height];
}
+ (NSArray *) defaultItemsWithDelegate:(id)delegate height:(CGFloat)height;
{
    return [[self class] defaultItemsWithDelegate:delegate toolbar:Nil height:height];

}
+ (NSArray *) defaultItemsWithDelegate:(id)delegate toolbar:(MysticLayerToolbar *)toolbar height:(CGFloat)height;
{
    return @[];

}
+ (NSArray *) defaultItemsWithDelegate:(id)delegate;
{
    return [[self class] defaultItemsWithDelegate:delegate height:MYSTIC_UI_TOOLBAR_HEIGHT];
}
+ (MysticLayerToolbar *) toolbar;
{
    MysticLayerToolbar *toolbar = [[[self class] alloc] initWithItems:[[self class] defaultItems]];
    return [toolbar autorelease];
}
+ (id) toolbarWithFrame:(CGRect)frame;
{
    id toolbar = [[[self class] alloc] initWithFrame:frame];
    
    return [toolbar autorelease];
}

+ (id) toolbarWithDelegate:(id)delegate height:(CGFloat)height;
{
    NSArray *items = [[self class] defaultItemsWithDelegate:delegate height:height];
    return [[self class] toolbarWithItems:items delegate:delegate height:height];
    
}
+ (id) toolbarWithHeight:(CGFloat)height;
{
    MysticLayerToolbar *toolbar = [[[self class] alloc] initWithItems:[[self class] defaultItemsWithHeight:height > 0 ? height : MYSTIC_UI_TOOLBAR_HEIGHT]];
    return [toolbar autorelease];
}
+ (id) toolbarWithItems:(NSArray *)theItems;
{
    return [[self class] toolbarWithItems:theItems delegate:nil];
}
+ (id) toolbarWithItems:(NSArray *)theItems delegate:(id)delegate;
{
    return [[self class] toolbarWithItems:theItems delegate:delegate height:MYSTIC_UI_TOOLBAR_HEIGHT];
}
+ (id) toolbarWithItems:(NSArray *)theItems delegate:(id)delegate height:(CGFloat)height;
{
    MysticLayerToolbar *toolbar = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, [MysticUI bounds].size.width, height) items:theItems];
    toolbar.delegate = delegate;
    return [toolbar autorelease];
}
+ (id) toolbarForObjectType:(MysticObjectType)objectType delegate:(id)delegate;
{
    return [[self class] toolbarForObjectType:objectType info:nil delegate:delegate];
}
+ (id) toolbarForObjectType:(MysticObjectType)objectType info:(NSDictionary *)info delegate:(id)delegate;
{
    NSArray *tools;
    switch (objectType) {
        case MysticObjectTypeBadge:
            tools = @[
                      @(MysticToolTypeFlexible),
                      @(MysticToolTypeColor),
                      @(MysticToolTypeFlexible),

                      ];
            break;
        case MysticObjectTypeDesign:
        case MysticObjectTypeText:
            tools = @[
                      @(MysticToolTypeFlexible),
                      @(MysticToolTypeColor),
                      @(MysticToolTypeFlexible),
                      ];
            break;
        case MysticObjectTypeFrame:
            tools = @[
                      @(MysticToolTypeFlexible),
                      @(MysticToolTypeVariant),
                      @(MysticToolTypeFlexible),
                      ];
            break;
        case MysticObjectTypeLight:
            tools = @[
                      @(MysticToolTypeFlexible),
                      @(MysticToolTypeVariant),
                      @(MysticToolTypeFlexible),
                      @(MysticToolTypeIntensity),
                      @(MysticToolTypeFlexible),
                      ];
            break;
        case MysticObjectTypeTexture:
            tools = @[
                      @(MysticToolTypeFlexible),
                      @(MysticToolTypeVariant),
                      @(MysticToolTypeFlexible),
                      ];
            break;
        case MysticObjectTypeFilter:
            tools = @[
                      @(MysticToolTypeFlexible),
                      @(MysticToolTypeIntensity),
                      @(MysticToolTypeFlexible),
                      ];
            break;
        case MysticObjectTypeSetting:
            tools = @[
                      @(MysticToolTypeFlexible),
                      @(MysticToolTypeReset),
                      @(MysticToolTypeFlexible),
                      ];
            break;
        default:
            tools = [NSArray array];
            break;
    }
    
    MysticLayerToolbar *toolbar = [[self class] toolbarWithItems:tools delegate:delegate];
    toolbar.objectType = objectType;
    return toolbar;
}
- (void) dealloc;
{
    
    [_oldItems release];
    __delegate = nil;
    [_targetOption release];
    [_titleToggleView release];
    
    [super dealloc];
    

}

- (id) initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self commonInit];
    }
    return self;
}
- (id) initWithItems:(NSArray *)theItems;
{
    return [self initWithFrame:CGRectMake(0, 0, [MysticUI bounds].size.width, MYSTIC_UI_TOOLBAR_HEIGHT) items:theItems];
}
- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self commonInit];
    }
    return self;
}
- (id) initWithFrame:(CGRect)frame delegate:(id)theDelegate;
{
    self = [self initWithFrame:frame];
    if(self)
    {
        self.delegate = theDelegate;
    }
    return self;
}
- (id) initWithFrame:(CGRect)frame items:(NSArray *)theItems;
{
    self = [self initWithFrame:frame];
    if(self)
    {
        [self setItemsInput:[self items:theItems addSpacing:NO] animated:NO];
    }
    return self;
}
- (void) commonInit;
{
    __delegate = self;
    _titleBorderHidden = YES;
    _useLayout = YES;
    self.tag = MysticViewTypeToolbarLayer;
    self.margin = MYSTIC_UI_TOOLBAR_MARGIN;
    self.clipsToBounds = YES;
    self.titleToggleIndex = NSNotFound;

}
- (void) setMargin:(CGFloat)margin;
{
    _margin = margin;
    [self setNeedsLayout];
}
- (void) selectItem:(MysticBarButton *)sender;
{
    if(sender && !sender.canSelect) return;
    if(sender)
    {
        UIImage *selectedImg = [sender imageForState:UIControlStateSelected];
        UIImage *normalImg = [sender imageForState:UIControlStateNormal];
        if(normalImg && [normalImg isEqual:selectedImg])
        {
            UIImage *newSelectedImg = [MysticImage image:normalImg withColor:@(MysticColorTypePink)];
            [sender setImage:newSelectedImg forState:UIControlStateSelected];
        }
    }
    for (MysticBarButtonItem *item in self.items) {
        if(sender && [item.customView isEqual:sender]) continue;
        MysticBarButton *button = item.button;
        if(button && [button respondsToSelector:@selector(setSelected:)]) button.selected = NO;
    }
    sender.selected = YES;
    
}
- (void) useItems:(NSArray *)theItems;
{
    [self useItems:theItems animated:self.items.count ? YES : NO];
}
- (void) useItems:(NSArray *)theItems animated:(BOOL)animated;
{
    [self setItemsInput:[self items:theItems addSpacing:NO] animated:animated];

}
- (void) setItemsInput:(NSArray *)theItems;
{
    [self setItemsInput:theItems animated:YES];
}
- (void) setItemsInput:(NSArray *)theItems animated:(BOOL)animated;
{
    if(theItems && theItems.count)
    {
        [self setItems:theItems animated:animated];
    }
}
- (NSArray *) items:(NSArray *)theItems addSpacing:(BOOL)addSpacing;
{
    return [self items:theItems spacing:addSpacing margin:YES];
}
- (NSArray *) items:(NSArray *)theItems spacing:(BOOL)addSpacing margin:(BOOL)addMargins;
{
    NSMutableArray *__items = [NSMutableArray array];

    if(theItems && theItems.count)
    {
        
        MysticBarButtonItem *item;
        if(addSpacing && addMargins)
        {
            item = [[self itemClass] itemForType:@(MysticToolTypeFlexible) target:self];
            if(item) [__items addObject:item];
        }
        int i = 0;
        for (id itemInfo in theItems) {
            
            item = [itemInfo isKindOfClass:[UIBarButtonItem class]] ? itemInfo : [[self itemClass] itemForType:itemInfo target:self];
            
           if(item) [__items addObject:item];
            
            if(addSpacing && (addMargins || (i != theItems.count - 1)))
            {
                item = [[self itemClass] itemForType:@(MysticToolTypeFlexible) target:self];
                [__items addObject:item];
            }
            i++;
        }
    }
    return __items;
}
- (BOOL) activeToggleTitleIsNew; { return [self.activeToggleTitleView isKindOfClass:self.toggleTitleViewClass]; }
- (void) setTitleToggleView:(MysticBarButtonItem *)titleToggleView;
{
    if(_titleToggleView == nil) self.toggleTitleViewClass = titleToggleView.customView.class;
    if(_titleToggleView) { [_titleToggleView release]; _titleToggleView = nil; }
    _titleToggleView = [titleToggleView retain];
}
- (void) toggleTitleView:(BOOL)animated complete:(MysticBlockObjObjObj)completed;
{
    if(!self.titleToggleView || self.titleToggleIndex == NSNotFound) { if(completed) completed(nil,nil,self); return; }
    self.hasToggled = !self.hasToggled;
    NSMutableArray *theItems = [NSMutableArray arrayWithArray:self.items];
    MysticBarButtonItem *newTitle = [self.titleToggleView retain];
    MysticBarButtonItem *oldTitle = (id)[[theItems objectAtIndex:self.titleToggleIndex] retain];
    [theItems replaceObjectAtIndex:self.titleToggleIndex withObject:self.titleToggleView];

    if(animated && oldTitle)
    {
        __unsafe_unretained __block MysticLayerToolbar *weakSelf = [self retain];
        __unsafe_unretained __block NSArray *_theItems = [theItems retain];
        __unsafe_unretained __block MysticBlockObjObjObj _c = completed ? Block_copy(completed) : nil;
        [MysticUIView animate:0.3 animations:^{
            oldTitle.customView.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf setItems:[_theItems autorelease] animated:NO];
            weakSelf.titleToggleView.customView.alpha = 0;
            [MysticUIView animate:0.3 animations:^{
                weakSelf.titleToggleView.customView.alpha = 1;
            } completion:^(BOOL finished2) {
                weakSelf.titleToggleView = oldTitle;
                if(_c)
                {
                    _c(newTitle.customView, oldTitle.customView, weakSelf);
                    Block_release(_c);
                }
                [newTitle autorelease];
                [oldTitle autorelease];
                [weakSelf release];
            }];
        }];
        return;
    }
    
    [self setItems:theItems animated:animated];
    self.titleToggleView = oldTitle;
    if(completed) completed(newTitle.customView,oldTitle.customView,self);
    [oldTitle autorelease];
    [newTitle autorelease];
}
- (void) replaceItemAtIndex:(NSUInteger)itemIndex view:(UIView *)view completion:(MysticBlock)complete;
{
    
}
- (UIView *) toggleTitleViewReplacement;
{
    if(self.titleToggleIndex == NSNotFound || self.items.count <= self.titleToggleIndex) return nil;
    return self.activeToggleTitleIsNew ? self.activeToggleTitleView : self.titleToggleView.customView;
}
- (UIView *) activeToggleTitleView;
{
    if(self.titleToggleIndex == NSNotFound || self.items.count <= self.titleToggleIndex) return nil;
    MysticBarButtonItem *item = (id)[self.items objectAtIndex:self.titleToggleIndex];
    return item ? item.customView : nil;
}
- (id) makeItemWithInfo:(NSDictionary *)itemInfo;
{
    if(!itemInfo) return nil;
    return [[self itemClass] itemForType:itemInfo target:self];
}
- (NSArray *) restoreItems;
{
    return [self restoreItemsAnimated:YES];
}
- (NSArray *) restoreItemsAnimated:(BOOL)animated;
{
    if(self.oldItems)
    {
        NSArray *newItems = [self.oldItems retain];
        [self replaceItems:newItems animated:animated];
        [newItems release];
    }
    return self.items;
}
- (NSArray *) replaceItemsWithInfo:(NSArray *)newItems animated:(BOOL)animated;
{
    NSArray *itms = [self items:newItems addSpacing:NO];
    return [self replaceItems:itms animated:animated];
}
- (NSArray *) replaceItems:(NSArray *)newItems;
{
    return [self replaceItems:newItems animated:YES];
}
- (NSArray *) replaceItems:(NSArray *)newItems animated:(BOOL)animated;
{
    self.oldItems = self.items;
    [self setItems:newItems animated:animated];
    return self.oldItems;
}
- (void) setBackgroundColor:(UIColor *)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    for (UIView *view in self.subviews) {
        if([view isKindOfClass:[UIImageView class]] && view.frame.size.height < 1)
        {
            if(![view.backgroundColor isEqualToColor:backgroundColor]) view.backgroundColor = backgroundColor;
        }
    }
}
- (void) addSubview:(UIView *)view;
{
    if([view isKindOfClass:[UIImageView class]] && view.frame.size.height < 1)
    {
        if(![view.backgroundColor isEqualToColor:self.backgroundColor]) view.backgroundColor = self.backgroundColor;
        return;
    }
    [super addSubview:view];
}
- (Class) itemClass;
{
    return [MysticBarButtonItem class];
}
- (void) setObjectType:(MysticObjectType)objectType;
{
    _objectType =objectType;
    for (MysticBarButtonItem *item in self.items) {
        item.objectType = objectType;
    }
}
- (void) addItem:(id)item;
{
    NSMutableArray *__items = [NSMutableArray arrayWithArray:self.items];
    
    if([item isKindOfClass:[UIBarButtonItem class]])
    {
        [__items addObject:item];
    }
    else
    {
        UIBarButtonItem *newItem = [[[UIBarButtonItem alloc] initWithCustomView:item] autorelease];
        [__items addObject:newItem];
//        [newItem release];

    }
    if(self.items.count != __items.count)
    {
        [self setItems:__items animated:YES];
    }
}
- (MysticBarButton *) buttonForType:(MysticToolType)toolType;
{
    MysticBarButtonItem *item = [self itemForType:toolType];
    if(item)
    {
        return (MysticBarButton *)item.customView;
    }
    return nil;
}
- (MysticBarButtonItem *) itemForType:(MysticToolType)toolType;
{
    for (MysticBarButtonItem *item in self.items) {
        if(![item isKindOfClass:[MysticBarButtonItem class]]) continue;

        if(item.toolType==toolType) return item;
    }
    return nil;
}

- (void) itemTouched:(MysticBarButton *)sender event:(id)event;
{
    if(self.onChange) return self.onChange(sender,event,self);
    if([self.delegate respondsToSelector:@selector(toolbar:itemTouched:toolType:event:)])
        [self.delegate toolbar:self itemTouched:sender toolType:sender.toolType event:event];
    
}
- (void) itemTapped:(MysticBarButton *)sender;
{
    if(self.onChange) return self.onChange(sender,nil,self);
    if([self.delegate respondsToSelector:@selector(toolbar:itemTouched:toolType:event:)])
        [self.delegate toolbar:self itemTouched:sender toolType:sender.toolType event:UIControlEventTouchUpInside];

}
- (void) itemTouchDown:(MysticBarButton *)sender;
{
    
//    [self.delegate toolbar:self itemTouched:sender toolType:sender.toolType event:UIControlEventTouchDown];
    
}
- (void) itemTouchDownRepeat:(MysticBarButton *)sender;
{
    if([self.delegate respondsToSelector:@selector(toolbar:itemTouched:toolType:event:)])
        [self.delegate toolbar:self itemTouched:sender toolType:sender.toolType event:UIControlEventTouchDownRepeat];
    
}
- (void) itemDoubleTapped:(MysticBarButton *)sender;
{
    if([self.delegate respondsToSelector:@selector(toolbar:itemDoubleTapped:toolType:)])
    {
        [self.delegate toolbar:self itemDoubleTapped:sender toolType:sender.toolType];
    }
}
- (MysticControl *)controlForItem:(MysticBarButtonItem *)item;
{
    MysticControl *control = nil;
    switch (item.toolType) {
        
        default:
        {
            control = (MysticControl *)item.customView;
            break;
        }
    }
    return control;
}
- (NSArray *) spacingItems;
{
    NSMutableArray *nitems = [NSMutableArray array];
    for (MysticBarButtonItem *item in self.items) {
        if(![item isKindOfClass:[MysticBarButtonItem class]]) continue;

        MysticToolType toolType = item.toolType;
        switch (toolType) {
            case MysticToolTypeFlexible:
                [nitems addObject:item];
                break;
                
            default: break;
        }
        
    }
    return nitems;
}
- (NSArray *) nonSpacingItems;
{
    NSMutableArray *nitems = [NSMutableArray array];
    for (MysticBarButtonItem *item in self.items) {
        if(![item isKindOfClass:[MysticBarButtonItem class]])
        {
            if([item isKindOfClass:[UIBarButtonItem class]])
            {
                if(item.width <= 0 && item.customView)
                {
                    [nitems addObject:item];
                }
            }
            
        }
        else
        {
            MysticToolType toolType = item.toolType;
            switch (toolType) {
                case MysticToolTypeFlexible:
                    
                    break;
                    
                default:
                    [nitems addObject:item];
                    break;
            }
        }
        
    }
    return nitems;
}
- (NSArray *) flexibleItems;
{
    NSMutableArray *nitems = [NSMutableArray array];
    for (MysticBarButtonItem *item in self.items) {
        if(![item isKindOfClass:[MysticBarButtonItem class]])
        {
            if([item isKindOfClass:[UIBarButtonItem class]])
            {
                if(item.width <= 0 && !item.customView)
                {
                    [nitems addObject:item];
                }
            }
        
        }
        else
        {
            MysticToolType toolType = item.toolType;
            switch (toolType) {
                case MysticToolTypeFlexible:
                    break;
                    
                default:
                    if(item.flexible)
                    {
                        [nitems addObject:item];
                    }
                    break;
            }
        }
        
    }
    return nitems;
}
- (NSArray *) nonFlexibleItems;
{
    NSMutableArray *nitems = [NSMutableArray array];
    for (MysticBarButtonItem *item in self.items) {
        if(![item isKindOfClass:[MysticBarButtonItem class]])
        {
            if([item isKindOfClass:[UIBarButtonItem class]])
            {
                if(item.width > 0)
                {
                    [nitems addObject:item];
                }
            }
            
        }
        else
        {        MysticToolType toolType = item.toolType;
        switch (toolType) {
            case MysticToolTypeFlexible:
                break;
                
            default:
                if(item.flexible)
                {
                    [nitems addObject:item];
                }
                break;
        }
        }
    }
    return nitems;
}
- (void) layoutSubviews;
{
    if(self.useLayout && self.flexibleItems.count)
    {
        CGFloat staticWidth = 0;
        CGFloat gapWidth = self.margin * (self.nonSpacingItems.count + 1);
        NSMutableArray *flexs = [NSMutableArray array];
        
        
        
        for (MysticBarButtonItem *item in self.nonSpacingItems) {
            
            if(item.flexible) [flexs addObject:item];
            else staticWidth+=item.width;
        }
        CGFloat availableWidth = self.frame.size.width - gapWidth;

        
        if(flexs.count)
        {
            CGFloat leftWidth = (availableWidth - staticWidth) / flexs.count;
            int i = 0;
            for (MysticBarButtonItem *item in flexs) {
                if(item.flexible) { item.width = leftWidth; }
                i++;
            }
        }
    }
    [super layoutSubviews];
}
- (void) setTargetOption:(PackPotionOption *)targetOption;
{
    if(targetOption && (!_targetOption || (_targetOption && ![targetOption isEqual:_targetOption] )))
    {
        [_targetOption release], _targetOption=nil;
        _targetOption = targetOption ? [targetOption retain] : nil;
        [self updateToolsWithOption:_targetOption];
    }
    
}
- (void) updateToolsWithOption:(PackPotionOption *)option;
{
    for (MysticBarButtonItem *item in self.items) {
        switch (item.toolType) {
            case MysticToolTypeVariant:
            {
                MysticToggleButton *toggler = (MysticToggleButton *)item.customView;
                if(option)
                {
                    if(option.layerEffect != toggler.toggleState)
                    {
                        toggler.toggleState = option.layerEffect;
                    }
                }
                else
                {
                    if(toggler.minToggleState != toggler.toggleState)
                    {
                        toggler.toggleState = toggler.minToggleState;
                    }
                }
                break;
            }
            default: break;
        }
    }
}

- (id) itemViewWithTag:(NSInteger)tag;
{
    MysticBarButtonItem *item = [self itemWithTag:tag];
    return [item respondsToSelector:@selector(customView)] ? item.customView : item;
}
- (id) itemWithTag:(NSInteger)itemTag;
{
    id theItem = [super itemWithTag:itemTag];
    if(!theItem) for (MysticBarButtonItem *item in self.items) if(item.toolType == itemTag) return item;
    return theItem;
}



- (void) setTitleEnabled:(BOOL)enabled;
{
    MysticBarButton *_label = (MysticBarButton *)[self viewWithTag:MysticUITypeLabel];
    if(_label)
    {
        _label.enabled = enabled;
    }
}
- (void) setTitle:(NSString *)value;
{
    [self setTitle:value animated:YES];
}
- (void) setTitle:(NSString *)value animated:(BOOL)animated;
{
    
    [self setTitle:value duration:animated ? 0.2 : 0];
}
- (void) setTitle:(NSString *)value duration:(NSTimeInterval)dur
{
    MysticBarButton *_label = (MysticBarButton *)[self viewWithTag:MysticUITypeLabel];
    __unsafe_unretained __block NSString *_value = [[value uppercaseString] retain];
    
    __block CGRect borderFrame = CGRectZero;

    if(_label && _value)
    {
        BOOL skip = YES;
        MysticToolbarTitleButton *__tlabel = nil;
        if([_label isKindOfClass:[MysticToolbarTitleButton class]])
        {
            __tlabel = (id)_label;
            
        }
        NSAttributedString *cTitleAttr = [_label attributedTitleForState:UIControlStateNormal];
        if(__tlabel)
        {
            skip = __tlabel.titleLabel.attributedText == nil ? NO : skip;
        }
        NSString *cTitle = [cTitleAttr string];
        skip = skip && cTitle && [cTitle isEqualToString:_value];
        
        if(skip)
        {
            [_value release];
            return;
        }
        
        
        if(dur <= 0 || ![_label attributedTitleForState:UIControlStateNormal] )
        {

            if(__tlabel) __tlabel.ready = YES;
            if(dur <= 0) _label.alpha = 1;
            NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:_value];
            [attrStr setFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
            [attrStr setCharacterSpacing:MYSTIC_UI_LABEL_BTN_CHAR_SPACE];
            [attrStr addAttribute:NSForegroundColorAttributeName
                           value:[UIColor color:MysticColorTypeMenuText]
                           range:NSMakeRange(0, _value.length)];
            
            [attrStr setTextAlignment:kCTCenterTextAlignment lineBreakMode:kCTLineBreakByTruncatingTail];
            NSRange strRange = NSMakeRange(0, [_value length]);
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentCenter;
            [attrStr addAttribute:NSParagraphStyleAttributeName value:style range:strRange];
            [style release];
            
            [_label setAttributedTitle:attrStr forState:UIControlStateNormal];
            [_label setAttributedTitle:attrStr forState:UIControlStateDisabled];
            [_label setAttributedTitle:attrStr forState:UIControlStateNormal];

            _label.titleLabel.attributedText = attrStr;

            attrStr = [NSMutableAttributedString attributedStringWithString:_value];
            [attrStr setFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
            [attrStr setCharacterSpacing:MYSTIC_UI_LABEL_BTN_CHAR_SPACE];
            [attrStr addAttribute:NSForegroundColorAttributeName
                            value:[UIColor color:MysticColorTypeMenuTextHighlighted]
                            range:NSMakeRange(0, _value.length)];
            [attrStr setTextAlignment:kCTCenterTextAlignment lineBreakMode:kCTLineBreakByTruncatingTail];
            style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentCenter;
            [attrStr addAttribute:NSParagraphStyleAttributeName value:style range:strRange];
            [style release];
            
            
            
            [_label setAttributedTitle:attrStr forState:UIControlStateHighlighted];
            
            
            CGSize lSize = [_value sizeWithFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE] constrainedToSize:(CGSize)_label.bounds.size];
            CGRect attrBounds = CGRectSize(lSize);
            
            borderFrame = (CGRect){0,0, ceilf(attrBounds.size.width) + MYSTIC_UI_LABEL_BTN_PADDING_X*4, MYSTIC_UI_LABEL_BTN_HEIGHT};
            borderFrame = MysticPositionRect(borderFrame, _label.bounds, MysticPositionCenter);
            
            UIView *borderView = [_label viewWithTag:MysticViewTypeBorderButton];
            if(borderView)
            {
                borderView.hidden = self.titleBorderHidden;
                borderView.frame = borderFrame;
            }
            [_value release];
        }
        else
        {

            
            [MysticUIView animateWithDuration:dur/2 animations:^{
                _label.alpha = 0;
            } completion:^(BOOL finished) {
                if(__tlabel) __tlabel.ready = YES;

                NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:_value];
                [attrStr setFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
                [attrStr addAttribute:NSForegroundColorAttributeName
                                value:[UIColor color:MysticColorTypeMenuText]
                                range:NSMakeRange(0, _value.length)];
                [attrStr setCharacterSpacing:MYSTIC_UI_LABEL_BTN_CHAR_SPACE];
                [attrStr setTextAlignment:kCTCenterTextAlignment lineBreakMode:kCTLineBreakByTruncatingTail];
                NSRange strRange = NSMakeRange(0, [_value length]);
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.alignment = NSTextAlignmentCenter;
                [attrStr addAttribute:NSParagraphStyleAttributeName value:style range:strRange];
                [style release];
                
                
                [_label setAttributedTitle:attrStr forState:UIControlStateNormal];
                [_label setAttributedTitle:attrStr forState:UIControlStateDisabled];

                attrStr = [NSMutableAttributedString attributedStringWithString:_value];
                [attrStr setFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
                [attrStr setCharacterSpacing:MYSTIC_UI_LABEL_BTN_CHAR_SPACE];
                [attrStr addAttribute:NSForegroundColorAttributeName
                                value:[UIColor color:MysticColorTypeMenuTextHighlighted]
                                range:NSMakeRange(0, _value.length)];
                [attrStr setTextAlignment:kCTCenterTextAlignment lineBreakMode:kCTLineBreakByTruncatingTail];
                style = [[NSMutableParagraphStyle alloc] init];
                style.alignment = NSTextAlignmentCenter;
                [attrStr addAttribute:NSParagraphStyleAttributeName value:style range:strRange];
                [style release];
                
                
                [_label setAttributedTitle:attrStr forState:UIControlStateHighlighted];
                
                
                CGSize lSize = [_value sizeWithFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE] constrainedToSize:(CGSize)_label.bounds.size];
                CGRect attrBounds = CGRectSize(lSize);
                
                
                borderFrame = (CGRect){0,0, ceilf(attrBounds.size.width) + MYSTIC_UI_LABEL_BTN_PADDING_X*4, MYSTIC_UI_LABEL_BTN_HEIGHT};
                
                
                
                CGRect borderFrame2 = MysticPositionRect(borderFrame, _label.bounds, MysticPositionCenter);
  
                UIView *borderView = [_label viewWithTag:MysticViewTypeBorderButton];
                if(borderView)
                {
                    borderView.hidden = self.titleBorderHidden;
                    borderView.frame = borderFrame2;
                }
                [MysticUIView animateWithDuration:dur*.75 animations:^{
                    _label.alpha = 1;
                }];
                [_value release];

            }];
        }
    }
    else
    {
        [_value release];
    }

}

- (void) setItemHidden:(BOOL)hidden item:(MysticBarButtonItem *)item animated:(BOOL)animated;
{
    if(item)
    {
        if(item.customView && item.customView.hidden != hidden)
        {
            if(!animated)
            {
                item.customView.alpha = hidden ? 0 : 1;
                item.customView.hidden = hidden;
            }
            else
            {
                item.customView.alpha = hidden ? 1 : 0;
                item.customView.hidden = NO;
                [MysticUIView animateWithDuration:0.4 animations:^{
                    
                    item.customView.alpha = hidden ? 0 : 1;
                    
                } completion:^(BOOL finished) {
                    item.customView.hidden = hidden;
                }];
            }
        }
        
    }
}
- (void) hideItemOfType:(MysticToolType)toolType animated:(BOOL)animated;
{
    MysticBarButtonItem *item = [self itemForType:toolType];
    [self setItemHidden:YES item:item animated:animated];
}

- (void) hideItemAtIndex:(NSInteger)toolIndex  animated:(BOOL)animated;
{
    if(toolIndex == NSNotFound || self.items.count < toolIndex) return;
    MysticBarButtonItem *item = (id)[self.items objectAtIndex:toolIndex];
    [self setItemHidden:YES item:item animated:animated];

}
- (void) showItemOfType:(MysticToolType)toolType animated:(BOOL)animated;
{
    MysticBarButtonItem *item = [self itemForType:toolType];

    [self setItemHidden:NO item:item animated:animated];

}
- (void) showItemAtIndex:(NSInteger)toolIndex animated:(BOOL)animated;
{
    if(toolIndex == NSNotFound || self.items.count < toolIndex) return;
    MysticBarButtonItem *item = (id)[self.items objectAtIndex:toolIndex];
    [self setItemHidden:NO item:item animated:animated];
}
- (NSInteger) indexOfItemWithType:(MysticToolType)toolType;
{
    NSInteger index = NSNotFound;
    for (MysticBarButtonItem *item in self.items) {
        if(![item isKindOfClass:[MysticBarButtonItem class]]) continue;
        
        if(item.toolType==toolType) return index;
        index++;
    }
    return index;
}
@end
