//
//  MysticLayerPanelViewController.m
//  Mystic
//
//  Created by Me on 3/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerPanelViewController.h"
#import "MysticPhotoContainerView.h"
#import "MysticController.h"
#import "MysticFontTools.h"
#import "MysticConstants.h"
#import "MysticPanelSubView.h"
#import "MysticBorderView.h"
#import "MysticCore.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "MysticTabBarPanelSettings.h"
#import "MysticPanelObject.h"
#import "MysticView.h"
#import "MysticToolbarTitleButton.h"
#import "MysticScrollHeaderView.h"
#import "MysticLayersScrollView.h"
#import "MysticTabBarFont.h"
#import "MysticTabBarSketch.h"
#import "MysticCategoryButton.h"
#import "MysticIndicatorView.h"
#import "MysticLevelsSlider.h"
#import "MysticSubSettingButton.h"
#import "MysticTabBarShapes.h"
#import "MysticButtonBrush.h"
#import "MysticShader.h"
#import "MysticEffectsManager.h"
#import "MysticFilterManager.h"
#import "MysticImageFilter.h"
#import "MysticColorButton.h"
#import "MysticUtility.h"
#import "MysticInputView.h"
#import "AppDelegate.h"
#import "MysticAttrString.h"
#import "MysticAttrStringStyle.h"
#import "MysticStore.h"
#import "MysticStoreViewController.h"
#import "PackPotionOptionMulti.h"


@interface MysticLayerPanelViewController () <MysticLayerPanelViewDelegate, MysticTabBarDelegate, EffectControlDelegate, MysticScrollHeaderViewDelegate>
{
    CGRect viewFrame;
    CGPoint _lastTabBarOffset;
    
}

@property (nonatomic, retain) MysticBlockObj *blockObj;

@end

@implementation MysticLayerPanelViewController


@synthesize blockObj=_blockObj;

#pragma mark - Panel Object Delegate


- (MysticPanelObject *) layerPanel:(MysticLayerPanelView *)panelView panelObjectForSection:(MysticPanelObject *)sectionInfo;
{
    MysticPanelObject *panelObj = [MysticPanelObject panelObjectWithPanelObject:sectionInfo];
    panelObj.panel = panelView;
    panelObj.viewHasLoaded = NO;
    panelObj.view = [self layerPanel:panelView viewForSection:panelObj];
    panelObj.viewDidAppear = [self layerPanel:panelView sectionDidAppearBlock:panelObj];
    panelObj.viewWillDisappear = [self layerPanel:panelView sectionWillDisappearBlock:panelObj];
    panelObj.viewIsReady = [self layerPanel:panelView sectionIsReadyBlock:panelObj];
    panelObj.viewDidDisappear = [self layerPanel:panelView sectionDidDisappearBlock:panelObj];
    panelObj.viewDidRemoveFromSuperview = [self layerPanel:panelView sectionDidRemoveFromSuperview:panelObj];
    panelObj.viewWillAppear = [self layerPanel:panelView sectionWillAppearBlock:panelObj];
    
    return panelObj;
}



- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionDidRemoveFromSuperview:(MysticPanelObject *)section;
{
    MysticBlockObjObj block = nil;
    
    switch (section.sectionType) {
        case MysticPanelTypeAdjust:
        default:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                //                DLog(@"panel obj sectionDidRemoveFromSuperview");
            };
            break;
        }
    }
    return block;
}
//- (MysticBlockObjObjComplete) layerPanel:(MysticLayerPanelView *)panelView prepareContainerForSectionBlock:(MysticPanelObject *)section;
//{
//    MysticBlockObjObjComplete block = ^(UIView *parentView, MysticPanelObject *panelObj, MysticBlockObjBOOL finished)
//    {
//        //        DLog(@"panel section obj prepare parent: %@", parentView);
//        if(finished) finished(panelObj, YES);
//    };
//    switch (section.sectionType)
//    {
//        case MysticPanelTypeAdjust:
//        default:
//            break;
//    }
//    return block;
//}
//



- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionWillAppearBlock:(MysticPanelObject *)section;
{
    MysticBlockObjObj block = nil;
    switch (section.sectionType) {
        case MysticPanelTypeVignette:
        {
            block =  ^(UIView *view, MysticPanelObject *panelObj) {
                [(MysticLayerPanelViewController *)panelObj.delegate toolbarForSection:panelObj];
            };
            break;
        }
        case MysticPanelTypePotions:
        {
            block =  ^(UIView *view, MysticPanelObject *panelObj)
            {
                [(MysticLayerPanelViewController *)panelObj.delegate toolbarForSection:panelObj];
                [panelObj.panel.toolbar hideItemOfType:MysticToolTypeCancel animated:NO];
                [panelObj.panel.toolbar hideItemOfType:MysticToolTypeConfirm  animated:NO];
            };
            break;
        }
        case MysticPanelTypeOptionSettings:
        {
            block =  ^(UIView *view, MysticPanelObject *panelObj)
            {
                [(MysticLayerPanelViewController *)panelObj.delegate toolbarForSection:panelObj];
            };
            break;
        }

        case MysticPanelTypeAdjust:
        default:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                [panelObj.delegate layerPanel:panelObj.panel sectionWillChange:panelObj];
            };
            break;
        }
    }
    return block;
}

- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionDidAppearBlock:(MysticPanelObject *)section;
{
    
    
    
    MysticBlockObjObj block = nil;
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = self;
    __unsafe_unretained __block MysticLayerPanelView *__panelView = panelView;
    __unsafe_unretained __block MysticPanelObject *__section = section;
    
    switch (section.sectionType) {
            
        case MysticPanelTypeOptionLayer:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                MysticLayerPanelViewController *_weakSelf = (MysticLayerPanelViewController *)panelObj.delegate;
                [_weakSelf toolbarForSection:panelObj];
            };
            break;
        }
            
        case MysticPanelTypePotions:
        {
            block = nil;
            break;
        }
        case MysticPanelTypeVignette:
            break;
        default:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                [(MysticLayerPanelViewController *)panelObj.delegate toolbarForSection:panelObj];
            };
            break;
        }
    }
    return block;
}

- (void) layerPanel:(MysticLayerPanelView *)panelView resetSection:(MysticPanelObject *)section;
{
    
    
}
- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionIsReadyBlock:(MysticPanelObject *)section;
{
    MysticBlockObjObj block = nil;
    switch (section.sectionType)
    {
#ifdef DEBUG
        case MysticPanelTypeTest:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                
                
                
            };
            break;
        }
#endif
        case MysticPanelTypeMask:
        case MysticPanelTypeMaskBrush:
        case MysticPanelTypeMaskErase:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                [[MysticController controller] showSketchView:MysticSketchToolTypeMask];
            };
            break;
        }
        case MysticPanelTypeBlend:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj){
                
                __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = (MysticLayerPanelViewController *)panelObj.delegate;
                weakSelf.controller.preventToolsFromBeingVisible = YES;
                [weakSelf.controller toggleMoreToolsHide];
                panelObj.scrollView.shouldSelectActiveControls = YES;
                if(!panelObj.resetAll && panelObj.scrollView.subviews.count) { [panelObj.scrollView reloadControls]; return ; }
                NSArray *controls = panelObj.targetOption.blendingModeOptions;
                MysticObjectType panelSetting = panelObj.setting;
                for (PackPotionOptionBlend *o in controls)
                {
                    o.action = ^(EffectControl *control, BOOL isSelected)
                    {
                        [control touchedEffect];
                        if(control.selected && isSelected != control.selected)
                        {
                            switch (panelSetting) {
                                case MysticSettingVignetteBlending:
                                {
                                    NSString *otype = MysticFilterTypeToString([(PackPotionOptionBlend *)control.option targetOption].vignetteBlendingType);
                                    [(PackPotionOptionBlend *)control.option targetOption].vignetteBlendingType = [(PackPotionOptionBlend *)control.option newBlendingType];
//                                    DLog(@"setting blend: %@ -> %@", otype, MysticFilterTypeToString([(PackPotionOptionBlend *)control.option targetOption].vignetteBlendingType));
                                    
                                    break;
                                }
                                    
                                default:
                                {
                                    [(PackPotionOptionBlend *)control.option setUserChoice];
                                    break;
                                }
                            }
                            
                            [weakSelf.controller reloadImageInBackground:NO settings:MysticRenderOptionsForceProcess];
                            [(MysticScrollView *)control.superview centerOnView:control animate:YES complete:nil];
                        }
                    };
                }
                
                panelObj.scrollView.shouldSelectActiveControls = YES;
                [panelObj.scrollView loadControls:controls];
            };
            break;

        }
        case MysticPanelTypePotions:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                __unsafe_unretained __block MysticLayerPanelViewController *_weakSelf = (MysticLayerPanelViewController *)panelObj.delegate;
                __unsafe_unretained __block MysticScrollView *__contentScrollView = panelObj.scrollView;
                __unsafe_unretained __block MysticPanelObject *__panelObj = panelObj;
                
                if(panelObj.shouldReload || _weakSelf.controller.lastSetting != panelObj.state)
                {
                    [panelObj.panel.toolbar hideItemOfType:MysticToolTypeCancel animated:NO];
                    [panelObj.panel.toolbar hideItemOfType:MysticToolTypeConfirm  animated:NO];
                    
                    [panelObj.panel.toolbar setTitle:@"POTIONS" animated:_weakSelf.layerPanelIsVisible];
                    [panelObj.panel.toolbar showItemOfType:MysticToolTypeCancel animated:YES];
                    [panelObj.panel.toolbar showItemOfType:MysticToolTypeConfirm animated:YES];
                    
                    NSMutableArray *controls = [NSMutableArray arrayWithArray:[PackPotionOptionMulti potions]];
//                    for (PackPotionOptionMulti *option in [PackPotionOptionMulti potions]) {
//                        EffectControl *effectControl = [[[EffectControl alloc] initWithFrame:(CGRect){0,0,__contentScrollView.frame.size.height, __contentScrollView.frame.size.height, } effect:option] autorelease];
//                        [controls addObject:effectControl];
//                    }
                    
                    if(__contentScrollView && controls)
                    {
                        __contentScrollView.enableControls = YES;
                        id optSlotKey = __panelObj.targetOption && !panelObj.panel.createNewOption ? __panelObj.targetOption.optionSlotKey : nil;
                        
//                        DLogDebug(@"load potions: %@  ->  %@  ->  %@", MBOOL(panelObj.panel.createNewOption), optSlotKey, __panelObj.targetOption);

                        
                        optSlotKey = optSlotKey ? optSlotKey : [[MysticOptions current] makeSlotKeyForOption:__panelObj.targetOption ? __panelObj.targetOption : [controls lastObject] force:YES];
                        
//                        DLogDebug(@"load potions 2: %@ ", optSlotKey);

                        
                        __unsafe_unretained __block id __optSlotKey = optSlotKey;
                        for (PackPotionOption *opt in controls)
                        {
                            opt.optionSlotKey = optSlotKey;
                        }
                        __contentScrollView.shouldSelectControlBlock = (^BOOL(PackPotionOption *o){
                            
                            PackPotionOption *ao = o ? o.activeOption : nil;
                            ao = ao ? ao : o;
                            return __optSlotKey && [ao.optionSlotKey isEqualToString:__optSlotKey] ? YES : NO;
                        });
                        
                        if(controls)
                        {
                            [__contentScrollView loadControls:controls selectIndex:MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX animated:NO complete:^{
                                EffectControl *selectedControl = (EffectControl *)__contentScrollView.selectedItem;
                                
                                NSString *toolbarTitle = MysticObjectTypeTitleParent(selectedControl.option.type, 0);
                                if(selectedControl)
                                {
                                    [selectedControl.option controlBecameActive:selectedControl];
                                    toolbarTitle = [selectedControl.option.name uppercaseString];
                                }
                                __panelObj.toolbarTitle = toolbarTitle;
                                MysticLayerToolbar *toolbar = [_weakSelf toolbarForSection:__panelObj];
                                if (toolbar)
                                {
                                    [toolbar setTitleEnabled:NO];
                                    toolbar.titleBorderHidden = YES;
                                    [toolbar setTitle:toolbarTitle animated:_weakSelf.layerPanelIsVisible];
                                }
                            }];
                        }
                    }
                }
            };
            break;
        }
        case MysticPanelTypeOptionSpecial:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                
                MysticLayerPanelViewController *_weakSelf = (MysticLayerPanelViewController *)panelObj.delegate;
                __unsafe_unretained __block MysticScrollView *__contentScrollView = [panelObj.scrollView retain];
                __unsafe_unretained __block MysticPanelObject *__panelObj = [panelObj retain];
                
                if(panelObj.shouldReload || _weakSelf.controller.lastSetting != panelObj.state)
                {
                    
                    [Mystic specialOptions:^(NSArray *controls, MysticDataState dataState) {
                        
                        
                        
                        if(dataState & MysticDataStateNew && controls && controls.count)
                        {
                            id optSlotKey = __panelObj.targetOption && !panelObj.panel.createNewOption ? __panelObj.targetOption.optionSlotKey : nil;

                            
                            
                            optSlotKey = optSlotKey ? optSlotKey : [[MysticOptions current] makeSlotKeyForOption:__panelObj.targetOption ? __panelObj.targetOption : [controls lastObject] force:panelObj.panel.createNewOption];
                            __block id __optSlotKey = optSlotKey;
                            
                            
                            
                            __contentScrollView.shouldSelectControlBlock = (^BOOL(PackPotionOption *o){
                                
                                PackPotionOption *ao = o ? o.activeOption : nil;
                                ao = ao ? ao : o;
                                return __optSlotKey && [ao.optionSlotKey isEqualToString:__optSlotKey] ? YES : NO;
                            });
                            
                            for (PackPotionOption *opt in controls)
                            {
                                opt.optionSlotKey = optSlotKey;
                            }
                            if(__contentScrollView)
                            {
                                __contentScrollView.enableControls = YES;
                                [__contentScrollView loadControls:controls selectIndex:MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX animated:NO complete:^{
                                    EffectControl *selectedControl = (EffectControl *)__contentScrollView.selectedItem;
                                    if(selectedControl) [selectedControl.option controlBecameActive:selectedControl];
                                    
                                    __panelObj.toolbarTitle = selectedControl ? selectedControl.option.name : MysticObjectTypeTitleParent(__panelObj.optionType, 0);
                                    
                                    MysticLayerToolbar *toolbar = [_weakSelf toolbarForSection:__panelObj];
                                    if (toolbar)
                                    {
                                        [toolbar setTitleEnabled:NO];
                                        toolbar.titleBorderHidden = YES;
                                        [toolbar setTitle:__panelObj.toolbarTitle animated:_weakSelf.layerPanelIsVisible];
                                    }
                                }];
                            }
                        }
                        if(dataState & MysticDataStateComplete)
                        {
                            [__panelObj release];
                            [__contentScrollView release];
                        }
                    }];
                    
                    
                }
                
                
            };
            break;
        }
            
        case MysticPanelTypeOptionFilter:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                __unsafe_unretained __block MysticLayerPanelViewController *_weakSelf = (MysticLayerPanelViewController *)panelObj.delegate;
                __unsafe_unretained __block MysticScrollView *__contentScrollView = [panelObj.scrollView retain];
                __unsafe_unretained __block MysticPanelObject *__panelObj = [panelObj retain];
                
                if(panelObj.shouldReload || _weakSelf.controller.lastSetting != panelObj.state)
                {
                    NSArray *controls = [Mystic core].filters;
                    id optSlotKey = __panelObj.targetOption && !panelObj.panel.createNewOption ? __panelObj.targetOption.optionSlotKey : nil;
                    
                    
                    optSlotKey = optSlotKey ? optSlotKey : [[MysticOptions current] makeSlotKeyForOption:__panelObj.targetOption ? __panelObj.targetOption : [controls lastObject] force:panelObj.panel.createNewOption];
                    __unsafe_unretained __block id __optSlotKey = optSlotKey;
                    for (PackPotionOption *opt in controls)
                    {
                        opt.optionSlotKey = optSlotKey;
                    }
                    __contentScrollView.shouldSelectControlBlock = (^BOOL(PackPotionOption *o){
                        
                        PackPotionOption *ao = o ? o.activeOption : nil;
                        ao = ao ? ao : o;
                        return __optSlotKey && [ao.optionSlotKey isEqualToString:__optSlotKey] ? YES : NO;
                    });
                    //
                    //
                    //
                    [__contentScrollView loadControls:controls selectIndex:MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX animated:NO complete:^{
                        
                        NSString *toolbarTitle = MysticObjectTypeTitleParent(MysticObjectTypeFilter, 0);
                        EffectControl *selectedControl = (EffectControl *)__contentScrollView.selectedItem;
                        if(selectedControl)
                        {
                            [selectedControl.option controlBecameActive:selectedControl];
                            toolbarTitle = [selectedControl.option.name uppercaseString];
                        }
                        __panelObj.toolbarTitle = toolbarTitle;
                        [_weakSelf updateToolbar:nil panel:__panelObj option:selectedControl ? (id)selectedControl.effect : _weakSelf.layerPanelView.targetOption];
                        
                        [__contentScrollView release];
                        [__panelObj release];
                        
                    }];
                    
                }
                else
                {
                    [__panelObj release];
                    [__contentScrollView release];
                }
            };
            break;
        }
            
            
        case MysticPanelTypeOptionLayer:
        {

            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                MysticLayerPanelViewController *_weakSelf = (MysticLayerPanelViewController *)panelObj.delegate;
                __unsafe_unretained __block MysticScrollView *__contentScrollView = [panelObj.scrollView retain];
                __unsafe_unretained __block MysticPanelObject *__panelObj = [panelObj retain];
                _weakSelf.controller.preventToolsFromBeingVisible = NO;

                if(__panelObj.optionType == MysticObjectTypeColorOverlay)
                {
                    NSArray *controls = [Mystic core].colorOverlays;
                    id optSlotKey = __panelObj.targetOption && !panelObj.panel.createNewOption ? __panelObj.targetOption.optionSlotKey : nil;
                    optSlotKey = optSlotKey ? optSlotKey : [[MysticOptions current] makeSlotKeyForOption:__panelObj.targetOption ? __panelObj.targetOption : [controls lastObject] force:panelObj.panel.createNewOption];
                    __unsafe_unretained __block id __optSlotKey = optSlotKey;
                    __contentScrollView.shouldSelectControlBlock = (^BOOL(PackPotionOption *o){
                        PackPotionOption *ao = o ? o.activeOption : nil;
                        ao = ao ? ao : o;
                        return __optSlotKey && [ao.optionSlotKey isEqualToString:__optSlotKey] ? YES : NO;
                    });
                    
                    for (PackPotionOption *opt in controls) opt.optionSlotKey = optSlotKey;
                    
                    if(__contentScrollView)
                    {
                        __contentScrollView.enableControls = YES;
                        [__contentScrollView loadControls:controls selectIndex:MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX animated:NO complete:^{
                            EffectControl *selectedControl = (EffectControl *)__contentScrollView.selectedItem;
                            if(selectedControl) {
                                [selectedControl.option controlBecameActive:selectedControl];
                            }
                            switch(__panelObj.optionType)
                            {
                                case MysticObjectTypeColorOverlay:
                                {
                                    __panelObj.toolbarTitle = selectedControl ? selectedControl.option.name : MysticObjectTypeTitleParent(__panelObj.optionType, 0);
                                    MysticLayerToolbar *toolbar = [_weakSelf toolbarForSection:__panelObj];
                                    if (toolbar)
                                    {
                                        [toolbar setTitleEnabled:NO];
                                        toolbar.titleBorderHidden = YES;
                                        [toolbar setTitle:__panelObj.toolbarTitle animated:_weakSelf.layerPanelIsVisible];
                                    }
                                    break;
                                }
                                default: break;
                            }
                        }];
                    }
                    return;
                    
                }
                
                if(__panelObj.shouldReload || _weakSelf.controller.lastSetting != __panelObj.state)
                {
//                    NSMutableArray *packs = [NSMutableArray arrayWithArray:__panelObj.packs ? __panelObj.packs : [MysticOptionsDataSource packsWithType:MysticObjectTypeToOptionTypes(__panelObj.optionType)|MysticOptionTypeShowFeaturedPack]];
                    NSMutableArray *packs = [NSMutableArray arrayWithArray:__panelObj.packs ? __panelObj.packs : [MysticOptionsDataSource packsWithType:MysticObjectTypeToOptionTypes(__panelObj.optionType)]];

                    MysticPacksScrollView *__packsScrollView = __panelObj.packsView;
                    MysticCategoryButton *lastCategoryButton, *selectedCategoryBtn= nil;
                    CGRect lastCategoryFrame = (CGRect){__packsScrollView.margin-5,0,0,0};
                    int tag = 1;
                    MysticPack *pack = nil;
//                    pack = [MysticPack packWithName:@"MORE" info:@{@"getmore":@(__panelObj.optionType)}];
//                    [packs insertObject:pack atIndex:0];
                    for (pack in packs) {
                        MysticCategoryButton *categoryBtn = [MysticCategoryButton buttonWithTitle:pack.title target:_weakSelf sel:@selector(categoryButtonTouched:)];
                        BOOL isGetMore = pack.info[@"getmore"]!=nil;
                        categoryBtn.pack = pack;
                        if(isGetMore)
                        {
                            [categoryBtn.titleLabel setFont:[MysticFont fontBold:MYSTIC_UI_CATEGORY_GET_MORE_FONTSIZE]];
                            categoryBtn.backgroundColor = [UIColor colorWithRed:0.96 green:0.35 blue:0.42 alpha:1.00];
                            [categoryBtn setTitleColor:[UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.00] forState:UIControlStateNormal];
                            [categoryBtn setTitleColor:[UIColor colorWithRed:0.90 green:0.85 blue:0.79 alpha:1.00] forState:UIControlStateHighlighted];
                            categoryBtn.bounds = CGRectWH(categoryBtn.frame, CGRectGetWidth(categoryBtn.frame)+6, 21);
                            categoryBtn.clipsToBounds = YES;
                            categoryBtn.roundCorners = YES;
                        }
                        lastCategoryFrame.size = categoryBtn.frame.size;
                        if(!isGetMore) lastCategoryFrame.size.height = __packsScrollView.frame.size.height;
                        
                        categoryBtn.frame = lastCategoryFrame;
                        categoryBtn.tag = __packsScrollView.tag + tag;
                        lastCategoryButton = categoryBtn;
                        if(categoryBtn.frame.size.height < __packsScrollView.frame.size.height)
                        {
                            categoryBtn.center = (CGPoint){categoryBtn.center.x, __packsScrollView.frame.size.height/2};
                            CGFloat hitInsets = (CGRectGetHeight(__packsScrollView.frame) - CGRectGetHeight(categoryBtn.frame))/2;
                            UIEdgeInsets hits = categoryBtn.hitInsets;
                            hits.top = hitInsets;
                            hits.bottom = hitInsets;
                            categoryBtn.hitInsets = hits;
                        }
                        
                        lastCategoryFrame.origin.x += categoryBtn.frame.size.width + __packsScrollView.margin;
                        
                        if(!selectedCategoryBtn && [pack.title isEqualToString:__panelObj.pack.title])
                        {
                            categoryBtn.selected = YES;
                            selectedCategoryBtn = categoryBtn;
                        }
                        [__packsScrollView addSubview:categoryBtn];
                        tag++;
                        
                    }
                    __packsScrollView.contentSize = (CGSize){lastCategoryFrame.origin.x, __packsScrollView.frame.size.height};
                    if(selectedCategoryBtn) [__packsScrollView scrollToView:selectedCategoryBtn animated:NO finished:nil];
                    
                    [__panelObj.pack packOptions:^(NSArray *controls, MysticDataState dataState) {
                        
                        if(dataState & MysticDataStateNew && controls && controls.count)
                        {
                            id optSlotKey = __panelObj.targetOption && !panelObj.panel.createNewOption ? __panelObj.targetOption.optionSlotKey : nil;
                            optSlotKey = optSlotKey ? optSlotKey : [[MysticOptions current] makeSlotKeyForOption:__panelObj.targetOption ? __panelObj.targetOption : [controls lastObject] force:panelObj.panel.createNewOption];
                            __unsafe_unretained __block id __optSlotKey = optSlotKey;
                            
                            __contentScrollView.shouldSelectControlBlock = (^BOOL(PackPotionOption *o){
                                
                                PackPotionOption *ao = o ? o.activeOption : nil;
                                ao = ao ? ao : o;
                                return __optSlotKey && [ao.optionSlotKey isEqualToString:__optSlotKey] ? YES : NO;
                            });
                            
                            for (PackPotionOption *opt in controls) opt.optionSlotKey = optSlotKey;
                            
                            if(__contentScrollView)
                            {
                                __contentScrollView.enableControls = YES;
                                [__contentScrollView loadControls:controls selectIndex:MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX animated:NO complete:^{
                                    EffectControl *selectedControl = (EffectControl *)__contentScrollView.selectedItem;
                                    if(selectedControl) {
                                        [selectedControl.option controlBecameActive:selectedControl];
                                    }
                                    switch(__panelObj.optionType)
                                    {
                                        case MysticObjectTypeColorOverlay:
                                        {
                                            __panelObj.toolbarTitle = selectedControl ? selectedControl.option.name : MysticObjectTypeTitleParent(__panelObj.optionType, 0);
                                            MysticLayerToolbar *toolbar = [_weakSelf toolbarForSection:__panelObj];
                                            if (toolbar)
                                            {
                                                [toolbar setTitleEnabled:NO];
                                                toolbar.titleBorderHidden = YES;
                                                [toolbar setTitle:__panelObj.toolbarTitle animated:_weakSelf.layerPanelIsVisible];
                                            }
                                            break;
                                        }
                                        default: break;
                                    }
                                }];
                            }
                        }
                        if(dataState & MysticDataStateComplete)
                        {
                            [__panelObj release];
                            [__contentScrollView release];
                        }
                    }];
                }
                else
                {
                    [__panelObj release];
                    [__contentScrollView release];
                }
            };
            break;
        }
        default:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                __unsafe_unretained __block MysticLayerPanelViewController *_weakSelf = (MysticLayerPanelViewController *)panelObj.delegate;
                __unsafe_unretained __block MysticScrollView *__contentScrollView = panelObj.scrollView;
                __unsafe_unretained __block MysticPanelObject *__panelObj = panelObj;
                
                MysticLayerToolbar *toolbar = [_weakSelf toolbarForSection:__panelObj];
                if (toolbar)
                {
                    switch (__panelObj.sectionType) {
                        case MysticPanelTypeOptionImageLayerSettings:
                        case MysticPanelTypeOptionLayerSettings: break;
                            
                        default:
                        {
                            [toolbar setTitleEnabled:NO];
                            toolbar.titleBorderHidden = YES;
                            [toolbar setTitle:__panelObj.toolbarTitle animated:_weakSelf.layerPanelIsVisible];
                            break;
                        }
                    }
                    
                }
                
                MysticBlockObject f = [panelObj.delegate layerPanel:panelObj.panel sectionDidChange:panelObj];
                
                if(f)
                {
                    f(view);
                    Block_release(f);
                }
            };
            break;
        }
    }
    
    return block;
}


- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionWillDisappearBlock:(MysticPanelObject *)section;
{
    MysticBlockObjObj block = nil;
    
    switch (section.sectionType)
    {
        case MysticPanelTypeAdjust:
        default:
            break;
    }
    return block;
}



- (MysticBlockObjObj) layerPanel:(MysticLayerPanelView *)panelView sectionDidDisappearBlock:(MysticPanelObject *)section;
{
    MysticBlockObjObj block = nil;
    
    switch (section.sectionType) {
        case MysticPanelTypeMask:
        case MysticPanelTypeMaskBrush:
        case MysticPanelTypeMaskErase:
        {
            block = ^(UIView *view, MysticPanelObject *panelObj)
            {
                [[MysticController controller] hideSketchView];
            };
            break;
        }
        case MysticPanelTypeAdjust:
        default:
//            block = ^(UIView *view, MysticPanelObject *panelObj)
//        {
//            //                DLog(@"panel obj sectionDidDisappearBlock");
//        };
            break;
    }
    return block;
}

















































































- (void) dealloc;
{
    [super dealloc];
    [_blockObj release], _blockObj = nil;
    _delegate = nil;
    [_selectedItemIndexes release];
}
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        viewFrame = CGRectMake(0, 0, [MysticUI screen].width, [MysticUI screen].height);
        [self commonInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame delegate:(id)delegate;
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        viewFrame = frame;
        self.delegate = delegate;
        [self commonInit];
    }
    return self;
}

- (void) commonInit;
{
    _lastTabBarOffset = CGPointZero;
    self.ignoreStateChanges = NO;
    self.selectedItemIndexes = [NSMutableDictionary dictionary];
}
- (MysticLayerPanelView *) layerPanelView;
{
    return (MysticLayerPanelView *)self.view;
}
- (MysticController *) controller;
{
    return (MysticController *)self.parentViewController;
}
- (void) loadView;
{
    MysticLayerPanelView *__view = [[MysticLayerPanelView alloc] initWithFrame:viewFrame];
    __view.delegate = self;
    self.view = __view;
    self.view.opaque = NO;
    [__view release];
}



- (MysticLayerPanelView *) showLayerPanel:(BOOL)opened info:(NSDictionary *)__options;
{
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:__options];
    PackPotionOption *option = [options objectForKey:@"option"] && [[options objectForKey:@"option"] isKindOfClass:[PackPotionOption class]] ? [options objectForKey:@"option"] : nil;
    BOOL removeOption = !option && [options objectForKey:@"option"] ? [[options objectForKey:@"option"] boolValue] : NO;
    if(!option) [options removeObjectForKey:@"option"];
    [self.layerPanelView reset:removeOption];
    self.layerPanelView.openInset = 0;
    [self.layerPanelView setOptions:options];
    [self updateLayerPanel:self.layerPanelView];
    if(option) self.layerPanelView.targetOption = option;
    self.layerPanelView.enabled = options && [options objectForKey:@"enabled"] ? [[options objectForKey:@"enabled"] boolValue] : YES;
    self.layerPanelView.backgroundColor = [UIColor clearColor];
    return self.layerPanelView;
}


#pragma mark - Delegate methods
- (void) updateLayerPanel:(MysticLayerPanelView *)panelView;
{
    
    
    
    
}

- (UINavigationItem *) navigationItem;
{
    return self.parentViewController.navigationItem;
}

- (NSString *) title;
{
    return self.controller.title;
}




- (UIView *) layerPanel:(MysticLayerPanelView *)panelView viewForSection:(MysticPanelObject *)section;
{
    
    
    BOOL createContentView = YES;
    
    
    CGRect contentFrame = panelView.contentFrame;
    MysticPanelContentView *contentView = nil;
    MysticPanelSubView *subContentView = nil;
    CGFloat scrollMargin = MYSTIC_UI_PANEL_CONTROLS_SPACING;
    MysticBlockObject finished = nil;
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = self;
    __unsafe_unretained __block MysticLayerPanelView *__panelView = panelView;
    __unsafe_unretained __block MysticPanelObject *__section = section;
    NSInteger subTag = NSNotFound;
    
    
    switch (section.sectionType)
    {
#pragma mark - View - Settings Mask
            
        case MysticPanelTypeMask:
        case MysticPanelTypeMaskBrush:
        case MysticPanelTypeMaskErase:
        {
            NSString *labelTitle;
            switch (section.sectionType) {
                case MysticPanelTypeMaskErase: labelTitle = @"ERASE"; break;
                default: labelTitle = @"BRUSH"; break;
            }
            CGRect subContentFrame = contentFrame;
            subContentFrame.origin.y = 0;
            subContentFrame.size.height = 68 ;
            contentFrame.size.height = subContentFrame.size.height;
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"mask"];
            
            __unsafe_unretained __block MysticToolbarTitleButton *__label = (MysticToolbarTitleButton *)[MysticToolbarTitleButton button:nil action:nil];
            
            __label.frame = CGRectMake(10, 0, 80, subContentFrame.size.height);
            __label.canSelect = NO;
            __label.backgroundColor = [UIColor clearColor];
            __label.tag = MysticUITypeLabel;
            __label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            __label.textAlignment = NSTextAlignmentLeft;
            __label.toolType = MysticToolTypeBrowsePacks;
            __label.enabled = YES;
            __label.textColor = [UIColor hex:@"4F4A44"];
            NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:labelTitle];
            [attrStr setFont:[MysticUI gothamBook:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
            [attrStr addAttribute:NSForegroundColorAttributeName
                            value:__label.textColor
                            range:NSMakeRange(0, attrStr.string.length)];
            [attrStr setCharacterSpacing:MYSTIC_UI_LABEL_BTN_CHAR_SPACE];
            [__label setAttributedTitle:attrStr forState:UIControlStateNormal];
            
            CGRect confirmFrame = CGRectMake(subContentFrame.size.width - subContentFrame.size.height, 0, subContentFrame.size.height, subContentFrame.size.height);
            
            UIImage *confirmIcon = [MysticIcon iconForType:MysticIconTypeToolBarConfirm size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM, MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM) color:[UIColor color:MysticColorTypeMenuIconConfirm]];
            __unsafe_unretained __block MysticButton *__confirmBtn = [MysticButton button:confirmIcon action:^(MysticButton * sender) {
                
                MysticBrushSetting tag = sender.tag - MysticViewTypeButton2;
                NSString *animationName = nil;
                switch (tag) {
                    case MysticBrushSettingFeather: animationName = @"panelBrushComplete-feather"; break;
                    case MysticBrushSettingOpacity: animationName = @"panelBrushComplete-opacity"; break;
                    case MysticBrushSettingSize: animationName = @"panelBrushComplete-size"; break;
                    default: break;
                }
                
                [MysticAnimation animate:animationName];
            }];
            __confirmBtn.frame = confirmFrame;
            __confirmBtn.hidden = YES;
            __confirmBtn.userInteractionEnabled = NO;
            __confirmBtn.alpha = 0;
            
            CGRect sliderFrame = (CGRect){(__label.frame.origin.x + __label.frame.size.width), 0, subContentFrame.size.width-(__label.frame.origin.x + __label.frame.size.width), subContentFrame.size.height};
            sliderFrame = CGRectInset(sliderFrame, 15, 0);
            __unsafe_unretained __block MysticSlider *__slider = [MysticSlider sliderWithFrame:CGRectWidth(sliderFrame, sliderFrame.size.width-10)];
            __slider.minimumValue = 0;
            __slider.maximumValue = 1;
            __slider.upperValue = 1;
            __slider.value = 1;
            __slider.userInteractionEnabled = NO;
            __slider.lowerValue = 0;
            __slider.lowerHandleHidden = YES;
            __slider.hidden = YES;
            __slider.alpha = 0;
            
            
            
            MysticBrush brush = __panelView.targetOption ? __panelView.targetOption.maskBrush : MysticBrushDefault;
            __unsafe_unretained __block MysticButtonBrush *__brushSize = [MysticButtonBrush brushButtonWithSetting:MysticBrushSettingSize brush:brush color:nil displayColor:[UIColor color:MysticColorTypePink] action:^(MysticButtonBrush *btn){
                __block MysticButtonBrush *__btn = btn;
                __slider.value = __btn.size;
                [MysticAnimation animate:@"panelBrushSize" complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                    __slider.changeBlock = ^(MysticSlider *slider){
                        MysticBrush _brush = __panelView.targetOption.maskBrush;
                        _brush.size = slider.value;
                        __panelView.targetOption.maskBrush=_brush;
                        __btn.size = slider.value;
                        [MysticController controller].sketchView.lineScale = _brush.size;
                        [MysticUser set:@(slider.value) key:@"maskPanelBrushSize"];
                    };
                    __slider.finishBlock = ^(MysticSlider *slider){ [MysticAnimation animate:@"panelBrushComplete-size"]; };
                }];
            }];
            __brushSize.frame = CGRectMake(0, 0, 72, 24);
            if([MysticUser get:@"maskPanelBrushSize"]!=nil) __brushSize.size = [MysticUser getf:@"maskPanelBrushSize"];
            
            MysticBrush brush2 = brush;
            __unsafe_unretained __block MysticButtonBrush *__brushOpacity = [MysticButtonBrush brushButtonWithSetting:MysticBrushSettingOpacity brush:brush2 color:nil displayColor:[UIColor color:MysticColorTypePink] action:^(MysticButtonBrush *btn){
                __block MysticButtonBrush *__btn = btn;
                __slider.value = __btn.opacity;
                [MysticAnimation animate:@"panelBrushOpacity" complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                    __slider.changeBlock = ^(MysticSlider *slider){
                        MysticBrush _brush = __panelView.targetOption.maskBrush;
                        _brush.opacity = slider.value;
                        __panelView.targetOption.maskBrush=_brush;
                        __btn.opacity = slider.value;
                        [MysticController controller].sketchView.lineOpacity = _brush.opacity;
                        [MysticUser set:@(slider.value) key:@"maskPanelBrushOpacity"];

                    };
                    __slider.finishBlock = ^(MysticSlider *slider){ [MysticAnimation animate:@"panelBrushComplete-opacity"]; };
                }];
            }];
            __brushOpacity.frame = CGRectMake(0, 0, 72, 24);
            if([MysticUser get:@"maskPanelBrushOpacity"]!=nil) __brushOpacity.opacity = [MysticUser getf:@"maskPanelBrushOpacity"];

            MysticBrush brush3 = brush;
            __unsafe_unretained __block MysticButtonBrush *__brushFeather = [MysticButtonBrush brushButtonWithSetting:MysticBrushSettingFeather brush:brush3 color:nil displayColor:[UIColor color:MysticColorTypePink] action:^(MysticButtonBrush *btn){
                __block MysticButtonBrush *__btn = btn;
                __slider.value = __btn.feather;
                [MysticAnimation animate:@"panelBrushFeather" complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                    __slider.changeBlock = ^(MysticSlider *slider){
                        MysticBrush _brush = __panelView.targetOption.maskBrush;
                        _brush.feather = slider.value;
                        __panelView.targetOption.maskBrush=_brush;
                        __btn.feather = slider.value;
                        [MysticController controller].sketchView.lineFeather = _brush.feather;
                        [MysticUser set:@(slider.value) key:@"maskPanelBrushFeather"];

                    };
                    __slider.finishBlock = ^(MysticSlider *slider){ [MysticAnimation animate:@"panelBrushComplete-feather"]; };
                }];
            }] ;
            __brushFeather.frame = CGRectMake(0, 0, 72, 24);
            if([MysticUser get:@"maskPanelBrushFeather"]!=nil) __brushFeather.feather = [MysticUser getf:@"maskPanelBrushFeather"];
            
            __unsafe_unretained __block MysticLayerToolbar *__toolbar = [MysticLayerToolbar toolbarWithItems:
  @[ @{@"toolType": @(MysticToolTypeStatic), @"width":@(-18)},
                                                                                                                @{@"toolType": @(MysticToolTypeFlexible)},
                                                                                                                @{@"toolType":@(MysticToolTypeCustom), @"view":__brushSize, @"width":@(CGRectW(__brushSize.frame))},
                                                                                                                @{@"toolType": @(MysticToolTypeStatic), @"width":@(0)},
                                                                                                                @{@"toolType":@(MysticToolTypeCustom), @"view":__brushOpacity, @"width":@(CGRectW(__brushOpacity.frame))},
                                                                                                                @{@"toolType": @(MysticToolTypeStatic), @"width":@(0)},
                                                                                                                @{@"toolType":@(MysticToolTypeCustom), @"view":__brushFeather, @"width":@(CGRectW(__brushFeather.frame))},
                                                                                                                @{@"toolType": @(MysticToolTypeStatic), @"width":@(25)},
                                                                                                                @{@"toolType": @(MysticToolTypeStatic), @"width":@(-18)},
                                                                                                                ] delegate:self height:subContentFrame.size.height];
            __toolbar.frame = CGRectX(CGRectWidth(__toolbar.frame, subContentFrame.size.width-(__label.frame.origin.x + __label.frame.size.width)), __label.frame.origin.x + __label.frame.size.width);
            __toolbar.backgroundColor = [UIColor hex:@"141412"];
            
            [subContentView addSubview:__toolbar];
            [subContentView addSubview:__slider];
            [subContentView addSubview:__label];
            
            __block CGRect oBrFrameFeather = CGRectUnknown;
            __block CGRect oBrFrameOpacity = CGRectUnknown;
            __block CGRect oBrFrameSize = CGRectUnknown;
            __block CGRect oToolbarFrame = CGRectUnknown;
            __block CGRect oLabelFrame = CGRectUnknown;
            __block CGPoint oToolbarCenter = CGPointUnknown;
            
            
            MysticAnimation *anim = [MysticAnimation animationWithDuration:0.4];
            anim.animationOptions = UIViewAnimationCurveEaseInOut;
            [anim addPreAnimation:^(MysticAnimationBlockObject *object) {
                if(CGRectIsUnknown(oBrFrameFeather)) oBrFrameFeather = __brushFeather.frame;
                if(CGRectIsUnknown(oBrFrameOpacity)) oBrFrameOpacity = __brushOpacity.frame;
                if(CGRectIsUnknown(oBrFrameSize)) oBrFrameSize = __brushSize.frame;
                if(CGRectIsUnknown(oToolbarFrame)) oToolbarFrame = __toolbar.frame;
                if(CGRectIsUnknown(oLabelFrame)) oLabelFrame = __label.frame;
                if(CGPointIsUnknown(oToolbarCenter)) oToolbarCenter = __toolbar.center;
            }];
            [[anim addKeyFrame:0 duration:0.2 animations:^{
                __brushOpacity.alpha = 0;
                __brushSize.alpha = 0;
                __label.alpha = 0;
            }] addKeyFrame:0.2 duration:0.2 animations:^{
                __brushFeather.alpha = 1;
                __brushFeather.hidden = NO;
                __brushFeather.frame = CGRectX(oBrFrameFeather, 0);
                __toolbar.center = CGPointMake(__toolbar.frame.size.width/2, __toolbar.center.y);
            }];
            
            
            MysticAnimation *anim2 = [anim addNextAnimationWithDuration:0.2 animations:^{
                __slider.alpha = 1;
                __confirmBtn.alpha = 1;
            }];
            [anim2 addPreAnimation:^(MysticAnimationBlockObject *object) {
                __slider.alpha = 0;
                __slider.hidden = NO;
                __confirmBtn.alpha = 0;
                __confirmBtn.hidden = NO;
                
            }];
            [anim finished:^(BOOL finished, MysticAnimationBlockObject *obj) {
                __slider.userInteractionEnabled = YES;
                __confirmBtn.userInteractionEnabled = YES;
                __brushFeather.hidden = NO;
                __brushSize.hidden = YES;
                __brushOpacity.hidden = YES;
                __confirmBtn.tag = MysticViewTypeButton2 + MysticBrushSettingFeather;
            }];
            
            [MysticAnimation setAnimation:anim forKey:@"panelBrushFeather"];
            
            // opacity animation
            anim = [MysticAnimation animationWithDuration:0.4];
            anim.animationOptions = UIViewAnimationCurveEaseInOut;
            [anim addPreAnimation:^(MysticAnimationBlockObject *object) {
                if(CGRectIsUnknown(oBrFrameFeather)) oBrFrameFeather = __brushFeather.frame;
                if(CGRectIsUnknown(oBrFrameOpacity)) oBrFrameOpacity = __brushOpacity.frame;
                if(CGRectIsUnknown(oBrFrameSize)) oBrFrameSize = __brushSize.frame;
                if(CGRectIsUnknown(oToolbarFrame)) oToolbarFrame = __toolbar.frame;
                if(CGRectIsUnknown(oLabelFrame)) oLabelFrame = __label.frame;
                if(CGPointIsUnknown(oToolbarCenter)) oToolbarCenter = __toolbar.center;
            }];
            [[anim addKeyFrame:0 duration:0.2 animations:^{
                __brushFeather.alpha = 0;
                __brushSize.alpha = 0;
                __label.alpha = 0;
            }] addKeyFrame:0.2 duration:0.2 animations:^{
                __brushOpacity.alpha = 1;
                __brushOpacity.hidden = NO;
                __brushOpacity.frame = CGRectX(oBrFrameOpacity, 0);
                __toolbar.center = CGPointMake(__toolbar.frame.size.width/2, __toolbar.center.y);
            }];
            
            anim2 = [anim addNextAnimationWithDuration:0.2 animations:^{
                __slider.alpha = 1;
                __confirmBtn.alpha = 1;
            }];
            [anim2 addPreAnimation:^(MysticAnimationBlockObject *object) {
                __slider.alpha = 0;
                __slider.hidden = NO;
                __confirmBtn.alpha = 0;
                __confirmBtn.hidden = NO;
            }];
            [anim finished:^(BOOL finished, MysticAnimationBlockObject *obj) {
                __slider.userInteractionEnabled = YES;
                __confirmBtn.userInteractionEnabled = YES;
                __brushFeather.hidden = YES;
                __brushSize.hidden = YES;
                __brushOpacity.hidden = NO;
                __confirmBtn.tag = MysticViewTypeButton2 + MysticBrushSettingOpacity;
                
            }];
            [MysticAnimation setAnimation:anim forKey:@"panelBrushOpacity"];
            
            
            // size animation
            anim = [MysticAnimation animationWithDuration:0.4];
            [anim addPreAnimation:^(MysticAnimationBlockObject *object) {
                if(CGRectIsUnknown(oBrFrameFeather)) oBrFrameFeather = __brushFeather.frame;
                if(CGRectIsUnknown(oBrFrameOpacity)) oBrFrameOpacity = __brushOpacity.frame;
                if(CGRectIsUnknown(oBrFrameSize)) oBrFrameSize = __brushSize.frame;
                if(CGRectIsUnknown(oToolbarFrame)) oToolbarFrame = __toolbar.frame;
                if(CGRectIsUnknown(oLabelFrame)) oLabelFrame = __label.frame;
                if(CGPointIsUnknown(oToolbarCenter)) oToolbarCenter = __toolbar.center;
            }];
            anim.animationOptions = UIViewAnimationCurveEaseInOut;
            [[anim addKeyFrame:0 duration:0.2 animations:^{
                __brushFeather.alpha = 0;
                __brushOpacity.alpha = 0;
                __label.alpha = 0;
            }] addKeyFrame:0.2 duration:0.2 animations:^{
                __brushSize.alpha = 1;
                __brushSize.hidden = NO;
                __brushSize.frame = CGRectX(oBrFrameSize, 0);
                [__brushSize setNeedsLayout];
                [__brushSize setNeedsDisplay];
                
                __toolbar.center = CGPointMake(__toolbar.frame.size.width/2, __toolbar.center.y);
            }];
            
            
            anim2 = [anim addNextAnimationWithDuration:0.2 animations:^{
                __slider.alpha = 1;
                __confirmBtn.alpha = 1;
            }];
            [anim2 addPreAnimation:^(MysticAnimationBlockObject *object) {
                __slider.alpha = 0;
                __slider.hidden = NO;
                __confirmBtn.alpha = 0;
                __confirmBtn.hidden = NO;
            }];
            
            [anim finished:^(BOOL finished, MysticAnimationBlockObject *obj) {
                __slider.userInteractionEnabled = YES;
                __confirmBtn.userInteractionEnabled = YES;
                __brushFeather.hidden = YES;
                __brushSize.hidden = NO;
                __brushOpacity.hidden = YES;
                __confirmBtn.tag = MysticViewTypeButton2 + MysticBrushSettingSize;
                [__brushSize setNeedsLayout];
                [__brushSize setNeedsDisplay];
            }];
            [MysticAnimation setAnimation:anim forKey:@"panelBrushSize"];
            
            
            // complete animation
            
            anim = [MysticAnimation animationWithDuration:0.4];
            anim.animationOptions = UIViewAnimationCurveEaseInOut;
            
            [[anim addKeyFrame:0 duration:0.2 animations:^{
                __slider.alpha = 0;
                __confirmBtn.alpha = 0;
            }] addKeyFrame:0.2 duration:0.2 animations:^{
                __brushFeather.frame = oBrFrameFeather;
                __toolbar.center = oToolbarCenter;
            }];
            
            anim2 = [anim addNextAnimationWithDuration:0.2 animations:^{
                __brushOpacity.alpha = 1;
                __brushSize.alpha = 1;
                __brushFeather.alpha = 1;
                __label.alpha = 1;
            }];
            [anim2 addPreAnimation:^(MysticAnimationBlockObject *object) {
                __slider.alpha = 0;
                __slider.hidden = YES;
                __confirmBtn.alpha = 0;
                __confirmBtn.hidden = YES;
                __brushFeather.hidden = NO;
                __brushSize.hidden = NO;
                __brushOpacity.hidden = NO;
            }];
            [anim finished:^(BOOL finished, MysticAnimationBlockObject *obj) {
                __slider.userInteractionEnabled = YES;
                __confirmBtn.userInteractionEnabled = YES;
            }];
            [MysticAnimation setAnimation:anim forKey:@"panelBrushComplete-feather"];
            
            anim = [MysticAnimation animationWithDuration:0.4];
            anim.animationOptions = UIViewAnimationCurveEaseInOut;
            
            [[anim addKeyFrame:0 duration:0.2 animations:^{
                __slider.alpha = 0;
                __confirmBtn.alpha = 0;
            }] addKeyFrame:0.2 duration:0.2 animations:^{
                __brushOpacity.frame = oBrFrameOpacity;
                __toolbar.center = oToolbarCenter;
            }];
            
            anim2 = [anim addNextAnimationWithDuration:0.2 animations:^{
                __brushOpacity.alpha = 1;
                __brushSize.alpha = 1;
                __brushFeather.alpha = 1;
                __label.alpha = 1;
            }];
            [anim2 addPreAnimation:^(MysticAnimationBlockObject *object) {
                __slider.alpha = 0;
                __slider.hidden = YES;
                __confirmBtn.alpha = 0;
                __confirmBtn.hidden = YES;
                __brushFeather.hidden = NO;
                __brushSize.hidden = NO;
                __brushOpacity.hidden = NO;
            }];
            [anim finished:^(BOOL finished, MysticAnimationBlockObject *obj) {
                __slider.userInteractionEnabled = YES;
                __confirmBtn.userInteractionEnabled = YES;
            }];
            [MysticAnimation setAnimation:anim forKey:@"panelBrushComplete-opacity"];
            
            anim = [MysticAnimation animationWithDuration:0.4];
            anim.animationOptions = UIViewAnimationCurveEaseInOut;
            
            [[anim addKeyFrame:0 duration:0.2 animations:^{
                __slider.alpha = 0;
                __confirmBtn.alpha = 0;
            }] addKeyFrame:0.2 duration:0.2 animations:^{
                __brushSize.frame = oBrFrameSize;
                __toolbar.center = oToolbarCenter;
            }];
            
            anim2 = [anim addNextAnimationWithDuration:0.2 animations:^{
                __brushOpacity.alpha = 1;
                __brushSize.alpha = 1;
                __brushFeather.alpha = 1;
                __label.alpha = 1;
            }];
            [anim2 addPreAnimation:^(MysticAnimationBlockObject *object) {
                __slider.alpha = 0;
                __slider.hidden = YES;
                __confirmBtn.alpha = 0;
                __confirmBtn.hidden = YES;
                __brushFeather.hidden = NO;
                __brushSize.hidden = NO;
                __brushOpacity.hidden = NO;
            }];
            [anim finished:^(BOOL finished, MysticAnimationBlockObject *obj) {
                __slider.userInteractionEnabled = YES;
                __confirmBtn.userInteractionEnabled = YES;
            }];
            [MysticAnimation setAnimation:anim forKey:@"panelBrushComplete-size"];
            [[MysticController controller].overlayView setupGestures:MysticSettingMaskLayer disable:NO];
            
            [__panelView resetBackgroundColor];
            __label.ready=YES;
            [__label updateState];
            break;
            
        }
#pragma mark - View - Sketch
            
        case MysticPanelTypeSketch:
        {
            CGRect subContentFrame = contentFrame;
            subContentFrame.origin.y = 0;
            subContentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SKETCH_TABS ;
            contentFrame.size.height = subContentFrame.size.height;
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"optionSketch"];
            subContentView.tag = MysticViewTypePanel + MysticViewTypeSubPanel;
            subContentView.autoresizesSubviews = NO;
            subContentView.clipsToBounds = NO;
            
            MysticTabBarSketch *subTabBar = [[MysticTabBarSketch alloc] initWithFrame:(CGRect){0,contentFrame.size.height - MYSTIC_UI_PANEL_HEIGHT_SKETCH_TABS, contentFrame.size.width, contentFrame.size.height}];
            subTabBar.tabBarDelegate = self.delegate;
            subTabBar.tabSelectedAction = @selector(sketchTabBar:selectedTab:);
            subTabBar.options = [MysticLayerPanelView tabsForOption:__panelView.targetOption type:MysticObjectTypeSketch];
            subTabBar.tag = MysticViewTypeTabBarPanelSketch + MysticViewTypePanel;
            subTabBar.hidden = NO;
            subTabBar.clipsToBounds = NO;
            subTabBar.userInteractionEnabled = YES;
            subTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            subTabBar.preventsScrollOnHide = YES;
            subTabBar.contentOffset = _lastTabBarOffset;
            _lastTabBarOffset = CGPointZero;
            self.layerPanelView.replacementTabBar = subTabBar;
            [subContentView addSubview:subTabBar];
            [subTabBar setNeedsDisplay];
            [subTabBar release];
            [__panelView resetBackgroundColor];
            
            break;
        }
#pragma mark - View - Settings Option
            
        case MysticPanelTypeOptionSettings:
        {
            CGRect subContentFrame = contentFrame;
            subContentFrame.origin.y = 0;
            subContentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SETTINGS_TABS ;
            contentFrame.size.height = subContentFrame.size.height;
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"optionSetting"];
            subContentView.tag = MysticViewTypePanel + MysticViewTypeSubPanel;
            subContentView.autoresizesSubviews = NO;
            //            subContentView.borderPosition = MysticPositionTop;
            //            subContentView.borderWidth = MYSTIC_UI_PANEL_BORDER;
            //            subContentView.borderInsets = UIEdgeInsetsMake(MYSTIC_UI_PANEL_BORDER/2, 0, 0, 0);
            //            subContentView.borderColor = [UIColor color:MysticColorTypePanelBorderColor];
            //            subContentView.showBorder = NO;
            subContentView.clipsToBounds = NO;
            
            MysticTabBarPanelSettings *subTabBar = [[MysticTabBarPanelSettings alloc] initWithFrame:(CGRect){0,contentFrame.size.height - MYSTIC_UI_PANEL_HEIGHT_SETTINGS_TABS, contentFrame.size.width, contentFrame.size.height}];
            subTabBar.tabBarDelegate = self;
            subTabBar.options = [MysticLayerPanelView tabsForOption:__panelView.targetOption type:MysticObjectTypeSetting];
            subTabBar.tag = MysticViewTypeTabBarPanelSettings + MysticViewTypePanel;
            subTabBar.hidden = NO;
            subTabBar.clipsToBounds = NO;
            subTabBar.userInteractionEnabled = YES;
            subTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            subTabBar.preventsScrollOnHide = YES;
            subTabBar.contentOffset = _lastTabBarOffset;
            _lastTabBarOffset = CGPointZero;
            self.layerPanelView.replacementTabBar = subTabBar;
            [subContentView addSubview:subTabBar];
            [subTabBar setNeedsDisplay];
            [subTabBar release];
            [__panelView resetBackgroundColor];
            
            break;
        }
#pragma mark - View - Layer Settings
            
        case MysticPanelTypeOptionImageLayerSettings:
        case MysticPanelTypeOptionLayerSettings:
        {
            [[MysticController controller].overlayView setupGestures:[MysticController controller].currentSetting disable:NO];
            
            CGRect subContentFrame = contentFrame;
            subContentFrame.origin.y = 0;
            subContentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SETTINGS_TABS ;
            contentFrame.size.height = subContentFrame.size.height;
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"optionLayerSettings"];
            subContentView.tag = MysticViewTypePanel + MysticViewTypeSubPanel;
            subContentView.autoresizesSubviews = NO;
            subContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            //            subContentView.borderPosition = MysticPositionTop;
            //            subContentView.borderWidth = MYSTIC_UI_PANEL_BORDER;
            //            subContentView.borderInsets = UIEdgeInsetsMake(MYSTIC_UI_PANEL_BORDER/2, 0, 0, 0);
            //            subContentView.borderColor = [UIColor color:MysticColorTypePanelBorderColor];
            //            subContentView.showBorder = NO;
            
            
            MysticTabBarPanelSettings *subTabBar = [[MysticTabBarPanelSettings alloc] initWithFrame:(CGRect){0,contentFrame.size.height - MYSTIC_UI_PANEL_HEIGHT_SETTINGS_TABS, contentFrame.size.width, MYSTIC_UI_PANEL_HEIGHT_SETTINGS_TABS}];
            subTabBar.tabBarDelegate = self;
            subTabBar.debug=NO;
            subTabBar.contentOffset = _lastTabBarOffset;
            _lastTabBarOffset = CGPointZero;
            subTabBar.options = [MysticLayerPanelView tabsForOption:__panelView.targetOption type:__panelView.targetOption.type];
            subTabBar.tag = MysticViewTypeTabBarPanelSettingsLayer + MysticViewTypePanel;
            subTabBar.hidden = NO;
            subTabBar.userInteractionEnabled = YES;
            subTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
            [subTabBar setNeedsDisplay];
            [subContentView addSubview:subTabBar];
            self.layerPanelView.replacementTabBar = subTabBar;
            [subTabBar release];
            [__panelView resetBackgroundColor];
            [[MysticController controller].overlayView setupGestures:MysticObjectTypeUnknown disable:NO];
            break;
        }
#pragma mark - View - Option Filter
            
        case MysticPanelTypeOptionFilter:
        {
            CGRect subContentFrame = contentFrame;
            subContentFrame.origin.y = 0;
            subContentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_FILTER;
            contentFrame.size.height = subContentFrame.size.height + MYSTIC_UI_CONTROLS_MARGIN;
            
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"optionFilter"];
            
            
            MysticFiltersScrollView *subContentScrollView = [[MysticFiltersScrollView alloc] initWithFrame:subContentFrame];
            __unsafe_unretained __block MysticFiltersScrollView *__subContentScrollView = (MysticFiltersScrollView *)subContentScrollView;
            __subContentScrollView.autoresizesSubviews = YES;
            __subContentScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            __subContentScrollView.showsHorizontalScrollIndicator = NO;
            __subContentScrollView.showsVerticalScrollIndicator = NO;
            __subContentScrollView.controlDelegate = self;
            __subContentScrollView.margin = MYSTIC_UI_CONTROLS_MARGIN;
            __subContentScrollView.controlInsets = UIEdgeInsetsMake(0, 0, 0, __subContentScrollView.margin);
            __subContentScrollView.tag = MysticViewTypeScrollView + MysticViewTypePanel;
            __subContentScrollView.cacheControlEnabled = YES;
            __subContentScrollView.shouldSelectActiveControls = YES;
            __subContentScrollView.enableControls = YES;
            __subContentScrollView.tileSize = CGSizeMake(__subContentScrollView.frame.size.width/5.5, __subContentScrollView.frame.size.height);
            weakSelf.controller.shouldSelectActiveControls = YES;
            [subContentView addSubview:__subContentScrollView];
            [subContentScrollView release];
            [__panelView resetDarkBackgroundColor];
            break;
        }
#pragma mark - View - Filter Settings
            
        case MysticPanelTypeOptionFilterSettings:
        {
            
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER;
            subContentView = (id)[[UIView alloc] initWithFrame:contentFrame];
            CGRect sliderFrame = CGRectInset(contentFrame, -25, 0);
            MysticSlider *adjustSlider = [MysticSlider panelSliderWithFrame:sliderFrame];
            adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider;
            adjustSlider.imageViewDelegate = weakSelf.controller;
            adjustSlider.refreshAction = @selector(refreshSliderAction:);
            adjustSlider.reloadAction = @selector(reloadSliderAction:);
            adjustSlider.finishAction = @selector(finishSliderAction:);
            adjustSlider.stillAction = @selector(stillSliderAction:);
            [adjustSlider setupActionsForSetting:__section.setting option:__panelView.targetOption animated:NO];
            [subContentView addSubview:adjustSlider];
            [__panelView resetBackgroundColor];
            break;
        }
#pragma mark - View - Grain
            
//        case MysticPanelTypeGrain:
//        {
//            
//            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER;
//            subContentView = (id)[[UIView alloc] initWithFrame:contentFrame];
//            CGRect sliderFrame = CGRectInset(contentFrame, -25, 0);
//            MysticSlider *adjustSlider = [MysticSlider panelSliderWithFrame:sliderFrame];
//            adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider;
//            adjustSlider.imageViewDelegate = weakSelf.controller;
//            adjustSlider.refreshAction = @selector(refreshSliderAction:);
//            adjustSlider.reloadAction = @selector(reloadSliderAction:);
//            adjustSlider.finishAction = @selector(finishSliderAction:);
//            adjustSlider.stillAction = @selector(stillSliderAction:);
//            [adjustSlider setupActionsForSetting:__section.setting option:__panelView.targetOption animated:NO];
//            [subContentView addSubview:adjustSlider];
//            [__panelView resetBackgroundColor];
//            break;
//        }
#pragma mark - View - Potions
            
        case MysticPanelTypePotions:
        {
            CGSize subScrollViewTileSize = (CGSize){0,0};
            CGRect subContentFrame = contentFrame;
            subContentFrame.origin.y = 0;
            subContentFrame.size.height = (scrollMargin)+MYSTIC_UI_PANEL_HEIGHT_POTIONS;
            subScrollViewTileSize = CGSizeMake(MYSTIC_UI_CONTROLS_TILEWIDTH_POTIONS, MYSTIC_UI_CONTROLS_TILEWIDTH_POTIONS );
            contentFrame.size.height = subContentFrame.size.height ;
            
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"potions"];
            
            
            MysticLayersScrollView *subContentScrollView = [[MysticLayersScrollView alloc] initWithFrame:subContentFrame];
            __unsafe_unretained __block MysticLayersScrollView *__subContentScrollView = (MysticLayersScrollView *)subContentScrollView;
            subContentScrollView.autoresizesSubviews = YES;
            subContentScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            __subContentScrollView.showsHorizontalScrollIndicator = NO;
            __subContentScrollView.showsVerticalScrollIndicator = NO;
            __subContentScrollView.controlDelegate = self;
            __subContentScrollView.margin = MYSTIC_UI_CONTROLS_MARGIN;
            __subContentScrollView.tag = MysticViewTypeScrollView + MysticViewTypePanel;
            __subContentScrollView.cacheControlEnabled = YES;
            __subContentScrollView.scrollDirection = MysticScrollDirectionHorizontal;
            __subContentScrollView.enableControls = YES;
            __subContentScrollView.tileSize = subScrollViewTileSize;
            __subContentScrollView.useHeaderControl = NO;
            
            weakSelf.controller.shouldSelectActiveControls = YES;
            [subContentView addSubview:subContentScrollView];
            [__panelView resetDarkBackgroundColor];
            
            [subContentScrollView release];
            
            break;
        }
#pragma mark - View - Layer & OptionSpecial
            
        case MysticPanelTypeOptionSpecial:
        case MysticPanelTypeOptionLayer:
        {
            [[MysticController controller].overlayView setupGestures:[MysticController controller].currentSetting disable:NO];
            CGSize subScrollViewTileSize = (CGSize){0,0};
            CGRect subContentFrame = contentFrame;
            subContentFrame.origin.y = 37;
            BOOL makePacks = YES;
            switch (__section.optionType) {
                case MysticObjectTypeColorOverlay:
                {
                    subContentFrame.origin.y = 0;
                    subContentFrame.size.height = (scrollMargin)+MYSTIC_UI_CONTROLS_TILEWIDTH_LAYER;
                    subScrollViewTileSize = CGSizeMake(MYSTIC_UI_CONTROLS_TILEWIDTH_LAYER, MYSTIC_UI_CONTROLS_TILEWIDTH_LAYER);
                    makePacks = NO;
                    break;
                }
                    
                default:
                {
                    subContentFrame.size.height = (scrollMargin)+MYSTIC_UI_PANEL_HEIGHT_LAYER;
                    subScrollViewTileSize = CGSizeMake(MYSTIC_UI_CONTROLS_TILEWIDTH_LAYER, MYSTIC_UI_CONTROLS_TILEWIDTH_LAYER );
                    break;
                }
            }
            contentFrame.size.height = subContentFrame.size.height + subContentFrame.origin.y;
            
            subContentView = [[MysticPanelSubView alloc] initWithFrame:makePacks ? contentFrame : subContentFrame name:@"optionSpecial optionLayer"];
            
            MysticLayersScrollView *subContentScrollView = [[MysticLayersScrollView alloc] initWithFrame:subContentFrame];
            __unsafe_unretained __block MysticLayersScrollView *__subContentScrollView = (MysticLayersScrollView *)subContentScrollView;
            __subContentScrollView.autoresizesSubviews = YES;
            __subContentScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            __subContentScrollView.showsHorizontalScrollIndicator = NO;
            __subContentScrollView.showsVerticalScrollIndicator = NO;
            __subContentScrollView.controlDelegate = self;
            __subContentScrollView.margin = MYSTIC_UI_CONTROLS_MARGIN;
            if(!makePacks)
            {
                __subContentScrollView.controlInsets = UIEdgeInsetsMake(__subContentScrollView.margin, 0, 0, __subContentScrollView.margin);

            }
            __subContentScrollView.tag = MysticViewTypeScrollView + MysticViewTypePanel;
            __subContentScrollView.cacheControlEnabled = YES;
            __subContentScrollView.scrollDirection = MysticScrollDirectionHorizontal;
            __subContentScrollView.enableControls = YES;
            __subContentScrollView.tileSize = subScrollViewTileSize;
            __subContentScrollView.tileOrigin = CGPointZero;
            __subContentScrollView.useHeaderControl = NO;
//            __subContentScrollView.useHeaderControl = section.panelType != MysticPanelTypeOptionSpecial;
            weakSelf.controller.shouldSelectActiveControls = YES;
            [subContentView addSubview:subContentScrollView];
            
            if(makePacks)
            {
                MysticPacksScrollView *packsScrollView = [[MysticPacksScrollView alloc] initWithFrame:CGRectMake(0, 0, subContentFrame.size.width, 38)];
                packsScrollView.tag = MysticViewTypeScrollView2 + MysticViewTypePanel;
                packsScrollView.autoresizesSubviews = YES;
                packsScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                packsScrollView.showsHorizontalScrollIndicator = NO;
                packsScrollView.showsVerticalScrollIndicator = NO;
                packsScrollView.controlDelegate = self;
                packsScrollView.margin = 18;
                packsScrollView.scrollDirection = MysticScrollDirectionHorizontal;
                
                [subContentView addSubview:packsScrollView];
                [packsScrollView release];
                
            
                MysticIndicatorView *iv = [[MysticIndicatorView alloc] initWithFrame:(CGRect){0,0,packsScrollView.frame.size.height, packsScrollView.frame.size.height}];
                packsScrollView.indicatorView = iv;
                [iv release];
            }
            [__panelView resetDarkBackgroundColor];
            [subContentScrollView release];
            break;
        }
#pragma mark - View - Move
            
        case MysticPanelTypeMove:
        {
            CGRect subContentFrame = contentFrame;
            subContentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_MOVE;
            subContentFrame.origin.y = MYSTIC_UI_PANEL_HEIGHT_MOVE;
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_MOVE * 2 ;
            
            MysticPanelSubView *_subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"typeMove"];
            //            _subContentView.borderPosition = MysticPositionBottom|MysticPositionCenter;
            //            _subContentView.showBorder = NO;
            subContentView = _subContentView;
            
            MysticMoveToolbar *toolbar = [MysticMoveToolbar toolbarWithFrame:CGRectMake(0, 0, contentFrame.size.width, MYSTIC_UI_PANEL_HEIGHT_MOVE)];
            toolbar.targetOption = panelView.targetOption;
            
            [subContentView addSubview:toolbar];
            
            MysticRotateScaleToolbar *toolbar2 = [MysticRotateScaleToolbar toolbarWithFrame:CGRectMake(0, MYSTIC_UI_PANEL_HEIGHT_MOVE, contentFrame.size.width, MYSTIC_UI_PANEL_HEIGHT_MOVE)];
            toolbar2.targetOption = panelView.targetOption;
            
            [subContentView addSubview:toolbar2];
            break;
        }
            
            
            
            
#pragma mark - View - Color & ColorAndIntensity
            
            
        case MysticPanelTypeColor:
        case MysticPanelTypeColorAndIntensity:
        {
            
            contentFrame.size.height = (scrollMargin)+MYSTIC_UI_PANEL_HEIGHT_COLORS;
            CGRect subContentFrame = contentFrame;
            subContentFrame.size.height -= MYSTIC_UI_CONTROLS_MARGIN;
            MysticPanelSubView *_subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"typeColorAndIntensity"];
            subContentView = _subContentView;
            
            CGRect subContentScrollFrame = subContentFrame;
            subContentScrollFrame.size.width -= contentFrame.size.height;
            subContentScrollFrame.size.width += 6;
            subContentScrollFrame.origin.x = contentFrame.size.height - 6;
            
            
            MysticColorsScrollView *__subContentView = (id)[[MysticColorsScrollView alloc] initWithFrame:subContentScrollFrame];
            
            __subContentView.tag = MysticViewTypeScrollView + MysticViewTypePanel;
            __subContentView.cacheControlEnabled = YES;
            __subContentView.showsHorizontalScrollIndicator = NO;
            __subContentView.showsVerticalScrollIndicator = NO;
            __subContentView.margin = MYSTIC_UI_CONTROLS_MARGIN;
            __subContentView.bufferItemsPerRow = 4;
            __subContentView.tileOrigin = (CGPoint){MYSTIC_UI_CONTROLS_MARGIN*3,0};
            __subContentView.tileSize = CGSizeMake(MYSTIC_UI_CONTROLS_TILEWIDTH_COLOR, __subContentView.frame.size.height);
            __subContentView.controlDelegate = self;
            [subContentView addSubview:[__subContentView autorelease]];
            
            
            MysticButton *colorWheel = [MysticButton buttonWithImage:[MysticImage image:@(MysticIconTypeToolColor) size:(CGSize){25,25} color:@(MysticColorTypeUnknown)] senderAction:^(MysticButton *sender) {
                
                MysticPanelSubView *___subContentView = (id)sender.superview;
                __block MysticColorsScrollView *___scrollView = (id)[___subContentView viewWithTag:MysticViewTypeScrollView + MysticViewTypePanel];
                if(___scrollView && [___scrollView isKindOfClass:[MysticScrollView class]])
                {
                    ___scrollView.ignoreScrollWhileRevealing = NO;
                    [___scrollView scrollToSelected:NO finished:^(EffectControl *selectedControl){
                        if(selectedControl)
                        {
                            [___scrollView.controlDelegate effectControl:selectedControl accessoryTouched:selectedControl.accessoryView];
                        }
                        else
                        {
                            [weakSelf.controller showColorInput:weakSelf.layerPanelView.targetOption title:nil color:[weakSelf.layerPanelView.targetOption color:MysticOptionColorTypeForeground] colorSetting:__section.setting colorChoice:MysticOptionColorTypeForeground colorOption:nil control:nil finished:nil];
                        }
                    }];
                }
                
                
            }];
            colorWheel.frame = CGRectMake(-4, 0, contentFrame.size.height - 1, contentFrame.size.height);
            CGRect colorWheelBorderFrame = colorWheel.frame;
            colorWheelBorderFrame.size.width += 2;
            colorWheelBorderFrame.origin.x = 0;
            MysticBorderView *borderView = [[MysticBorderView alloc] initWithFrame:colorWheel.frame];
            borderView.borderInsets = UIEdgeInsetsMake(MYSTIC_UI_PANEL_BORDER/2, 0, -MYSTIC_UI_PANEL_BORDER/2, 0);
            borderView.borderPosition = MysticPositionRight;
            borderView.borderWidth = MYSTIC_UI_PANEL_BORDER;
            borderView.borderColor = [UIColor color:MysticColorTypePanelBorderColor];
            
            borderView.showBorder = NO;
            
            
            [subContentView addSubview:[borderView autorelease]];
            [subContentView addSubview:colorWheel];
            
            break;
        }
#pragma mark - View - Blend
            
        case MysticPanelTypeBlend:
        {
            
            contentFrame.size.height = (MYSTIC_UI_CONTROLS_MARGIN)+MYSTIC_UI_PANEL_HEIGHT_BLEND;
            CGRect subContentFrame = contentFrame;
            subContentFrame.size.height -= MYSTIC_UI_CONTROLS_MARGIN;
            subContentView = (id)[[MysticBlendsScrollView alloc] initWithFrame:subContentFrame];
            __unsafe_unretained __block MysticBlendsScrollView *__subContentView = (MysticBlendsScrollView *)subContentView;
            subContentView.autoresizesSubviews = YES;
            subContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            __subContentView.showsHorizontalScrollIndicator = NO;
            __subContentView.showsVerticalScrollIndicator = NO;
            __subContentView.controlDelegate = self;
            __subContentView.margin = MYSTIC_UI_CONTROLS_MARGIN;
            subTag = MysticViewTypeScrollView + MysticViewTypePanel;
            __subContentView.tag = MysticViewTypeScrollView + MysticViewTypePanel;
            __subContentView.enableControls = YES;
            __subContentView.cacheControlEnabled = YES;
            __subContentView.bufferItemsPerRow = 4;
            
            __subContentView.tileSize = CGSizeMake(MYSTIC_UI_CONTROLS_TILEWIDTH_BLEND, __subContentView.frame.size.height);
            weakSelf.controller.shouldSelectActiveControls = YES;
            
            
            
            break;
        }
#pragma mark - View - Font
            
        case MysticPanelTypeFont:
        {
            
            CGRect subContentFrame = contentFrame;
            subContentFrame.origin.y = MYSTIC_UI_MENU_HEIGHT;
            subContentFrame.size.height = (scrollMargin)+MYSTIC_UI_PANEL_HEIGHT_FONT;
            contentFrame.size.height = subContentFrame.size.height + MYSTIC_UI_MENU_HEIGHT;
            
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"typeFont"];
            
            MysticFontToolbar *subToolbar = [MysticFontToolbar toolbarWithDelegate:weakSelf height:MYSTIC_UI_MENU_HEIGHT];
            subToolbar.targetOption = (PackPotionOptionFontStyle *)panelView.targetOption;
            subToolbar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
            [subContentView addSubview:subToolbar];
            
            
            
            MysticFontsScrollView *subContentScrollView = [[MysticFontsScrollView alloc] initWithFrame:subContentFrame];
            __unsafe_unretained __block MysticFontsScrollView *__subContentScrollView = (MysticFontsScrollView *)subContentScrollView;
            subContentScrollView.autoresizesSubviews = YES;
            subContentScrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
            __subContentScrollView.showsHorizontalScrollIndicator = NO;
            __subContentScrollView.showsVerticalScrollIndicator = NO;
            __subContentScrollView.controlDelegate = self;
            __subContentScrollView.cacheControlEnabled = YES;
            __subContentScrollView.margin = MYSTIC_UI_CONTROLS_MARGIN;
            __subContentScrollView.tag = MysticViewTypeScrollView + MysticViewTypePanel;
            __subContentScrollView.enableControls = YES;
            __subContentScrollView.bufferItemsPerRow = 4;
            
            __subContentScrollView.tileSize = CGSizeMake(MYSTIC_UI_CONTROLS_TILEWIDTH_FONT, __subContentScrollView.frame.size.height);
            weakSelf.controller.shouldSelectActiveControls = YES;
            
            
            [subContentView addSubview:subContentScrollView];
            [subContentScrollView release];
            [__panelView resetBackgroundColor];
            
            break;
        }
            
#pragma mark - View - Shapes
            
        case MysticPanelTypeShape:
        {
            CGRect subContentFrame = contentFrame;
            
            subContentFrame.origin.y = 0;
            subContentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_FONT_TABS;
            
            
            contentFrame.size.height = subContentFrame.size.height;
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"shape"];
            subContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            subContentView.backgroundColor = [UIColor hex:@"141412"];
            subContentView.autoresizesSubviews=NO;
            //            subContentView.borderPosition = MysticPositionTop;
            //            subContentView.borderWidth = MYSTIC_UI_PANEL_BORDER;
            //            subContentView.borderInsets = UIEdgeInsetsMake(MYSTIC_UI_PANEL_BORDER/2, 0, 0, 0);
            //            subContentView.borderColor = [UIColor color:MysticColorTypePanelBorderColor];
            //            subContentView.showBorder = NO;
            
            
            MysticTabBarShapes *subTabBar = [[MysticTabBarShapes alloc] initWithFrame:(CGRect){0,0, contentFrame.size.width, contentFrame.size.height}];
            subTabBar.tabBarDelegate = self.controller;
            subTabBar.contentOffset = _lastTabBarOffset;
            _lastTabBarOffset = CGPointZero;
            subTabBar.options = @[
                                  @{@"type": @(MysticSettingShapeAdd),
                                    @"icon": @(MysticIconTypeShapeAdd),
                                    @"margin": @(0.f),
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){34,22}],
                                    @"imageInsets": NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 2, 0, 0)),
                                    },
                                  
                                  
                                  @{@"type": @(MysticSettingShapeEdit),
                                    @"icon": @(MysticIconTypeShapeStyle),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){35,22}],
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    @"margin": @(0.f),
                                    @"imageInsets": NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 2, 0, 0)),
                                    
                                    
                                    },
                                  
                                  @{@"type": @(MysticSettingShapeMove), @"icon": @(MysticIconTypeShapeMove),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){22,22}],
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    },
                                  
                                  @{@"type": @(MysticSettingShapeAlign), @"icon": @(MysticIconTypeShapeAlign),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){22,22}],
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    },
                                  
                                  @{@"type": @(MysticSettingShapeClone), @"icon": @(MysticIconTypeShapeClone),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){22,22}],
                                    @"margin": @(0.f),
                                    @"imageInsets": NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 0, 0, 0)),
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    
                                    },
                                  
                                  
                                  
                                  @{@"type": @(MysticSettingShapeDelete),
                                    @"icon": @(MysticIconTypeShapeDelete),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){21,21}],
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    @"margin": @(0.f),
                                    },
                                  
                                  ];
            subTabBar.hidden = NO;
            subTabBar.userInteractionEnabled = YES;
            subTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            subTabBar.preventsScrollOnHide = YES;
            self.layerPanelView.replacementTabBar = subTabBar;
            [subContentView addSubview:subTabBar];
            [subTabBar setNeedsDisplay];
            [subTabBar release];
            
            [__panelView resetBackgroundColor];
            break;
        }
#pragma mark - View - Fonts
            
        case MysticPanelTypeFonts:
        {
            CGRect subContentFrame = contentFrame;
            
            subContentFrame.origin.y = 0;
            subContentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_FONT_TABS;
            
            
            contentFrame.size.height = subContentFrame.size.height;
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"typeFonts"];
            subContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            subContentView.backgroundColor = [UIColor hex:@"141412"];
            subContentView.autoresizesSubviews=NO;
            //            subContentView.borderPosition = MysticPositionTop;
            //            subContentView.borderWidth = MYSTIC_UI_PANEL_BORDER;
            //            subContentView.borderInsets = UIEdgeInsetsMake(MYSTIC_UI_PANEL_BORDER/2, 0, 0, 0);
            //            subContentView.borderColor = [UIColor color:MysticColorTypePanelBorderColor];
            //            subContentView.showBorder = NO;
            
            
            MysticTabBarFont *subTabBar = [[MysticTabBarFont alloc] initWithFrame:(CGRect){0,0, contentFrame.size.width, contentFrame.size.height}];
            subTabBar.tabBarDelegate = self.controller;
            subTabBar.contentOffset = _lastTabBarOffset;
            _lastTabBarOffset = CGPointZero;
            subTabBar.options = @[
                                  @{@"type": @(MysticSettingFontAdd), @"icon": @(MysticIconTypeFontAdd),
                                    @"margin": @(0.f),
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){28,22}],
                                    @"imageInsets": NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 2, 0, 0)),
                                    
                                    },
                                  
                                  @{@"type": @(MysticSettingFontEdit),
                                    @"icon": @(MysticIconTypeFontEdit),
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){21,19}], },
                                  
                                  @{@"type": @(MysticSettingFontStyle),
                                    @"icon": @(MysticIconTypeFontStyle),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){35,22}],
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    @"margin": @(0.f),
                                    
                                    },
                                  
                                  @{@"type": @(MysticSettingFontMove), @"icon": @(MysticIconTypeFontMove),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){22,22}],
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    },
                                  
                                  @{@"type": @(MysticSettingFontClone), @"icon": @(MysticIconTypeFontClone),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){22,22}],
                                    @"margin": @(0.f),
                                    @"imageInsets": NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 0, 0, 0)),
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    
                                    },
                                  
                                  
                                  
                                  @{@"type": @(MysticSettingFontDelete),
                                    @"icon": @(MysticIconTypeFontDelete),
                                    @"iconSize": [NSValue valueWithCGSize:(CGSize){21,21}],
                                    @"colorDisabled": @(MysticColorTypeTabIconDisabled),
                                    @"margin": @(0.f),
                                    
                                    },
                                  
                                  
                                  
                                  
                                  
                                  
                                  
                                  ];
            subTabBar.tag = MysticViewTypeTabBarFont;
            subTabBar.hidden = NO;
            subTabBar.userInteractionEnabled = YES;
            subTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            subTabBar.preventsScrollOnHide = YES;
            self.layerPanelView.replacementTabBar = subTabBar;
            [subContentView addSubview:subTabBar];
            [subTabBar setNeedsDisplay];
            [subTabBar release];
            
            [__panelView resetBackgroundColor];
            break;
        }
            
            
#pragma mark - View - MysticPanelTypeFontAlign
            
        case MysticPanelTypeFontAlign: break;
            
#pragma mark - View - Shadows & Highlights
            
        case MysticPanelTypeShadows:
        case MysticPanelTypeHighlights:
        {
            NSString *title = @"SHADOW";
            MysticObjectType subSetting = MysticSettingShadowIntensity;
            UIColor *tintColor = __panelView.targetOption.shadowTintColor ? __panelView.targetOption.shadowTintColor : [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            switch (section.sectionType)
            {
                case MysticPanelTypeHighlights:
                {
                    title = @"HIGHLIGHT";
                    subSetting = MysticSettingHighlightIntensity;
                    tintColor = __panelView.targetOption.highlightTintColor ? __panelView.targetOption.highlightTintColor : [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
                    break;
                }
                default: break;
            }
            CGFloat toneSize = 26;
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER + 40;
            subContentView = (id)[[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"hue,sat,tone..."];
            CGRect sliderFrame = CGRectY(CGRectInset(CGRectHeight(contentFrame, MYSTIC_UI_PANEL_HEIGHT_SLIDER), 15, 0), 40);
            MysticSlider *adjustSlider = [MysticSlider panelSliderWithFrame:sliderFrame];
            adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider;
            adjustSlider.imageViewDelegate = weakSelf.controller;
            adjustSlider.refreshAction = @selector(refreshSliderAction:);
            adjustSlider.reloadAction = @selector(reloadSliderAction:);
            adjustSlider.finishAction = @selector(finishSliderAction:);
            adjustSlider.stillAction = @selector(stillSliderAction:);
            [adjustSlider setupActionsForSetting:__section.setting option:__panelView.targetOption animated:NO];
            CGFloat padding = 7;
            CGSize btnsSize = CGSizeMake(0, sliderFrame.origin.y);
            MysticSubSettingButton *intensityBtn = [MysticSubSettingButton buttonWithTitle:title senderAction:^(MysticSubSettingButton *sender) {
                for (MysticSubSettingButton*sibling in sender.superview.subviews) if([sibling isKindOfClass:[sender class]]) sibling.selected = NO;
                UIView *slider = [sender.superview viewWithTag:MysticViewTypePanel + MysticViewTypeSlider];
                UIView *toneView = [sender.superview viewWithTag:MysticViewTypeSubPanel];
                slider.hidden = NO;
                toneView.hidden = YES;
                sender.selected = YES;
                BOOL rc = [__panelView.targetOption hasAdjusted:__section.setting];
                BOOL gc = [__panelView.targetOption hasAdjusted:subSetting];
                if(rc || !gc) [MysticUser setTemp:@(1) key:[NSString stringWithFormat:@"setting-sh%d",subSetting]];
                if(!rc && gc && [MysticUser temp:[NSString stringWithFormat:@"setting-sh%d",subSetting] int:0]!=2) [MysticUser setTemp:@(2) key:[NSString stringWithFormat:@"setting-sh%d",subSetting]];
            }];
            [intensityBtn setTitleColor:[UIColor color:MysticColorTypeBackgroundWhite] forState:UIControlStateSelected];
            [intensityBtn setTitleColor:[UIColor hex:@"292522"] forState:UIControlStateHighlighted];
            btnsSize.width += intensityBtn.frame.size.width + padding;
            
            MysticSubSettingButton *toneBtn = [MysticSubSettingButton buttonWithTitle:@"TINT" senderAction:^(MysticSubSettingButton *sender) {
                for (MysticSubSettingButton*sibling in sender.superview.subviews) if([sibling isKindOfClass:[sender class]]) sibling.selected = NO;
                UIView *slider = [sender.superview viewWithTag:MysticViewTypePanel + MysticViewTypeSlider];
                UIView *toneView = [sender.superview viewWithTag:MysticViewTypeSubPanel];
                slider.hidden = YES;
                toneView.hidden = NO;
                sender.selected = YES;
                BOOL rc = [__panelView.targetOption hasAdjusted:__section.setting];
                BOOL gc = [__panelView.targetOption hasAdjusted:subSetting];
                if(!rc || gc) [MysticUser setTemp:@(2) key:[NSString stringWithFormat:@"setting-sh%d",subSetting]];
                if(rc && !gc && [MysticUser temp:[NSString stringWithFormat:@"setting-sh%d",subSetting] int:0]!=1) [MysticUser setTemp:@(1) key:[NSString stringWithFormat:@"setting-sh%d",subSetting]];
            }];
            [toneBtn setTitleColor:[UIColor color:MysticColorTypeBackgroundWhite] forState:UIControlStateSelected];
            [toneBtn setTitleColor:[UIColor hex:@"292522"] forState:UIControlStateHighlighted];
            btnsSize.width += toneBtn.frame.size.width + padding;
            intensityBtn.frame = CGRectXYH(intensityBtn.frame,(contentFrame.size.width - btnsSize.width)/2,14,38);
            toneBtn.frame = CGRectXW(intensityBtn.frame, intensityBtn.frame.origin.x + intensityBtn.frame.size.width + padding, toneBtn.frame.size.width);
            intensityBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            toneBtn.autoresizingMask = intensityBtn.autoresizingMask;
            [subContentView addSubview:adjustSlider];
            UIView *toneView = [[[UIView alloc] initWithFrame:sliderFrame] autorelease];
            toneView.tag = MysticViewTypeSubPanel;
            MysticSlider *adjustSlider2 = [MysticSlider panelSliderWithFrame:CGRectAddXW(CGRectY(sliderFrame,0), toneSize, -(toneSize+15))];
            adjustSlider2.tag = MysticViewTypePanel + MysticViewTypeSlider + MysticViewTypeSubPanel;
            adjustSlider2.imageViewDelegate = weakSelf.controller;
            adjustSlider2.refreshAction = @selector(refreshSliderAction:);
            adjustSlider2.reloadAction = @selector(reloadSliderAction:);
            adjustSlider2.finishAction = @selector(finishSliderAction:);
            adjustSlider2.stillAction = @selector(stillSliderAction:);
            adjustSlider2.trackImage = [MysticImage image:[UIImage imageNamed:@"slider-mystic-track"] color:[tintColor alpha:1]];
            [adjustSlider2 setupActionsForSetting:subSetting option:__panelView.targetOption animated:NO];
            MysticColorButton *colorBtn = [MysticColorButton colorButton:tintColor title:title option:__panelView.targetOption action:^(MysticColorButton *sender, UIColor *color, id obj2, BOOL success) {
                switch(subSetting)
                {
                    case MysticSettingShadowIntensity: {
                        success = [[sender.option.shadowTintColor alpha:1] isEqualToColor:[color alpha:1]];
                        sender.option.shadowTintColor = color;
                        [[MysticOptions current].filters.filter setShadowIntensity:sender.option.shadowIntensity tint:sender.option.shadowTintColor index:sender.option.shaderIndex option:sender.option];
                        break;
                    }
                    case MysticSettingHighlightIntensity: {
                        success = [[sender.option.highlightTintColor alpha:1] isEqualToColor:[color alpha:1]];
                        sender.option.highlightTintColor = color;
                        [[MysticOptions current].filters.filter setHighlightIntensity:sender.option.highlightIntensity tint:sender.option.highlightTintColor index:sender.option.shaderIndex option:sender.option];
                        break;
                    }
                    default: break;
                }
                [MysticEffectsManager refresh:sender.option];
                MysticSlider *slider = [sender.superview viewWithTag: MysticViewTypePanel + MysticViewTypeSlider + MysticViewTypeSubPanel];
                if(slider) { slider.trackImage = [MysticImage image:slider.trackImage color:[color alpha:1]]; [slider setNeedsLayout]; [slider setNeedsDisplay]; }
                if(success) return;

            }];
            colorBtn.frame = CGRectMake(0, (MYSTIC_UI_PANEL_HEIGHT_SLIDER - toneSize)/2, toneSize, toneSize);
            toneBtn.selected = [MysticUser temp:[NSString stringWithFormat:@"setting-sh%d",subSetting] int:0]==2;
            intensityBtn.selected = [MysticUser temp:[NSString stringWithFormat:@"setting-sh%d",subSetting] int:1]==1;
            adjustSlider.hidden = !intensityBtn.selected;
            toneView.hidden = !adjustSlider.hidden;
            [toneView addSubview:colorBtn];
            [toneView addSubview:adjustSlider2];
            [subContentView addSubview:toneView];
            [subContentView addSubview:intensityBtn];
            [subContentView addSubview:toneBtn];
            [__panelView resetBackgroundColor];
            __panelView.targetOption.refreshState = !adjustSlider.hidden ? __section.setting : subSetting;
            [[MysticController controller].overlayView setupGestures:MysticObjectTypeUnknown disable:YES];
            break;
        }
#pragma mark - View - Hue, Saturation, Tone, Brightness, etc...
            
        case MysticPanelTypeHue:
        case MysticPanelTypeSaturation:
        case MysticPanelTypeTone:
        case MysticPanelTypeVibrance:
        case MysticPanelTypeBrightness:
        case MysticPanelTypeContrast:
        case MysticPanelTypeHaze:
        case MysticPanelTypeGamma:
        case MysticPanelTypeUnsharpMask:
        case MysticPanelTypeSharpness:
        case MysticPanelTypeExposure:
        case MysticPanelTypeGrain:
        case MysticPanelTypeSlider:
        case MysticPanelTypeAdjust:
        case MysticPanelTypeToon:
        case MysticPanelTypeHalftone:
        case MysticPanelTypePixellate:
        case MysticPanelTypePosterize:
        case MysticPanelTypeSketchFilter:
        
        case MysticPanelTypeBlur:
        {
            switch(section.panelType)
            {
                case MysticPanelTypeToon:
                {
                    __panelView.targetOption.toonWidth = ktoonWidth;
                    __panelView.targetOption.toonHeight = ktoonHeight;
                    __panelView.targetOption.toonLevels = ktoonLevels;
                    __panelView.targetOption.toonThreshold = ktoonThreshold;

                    break;
                }
                case MysticPanelTypeHalftone:
                {
                    __panelView.targetOption.halftonePixelWidth = khalftonePixelWidth;
                    break;
                }
                case MysticPanelTypePixellate:
                {
                    __panelView.targetOption.pixellatePixelWidth = kpixellatePixelWidth;
                    break;
                }
                case MysticPanelTypePosterize:
                {
                    __panelView.targetOption.posterizeLevels = kposterizeLevels;
                    break;
                }
                case MysticPanelTypeSketchFilter:
                {
                    __panelView.targetOption.sketchWidth = ksketchWidth;
                    __panelView.targetOption.sketchHeight = ksketchHeight;
                    __panelView.targetOption.sketchStrength = ksketchStrength;

                    break;
                }
                case MysticPanelTypeUnsharpMask:
                {
                    __panelView.targetOption.unsharpMask = kUnsharpMask;
                    __panelView.targetOption.unsharpBlurRadius = kunsharpBlurRadius;
                    break;
                }
                default: break;
            }
            
            
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER;
            subContentView = (id)[[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"hue,sat,tone..."];
            CGRect sliderFrame = CGRectInset(contentFrame, 15, 0);
            MysticSlider *adjustSlider = [MysticSlider panelSliderWithFrame:sliderFrame];
            adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider;
            adjustSlider.imageViewDelegate = weakSelf.controller;
            adjustSlider.refreshAction = @selector(refreshSliderAction:);
            adjustSlider.reloadAction = @selector(reloadSliderAction:);
            adjustSlider.finishAction = @selector(finishSliderAction:);
            adjustSlider.stillAction = @selector(stillSliderAction:);
            [adjustSlider setupActionsForSetting:__section.setting option:__panelView.targetOption animated:NO];
            [subContentView addSubview:adjustSlider];
            [__panelView resetBackgroundColor];
            __panelView.targetOption.blurRadius = kblurRadius;
            __panelView.targetOption.blurPasses = kblurPasses;
            [[MysticController controller].overlayView setupGestures:MysticObjectTypeUnknown disable:YES];
//            DLogError(@"showing setting panel: %d -> %d", (int)section.sectionType, (int)MysticPanelTypeTiltShift );
            break;
        }
        case MysticPanelTypeBlurCircle:
        {
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER;
            subContentView = (id)[[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"hue,sat,tone..."];
            CGRect sliderFrame = CGRectInset(contentFrame, 15, 0);
            MysticSlider *adjustSlider = [MysticSlider panelSliderWithFrame:sliderFrame];
            adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider;
            adjustSlider.imageViewDelegate = weakSelf.controller;
            adjustSlider.refreshAction = @selector(refreshSliderAction:);
            adjustSlider.reloadAction = @selector(reloadSliderAction:);
            adjustSlider.finishAction = @selector(finishSliderAction:);
            adjustSlider.stillAction = @selector(stillSliderAction:);
            [adjustSlider setupActionsForSetting:__section.setting option:__panelView.targetOption animated:NO];
            [subContentView addSubview:adjustSlider];
            [__panelView resetBackgroundColor];
            CGPoint centerDotPoint = [weakSelf.controller.imageView.imageView.superview convertPoint:weakSelf.controller.imageView.imageView.center toView:weakSelf.controller.view];
            
            MysticDotView *centerDot = [MysticDotView dot:centerDotPoint color:MysticColorTypeWhite size:16 borderWidth:3];
            centerDot.hitInsets = UIEdgeInsetsMake(-14, -14, -14, -14);
            [weakSelf.controller.view addSubview:centerDot];
            centerDot.tag = MysticViewTypeButton1;
            centerDot.backgroundColor = [[UIColor colorWithCGColor:centerDot.layer.borderColor] colorWithAlphaComponent:0.4];
            centerDot.userInteractionEnabled = NO;
            UIView *circleView = [[UIView alloc] initWithFrame:CGRectS(weakSelf.controller.imageView.imageView.frame, CGSizeSquare(weakSelf.controller.imageView.imageView.frame.size))];
            MBorder(circleView, [[UIColor colorWithCGColor:centerDot.layer.borderColor] colorWithAlphaComponent:0.5], 1.5);
            circleView.tag = MysticViewTypeButton2;
            circleView.layer.cornerRadius = circleView.frame.size.height/2;
            circleView.userInteractionEnabled = NO;
            [weakSelf.controller.view addSubview:circleView];
            __panelView.targetOption.blurCircleExcludeRadius = kblurCircleExcludeRadius;
            __panelView.targetOption.blurCircleExcludeSize = kblurCircleExcludeSize;
            __panelView.targetOption.blurCircleAspectRatio = kblurCircleAspectRatio;
            __panelView.targetOption.blurCircleRadius = kblurCircleRadius;
            __panelView.targetOption.blurCirclePoint = (CGPoint){.5,.5};

            [weakSelf.controller.extraControls addObjectsFromArray:@[centerDot,circleView]];
            weakSelf.controller.extraControlsSetting = MysticSettingBlurCircle;
            [[MysticController controller].overlayView setupGestures:MysticSettingBlurCircle disable:NO];
            break;
        }
        case MysticPanelTypeDistortSwirl:
        case MysticPanelTypeBlurMotion:
        {
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER;
            subContentView = (id)[[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"hue,sat,tone..."];
            CGRect sliderFrame = CGRectInset(contentFrame, 15, 0);
            MysticSlider *adjustSlider = [MysticSlider panelSliderWithFrame:sliderFrame];
            adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider;
            adjustSlider.imageViewDelegate = weakSelf.controller;
            adjustSlider.refreshAction = @selector(refreshSliderAction:);
            adjustSlider.reloadAction = @selector(reloadSliderAction:);
            adjustSlider.finishAction = @selector(finishSliderAction:);
            adjustSlider.stillAction = @selector(stillSliderAction:);
            [adjustSlider setupActionsForSetting:__section.setting option:__panelView.targetOption animated:NO];
            [subContentView addSubview:adjustSlider];
            [__panelView resetBackgroundColor];
            CGPoint centerDotPoint = [weakSelf.controller.imageView.imageView.superview convertPoint:weakSelf.controller.imageView.imageView.center toView:weakSelf.controller.view];
            
            MysticDotView *centerDot = [MysticDotView dot:centerDotPoint color:MysticColorTypeWhite size:10 borderWidth:3];
            centerDot.hitInsets = UIEdgeInsetsMake(-14, -14, -14, -14);
            [weakSelf.controller.view addSubview:centerDot];
            centerDot.tag = MysticViewTypeButton1;
            centerDot.backgroundColor = [[UIColor colorWithCGColor:centerDot.layer.borderColor] colorWithAlphaComponent:0.4];
            centerDot.userInteractionEnabled = NO;
            
            CGPoint angleDotPoint = centerDotPoint;
            angleDotPoint.x = weakSelf.controller.imageView.imageView.frame.size.width/6;
            MysticDotView *angleDot = [MysticDotView dot:angleDotPoint color:MysticColorTypeWhite size:16 borderWidth:3];
            angleDot.hitInsets = UIEdgeInsetsMake(-14, -14, -14, -14);
            [weakSelf.controller.view addSubview:angleDot];
            angleDot.tag = MysticViewTypeButton2;
            angleDot.backgroundColor = [[UIColor colorWithCGColor:angleDot.layer.borderColor] colorWithAlphaComponent:0.4];
            angleDot.userInteractionEnabled = NO;
//            [angleDot connectTo:centerDot color:[UIColor colorWithCGColor:angleDot.layer.borderColor]];
            switch(section.panelType)
            {
                case MysticPanelTypeDistortSwirl:
                {
                    __panelView.targetOption.swirlAngle = kswirlAngle;
                    __panelView.targetOption.swirlRadius = kswirlRadius;
                    __panelView.targetOption.swirlCenter = (CGPoint){.5,.5};
                    break;
                }
                case MysticPanelTypeBlurMotion:
                {
                    __panelView.targetOption.blurMotionSize = kblurMotionSize;
                    __panelView.targetOption.blurMotionAngle = kblurMotionAngle;
                    break;
                }
                default: break;
            }
            [weakSelf.controller.extraControls addObjectsFromArray:@[centerDot,angleDot]];
            weakSelf.controller.extraControlsSetting = __section.setting;
            [[MysticController controller].overlayView setupGestures:__section.setting disable:NO];
            break;
        }
        case MysticPanelTypeDistortGlassSphere:
        case MysticPanelTypeDistortPinch:
        case MysticPanelTypeDistortBuldge:
        case MysticPanelTypeDistortStretch:
        case MysticPanelTypeBlurZoom:
        {
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER;
            subContentView = (id)[[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"hue,sat,tone..."];
            CGRect sliderFrame = CGRectInset(contentFrame, 15, 0);
            if(section.panelType != MysticPanelTypeDistortStretch)
            {
                MysticSlider *adjustSlider = [MysticSlider panelSliderWithFrame:sliderFrame];
                adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider;
                adjustSlider.imageViewDelegate = weakSelf.controller;
                adjustSlider.refreshAction = @selector(refreshSliderAction:);
                adjustSlider.reloadAction = @selector(reloadSliderAction:);
                adjustSlider.finishAction = @selector(finishSliderAction:);
                adjustSlider.stillAction = @selector(stillSliderAction:);
                [adjustSlider setupActionsForSetting:__section.setting option:__panelView.targetOption animated:NO];
                [subContentView addSubview:adjustSlider];
            }
            [__panelView resetBackgroundColor];
            CGPoint centerDotPoint = [weakSelf.controller.imageView.imageView.superview convertPoint:weakSelf.controller.imageView.imageView.center toView:weakSelf.controller.view];
            
            MysticDotView *centerDot = [MysticDotView dot:centerDotPoint color:MysticColorTypeWhite size:16 borderWidth:3];
            centerDot.hitInsets = UIEdgeInsetsMake(-14, -14, -14, -14);
            [weakSelf.controller.view addSubview:centerDot];
            centerDot.tag = MysticViewTypeButton1;
            centerDot.backgroundColor = [[UIColor colorWithCGColor:centerDot.layer.borderColor] colorWithAlphaComponent:0.4];
            centerDot.userInteractionEnabled = NO;
            
            switch(section.panelType)
            {
                case MysticPanelTypeDistortGlassSphere:
                {
                    __panelView.targetOption.sphereRadius = ksphereRadius;
                    __panelView.targetOption.sphereRefractiveIndex = ksphereRefractiveIndex;
                    __panelView.targetOption.sphereCenter = (CGPoint){.5,.5};
                    break;
                }
                case MysticPanelTypeDistortPinch:
                {
                    __panelView.targetOption.pinchScale = kpinchScale;
                    __panelView.targetOption.pinchRadius = kpinchRadius;
                    __panelView.targetOption.pinchCenter = (CGPoint){.5,.5};
                    break;
                }
                case MysticPanelTypeDistortBuldge:
                {
                    __panelView.targetOption.buldgeRadius = kbuldgeRadius;
                    __panelView.targetOption.buldgeScale = kbuldgeScale;
                    __panelView.targetOption.buldgeCenter = (CGPoint){.5,.5};
                    break;
                }
                case MysticPanelTypeDistortStretch:
                {
                    
                    __panelView.targetOption.stretchCenter = (CGPoint){.5,.5};
                    break;
                }
                case MysticPanelTypeBlurZoom:
                {
                    __panelView.targetOption.blurZoomSize = kblurZoomSize;
                    __panelView.targetOption.blurZoomCenter = (CGPoint){.5,.5};
                    break;
                }
                
                default: break;
            }
            [weakSelf.controller.extraControls addObjectsFromArray:@[centerDot]];
            weakSelf.controller.extraControlsSetting = __section.setting;
            [[MysticController controller].overlayView setupGestures:__section.setting disable:NO];
            break;
        }
            
#pragma mark - View - Tilt Shift
        case MysticPanelTypeTiltShift:
        {
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER;
            subContentView = (id)[[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"hue,sat,tone..."];
            CGRect sliderFrame = CGRectInset(contentFrame, 15, 0);
            MysticSlider *adjustSlider = [MysticSlider panelSliderWithFrame:sliderFrame];
            adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider;
            adjustSlider.imageViewDelegate = weakSelf.controller;
            adjustSlider.refreshAction = @selector(refreshSliderAction:);
            adjustSlider.reloadAction = @selector(reloadSliderAction:);
            adjustSlider.finishAction = @selector(finishSliderAction:);
            adjustSlider.stillAction = @selector(stillSliderAction:);
            __panelView.targetOption.tiltShiftTop = ktiltShiftTop;
            __panelView.targetOption.tiltShiftBottom = ktiltShiftBottom;
            __panelView.targetOption.tiltShiftBlurSizeInPixels = ktiltShiftBlurSizeInPixels;
            __panelView.targetOption.tiltShiftFallOff = ktiltShiftFallOff;

            [adjustSlider setupActionsForSetting:__section.setting option:__panelView.targetOption animated:NO];
            [subContentView addSubview:adjustSlider];
            [__panelView resetBackgroundColor];
            
            
            CGRect imageViewFrame = weakSelf.controller.imageView.imageView.frame;

            CGPoint centerDotPoint = [weakSelf.controller.imageView.imageView.superview convertPoint:weakSelf.controller.imageView.imageView.center toView:weakSelf.controller.view];
//            MysticDotView *centerDot = [MysticDotView dot:centerDotPoint color:MysticColorTypeBlack size:5 borderWidth:2];
//            [weakSelf.controller.view addSubview:centerDot];
//            
            CGPoint topDotPoint = [weakSelf.controller.imageView.imageView.superview convertPoint:weakSelf.controller.imageView.imageView.center toView:weakSelf.controller.view];
            CGPoint topDotPoint2 = topDotPoint;
            topDotPoint.y = 0;
            topDotPoint2.y = topDotPoint2.y + (imageViewFrame.size.height *ktiltShiftFallOff);

            CGPoint bottomDotPoint = (CGPoint){centerDotPoint.x, topDotPoint.y + imageViewFrame.size.height};
            CGPoint bottomDotPoint2 = bottomDotPoint2;
            bottomDotPoint2.y -= (imageViewFrame.size.height *ktiltShiftFallOff);
            
//            MysticDotView *topDot = [MysticDotView dot:topDotPoint color:MysticColorTypeBlack size:11 borderWidth:2];
//            MysticDotView *topDot2 = [MysticDotView dot:topDotPoint2 color:MysticColorTypeBlack size:7 borderWidth:2];
//            MysticDotView *bottomDot = [MysticDotView dot:bottomDotPoint color:MysticColorTypeBlack size:11 borderWidth:2];
//            MysticDotView *bottomDot2 = [MysticDotView dot:bottomDotPoint2 color:MysticColorTypeBlack size:7 borderWidth:2];
            MysticDotView *topDot = [MysticDotView dot:topDotPoint color:MysticColorTypeWhite size:16 borderWidth:3];
            MysticDotView *topDot2 = [MysticDotView dot:topDotPoint2 color:MysticColorTypeWhite size:10 borderWidth:3];
            MysticDotView *bottomDot = [MysticDotView dot:bottomDotPoint color:MysticColorTypeWhite size:16 borderWidth:3];
            MysticDotView *bottomDot2 = [MysticDotView dot:bottomDotPoint2 color:MysticColorTypeWhite size:10 borderWidth:3];
            
            topDot.hitInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
            bottomDot.hitInsets = topDot.hitInsets;
            topDot2.hitInsets = UIEdgeInsetsMake(-14, -14, -14, -14);
            bottomDot2.hitInsets = topDot2.hitInsets;
            

            [weakSelf.controller.view addSubview:topDot2];
            
            [weakSelf.controller.view addSubview:bottomDot2];
            [weakSelf.controller.view addSubview:topDot];
            [weakSelf.controller.view addSubview:bottomDot];
            
            topDot.tag = MysticViewTypeButton1;
            topDot2.tag = MysticViewTypeButton2;
            bottomDot.tag = MysticViewTypeButton3;
            bottomDot2.tag = MysticViewTypeButton4;

            topDot.backgroundColor = [[UIColor colorWithCGColor:topDot.layer.borderColor] colorWithAlphaComponent:0.4];
            bottomDot.backgroundColor = topDot.backgroundColor;
            topDot2.backgroundColor = [topDot.backgroundColor colorWithAlphaComponent:0.1];
            bottomDot2.backgroundColor = [topDot.backgroundColor colorWithAlphaComponent:0.1];
            
            [weakSelf.controller.extraControls addObjectsFromArray:@[topDot,topDot2,bottomDot,bottomDot2]];
            weakSelf.controller.extraControlsSetting = MysticSettingTiltShift;
            [[MysticController controller].overlayView setupGestures:MysticSettingTiltShift disable:NO];
            
            
            break;
        }
#ifdef DEBUG
        case MysticPanelTypeTest:
        {
            GPUImageView *imageView = [MysticOptions current].imageView;

            GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:[UserPotion potion].sourceImage];

            GPUImageTiltShiftFilter *tilt = [[GPUImageTiltShiftFilter alloc] init];
            tilt.bottomFocusLevel = 1;
            tilt.topFocusLevel = 0.6;
            tilt.focusFallOffRate = 0.25;
            
            
            GPUImageSharpenFilter *sharpen = [[GPUImageSharpenFilter alloc] init];
            sharpen.sharpness = 0.0;
            
            [source addTarget:tilt];
            [tilt addTarget:sharpen];
            [sharpen addTarget:imageView];
            
//            [source addTarget:sharpen];
//            [sharpen addTarget:tilt];
//            [tilt addTarget:imageView];
            [source processImage];
            
            
            
            
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER;
            subContentView = (id)[[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"hue,sat,tone..."];
            CGRect sliderFrame = CGRectInset(contentFrame, 15, 0);
            MysticSlider *adjustSlider = [MysticSlider panelSliderWithFrame:sliderFrame];
            adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider;
            adjustSlider.imageViewDelegate = weakSelf.controller;
            adjustSlider.refreshAction = @selector(refreshSliderAction:);
            adjustSlider.reloadAction = @selector(reloadSliderAction:);
            adjustSlider.finishAction = @selector(finishSliderAction:);
            adjustSlider.stillAction = @selector(stillSliderAction:);
            
            [adjustSlider setTestFilter:sharpen forKey:@"sharpen"];
            [adjustSlider setTestFilter:tilt forKey:@"tilt"];
            [adjustSlider setTestFilter:source forKey:@"source"];

            [adjustSlider setupActionsForSetting:__section.setting option:__panelView.targetOption animated:NO];
            [subContentView addSubview:adjustSlider];
            [__panelView resetBackgroundColor];
            [[MysticController controller].overlayView setupGestures:MysticObjectTypeUnknown disable:YES];
            break;
        }
#endif
            
#pragma mark - View - Skin
        case MysticPanelTypeSkin:
        case MysticPanelTypeSkinHue:
        case MysticPanelTypeSkinHueThreshold:
        case MysticPanelTypeSkinHueMaxShift:
        case MysticPanelTypeSkinMaxSaturationShift:
        case MysticPanelTypeSkinUpperTone:
        {
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER;
            subContentView = (id)[[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"hue,sat,tone..."];
            CGFloat skinIconSize = 26;
            CGRect sliderFrame = CGRectInset(contentFrame, 15, 0);
            sliderFrame.size.width -= skinIconSize+30;
            sliderFrame.origin.x += skinIconSize+30;
            MysticSlider *adjustSlider = [MysticSlider panelSliderWithFrame:sliderFrame];
            adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider;
            adjustSlider.imageViewDelegate = weakSelf.controller;
            adjustSlider.refreshAction = @selector(refreshSliderAction:);
            adjustSlider.reloadAction = @selector(reloadSliderAction:);
            adjustSlider.finishAction = @selector(finishSliderAction:);
            adjustSlider.stillAction = @selector(stillSliderAction:);
            [adjustSlider setupActionsForSetting:__section.setting option:__panelView.targetOption animated:NO];
            [subContentView addSubview:adjustSlider];
            [__panelView resetBackgroundColor];
            
            MysticButton *btn = [MysticButton button:[MysticIcon iconForType:MysticIconTypeSkin color:[UIColor greenColor]] action:^(MysticButton *sender) {
                [MysticController controller].transformOption.skinUpperTone = sender.selected ? 0 : 1;
                sender.selected = !sender.selected;
                [[MysticOptions current].filters.filter setSkin:[MysticController controller].transformOption.skinToneAdjust hue:[MysticController controller].transformOption.skinHue hueThreshold:[MysticController controller].transformOption.skinHueThreshold maxHueShift:[MysticController controller].transformOption.skinHueMaxShift maxSaturation:[MysticController controller].transformOption.skinMaxSaturation upperTone:[MysticController controller].transformOption.skinUpperTone index:[MysticController controller].transformOption.shaderIndex option:[MysticController controller].transformOption];
                [MysticEffectsManager refresh:[MysticController controller].transformOption];
            }];
            [btn setImage:[MysticIcon iconForType:MysticIconTypeSkin color:[UIColor orangeColor]] forState:UIControlStateSelected];
            btn.selected = [MysticController controller].transformOption.skinUpperTone == 0 ? NO:YES;
            btn.frame = CGRectMake(15, (MYSTIC_UI_PANEL_HEIGHT_SLIDER-skinIconSize)/2, skinIconSize, skinIconSize);
            PackPotionOption *opt = __panelView.targetOption ? __panelView.targetOption : nil;
            [subContentView addSubview:btn];
            [[MysticController controller].overlayView setupGestures:MysticObjectTypeUnknown disable:YES];
            break;
        }
#pragma mark - View - Color Balance
            
        case MysticPanelTypeColorBalance:
        {
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER + 40;
            
            CGRect sliderFrame = CGRectInset(CGRectHeight(contentFrame,MYSTIC_UI_PANEL_HEIGHT_SETTINGS_SLIDER), 25, 0);
            sliderFrame.origin.y = 40;
            
            __unsafe_unretained __block MysticRGBSlider *adjustSlider = [MysticRGBSlider panelSliderWithFrame:sliderFrame];
            adjustSlider.tag = MysticViewTypeContainer + MysticViewTypeSlider;
            adjustSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            adjustSlider.imageViewDelegate = weakSelf.controller;
            adjustSlider.refreshAction = @selector(refreshSliderAction:);
            adjustSlider.reloadAction = @selector(reloadSliderAction:);
            adjustSlider.finishAction = @selector(finishSliderAction:);
            adjustSlider.stillAction = @selector(stillSliderAction:);
            [adjustSlider setupActionsForSetting:MysticSettingColorBalance option:weakSelf.layerPanelView.targetOption animated:NO];
            
            contentFrame.size.height = 40 + adjustSlider.frame.size.height;
            
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"colorBalance"];
            
            subContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            subContentView.autoresizesSubviews = NO;
            subTag = MysticViewTypeContainer;
            CGFloat padding = 7;
            CGSize btnsSize = CGSizeMake(0, sliderFrame.origin.y);
            
            
            MysticSubSettingButton *rBtn = [MysticSubSettingButton buttonWithTitle:@"RED" senderAction:^(MysticSubSettingButton *sender) {
                MysticRGBSlider *slider = nil;
                for (MysticSubSettingButton*sibling in sender.superview.subviews) {
                    if([sibling isKindOfClass:[sender class]]) sibling.selected = NO;
                    if([sibling isKindOfClass:[MysticRGBSlider class]]) [(MysticRGBSlider *)sibling setColorState:MysticSliderStateRed];
                }
                sender.selected = YES;
                BOOL rc = [__panelView.targetOption hasAdjusted:MysticSettingColorBalanceRed];
                BOOL gc = [__panelView.targetOption hasAdjusted:MysticSettingColorBalanceGreen];
                BOOL bc = [__panelView.targetOption hasAdjusted:MysticSettingColorBalanceBlue];
                if(rc || (!gc && !bc)) [MysticUser setTemp:@(2) key:@"setting-rgb"];
                if(!rc && (bc || gc))
                {
                    if( bc && !gc && [MysticUser temp:@"setting-rgb" int:0]!=4) return [MysticUser setTemp:@(4) key:@"setting-rgb"];
                    if(!bc &&  gc && [MysticUser temp:@"setting-rgb" int:0]!=3) return [MysticUser setTemp:@(3) key:@"setting-rgb"];
                }
                
            }];
            [rBtn setTitleColor:[UIColor hex:@"9A3130"] forState:UIControlStateSelected];
            [rBtn setTitleColor:[UIColor hex:@"292522"] forState:UIControlStateHighlighted];
            btnsSize.width += rBtn.frame.size.width + padding;
            
            MysticSubSettingButton *gBtn = [MysticSubSettingButton buttonWithTitle:@"GREEN" senderAction:^(MysticSubSettingButton *sender) {
                MysticRGBSlider *slider = nil;
                for (MysticSubSettingButton*sibling in sender.superview.subviews) {
                    if([sibling isKindOfClass:[sender class]]) sibling.selected = NO;
                    if([sibling isKindOfClass:[MysticRGBSlider class]]){ [(MysticRGBSlider *)sibling setColorState:MysticSliderStateGreen]; }
                }
                sender.selected = YES;
                BOOL rc = [__panelView.targetOption hasAdjusted:MysticSettingColorBalanceRed];
                BOOL gc = [__panelView.targetOption hasAdjusted:MysticSettingColorBalanceGreen];
                BOOL bc = [__panelView.targetOption hasAdjusted:MysticSettingColorBalanceBlue];
                if(gc || (!bc && !rc)) [MysticUser setTemp:@(3) key:@"setting-rgb"];
                if(!gc && (bc || rc))
                {
                    if( bc && !rc && [MysticUser temp:@"setting-rgb" int:0]!=4) return [MysticUser setTemp:@(4) key:@"setting-rgb"];
                    if(!bc &&  rc && [MysticUser temp:@"setting-rgb" int:0]!=2) return [MysticUser setTemp:@(2) key:@"setting-rgb"];
                }
            }];
            [gBtn setTitleColor:[UIColor hex:@"427829"] forState:UIControlStateSelected];
            [gBtn setTitleColor:[UIColor hex:@"292522"] forState:UIControlStateHighlighted];
            
            btnsSize.width += gBtn.frame.size.width + padding;
            
            MysticSubSettingButton *bBtn = [MysticSubSettingButton buttonWithTitle:@"BLUE" senderAction:^(MysticSubSettingButton *sender) {
                MysticRGBSlider *slider = nil;
                for (MysticSubSettingButton*sibling in sender.superview.subviews) {
                    if([sibling isKindOfClass:[sender class]]) sibling.selected = NO;
                    if([sibling isKindOfClass:[MysticRGBSlider class]]) [(MysticRGBSlider *)sibling setColorState:MysticSliderStateBlue];
                }
                sender.selected = YES;
                BOOL rc = [__panelView.targetOption hasAdjusted:MysticSettingColorBalanceRed];
                BOOL gc = [__panelView.targetOption hasAdjusted:MysticSettingColorBalanceGreen];
                BOOL bc = [__panelView.targetOption hasAdjusted:MysticSettingColorBalanceBlue];
                if(bc || (!gc && !rc)) [MysticUser setTemp:@(4) key:@"setting-rgb"];
                if(!bc && (rc || gc))
                {
                    if( rc && !gc && [MysticUser temp:@"setting-rgb" int:0]!=2) return [MysticUser setTemp:@(2) key:@"setting-rgb"];
                    if(!rc &&  gc && [MysticUser temp:@"setting-rgb" int:0]!=3) return [MysticUser setTemp:@(3) key:@"setting-rgb"];
                }
            }];
            [bBtn setTitleColor:[UIColor hex:@"227195"] forState:UIControlStateSelected];
            [bBtn setTitleColor:[UIColor hex:@"292522"] forState:UIControlStateHighlighted];
            btnsSize.width += bBtn.frame.size.width;
            
            CGRect btnFrame = rBtn.frame;
            btnFrame.origin.y = 14;
            btnFrame.size.height = 38;
            btnFrame.origin.x = (contentFrame.size.width - btnsSize.width)/2;
            rBtn.frame = btnFrame;
            btnFrame.origin.x = rBtn.frame.origin.x + rBtn.frame.size.width + padding;
            btnFrame.size.width = gBtn.frame.size.width;
            gBtn.frame = btnFrame;
            btnFrame.origin.x = gBtn.frame.origin.x + gBtn.frame.size.width + padding;
            btnFrame.size.width = bBtn.frame.size.width;
            
            bBtn.frame = btnFrame;
            
            bBtn.selected = [MysticUser temp:@"setting-rgb" int:0]==4;
            gBtn.selected = [MysticUser temp:@"setting-rgb" int:0]==3;
            rBtn.selected = [MysticUser temp:@"setting-rgb" int:2]==2;
            
            
            MysticSliderState s = MysticSliderStateRGB;
            s = rBtn.selected? MysticSliderStateRed : s;
            s = gBtn.selected? MysticSliderStateGreen : s;
            s = bBtn.selected? MysticSliderStateBlue : s;
            [adjustSlider setColorState:s];
            rBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            gBtn.autoresizingMask = rBtn.autoresizingMask;
            bBtn.autoresizingMask = rBtn.autoresizingMask;
            [subContentView addSubview:adjustSlider];
            [subContentView addSubview:rBtn];
            [subContentView addSubview:gBtn];
            [subContentView addSubview:bBtn];
            break;
        }
#pragma mark - View - Levels
            
        case MysticPanelTypeLevels:
        {
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SLIDER + 40;
            
            CGRect nSliderBounds = contentFrame;
            nSliderBounds.size.height = MYSTIC_UI_PANEL_HEIGHT_SETTINGS_SLIDER;
            CGRect sliderFrame = CGRectInset(nSliderBounds, 25, 0);
            sliderFrame.origin.y = 40;
            
            __unsafe_unretained __block MysticLevelsSlider *adjustSlider = [MysticLevelsSlider panelSliderWithFrame:sliderFrame];
            adjustSlider.tag = MysticViewTypeContainer + MysticViewTypeSlider;
            adjustSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            adjustSlider.imageViewDelegate = weakSelf.controller;
            adjustSlider.refreshAction = @selector(refreshSliderAction:);
            adjustSlider.reloadAction = @selector(reloadSliderAction:);
            adjustSlider.finishAction = @selector(finishSliderAction:);
            adjustSlider.stillAction = @selector(stillSliderAction:);
            [adjustSlider setupActionsForSetting:MysticSettingLevels option:weakSelf.layerPanelView.targetOption animated:NO];
            contentFrame.size.height = 40 + adjustSlider.frame.size.height;
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"levels"];
            subContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            subContentView.autoresizesSubviews = NO;
            subTag = MysticViewTypeContainer;
            
            CGFloat padding = 1;
            CGSize btnsSize = CGSizeMake(0, sliderFrame.origin.y);
            MysticSubSettingButton *rgbBtn = [MysticSubSettingButton buttonWithTitle:@"RGB" senderAction:^(MysticSubSettingButton *sender) {
                MysticLevelsSlider *slider = nil;
                for (MysticSubSettingButton*sibling in sender.superview.subviews) {
                    if([sibling isKindOfClass:[sender class]]) sibling.selected = NO;
                    if([sibling isKindOfClass:[MysticLevelsSlider class]]) [(MysticLevelsSlider *)sibling setColorState:MysticSliderStateRGB];
                }
                sender.selected = YES;
                BOOL rgbc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsRGB];
                BOOL rc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsRed];
                BOOL gc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsGreen];
                BOOL bc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsBlue];
                if(rgbc || (!bc && !rc && !gc)) [MysticUser setTemp:@(1) key:@"setting-lvl"];
                if(!rgbc && (bc || gc || rc))
                {
                    if( rc && !gc && !bc && [MysticUser temp:@"setting-lvl" int:0]!=2) return [MysticUser setTemp:@(2) key:@"setting-lvl"];
                    if( bc && !gc && !rc && [MysticUser temp:@"setting-lvl" int:0]!=4) return [MysticUser setTemp:@(4) key:@"setting-lvl"];
                    if(!bc &&  gc && !rc && [MysticUser temp:@"setting-lvl" int:0]!=3) return [MysticUser setTemp:@(3) key:@"setting-lvl"];
                }
            }];
            [rgbBtn setTitleColor:[UIColor hex:@"292522"] forState:UIControlStateHighlighted];
            btnsSize.width += rgbBtn.frame.size.width + padding;
            MysticSubSettingButton *rBtn = [MysticSubSettingButton buttonWithTitle:@"RED" senderAction:^(MysticSubSettingButton *sender) {
                MysticLevelsSlider *slider = nil;
                for (MysticSubSettingButton*sibling in sender.superview.subviews) {
                    if([sibling isKindOfClass:[sender class]]) sibling.selected = NO;
                    if([sibling isKindOfClass:[MysticLevelsSlider class]]) [(MysticLevelsSlider *)sibling setColorState:MysticSliderStateRed];
                }
                BOOL rgbc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsRGB];
                BOOL rc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsRed];
                BOOL gc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsGreen];
                BOOL bc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsBlue];
                if(rc || (!gc && !bc && !rgbc)) [MysticUser setTemp:@(2) key:@"setting-lvl"];
                if(!rc && (bc || gc || rgbc))
                {
                    if( rgbc && !gc && !bc && [MysticUser temp:@"setting-lvl" int:0]!=1) return [MysticUser setTemp:@(1) key:@"setting-lvl"];
                    if( bc && !gc && !rgbc && [MysticUser temp:@"setting-lvl" int:0]!=4) return [MysticUser setTemp:@(4) key:@"setting-lvl"];
                    if(!bc &&  gc && !rgbc && [MysticUser temp:@"setting-lvl" int:0]!=3) return [MysticUser setTemp:@(3) key:@"setting-lvl"];
                }
                sender.selected = YES;
            }];
            [rBtn setTitleColor:[UIColor hex:@"9A3130"] forState:UIControlStateSelected];
            [rBtn setTitleColor:[UIColor hex:@"292522"] forState:UIControlStateHighlighted];
            btnsSize.width += rBtn.frame.size.width + padding;
            MysticSubSettingButton *gBtn = [MysticSubSettingButton buttonWithTitle:@"GREEN" senderAction:^(MysticSubSettingButton *sender) {
                MysticLevelsSlider *slider = nil;
                for (MysticSubSettingButton*sibling in sender.superview.subviews) {
                    if([sibling isKindOfClass:[sender class]]) sibling.selected = NO;
                    if([sibling isKindOfClass:[MysticLevelsSlider class]]) [(MysticLevelsSlider *)sibling setColorState:MysticSliderStateGreen];
                }
                sender.selected = YES;
                BOOL rgbc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsRGB];
                BOOL rc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsRed];
                BOOL gc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsGreen];
                BOOL bc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsBlue];
                if(gc || (!rc && !bc && !rgbc)) [MysticUser setTemp:@(3) key:@"setting-lvl"];
                if(!gc && (bc || rc || rgbc))
                {
                    if(!bc && !rc &&  rgbc && [MysticUser temp:@"setting-lvl" int:0]!=1) return [MysticUser setTemp:@(1) key:@"setting-lvl"];
                    if( bc && !rc && !rgbc && [MysticUser temp:@"setting-lvl" int:0]!=4) return [MysticUser setTemp:@(4) key:@"setting-lvl"];
                    if(!bc &&  rc && !rgbc && [MysticUser temp:@"setting-lvl" int:0]!=2) return [MysticUser setTemp:@(2) key:@"setting-lvl"];
                }
            }];
            [gBtn setTitleColor:[UIColor hex:@"427829"] forState:UIControlStateSelected];
            [gBtn setTitleColor:[UIColor hex:@"292522"] forState:UIControlStateHighlighted];
            btnsSize.width += gBtn.frame.size.width + padding;
            MysticSubSettingButton *bBtn = [MysticSubSettingButton buttonWithTitle:@"BLUE" senderAction:^(MysticSubSettingButton *sender) {
                MysticLevelsSlider *slider = nil;
                for (MysticSubSettingButton*sibling in sender.superview.subviews) {
                    if([sibling isKindOfClass:[sender class]]) sibling.selected = NO;
                    if([sibling isKindOfClass:[MysticLevelsSlider class]]) [(MysticLevelsSlider *)sibling setColorState:MysticSliderStateBlue];
                }
                sender.selected = YES;
                BOOL rgbc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsRGB];
                BOOL rc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsRed];
                BOOL gc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsGreen];
                BOOL bc = [__panelView.targetOption hasAdjusted:MysticSettingLevelsBlue];
                if(bc || (!rc && !gc && !rgbc)) [MysticUser setTemp:@(4) key:@"setting-lvl"];
                if(!bc && (gc || rc || rgbc))
                {
                    if(!gc && !rc &&  rgbc && [MysticUser temp:@"setting-lvl" int:0]!=1) return [MysticUser setTemp:@(1) key:@"setting-lvl"];
                    if( gc && !rc && !rgbc && [MysticUser temp:@"setting-lvl" int:0]!=3) return [MysticUser setTemp:@(3) key:@"setting-lvl"];
                    if(!gc &&  rc && !rgbc && [MysticUser temp:@"setting-lvl" int:0]!=2) return [MysticUser setTemp:@(2) key:@"setting-lvl"];
                }
            }];
            [bBtn setTitleColor:[UIColor hex:@"227195"] forState:UIControlStateSelected];
            [bBtn setTitleColor:[UIColor hex:@"292522"] forState:UIControlStateHighlighted];
            btnsSize.width += bBtn.frame.size.width;
            CGRect btnFrame = rgbBtn.frame;
            btnFrame.origin.y = 14;
            btnFrame.size.height = 38;
            btnFrame.origin.x = (contentFrame.size.width - btnsSize.width)/2;
            rgbBtn.frame = btnFrame;
            btnFrame.origin.x = rgbBtn.frame.origin.x + rgbBtn.frame.size.width + padding;
            btnFrame.size.width = rBtn.frame.size.width;
            rBtn.frame = btnFrame;
            btnFrame.origin.x = rBtn.frame.origin.x + rBtn.frame.size.width + padding;
            btnFrame.size.width = gBtn.frame.size.width;
            gBtn.frame = btnFrame;
            btnFrame.origin.x = gBtn.frame.origin.x + gBtn.frame.size.width + padding;
            btnFrame.size.width = bBtn.frame.size.width;
            bBtn.frame = btnFrame;
            bBtn.selected = [MysticUser temp:@"setting-lvl" int:0]==4;
            gBtn.selected = [MysticUser temp:@"setting-lvl" int:0]==3;
            rBtn.selected = [MysticUser temp:@"setting-lvl" int:0]==2;
            rgbBtn.selected = [MysticUser temp:@"setting-lvl" int:0]<2;
            MysticSliderState s = MysticSliderStateRGB;
            s = rBtn.selected? MysticSliderStateRed : s;
            s = gBtn.selected? MysticSliderStateGreen : s;
            s = bBtn.selected? MysticSliderStateBlue : s;
            [adjustSlider setColorState:s];
            rgbBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            rBtn.autoresizingMask = rgbBtn.autoresizingMask;
            gBtn.autoresizingMask = rgbBtn.autoresizingMask;
            bBtn.autoresizingMask = rgbBtn.autoresizingMask;
            [subContentView addSubview:adjustSlider];
            [subContentView addSubview:rgbBtn];
            [subContentView addSubview:rBtn];
            [subContentView addSubview:gBtn];
            [subContentView addSubview:bBtn];
            break;
        }
            
#pragma mark - View - AdjustMove, Intensity, Custom
            
        case MysticPanelTypeAdjustMove:
        case MysticPanelTypeIntensity:
        case MysticPanelTypeCustom:
            break;
            
#pragma mark - View - More
            
        case MysticPanelTypeMore:
        {
            contentFrame.size.height = (scrollMargin)+MYSTIC_UI_PANEL_HEIGHT_MORE;
            MysticTabBarPanel *panelTabBar = [[MysticTabBarPanel alloc] initWithFrame:contentFrame];
            panelTabBar.tabBarDelegate = self;
            panelTabBar.contentOffset = _lastTabBarOffset;
            _lastTabBarOffset = CGPointZero;
            panelTabBar.options = @[
                                    
                                    @{@"type": @(MysticSettingSaturation), },
                                    @{@"type": @(MysticSettingIntensity), },
                                    @{@"type": @(MysticSettingBrightness), },
                                    @{@"type": @(MysticSettingContrast), },
                                    //                                    @{@"type": @(MysticSettingFill), },
                                    @{@"type": @(MysticSettingLevels), },
                                    @{@"type": @(MysticSettingColorBalance), },
                                    @{@"type": @(MysticSettingShadows), },
                                    @{@"type": @(MysticSettingHighlights), },
                                    
                                    
                                    ];
            
            
            panelTabBar.hidden = NO;
            panelTabBar.userInteractionEnabled = YES;
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"more"];
            subContentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
            [subContentView addSubview:panelTabBar];
            
            break;
        }
#pragma mark - View - Vignette
            
        case MysticPanelTypeVignette:
        {
            __section.setting = MysticSettingVignette;
            __section.animationTransition=MysticAnimationTransitionNormal;
            __section.toolbarTitle = MysticObjectTypeTitleParent(MysticSettingVignette, MysticObjectTypeUnknown);
            contentFrame.size.height = (scrollMargin)+MYSTIC_UI_PANEL_HEIGHT_COLORS-5;
            subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"vignette"];
            MysticSlider *adjustSlider = [MysticSlider panelSliderWithFrame:contentFrame];
            adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider + MysticViewTypeSubPanel;
            adjustSlider.imageViewDelegate = weakSelf.controller;
            adjustSlider.refreshAction = @selector(refreshSliderAction:);
            adjustSlider.reloadAction = @selector(reloadSliderAction:);
            adjustSlider.finishAction = @selector(finishSliderAction:);
            adjustSlider.stillAction = @selector(stillSliderAction:);
            [adjustSlider setupActionsForSetting:MysticSettingVignetteColorAlpha option:__panelView.targetOption animated:NO];
            UIColor *vc = __panelView.targetOption.vignetteColor;
            vc = vc ? vc : [UIColor blackColor];
            float sv = adjustSlider.value;
            MysticColorButton *colorWheel = [MysticColorButton colorButton:vc  title:@"VIGNETTE" option:__panelView.targetOption action:^(MysticColorButton *sender, UIColor *color, id obj2, BOOL success) {
                sender.option.vignetteColor = [color alpha:sender.option.vignetteColor ? sender.option.vignetteColor.alpha : color.alpha];
                [[MysticOptions current].filters.filter setVignette:sender.option.vignetteCenter color:sender.option.vignetteColor start:sender.option.vignetteStart end:sender.option.vignetteEnd option:sender.option];
                [MysticEffectsManager refresh:sender.option];
                if(!success) return;
                [sender retain];
                MysticSlider *slider = [sender.superview viewWithTag:MysticViewTypePanel + MysticViewTypeSlider + MysticViewTypeSubPanel];
                slider.blockEvents=YES;
                slider.upperValue = sv;
                MysticWait(0.12, ^{
                    if(slider && slider.value!=sender.option.vignetteColor.alpha) [slider setUpperValue:sender.option.vignetteColor.alpha animated:YES];
                    slider.blockEvents=NO;
                    [sender release];
                });
            }];
            colorWheel.frame = CGRectMake(-4, 0, contentFrame.size.height - 1, contentFrame.size.height);
            
            MysticButton *blendBtn = [MysticButton button:[MysticIcon iconForSetting:MysticSettingBlending size:(CGSize){25,25} color:nil] action:^(id sender) {
                [weakSelf pushPanel:MysticPanelTypeBlend setting:MysticSettingVignetteBlending];
            }];
            blendBtn.frame = CGRectMake(CGRectW(contentFrame)-CGRectH(contentFrame)+2, 0, contentFrame.size.height - 1, contentFrame.size.height);
            adjustSlider.frame = CGRectAddXW(CGRectInset(CGRectHeight(contentFrame, MYSTIC_UI_PANEL_HEIGHT_SLIDER), 15, 0), colorWheel.frame.size.height - 25, -(CGRectW(blendBtn.frame)+ colorWheel.frame.size.height-46));
            
            adjustSlider.center = CGPointMake(adjustSlider.center.x, colorWheel.center.y);
            
            [subContentView addSubview:colorWheel];
            [subContentView addSubview:blendBtn];
            [subContentView addSubview:adjustSlider];
            [weakSelf.controller.overlayView setupGestures:MysticSettingVignette disable:NO];
            
            CGRect imageViewFrame = weakSelf.controller.imageView.imageView.frame;

            
            CGPoint centerDotPoint = [weakSelf.controller.imageView.imageView.superview convertPoint:weakSelf.controller.imageView.imageView.center toView:weakSelf.controller.view];
            MysticDotView *centerDot = [MysticDotView dot:centerDotPoint color:MysticColorTypeBlack size:15 borderWidth:2];
            [weakSelf.controller.view addSubview:centerDot];
            
            CGPoint leftDotPoint = [weakSelf.controller.imageView.imageView.superview convertPoint:weakSelf.controller.imageView.imageView.frame.origin toView:weakSelf.controller.view];
            leftDotPoint.y = centerDotPoint.y;
            leftDotPoint.x = -1*imageViewFrame.size.width*0.25;
            MysticDotView *leftDot = [MysticDotView dot:leftDotPoint color:MysticColorTypeBlack size:5 borderWidth:2];
            [weakSelf.controller.view addSubview:leftDot];
            
            CGPoint leftDotPoint2 = [weakSelf.controller.imageView.imageView.superview convertPoint:weakSelf.controller.imageView.imageView.frame.origin toView:weakSelf.controller.view];
            leftDotPoint2.y = centerDotPoint.y;
            //            leftDotPoint2.x = centerDotPoint.x/2;
            MysticDotView *leftDot2 = [MysticDotView dot:leftDotPoint2 color:MysticColorTypeBlack size:11 borderWidth:2];
            [weakSelf.controller.view addSubview:leftDot2];
            
            
            CGPoint rightDotPoint = (CGPoint){leftDotPoint2.x + (imageViewFrame.size.width*1.25),centerDotPoint.y};
            MysticDotView *rightDot = [MysticDotView dot:rightDotPoint color:MysticColorTypeBlack size:5 borderWidth:2];
            [weakSelf.controller.view addSubview:rightDot];
            
            
            
            
            
            CGPoint rightDotPoint2 = [weakSelf.controller.imageView.imageView.superview convertPoint:weakSelf.controller.imageView.imageView.frame.origin toView:weakSelf.controller.view];
            rightDotPoint2.y = centerDotPoint.y;
            rightDotPoint2.x = centerDotPoint.x*2;
            MysticDotView *rightDot2 = [MysticDotView dot:rightDotPoint2 color:MysticColorTypeBlack size:11 borderWidth:2];
            [weakSelf.controller.view addSubview:rightDot2];
            
            
            
            
            leftDot.tag = MysticViewTypeButton1;
            centerDot.tag = MysticViewTypeButton2;
            rightDot.tag = MysticViewTypeButton3;
            leftDot2.tag = MysticViewTypeButton4;
            rightDot2.tag = MysticViewTypeButton5;
            
            
            leftDot.hitInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
            centerDot.hitInsets = leftDot.hitInsets;
            rightDot.hitInsets = leftDot.hitInsets;
            rightDot2.hitInsets = leftDot.hitInsets;
            leftDot2.hitInsets = leftDot.hitInsets;

            leftDot.backgroundColor = [leftDot.backgroundColor colorWithAlphaComponent:0.6];
            rightDot.backgroundColor = [rightDot.backgroundColor colorWithAlphaComponent:0.6];
            centerDot.backgroundColor = [centerDot.backgroundColor colorWithAlphaComponent:0.6];
            leftDot2.backgroundColor = [centerDot.backgroundColor colorWithAlphaComponent:0.2];
            rightDot2.backgroundColor = leftDot2.backgroundColor;

            [weakSelf.controller.extraControls addObjectsFromArray:@[leftDot,leftDot2,centerDot,rightDot2,rightDot]];
            weakSelf.controller.extraControlsSetting = MysticSettingVignette;
          
            break;
        }
#pragma mark - View - MysticPanelTypeSize
            
        case MysticPanelTypeSize:
        {
            CGRect subContentFrame = contentFrame;
            subContentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_MOVE;
            subContentFrame.origin.y = MYSTIC_UI_PANEL_HEIGHT_MOVE;
            contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_MOVE * 2 ;
            
            MysticPanelSubView *_subContentView = [[MysticPanelSubView alloc] initWithFrame:contentFrame name:@"typeSize"];
            //            _subContentView.borderPosition = MysticPositionBottom|MysticPositionCenter;
            //            _subContentView.showBorder = NO;
            subContentView = _subContentView;
            
            MysticSizeToolbar *toolbar = [MysticSizeToolbar toolbarWithDelegate:weakSelf height:MYSTIC_UI_MENU_HEIGHT];
            toolbar.targetOption = (PackPotionOptionView *)panelView.targetOption;
            toolbar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
            
            //
            //            MysticSizeToolbar *toolbar = [MysticSizeToolbar toolbarWithFrame:CGRectMake(0, 0, contentFrame.size.width, MYSTIC_UI_PANEL_HEIGHT_MOVE)];
            //            toolbar.targetOption = (PackPotionOptionView *)panelView.targetOption;
            [subContentView addSubview:toolbar];
            
            //            MysticSizeToolbar *toolbar2 = [MysticSizeToolbar toolbarWithFrame:CGRectMake(0, MYSTIC_UI_PANEL_HEIGHT_MOVE, contentFrame.size.width, MYSTIC_UI_PANEL_HEIGHT_MOVE)];
            //            toolbar2.targetOption = (PackPotionOptionView *)panelView.targetOption;
            //            [subContentView addSubview:toolbar2];
            break;
            
        }
            
#pragma mark - View - MysticPanelTypeUnknown
            
        case MysticPanelTypeUnknown:
        {
            DLog(@"ERROR: View for section type unknown: %@", section);
            break;
        }
            
#pragma mark - View - default
            
        default:
        {
            DLog(@"ERROR: View for section type not found: %@", section);
            
            break;
        }
    }
    if(!contentView && createContentView)
    {
        contentView = [[MysticPanelContentView alloc] initWithFrame:contentFrame name:@"parentContentView"];
        contentView.autoresizesSubviews = YES;
        contentView.clipsToBounds = NO;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    
    contentView.frame = contentFrame;
    
    if(subContentView && contentView)
    {
        [contentView addSubview:subContentView];
        if(subTag != NSNotFound) subContentView.tag = subTag;
        [subContentView release];
    }
    
    
    return [contentView autorelease];
}


- (MysticPanelObject *) pushPanel:(MysticPanelType)sectionType setting:(MysticObjectType)__itemType;
{
    NSMutableDictionary *newInfo = [NSMutableDictionary dictionary];
    [newInfo addEntriesFromDictionary:self.layerPanelView.visiblePanel.info];
    PackPotionOption *targetOption = self.layerPanelView.targetOption;
    __unsafe_unretained __block MysticPanelObject *newPanel = [MysticPanelObject info:newInfo];
    
    newPanel.setting = __itemType;
    newPanel.sectionType = sectionType;
    if(targetOption) targetOption.refreshState = __itemType;
    
    newPanel = [[self layerPanel:self.layerPanelView panelObjectForSection:newPanel ] retain];
    newPanel.title = MysticObjectTypeTitleParent(__itemType, MysticObjectTypeUnknown);
    newPanel.toolbarTitle = newPanel.title;
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = self;
    __unsafe_unretained __block MysticPanelSubView *subPanelView2 = (id)newPanel.view;
    __unsafe_unretained __block MysticLayerToolbar *toolbar = self.layerPanelView.bottomBarView.toolbar;
    newPanel.animationTransition = MysticAnimationTransitionNormal;
    newPanel.view = subPanelView2;
    [self.layerPanelView.panels addObject:newPanel];
    self.layerPanelView.visiblePanel = newPanel;
    
    
    MysticAnimation *animation = [MysticAnimation animationWithDuration:.25];
    animation.animationOptions = UIViewAnimationCurveEaseInOut;
    weakSelf.layerPanelView.contentContainerView.frame = CGRectXH(weakSelf.layerPanelView.contentContainerView.frame, 0, subPanelView2.frame.size.height);
    weakSelf.layerPanelView.stopLayout=YES;
    weakSelf.layerPanelView.contentContainerView.autoresizesSubviews =NO;
    [animation addAnimation:^{
        toolbar.alpha = 0;
        weakSelf.layerPanelView.contentContainerView.frame = CGRectXY(weakSelf.layerPanelView.contentContainerView.frame, 0, subPanelView2.frame.size.height);
        
    } complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
//        weakSelf.layerPanelView.contentContainerView.frame = newContainerFrame;
        weakSelf.layerPanelView.contentContainerView.alpha = 0;
        [weakSelf.layerPanelView.contentView removeFromSuperview];
        weakSelf.layerPanelView.contentView = nil;
        [weakSelf.layerPanelView.contentContainerView addSubview:subPanelView2];
        [weakSelf.layerPanelView keepContentView:subPanelView2];
        [toolbar replaceItemsWithInfo:[[weakSelf.layerPanelView class] toolbarItemsForSection:weakSelf.layerPanelView.visiblePanel type:__itemType target:toolbar.delegate toolbar:toolbar] animated:NO];
        [toolbar setTitle:MysticObjectTypeTitleParent(__itemType, MysticObjectTypeUnknown) animated:NO];
        [newPanel didAppear];
        [newPanel isReady];
        MysticAnimation *animation2 = [MysticAnimation animationWithDuration:.25];
        animation2.animationOptions = UIViewAnimationCurveEaseInOut;
        [animation2 addAnimation:^{
            weakSelf.layerPanelView.contentContainerView.alpha = 1;
            weakSelf.layerPanelView.contentContainerView.frame = CGRectIntegral((CGRect){0,0,weakSelf.layerPanelView.contentContainerView.frame.size.width, weakSelf.layerPanelView.contentContainerView.frame.size.height});
            toolbar.alpha = 1;
            weakSelf.layerPanelView.bottomBarView.frame = (CGRect){0,weakSelf.layerPanelView.frame.size.height-MYSTIC_UI_PANEL_BOTTOMBAR_HEIGHT, weakSelf.layerPanelView.bottomBarView.frame.size.width, MYSTIC_UI_PANEL_BOTTOMBAR_HEIGHT};
            weakSelf.layerPanelView.frame = [weakSelf.layerPanelView frameForState:MysticLayerPanelStateOpen];
        } complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
            weakSelf.layerPanelView.stopLayout = NO;
            weakSelf.layerPanelView.autoresizesSubviews = YES;
            weakSelf.layerPanelView.contentContainerView.autoresizesSubviews = YES;
            [newPanel autorelease];
        }];
        [animation2 animate];
    }];
    [animation animate];
    return newPanel;
}

- (id) layerPanel:(MysticLayerPanelView *)panelView sectionDidChange:(MysticPanelObject *)section;
{
    
    MysticBlockObject finished = nil;
    MysticObjectType objectType = panelView.targetOption.type;
    
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = self;
    __unsafe_unretained __block MysticLayerPanelView *__panelView = panelView;
    __unsafe_unretained __block MysticPanelObject *__section = section;
    __unsafe_unretained __block MysticController *__controller = self.controller;
    
    
    switch (section.sectionType) {
        case MysticPanelTypeMove: break;
        case MysticPanelTypeOptionSettings:
        {
            finished = ^(UIView *__contentView)
            {
                //[weakSelf toolbarForSection:__section];
                [weakSelf.controller toggleMoreToolsHide];
                
            };
            break;
        }
        case MysticPanelTypeOptionImageLayerSettings:
        case MysticPanelTypeOptionLayerSettings:
        {
            finished = ^(UIView *__contentView)
            {
                weakSelf.controller.preventToolsFromBeingVisible = YES;
                [weakSelf.controller toggleMoreToolsHide];
                MysticTabBar *tabBar = (MysticTabBar *)[__contentView viewWithTag:MysticViewTypeTabBarPanelSettingsLayer + MysticViewTypePanel];
                if(tabBar) [tabBar setNeedsDisplay];
                
            };
            break;
        }
            
        case MysticPanelTypeOptionFilterSettings:
        {
            finished = ^(UIView *__contentView)
            {
                [weakSelf.controller toggleMoreToolsHide];
                weakSelf.controller.preventToolsFromBeingVisible = YES;
                
                MysticLayerToolbar *toolbar = [weakSelf toolbarForSection:__section];
                if (toolbar)
                {
                    [toolbar setTitleEnabled:NO];
                    toolbar.titleBorderHidden = YES;
                    [toolbar setTitle:@"INTENSITY" animated:weakSelf.layerPanelIsVisible];
                }
            };
            break;
        }
            
        case MysticPanelTypeOptionLayer:
        {
            finished = ^(UIView *__contentView)
            {
                MysticScrollView *contentScrollView = (MysticScrollView *)[__contentView viewWithTag:MysticViewTypeScrollView + MysticViewTypePanel];
                weakSelf.controller.preventToolsFromBeingVisible = NO;
                
                
                if(__controller.lastSetting != __section.state)
                {
                    MysticPack *pack = __section.pack ? __section.pack : [__controller currentOptionPack:__panelView.targetOption];
                    
                    [__controller loadPack:pack info:__controller.currentStateInfo scrollView:contentScrollView complete:^{
                        
                        EffectControl *selectedControl = (EffectControl *)contentScrollView.selectedItem;
                        if(selectedControl) [selectedControl.option controlBecameActive:selectedControl];
                        
                    }];
                }
                
                
            };
            break;
        }
        case MysticPanelTypeColor:
        case MysticPanelTypeColorAndIntensity:
        {
            
            finished = ^(UIView *__contentView){
                weakSelf.controller.preventToolsFromBeingVisible = YES;
                [weakSelf.controller toggleMoreToolsHide];
                MysticColorsScrollView *contentScrollView = (MysticColorsScrollView *)[__contentView viewWithTag:MysticViewTypeScrollView + MysticViewTypePanel];
                contentScrollView.shouldSelectActiveControls = YES;
                if(!__section.resetAll && contentScrollView.subviews.count) { [contentScrollView reloadControls]; return; }
                
                
                MysticOptionColorType optType =MysticOptionColorTypeForeground;
                switch (__section.setting) {
                    case MysticSettingBackground:
                    case MysticSettingBackgroundColor: optType = MysticOptionColorTypeBackground; break;
                    default: break;
                }
                
                NSMutableArray *theColors = [NSMutableArray array];
                [theColors addObjectsFromArray:[[Mystic core] colorsForOption:__panelView.targetOption option:optType setting:__section.setting]];
                weakSelf.controller.shouldSelectActiveControls = YES;
                contentScrollView.enableControls = YES;
                contentScrollView.tileSize = CGSizeMake(MYSTIC_UI_CONTROLS_TILEWIDTH_COLOR, contentScrollView.frame.size.height);
                [contentScrollView loadControls:theColors selectIndex:MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX animated:NO complete:^{
                    EffectControl *selectedControl = (EffectControl *)contentScrollView.selectedItem;
                    if(selectedControl) [selectedControl.option controlBecameActive:selectedControl];
                }];
                
            };
            break;
        }
        case MysticPanelTypeBlend:
        {
            
            finished = ^(UIView *__contentView){
                
                weakSelf.controller.preventToolsFromBeingVisible = YES;
                [weakSelf.controller toggleMoreToolsHide];
                MysticScrollView *contentScrollView = (MysticScrollView *)[__contentView viewWithTag:MysticViewTypeScrollView + MysticViewTypePanel];
                contentScrollView.shouldSelectActiveControls = YES;
                
                if(!__section.resetAll && contentScrollView.subviews.count)
                {
                    [contentScrollView reloadControls];
                    return;
                }
                
                
                NSArray *controls = __panelView.targetOption.blendingModeOptions;
                for (PackPotionOptionBlend *o in controls)
                {
                    o.action = ^(EffectControl *control, BOOL isSelected)
                    {
                        [control touchedEffect];
                        BOOL changed = isSelected != control.selected;
                        if(control.selected && changed)
                        {
                            PackPotionOptionBlend *blendOption = (PackPotionOptionBlend *)control.option;
                            [blendOption setUserChoice];
                            [weakSelf.controller reloadImageInBackground:NO settings:MysticRenderOptionsForceProcess];
                            [(MysticScrollView *)control.superview centerOnView:control animate:YES complete:nil];
                        }
                    };
                }
                
                contentScrollView.shouldSelectActiveControls = YES;
                [contentScrollView loadControls:controls];
                
                
            };
            
            
            break;
        }
            
        case MysticPanelTypeShape:
        {
            
            finished = nil;
            break;
        }
        case MysticPanelTypeFontAlign:
        case MysticPanelTypeAdjust:
        case MysticPanelTypeAdjustMove:
        case MysticPanelTypeIntensity:
        case MysticPanelTypeCustom:
        case MysticPanelTypeMore:
        case MysticPanelTypeSize:
        case MysticPanelTypeHue:
        case MysticPanelTypeSaturation:
        case MysticPanelTypeTone:
        case MysticPanelTypeVibrance:
        case MysticPanelTypeBrightness:
        case MysticPanelTypeSkin:
        case MysticPanelTypeSkinHue:
        case MysticPanelTypeSkinHueThreshold:
        case MysticPanelTypeSkinHueMaxShift:
        case MysticPanelTypeSkinMaxSaturationShift:
        case MysticPanelTypeSkinUpperTone:
        case MysticPanelTypeContrast:
        case MysticPanelTypeHaze:
        case MysticPanelTypeGamma:
        case MysticPanelTypeExposure:
        case MysticPanelTypeShadows:
        case MysticPanelTypeHighlights:
        case MysticPanelTypeGrain:
        case MysticPanelTypeVignette:
        case MysticPanelTypeSlider: break;
        case MysticPanelTypeUnknown:
        {
            DLog(@"ERROR: Section did change load Unknown section type");
            
            break;
        }
        default:
        {
            finished = ^(UIView *__contentView)
            {
                weakSelf.controller.preventToolsFromBeingVisible = NO;
                [weakSelf.controller toggleMoreToolsHide];
                
                MysticLayerToolbar *toolbar = [weakSelf toolbarForSection:__section];
                if (toolbar)
                {
                    [toolbar setTitleEnabled:YES];
                    toolbar.titleBorderHidden = YES;
                    [toolbar setTitle:__section.toolbarTitle animated:weakSelf.layerPanelIsVisible];
                }
            };
            break;
        }
    }
    
    return finished ? Block_copy(finished) : nil;
    //    if(finished) finished(panelView.contentView);
}

- (void) layerPanel:(MysticLayerPanelView *)panelView sectionWillChange:(MysticPanelObject *)section;
{
    return;
    
    
}
- (void) layerPanel:(MysticLayerPanelView *)panelView selectedTabSection:(MysticPanelObject *)sectionInfo;
{
    [self layerPanel:panelView selectedSection:sectionInfo];
}
- (void) layerPanel:(MysticLayerPanelView *)panelView selectedSection:(MysticPanelObject *)sectionInfo;
{
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = self;
    __unsafe_unretained __block MysticLayerPanelView *__panelView = panelView;
    __unsafe_unretained __block MysticPanelObject *__sectionInfo = [sectionInfo retain];
    
    [weakSelf layerPanel:panelView sectionWillChange:sectionInfo];
    UIView *contentView = [self layerPanel:panelView viewForSection:sectionInfo];
    [panelView setContentView:contentView completion:^(id object)
     {
         MysticBlockObject f = [weakSelf layerPanel:__panelView sectionDidChange:__sectionInfo];
         if(f) { f(__panelView.contentView); Block_release(f); }
         [__sectionInfo release];
     }];
    
    
    [self setLastSelectedItemIndex];
    
    
    
}
- (void) layerPanel:(MysticLayerPanelView *)panelView stateWillChange:(MysticLayerPanelState)nextState;
{
    switch (panelView.previousState)
    {
        case MysticLayerPanelStateUnInit: [self updateLayerPanel:panelView]; break;
        default: break;
    }
    [self layerPanelFrameChanged:panelView state:nextState];
}

- (void) layerPanel:(MysticLayerPanelView *)panelView stateDidChange:(MysticLayerPanelState)state;
{
    self.ignoreStateChanges = NO;
}
- (void) layerPanel:(MysticLayerPanelView *)panelView disableSection:(MysticPanelObject *)section;
{
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = self;
    __unsafe_unretained __block MysticLayerPanelView *__panelView = panelView;
    __unsafe_unretained __block MysticPanelObject *__section = section;
    
    
}

- (void) layerPanel:(MysticLayerPanelView *)panelView updateSection:(MysticPanelObject *)section;
{
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = self;
    __unsafe_unretained __block MysticLayerPanelView *__panelView = panelView;
    __unsafe_unretained __block MysticPanelObject *__section = section;
    
    
}

- (void) layerPanel:(MysticLayerPanelView *)panelView refreshSection:(MysticPanelObject *)section;
{
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = self;
    __unsafe_unretained __block MysticLayerPanelView *__panelView = panelView;
    __unsafe_unretained __block MysticPanelObject *__section = section;
    
}
- (void) panelClosed;
{
    self.layerPanelView.delegate = nil;
    [self.layerPanelView removeContentView];
    for (UIView *s in self.layerPanelView.bottomBarView.subviews) { [s removeFromSuperview]; }
    self.layerPanelView.options = nil;
    if(self.blockObj) self.blockObj = nil;
    [self.view removeFromSuperview];
}
- (void) layerPanelContentWillHide:(MysticLayerPanelView *)panelView;
{
    
}
- (void) layerPanelContentDidHide:(MysticLayerPanelView *)panelView;
{
    
}

- (void) layerPanelFrameChanged:(MysticLayerPanelView *)panelView state:(MysticLayerPanelState)state;
{
    
    if(self.ignoreStateChanges) return;
    
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = self;
    
    CGFloat navH = ![(MysticNavigationViewController *)weakSelf.controller.navigationController willNavigationBarBeVisible] ? 0 : weakSelf.controller.navigationController.navigationBar.frame.size.height;
    CGPoint offset = CGPointZero;
    UIEdgeInsets imageViewInsets = [MysticPhotoContainerView defaultInsets];
    UIViewAnimationOptions animOpt = UIViewAnimationOptionCurveEaseInOut;
    NSTimeInterval animDuration = 0.35;
    NSTimeInterval animDelay = 0;
    
    if(state == MysticLayerPanelStateOpen)
    {
        imageViewInsets.top = navH + (navH > 0 ? MYSTIC_UI_IMAGEVIEW_INSET_NAV_OFFSET :MYSTIC_UI_IMAGEVIEW_INSET_NAV_HIDDEN_OFFSET);
        imageViewInsets.bottom = panelView.visibleHeight + MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_HIDDEN_OFFSET;
        
        switch (self.layerPanelView.visiblePanel.panelType) {
            case MysticPanelTypeFont:
            case MysticPanelTypeFonts:
            case MysticPanelTypeFontStyle:
            case MysticPanelTypeFontAdjust:
            case MysticPanelTypeFontAlign:
            case MysticPanelTypeShape:
            {
                
                imageViewInsets.top += MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_Y;
                imageViewInsets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_Y;
                imageViewInsets.left = MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_X;
                imageViewInsets.right = MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_X;
                break;
            }
                
            default:
            {
                imageViewInsets.top += MYSTIC_UI_IMAGEVIEW_INSET_EDIT;
                imageViewInsets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_EDIT;
                break;
            }
        }
    }
    else
    {
        animOpt = UIViewAnimationOptionCurveEaseIn;
        imageViewInsets.top = navH + (navH > 0 ? MYSTIC_UI_IMAGEVIEW_INSET_NAV_OFFSET :MYSTIC_UI_IMAGEVIEW_INSET_NAV_HIDDEN_OFFSET);
        imageViewInsets.bottom = weakSelf.controller.bottomPanelView.frame.size.height + MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_OFFSET;
        imageViewInsets.top += MYSTIC_UI_IMAGEVIEW_INSET_HOME;
        imageViewInsets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_HOME;
    }
    
    MysticBlock animBlock = [self layerPanelStateChangeAnimationBlock:panelView state:state];
    
    [MysticUIView animateWithDuration:animDuration delay:animDelay options:animOpt animations:animBlock completion:^(BOOL finished) {
        [weakSelf.controller performSelector:@selector(layerPanelFrameChanged:) withObject:panelView];
    }];
    
    Block_release(animBlock);
    
}

- (MysticBlock) layerPanelStateChangeAnimationBlock:(MysticLayerPanelView *)panelView state:(MysticLayerPanelState)state;
{
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = self;
    
    __block CGFloat navH = ![(MysticNavigationViewController *)weakSelf.controller.navigationController willNavigationBarBeVisible] ? 0 : weakSelf.controller.navigationController.navigationBar.frame.size.height;
    __block CGPoint offset = CGPointZero;
    __block UIEdgeInsets imageViewInsets = [MysticPhotoContainerView defaultInsets];
    if(state == MysticLayerPanelStateOpen)
    {
        imageViewInsets.top = MYSTIC_UI_IMAGEVIEW_INSET_NAV_HIDDEN_OFFSET;
        imageViewInsets.bottom = panelView.visibleHeight + MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_HIDDEN_OFFSET;
        switch (self.layerPanelView.visiblePanel.panelType) {
            case MysticPanelTypeFont:
            case MysticPanelTypeFonts:
            case MysticPanelTypeFontStyle:
            case MysticPanelTypeFontAdjust:
            case MysticPanelTypeFontAlign:
            case MysticPanelTypeShape:
            {
                imageViewInsets.top += MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_Y;
                imageViewInsets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_Y;
                imageViewInsets.left = MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_X;
                imageViewInsets.right = MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_X;
                break;
            }
                
            default:
            {
                imageViewInsets.top += MYSTIC_UI_IMAGEVIEW_INSET_EDIT;
                imageViewInsets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_EDIT;
                break;
            }
        }
    }
    else
    {
        imageViewInsets.top = MYSTIC_UI_IMAGEVIEW_INSET_NAV_HIDDEN_OFFSET;
        imageViewInsets.bottom = weakSelf.controller.bottomPanelView.frame.size.height + MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_OFFSET;
        imageViewInsets.top += MYSTIC_UI_IMAGEVIEW_INSET_HOME;
        imageViewInsets.bottom += MYSTIC_UI_IMAGEVIEW_INSET_HOME;
    }
    return Block_copy(^{ [weakSelf.controller setImageViewFrame:weakSelf.controller.view.frame insets:imageViewInsets offset:offset]; });
}



- (void) setCurrentSetting:(MysticObjectType)setting;
{
    
}
- (void) setLastSelectedItemIndex;
{
    if(self.layerPanelView.targetOption) [self.selectedItemIndexes setObject:@(self.layerPanelView.selectedControlIndex) forKey:self.layerPanelView.targetOption.tag];
    else
    {
        MysticObjectType otype = MysticTypeForSetting(self.controller.currentSetting, nil);
        NSString *objKey = [NSString stringWithFormat:@"%d", otype];
        [self.selectedItemIndexes setObject:@(self.layerPanelView.selectedControlIndex) forKey:objKey];
    }
}
- (void) removeLastSelectedIndexesForOption:(PackPotionOption *)option;
{
    if(option)
    {
        [self.selectedItemIndexes removeObjectForKey:option.tag];
        NSString *objKey = [NSString stringWithFormat:@"%d", option.type];
        [self.selectedItemIndexes removeObjectForKey:objKey];
    }
}
- (NSInteger) lastSelectedItemIndexForOption:(PackPotionOption *)option type:(MysticObjectType)objectType;
{
    NSNumber *value = nil;
    NSString *objKey;
    if(option && [self.selectedItemIndexes objectForKey:option.tag])
    {
        value = [self.selectedItemIndexes objectForKey:option.tag];
    }
    
    
    if(!value)
    {
        NSString *objKey = [NSString stringWithFormat:@"%d", objectType];
        
        if([self.selectedItemIndexes objectForKey:objKey])
        {
            value = [self.selectedItemIndexes objectForKey:objKey];
        }
    }
    
    NSInteger i = value ? [value integerValue] : [[self.layerPanelView class] activeTabForOption:option];
    
    
    return i;
}

#pragma mark - Toolbar stuff

- (id) buildToolbar;
{
    
    return [self toolbarForSection:self.layerPanelView.visiblePanel];
}
- (id) toolbarForSection:(MysticPanelObject *)section;
{
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = self;
    MysticLayerPanelBottomBarView *toolbarContainer = weakSelf.layerPanelView.bottomBarView;
    MysticPack *pack = section.pack ? section.pack : weakSelf.controller.activePack;
    MysticLayerToolbar *toolbar = nil;
    toolbar = (MysticLayerToolbar *)[toolbarContainer viewWithTag:MysticViewTypeToolbarPanel];
    if(toolbar || section == nil)
    {
        [MysticLayerPanelView resetToolbarForSection:section target:self toolbar:toolbar];
        return toolbar;
    }
    toolbar = [[MysticLayerToolbar alloc] initWithFrame:toolbarContainer.bounds delegate:self];
    toolbar.tag = MysticViewTypeToolbarPanel;
    toolbar.frame = toolbarContainer.bounds;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [weakSelf.controller removeSubviews:toolbarContainer except:nil];
    [toolbar setItemsInput:[toolbar items:[MysticLayerPanelView toolbarItemsForSection:section type:section.optionType target:self toolbar:toolbar] addSpacing:NO]];
    toolbar.backgroundColor = toolbarContainer.backgroundColor;
    [toolbarContainer addSubview:toolbar];
    [self layerPanel:weakSelf.layerPanelView resetSection:section];
    return [toolbar autorelease];
}
- (void) toggleButtonToggled:(MysticToggleButton *)toggler;
{
    [self.controller performSelector:@selector(toggleButtonToggled:) withObject:toggler];
}
- (void) toolbar:(MysticLayerToolbar *)toolbar itemTouched:(MysticBarButton *)sender toolType:(MysticToolType)toolType event:(UIControlEvents)event;
{
    if([self.controller respondsToSelector:@selector(toolbar:itemTouched:toolType:event:)])
    {
        [(id <MysticLayerToolbarDelegate>)self.controller toolbar:toolbar itemTouched:sender toolType:toolType event:event];
    }
}
- (void) toolBarHide:(MysticButton *)sender;
{
    [self.controller performSelector:@selector(toolBarHide:) withObject:sender];
    
}
- (void) toolBarHideSketch:(MysticButton *)sender;
{
    [self.controller performSelector:@selector(toolBarHideSketch:) withObject:sender];
    
}
- (void) toolBarCanceledOption:(MysticButton *)sender;
{
    
    [self.controller performSelector:@selector(toolBarCanceledOption:) withObject:sender];
    
}

- (void) toolBarConfirmedOption:(MysticButton *)sender;
{
    [self.controller performSelector:@selector(toolBarConfirmedOption:) withObject:sender];
}

- (void) toolBarConfirmedSketchOption:(MysticButton *)sender;
{
    [self.controller performSelector:@selector(toolBarConfirmedSketchOption:) withObject:sender];
}
- (void) toolBarCanceledSketchOption:(MysticButton *)sender;
{
    
    [self.controller performSelector:@selector(toolBarCanceledSketchOption:) withObject:sender];
    
}
- (void) toolBarUndo:(MysticButton *)sender;
{
    [self.controller performSelector:@selector(toolBarUndo:) withObject:sender];
}
- (void) toolBarRedo:(MysticButton *)sender;
{
    [self.controller performSelector:@selector(toolBarRedo:) withObject:sender];
}

- (void) toolBarCanceledOptionSetting:(MysticButton *)sender;
{
    [self.controller performSelector:@selector(toolBarCanceledOptionSetting:) withObject:sender];
}

- (void) toolBarConfirmedOptionSetting:(MysticButton *)sender;
{
    [self.controller performSelector:@selector(toolBarConfirmedOptionSetting:) withObject:sender];
    
    
}

- (void) toolBarLabelTouched:(MysticToolbarTitleButton *)titleLabel;
{
    [self.controller performSelector:@selector(toolBarLabelTouched:) withObject:titleLabel];
    
}

- (void) toolBarResetOptionSetting:(MysticButton *)sender;
{
    switch (self.layerPanelView.visiblePanel.sectionType) {
        case MysticPanelTypeOptionColorAdjust:
        {
            NSArray *sliders = [[self.layerPanelView.visiblePanel.contentView viewsWithClass:[MysticSlider class]] objectForKey:@"views"];
            for (MysticSlider *slider in sliders) {
                __unsafe_unretained __block MysticSlider *_slider = slider;
                slider.preventsRender = YES;
                [slider setUpperValue:slider.lastUpperValue animated:YES complete:^(BOOL active) {
                    
                    [_slider commitValues];
                }];
            }
            for (MysticSlider *slider in sliders) {
                slider.preventsRender = NO;
            }
            
            MysticSlider *lastSlider = [sliders lastObject];
            [lastSlider commitValues];
            break;
        }
            
        default: break;
    }
}


#pragma mark - Category Button

- (void) categoryButtonTouched:(MysticCategoryButton *)sender;
{
    //    DLog(@"category touched: %@", sender.titleLabel.text);
    NSNumber *getMoreType = sender.pack.info[@"getmore"];
    
    __unsafe_unretained __block  MysticPacksScrollView *scrollView = (id)sender.superview;
    
    scrollView.ignoreIndicator = (sender.pack.productID && ![MysticStore hasPurchased:sender.pack.productID]) || getMoreType;

    if(scrollView.ignoreIndicator)
    {
        BOOL loadingProduct = sender.pack.productID != nil;
        MysticObjectType objectType = [getMoreType integerValue];
        MysticStoreType storeType = MysticStoreTypeDefault;
        switch (objectType) {
            case MysticObjectTypeText: storeType = MysticStoreTypeText; break;
            case MysticObjectTypeTexture: storeType = MysticStoreTypeTextures; break;
            case MysticObjectTypeFrame: storeType = MysticStoreTypeFrames; break;
            case MysticObjectTypeLight: storeType = MysticStoreTypeLights; break;
            case MysticObjectTypeFont: storeType = MysticStoreTypeFonts; break;
            case MysticObjectTypeColorOverlay: storeType = MysticStoreTypeColors; break;
            case MysticObjectTypeLayerShape:
            case MysticObjectTypeShape: storeType = MysticStoreTypeShapes; break;
            case MysticObjectTypeFilter: storeType = MysticStoreTypeFilters; break;
            default: break;
        }
        __unsafe_unretained __block MysticCategoryButton *_sender = sender ? [sender retain] : nil;
        __unsafe_unretained __block MysticPanelObject *__panelObj = [self.layerPanelView.visiblePanel retain];
        __unsafe_unretained __block  MysticPacksScrollView *__contentScrollView = [(id)__panelObj.scrollView retain];

        if(getMoreType)
        {
            [[AppDelegate instance] showStore:storeType product:nil  download:NO setup:nil purchased:^(id obj, BOOL success) {
                
            } completion:^{
                
            }];
            [__contentScrollView release];
            [__panelObj release];
            if(_sender) [_sender release];
            return;
        }
        [scrollView revealItem:sender animated:self.layerPanelIsVisible complete:^(id object) {
            MysticWait(0.3, ^{
                
                [[AppDelegate instance] showStore:storeType product:_sender.pack.productID  download:_sender.pack.productID!=nil setup:^(MysticStoreViewController *theStore){
                    theStore.hideNonFocusedProducts = YES;
                } purchased:^(id obj, BOOL success) {
                    
                } completion:^{
                    
                }];
                if(_sender) [_sender release];
            });

            [__contentScrollView release];
            [__panelObj release];
        }];
        
        return;
    }
    if(!getMoreType) {
        [scrollView deselectAll];
        sender.selected = YES;
    }
    [scrollView revealItem:sender animated:self.layerPanelIsVisible complete:nil];

    __unsafe_unretained __block MysticPanelObject *__panelObj = [self.layerPanelView.visiblePanel retain];
    __unsafe_unretained __block  MysticPacksScrollView *__contentScrollView = [(id)__panelObj.scrollView retain];
    __unsafe_unretained __block  MysticLayerPanelViewController *_weakSelf = (id)self;
    
    __panelObj.toolbarTitle = sender.pack.title;
    
    MysticLayerToolbar *toolbar = [_weakSelf toolbarForSection:__panelObj];
    if (toolbar)
    {
        [toolbar setTitleEnabled:NO];
        toolbar.titleBorderHidden = YES;
        [toolbar setTitle:__panelObj.toolbarTitle animated:_weakSelf.layerPanelIsVisible];
    }
    
    __panelObj.pack = sender.pack;
    
    [sender.pack packOptions:^(NSArray *controls, MysticDataState dataState) {
        
        
        if(dataState & MysticDataStateNew && controls && controls.count)
        {
            __unsafe_unretained __block id __optSlotKey = __panelObj.targetOption && !__panelObj.panel.createNewOption ? __panelObj.targetOption.optionSlotKey : nil;
            
            
            __optSlotKey = __optSlotKey ? __optSlotKey : [[MysticOptions current] makeSlotKeyForOption:__panelObj.targetOption ? __panelObj.targetOption : [controls lastObject] force:__panelObj.panel.createNewOption];
            __contentScrollView.shouldSelectControlBlock = (^BOOL(PackPotionOption *o){
                PackPotionOption *ao = o ? o.activeOption : nil;
                ao = ao ? ao : o;
                return __optSlotKey && [ao.optionSlotKey isEqualToString:__optSlotKey] ? YES : NO;
            });
            
            for (PackPotionOption *opt in controls) opt.optionSlotKey = __optSlotKey;
            
            if(__contentScrollView)
            {
                __contentScrollView.enableControls = YES;
                [__contentScrollView loadControls:controls selectIndex:MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX animated:NO complete:^{
                    EffectControl *selectedControl = (EffectControl *)__contentScrollView.selectedItem;
                    if(selectedControl)  [selectedControl.option controlBecameActive:selectedControl];
                    
                    switch(__panelObj.optionType)
                    {
                        case MysticObjectTypeColorOverlay:
                        {
                            __panelObj.toolbarTitle = selectedControl ? selectedControl.option.name : MysticObjectTypeTitleParent(__panelObj.optionType, 0);
                            
                            MysticLayerToolbar *toolbar = [_weakSelf toolbarForSection:__panelObj];
                            if (toolbar)
                            {
                                [toolbar setTitleEnabled:NO];
                                toolbar.titleBorderHidden = YES;
                                [toolbar setTitle:__panelObj.toolbarTitle animated:_weakSelf.layerPanelIsVisible];
                            }
                            break;
                        }
                        default:
                        {
                            
                            break;
                        }
                            
                    }
                }];
            }
        }
        if(dataState & MysticDataStateComplete)
        {
            [__panelObj release];
            [__contentScrollView release];
        }
    }];
    
    
}

#pragma mark - Slider Begin

- (void)sliderEditingDidBegin:(MysticSlider *)sender;
{
    NSString *newTitle = nil;
    switch (sender.setting) {
        case MysticSettingColorAdjustBrightness:
            newTitle = @"BRIGHTNESS";
            break;
        case MysticSettingColorAdjustHue:
            newTitle = @"HUE";
            
            break;
        case MysticSettingColorAdjustSaturation:
            newTitle = @"SATURATION";
            
            break;
            
        default: break;
    }
    
    if(newTitle)
    {
        MysticLayerToolbar *toolbar = [self toolbarForSection:nil];
        if(toolbar) [toolbar setTitle:newTitle animated:self.layerPanelIsVisible];
    }
}



- (BOOL) layerPanelIsVisible;
{
    return self.layerPanelView.frame.origin.y >= CGRectGetMaxY(self.controller.view.frame) ? NO : YES;
}

#pragma mark - Tab Bar Delegate

- (BOOL) mysticTabBar:(MysticTabBar *)tabBar isItemActive:(MysticTabButton *)item;
{
    BOOL isActive = NO;
    if(item && self.layerPanelView && self.layerPanelView.targetOption)
    {
        PackPotionOption *targetOpt = self.layerPanelView.targetOption;
        switch (item.type)
        {
            case MysticSettingFilter:
            case MysticObjectTypeFilter:
            {
                isActive = [[MysticOptions current] option:MysticObjectTypeFilter] != nil;
                break;
            }
            case MysticSettingInvert:
            {
                isActive = [targetOpt hasAdjusted:MysticSettingInvert];
                break;
            }
            case MysticSettingShadows:
            {
                isActive = [targetOpt hasAdjusted:MysticSettingShadowIntensity] || [targetOpt hasAdjusted:MysticSettingShadows];
                break;
            }
            case MysticSettingHighlights:
            {
                isActive = [targetOpt hasAdjusted:MysticSettingHighlightIntensity] || [targetOpt hasAdjusted:MysticSettingHighlights];
                break;
            }
            default:
            {
                isActive = [targetOpt hasAdjusted:item.type];
                break;
            }
        }
    }
    return isActive;
}
static BOOL rendering = NO;
static BOOL refreshing = NO;

- (void) mysticTabBar:(MysticTabBar *)tabBar didSelectItem:(MysticTabButton *)item info:(id)userInfo;
{
    _lastTabBarOffset = tabBar.contentOffset;
    MysticViewType tabBarType = tabBar.tag - MysticViewTypePanel;
    __block MysticLayerPanelViewController *weakSelf = self;
    __block MysticPanelType sectionType;
    __block CGFloat bottomBarHeight = MYSTIC_UI_PANEL_BOTTOMBAR_HEIGHT;
    PackPotionOption *targetOption = weakSelf.layerPanelView.targetOption;
    __block MysticObjectType __itemType = item.type;
    __block BOOL reloadImage = targetOption ? ![MysticShader has:@(__itemType) forOption:targetOption] : NO;
    if(item.hasControlStates) [item nextControlState];
    if(__itemType > MysticSettingImageProcessing)
    {
        reloadImage=YES;
    }
    switch (__itemType) {
#ifdef DEBUG
        case MysticSettingTest:
        {
            reloadImage = NO;
            break;
        }
#endif
//        case MysticSettingSketchFilter:
//        case MysticSettingBlur:
//        case MysticSettingBlurGaussian:
//        case MysticSettingBlurMotion:
//        case MysticSettingBlurCircle:
//        case MysticSettingBlurZoom:
//        case MysticSettingDistortGlassSphere:
//        case MysticSettingDistortStretch:
//        case MysticSettingDistortBuldge:
//        case MysticSettingDistortSwirl:
//        case MysticSettingDistortPinch:
//        case MysticSettingToon:
//        case MysticSettingPosterize:
//        case MysticSettingPixellate:
//        case MysticSettingHalfTone:
//        case MysticSettingTiltShift:
//        {
//            reloadImage = YES;
//            break;
//        }
        case MysticSettingInvert:
        {
            if(targetOption.layerEffect == MysticLayerEffectInverted)
            {
                targetOption.layerEffect = MysticLayerEffectNone;
                targetOption.inverted = NO;
            }
            else
            {
                targetOption.inverted = item.selected;
            }
            targetOption.hasChanged = YES;
            targetOption.refreshState = __itemType;
            [[MysticController controller] render:NO atSourceSize:NO complete:^(UIImage *i, id n, id o, BOOL c) {

            }];
            return;
        }
        case MysticSettingStretch:
        case MysticSettingStretchFill:
        case MysticSettingStretchNone:
        case MysticSettingStretchAspectFit:
        case MysticSettingStretchAspectFill:
            targetOption.stretchModeSetting = (MysticObjectType)item.controlState;
            targetOption.hasChanged = YES;
            [targetOption updateTransform:YES];
            return [MysticEffectsManager refresh:targetOption];
        case MysticSettingHighlights:
        case MysticSettingShadows:
        case MysticSettingShadowsHighlights: if(!reloadImage) reloadImage = targetOption ? ![MysticShader has:@(MysticSettingShadowIntensity) forOption:targetOption] || ![MysticShader has:@(MysticSettingHighlightIntensity) forOption:targetOption] : NO; break;
        case MysticSettingAdjustColor:
        {
            reloadImage = YES;
            __unsafe_unretained __block MysticTabButton *_item = [item retain];
            MysticWait(0.1, ^{
                _item.selected = NO;
                _item.highlighted = NO;
            });
            
            targetOption.refreshState = __itemType;
            return [[MysticController controller] showColorInput:targetOption title:@"ADJUST" color:nil init:^(MysticInputView *input)
            {
                input.allowEyeDropper=YES;
                input.showHexValues=NO;
                input.showRemoveButton=YES;
                input.showColorTools=YES;
                input.showColors=NO;
                input.showNewButton = YES;
                input.showToolbarBorder=NO;
                input.colorPickerMode = ColorPickerModeTone;
                input.selectedColorTitle = @"PICK A COLOR";
                input.selectedColorWithColorTitle = @"ADJUST";
                input.update = ^(UIColor *obj, UIColor *selectedColor, CGPoint p, MysticThreshold threshold, int index,  MysticInputView *input, BOOL finished)
                {
                    MysticAdjustColorInfo info = (MysticAdjustColorInfo){NSNotFound,NO};
                    if(CGPointIsUnknown(p)) {
                        MysticPointColorBtn *b = [[MysticController controller] colorButtonAtIndex:input.selectedColorIndex];
                        if(b) p = b.point;
                    }
                    if(obj) info = [input.targetOption adjustColor:selectedColor toColor:obj intensity:obj.alpha point:p threshold:threshold index:index];
                    if(!finished || info.added) return;
                    [input.targetOption setupFilter:nil];
                    if(!rendering && !refreshing && [MysticController controller].readyForRenderEngine)
                    {
                        refreshing = YES;
                        [MysticEffectsManager refresh:input.targetOption completion:^{
                            rendering = NO;
                            refreshing=NO;
                        }];
                    }
                };
                
            } finished:^(UIColor *obj, UIColor *selectedColor, CGPoint p0, MysticThreshold threshold, int index,  MysticInputView *input, BOOL finished) {
                MysticAdjustColorInfo info = (MysticAdjustColorInfo){NSNotFound,NO};
                if(CGPointIsUnknown(p0)) { MysticPointColorBtn *b = [[MysticController controller] colorButtonAtIndex:input.selectedColorIndex]; p0 = b ? b.point : p0; }
                if(obj) info = [input.targetOption adjustColor:selectedColor toColor:obj intensity:obj.alpha point:p0 threshold:threshold index:index];
                input.selectedColorIndex=info.index;
                input.targetOption.hasChanged = YES;
                [input.targetOption setupFilter:nil];
                if(!rendering && !refreshing && [MysticController controller].readyForRenderEngine)
                {
                    if(!info.added){
                        
//                        DLog(@"refreshing....");
                        refreshing=YES;

                        [MysticEffectsManager refresh:input.targetOption completion:^{
                            rendering = NO;
                            refreshing=NO;

                        }];
                    }
                    else {
                        __unsafe_unretained __block MysticInputView *_in = input ? [input retain] : nil;
//                        DLogRender(@"rendering....");
                        rendering = YES;
                        refreshing=YES;

                        [[MysticController controller] render:NO atSourceSize:NO complete:^(UIImage *i, id n, id o, BOOL c) {
    //                        [MysticEffectsManager refresh:_in.targetOption];
                            rendering = NO;
                            refreshing=NO;
                            [_in autorelease]; }];
                    }
                }
                if(!finished) return;
                _item.selected = NO;
                _item.highlighted = NO;
                [_item release];
            }];
        }
        case MysticSettingColorAndIntensity:
        case MysticSettingColor:
        {
            __unsafe_unretained __block MysticTabButton *_item = [item retain];
            return [[MysticController controller] showColorInput:targetOption title:@"COLOR" color:[targetOption color:MysticOptionColorTypeForeground] finished:^(UIColor *obj, UIColor *c2, CGPoint p, MysticThreshold t, int i,MysticInputView *input, BOOL finished) {
                [input.targetOption setColorType:MysticOptionColorTypeForeground color:obj];
                input.targetOption.hasChanged = YES;
                [input.targetOption setupFilter:nil];
                [MysticEffectsManager refresh:input.targetOption];
                if(!finished) return;
                _item.selected = NO;
                _item.highlighted = NO;
                [_item release];
            }];
        }
        default: break;
    }
    [[MysticController controller].overlayView setupGestures:MysticObjectTypeUnknown disable:YES];
    if(item.userInfo && [item.userInfo objectForKey:@"panel"]) sectionType = [[item.userInfo objectForKey:@"panel"] integerValue];
    else sectionType = [MysticLayerPanelView sectionTypeForSetting:__itemType option:self.layerPanelView.targetOption];
    [self setLastSelectedItemIndex];
    switch (tabBarType)
    {
        case MysticViewTypeTabBarPanelSettings:
        case MysticViewTypeTabBarPanelSettingsLayer:
        {
            
            __unsafe_unretained __block MysticSlider *adjustSlider = nil;
            __unsafe_unretained __block UIView * reusedControl = nil;
            [weakSelf.controller toggleMoreToolsHide];
            
            BOOL animated = YES;
            BOOL reuseControls = NO;
            MysticBlockReturnsBOOL reuseControlBlock = nil;
            int animCount = 0;
            
            
            __unsafe_unretained __block MysticPanelSubView *subPanelView = (MysticPanelSubView *)[weakSelf.layerPanelView.contentView viewWithTag:MysticViewTypePanel+MysticViewTypeSubPanel];
            __unsafe_unretained __block MysticLayerToolbar *toolbar = self.layerPanelView.bottomBarView.toolbar;
            
            if(toolbar) { [toolbar setTitleEnabled:NO]; toolbar.titleBorderHidden = YES; }
            
            
            
            switch (sectionType)
            {
                case MysticPanelTypeHue:
                case MysticPanelTypeSaturation:
                case MysticPanelTypeTone:
                case MysticPanelTypeVibrance:
                case MysticPanelTypeBrightness:
                case MysticPanelTypeSkin:
                case MysticPanelTypeSkinHue:
                case MysticPanelTypeSkinHueThreshold:
                case MysticPanelTypeSkinHueMaxShift:
                case MysticPanelTypeSkinMaxSaturationShift:
                case MysticPanelTypeSkinUpperTone:
                case MysticPanelTypeContrast:
                case MysticPanelTypeHaze:
                case MysticPanelTypeGamma:
                case MysticPanelTypeExposure:
                case MysticPanelTypeShadows:
                case MysticPanelTypeHighlights:
                case MysticPanelTypeGrain:
                case MysticPanelTypeSlider:
                case MysticPanelTypeTiltShift:
                case MysticPanelTypeUnsharpMask:
                case MysticPanelTypeSharpness:
                case MysticPanelTypeToon:
                case MysticPanelTypeHalftone:
                case MysticPanelTypePixellate:
                case MysticPanelTypePosterize:
                case MysticPanelTypeSketchFilter:
                case MysticPanelTypeDistortGlassSphere:
                case MysticPanelTypeDistortPinch:
                case MysticPanelTypeDistortSwirl:
                case MysticPanelTypeBlurZoom:
                case MysticPanelTypeBlurMotion:
                case MysticPanelTypeBlurCircle:
                case MysticPanelTypeBlur:
                case MysticPanelTypeAdjust:
#ifdef DEBUG
                case MysticPanelTypeTest:
#endif
                {
                    reuseControls = YES;
                    reuseControlBlock = ^ BOOL (UIView *subView)
                    {
                        if(subView.tag == MysticViewTypeContainer) return YES;
                        return [subView isKindOfClass:[MysticSlider class]];
                    };
                    break;
                }
                case MysticPanelTypeLevels:
                {
                    reuseControls = YES;
                    reuseControlBlock = ^ BOOL (UIView *subView)
                    {
                        if(subView.tag == MysticViewTypeContainer) return YES;
                        return [subView isKindOfClass:[MysticLevelsSlider class]];
                    };
                    break;
                }
                case MysticPanelTypeColorBalance:
                {
                    reuseControls = YES;
                    reuseControlBlock = ^ BOOL (UIView *subView)
                    {
                        if(subView.tag == MysticViewTypeContainer) return YES;
                        return [subView isKindOfClass:[MysticRGBSlider class]];
                    };
                    break;
                }
                case MysticPanelTypeFlip:
                {
                    
                    
                    BOOL reloadImage = [targetOption isKindOfClass:[PackPotionOptionSetting class]];
                    switch (__itemType) {
                        case MysticSettingFlipVertical:
                            targetOption.flipVertical = !targetOption.flipVertical;
                            if(targetOption.layer.textures.allValues.count) targetOption.flipTextureVertical = !targetOption.flipTextureVertical;
                            break;
                        case MysticSettingFlipHorizontal:
                            targetOption.flipHorizontal = !targetOption.flipHorizontal;
                            if(targetOption.layer.textures.allValues.count) targetOption.flipTextureHorizontal = !targetOption.flipTextureHorizontal;
                            break;
                        default: break;
                    }
                    [targetOption updateTransform:YES];
                    if(reloadImage) [[MysticController controller] render:nil];
                    else [MysticEffectsManager refresh:[MysticController controller].transformOption];
                    return;
                }
                default: break;
            }
            
            
            
            NSArray *trashSubviews = nil;
            reusedControl = [subPanelView reuseableSubViewExcept:@[tabBar] subviews:&trashSubviews matching:reuseControlBlock];
            
            NSMutableDictionary *newInfo = [NSMutableDictionary dictionary];
            [newInfo addEntriesFromDictionary:self.layerPanelView.visiblePanel.info];
            
            __unsafe_unretained __block MysticPanelObject *newPanel = [[MysticPanelObject info:newInfo] retain];
            
            
            newPanel.setting = __itemType;
            newPanel.sectionType = sectionType;
            newPanel.title = MysticObjectTypeTitleParent(__itemType, MysticObjectTypeUnknown);
            if(targetOption) targetOption.refreshState = __itemType;
            self.blockObj = [MysticBlockObj objectWithKey:@"hidesubpanelltbsubviews" blockObject:^(UIView *reusedView){
                
                int contentSubViewsCount = subPanelView.subviews.count - 1;
                CGRect contentFrame = weakSelf.layerPanelView.contentView.frame;
                contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SETTINGS_SLIDER;
                switch (sectionType)
                {
                    case MysticPanelTypeHue:
                    case MysticPanelTypeSaturation:
                    case MysticPanelTypeTone:
                    case MysticPanelTypeVibrance:
                    case MysticPanelTypeBrightness:
                    case MysticPanelTypeContrast:
                    case MysticPanelTypeHaze:
                    case MysticPanelTypeGamma:
                    case MysticPanelTypeUnsharpMask:
                    case MysticPanelTypeSharpness:
                    case MysticPanelTypeExposure:
                    case MysticPanelTypeGrain:
                    case MysticPanelTypeSlider:
                    case MysticPanelTypeAdjust:
                    case MysticPanelTypeIntensity:
                    {
                        
                        weakSelf.layerPanelView.autoresizesSubviews = NO;
                        weakSelf.layerPanelView.contentContainerView.autoresizesSubviews = NO;
                        weakSelf.layerPanelView.stopLayout = YES;
                        
                        CGRect newSubPanelFrame = subPanelView.frame;
                        newSubPanelFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SETTINGS_SLIDER;
                        CGRect nSliderBounds = newSubPanelFrame;
                        nSliderBounds.size.height = MYSTIC_UI_PANEL_HEIGHT_SETTINGS_SLIDER;
                        CGRect sliderFrame = CGRectInset(nSliderBounds, 25, 0);
                        
                        BOOL animated = YES;
                        if(!reusedView)
                        {
                            
                            adjustSlider = [MysticSlider panelSliderWithFrame:sliderFrame];
                            adjustSlider.tag = MysticViewTypeContainer + MysticViewTypeSlider;
                            adjustSlider.alpha = 1;
                            adjustSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                            adjustSlider.imageViewDelegate = weakSelf.controller;
                            adjustSlider.refreshAction = @selector(refreshSliderAction:);
                            adjustSlider.reloadAction = @selector(reloadSliderAction:);
                            adjustSlider.finishAction = @selector(finishSliderAction:);
                            adjustSlider.stillAction = @selector(stillSliderAction:);
                            [adjustSlider setupActionsForSetting:__itemType option:weakSelf.layerPanelView.targetOption animated:NO];
                            
                            __unsafe_unretained __block MysticBorderView *subPanelView2 = [[MysticBorderView alloc] initWithFrame:newSubPanelFrame];
                            [subPanelView2 addSubview:adjustSlider];
                            subPanelView2.borderWidth = MYSTIC_UI_PANEL_BORDER;
                            subPanelView2.borderInsets = UIEdgeInsetsMake(MYSTIC_UI_PANEL_BORDER/2, 0, 0, 0);
                            subPanelView2.borderColor = [UIColor color:MysticColorTypePanelBorderColor];
                            subPanelView2.borderPosition = MysticPositionTop;
                            subPanelView2.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
                            subPanelView2.autoresizesSubviews = NO;
                            subPanelView2.showBorder = NO;
                            subPanelView2.tag = MysticViewTypeContainer;
                            newPanel.view = subPanelView2;
                            [weakSelf.layerPanelView.panels addObject:newPanel];
                            weakSelf.layerPanelView.visiblePanel = newPanel;
                            
                            
                            MysticAnimation *animation = [MysticAnimation animationWithDuration:.25];
                            animation.animationOptions = UIViewAnimationCurveEaseInOut;
                            [animation addAnimation:^{
                                toolbar.alpha = 0;
                                weakSelf.layerPanelView.contentContainerView.frame = (CGRect){0,weakSelf.layerPanelView.contentContainerView.frame.size.height, weakSelf.layerPanelView.contentContainerView.frame.size.width, subPanelView2.frame.size.height};
                                
                            } complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                                
                                
                                weakSelf.layerPanelView.contentContainerView.alpha = 0;
                                [weakSelf.layerPanelView.contentView removeFromSuperview];
                                weakSelf.layerPanelView.contentView = nil;
                                [weakSelf.layerPanelView.contentContainerView addSubview:subPanelView2];
                                [weakSelf.layerPanelView keepContentView:subPanelView2];
                                [toolbar replaceItemsWithInfo:[[weakSelf.layerPanelView class] toolbarItemsForSection:weakSelf.layerPanelView.visiblePanel type:__itemType target:toolbar.delegate toolbar:toolbar] animated:NO];
                                [toolbar setTitle:MysticObjectTypeTitleParent(__itemType, MysticObjectTypeUnknown) animated:NO];
                                MysticAnimation *animation2 = [MysticAnimation animationWithDuration:.25];
                                animation2.animationOptions = UIViewAnimationCurveEaseInOut;
                                [animation2 addAnimation:^{
                                    
                                    weakSelf.layerPanelView.contentContainerView.alpha = 1;
                                    weakSelf.layerPanelView.contentContainerView.frame = CGRectIntegral((CGRect){0,0,weakSelf.layerPanelView.contentContainerView.frame.size.width, weakSelf.layerPanelView.contentContainerView.frame.size.height});
                                    toolbar.alpha = 1;
                                    weakSelf.layerPanelView.bottomBarView.frame = (CGRect){0,weakSelf.layerPanelView.contentContainerView.frame.size.height, weakSelf.layerPanelView.bottomBarView.frame.size.width, bottomBarHeight};
                                    weakSelf.layerPanelView.frame = [weakSelf.layerPanelView frameForState:MysticLayerPanelStateOpen];
                                    
                                } complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                                    tabBar.preventsScrollOnHide = NO;
                                    weakSelf.layerPanelView.stopLayout = NO;
                                    weakSelf.layerPanelView.autoresizesSubviews = YES;
                                    weakSelf.layerPanelView.contentContainerView.autoresizesSubviews = YES;
                                    [newPanel autorelease];
                                    
                                }];
                                [animation2 animate];
                                
                            }];
                            [animation animate];
                            
                        }
                        else
                        {
                            MysticBorderView *subPanelView2 = (id)reusedView;
                            adjustSlider = (id)[subPanelView2 viewWithTag:MysticViewTypeContainer + MysticViewTypeSlider];
                            adjustSlider.frame = sliderFrame;
                            [adjustSlider reset];
                            adjustSlider.targetOption = weakSelf.layerPanelView.targetOption;
                            adjustSlider.alpha = 1;
                            [adjustSlider setSetting:__itemType animated:animated setValue:YES];
                            [weakSelf.layerPanelView setBottomBarHeight:bottomBarHeight];
                            
                        }
                        break;
                    }
                    // these panels have custom panels
                    case MysticPanelTypeTiltShift:
                    case MysticPanelTypeToon:
                    case MysticPanelTypeHalftone:
                    case MysticPanelTypePixellate:
                    case MysticPanelTypePosterize:
                    case MysticPanelTypeSketchFilter:
                    case MysticPanelTypeDistortGlassSphere:
                    case MysticPanelTypeDistortPinch:
                    case MysticPanelTypeDistortSwirl:
                    case MysticPanelTypeBlurZoom:
                    case MysticPanelTypeBlurMotion:
                    case MysticPanelTypeBlurCircle:
                    case MysticPanelTypeBlur:
                    case MysticPanelTypeSkin:
                    case MysticPanelTypeSkinHue:
                    case MysticPanelTypeSkinHueThreshold:
                    case MysticPanelTypeSkinHueMaxShift:
                    case MysticPanelTypeSkinMaxSaturationShift:
                    case MysticPanelTypeSkinUpperTone:
                    case MysticPanelTypeLevels:
                    case MysticPanelTypeColorBalance:
                    case MysticPanelTypeShadows:
                    case MysticPanelTypeHighlights:
                    case MysticPanelTypeShadowsTone:
                    case MysticPanelTypeHighlightsTone:
                    {
                        weakSelf.layerPanelView.autoresizesSubviews = NO;
                        weakSelf.layerPanelView.contentContainerView.autoresizesSubviews = NO;
                        weakSelf.layerPanelView.stopLayout = YES;
                        
                        
                        CGRect newSubPanelFrame = subPanelView.frame;
                        newSubPanelFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SETTINGS_SLIDER;
                        CGRect nSliderBounds = newSubPanelFrame;
                        nSliderBounds.size.height = MYSTIC_UI_PANEL_HEIGHT_SETTINGS_SLIDER;
                        CGRect sliderFrame = CGRectInset(nSliderBounds, 25, 0);
                        
                        BOOL animated = YES;
                        
                        if(!reusedView)
                        {
                            __unsafe_unretained __block MysticPanelSubView *subPanelView2 = (id)[weakSelf layerPanel:weakSelf.layerPanelView viewForSection:newPanel].subviews.lastObject;
                            newPanel.view = subPanelView2;
                            [weakSelf.layerPanelView.panels addObject:newPanel];
                            weakSelf.layerPanelView.visiblePanel = newPanel;
                            
                            
                            MysticAnimation *animation = [MysticAnimation animationWithDuration:.25];
                            animation.animationOptions = UIViewAnimationCurveEaseInOut;
                            [animation addAnimation:^{
                                toolbar.alpha = 0;
                                weakSelf.layerPanelView.contentContainerView.frame = (CGRect){0,weakSelf.layerPanelView.contentContainerView.frame.size.height, weakSelf.layerPanelView.contentContainerView.frame.size.width, subPanelView2.frame.size.height};
                                
                            } complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                                
                                weakSelf.layerPanelView.contentContainerView.alpha = 0;
                                [weakSelf.layerPanelView.contentView removeFromSuperview];
                                weakSelf.layerPanelView.contentView = nil;
                                [weakSelf.layerPanelView.contentContainerView addSubview:subPanelView2];
                                [weakSelf.layerPanelView keepContentView:subPanelView2];
                                [toolbar replaceItemsWithInfo:[[weakSelf.layerPanelView class] toolbarItemsForSection:weakSelf.layerPanelView.visiblePanel type:__itemType target:toolbar.delegate toolbar:toolbar] animated:NO];
                                [toolbar setTitle:MysticObjectTypeTitleParent(__itemType, MysticObjectTypeUnknown) animated:NO];
                                
                                MysticAnimation *animation2 = [MysticAnimation animationWithDuration:.25];
                                animation2.animationOptions = UIViewAnimationCurveEaseInOut;
                                [animation2 addAnimation:^{
                                    
                                    weakSelf.layerPanelView.contentContainerView.alpha = 1;
                                    weakSelf.layerPanelView.contentContainerView.frame = CGRectIntegral((CGRect){0,0,weakSelf.layerPanelView.contentContainerView.frame.size.width, weakSelf.layerPanelView.contentContainerView.frame.size.height});
                                    toolbar.alpha = 1;
                                    weakSelf.layerPanelView.bottomBarView.frame = (CGRect){0,weakSelf.layerPanelView.contentContainerView.frame.size.height, weakSelf.layerPanelView.bottomBarView.frame.size.width, bottomBarHeight};
                                    weakSelf.layerPanelView.frame = [weakSelf.layerPanelView frameForState:MysticLayerPanelStateOpen];
                                } complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                                    tabBar.preventsScrollOnHide = NO;
                                    weakSelf.layerPanelView.stopLayout = NO;
                                    weakSelf.layerPanelView.autoresizesSubviews = YES;
                                    weakSelf.layerPanelView.contentContainerView.autoresizesSubviews = YES;
                                    [newPanel autorelease];
                                }];
                                [animation2 animate];
                            }];
                            [animation animate];
                        }
                        else
                        {
                            MysticBorderView *subPanelView2 = (id)reusedView;
                            adjustSlider = (id)[subPanelView2 viewWithTag:MysticViewTypeContainer + MysticViewTypeSlider];
                            adjustSlider.frame = sliderFrame;
                            [adjustSlider reset];
                            adjustSlider.targetOption = weakSelf.layerPanelView.targetOption;
                            adjustSlider.alpha = 1;
                            [adjustSlider setSetting:__itemType animated:animated setValue:YES];
                            [weakSelf.layerPanelView setBottomBarHeight:bottomBarHeight];
                            
                        }
                        break;
                    }
                        
                    default:
                    {
                        newPanel = [weakSelf layerPanel:weakSelf.layerPanelView panelObjectForSection:newPanel];
                        __block BOOL showBorder = sectionType == MysticPanelTypeColor || sectionType == MysticPanelTypeColorAndIntensity;
                        
                        if(newPanel.view)
                        {
                            weakSelf.layerPanelView.autoresizesSubviews = NO;
                            weakSelf.layerPanelView.contentContainerView.autoresizesSubviews = NO;
                            weakSelf.layerPanelView.stopLayout = YES;
                            
                            [weakSelf.layerPanelView.panels addObject:newPanel];
                            weakSelf.layerPanelView.visiblePanel = newPanel;
                            
                            MysticAnimation *animation = [MysticAnimation animationWithDuration:0.25];
                            animation.animationOptions = UIViewAnimationCurveEaseInOut;
                            [animation addAnimation:^{
                                toolbar.alpha = 0;
                                weakSelf.layerPanelView.contentContainerView.frame = (CGRect){0,weakSelf.layerPanelView.contentContainerView.frame.size.height, weakSelf.layerPanelView.contentContainerView.frame.size.width, newPanel.view.frame.size.height};
                                
                            } complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                                
                                if(showBorder)
                                {
                                    MysticPanelContentView *panelView = (id)newPanel.view;
                                    //                                    panelView.borderWidth = MYSTIC_UI_PANEL_BORDER;
                                    //                                    panelView.borderInsets = UIEdgeInsetsMake(MYSTIC_UI_PANEL_BORDER/2, 0, 0, 0);
                                    //                                    panelView.borderColor = [UIColor color:MysticColorTypePanelBorderColor];
                                    //                                    panelView.borderPosition = MysticPositionTop;
                                    panelView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
                                    panelView.autoresizesSubviews = NO;
                                    //                                    panelView.showBorder = NO;
                                }
                                weakSelf.layerPanelView.contentContainerView.alpha = 0;
                                [weakSelf.layerPanelView.contentView removeFromSuperview];
                                weakSelf.layerPanelView.contentView = nil;
                                
                                [weakSelf.layerPanelView.contentContainerView addSubview:newPanel.view];
                                [weakSelf.layerPanelView keepContentView:newPanel.view];
                                [toolbar replaceItemsWithInfo:[[weakSelf.layerPanelView class] toolbarItemsForSection:weakSelf.layerPanelView.visiblePanel type:__itemType target:toolbar.delegate toolbar:toolbar] animated:NO];
                                [toolbar setTitle:MysticObjectTypeTitleParent(__itemType, MysticObjectTypeUnknown) animated:NO];
                                [newPanel didAppear];
                                [newPanel isReady];
                                MysticAnimation *animation2 = [MysticAnimation animationWithDuration:0.25];
                                animation2.animationOptions = UIViewAnimationCurveEaseInOut;
                                [animation2 addAnimation:^{
                                    weakSelf.layerPanelView.contentContainerView.alpha = 1;
                                    weakSelf.layerPanelView.contentContainerView.frame = CGRectIntegral((CGRect){0,0,weakSelf.layerPanelView.contentContainerView.frame.size.width, weakSelf.layerPanelView.contentContainerView.frame.size.height});
                                    toolbar.alpha = 1;
                                    weakSelf.layerPanelView.bottomBarView.frame = (CGRect){0,weakSelf.layerPanelView.contentContainerView.frame.size.height, weakSelf.layerPanelView.bottomBarView.frame.size.width, bottomBarHeight};
                                    weakSelf.layerPanelView.frame = [weakSelf.layerPanelView frameForState:MysticLayerPanelStateOpen];
                                } complete:^(BOOL finished, MysticAnimationBlockObject *obj) {
                                    weakSelf.layerPanelView.stopLayout = NO;
                                    weakSelf.layerPanelView.autoresizesSubviews = YES;
                                    weakSelf.layerPanelView.contentContainerView.autoresizesSubviews = YES;
                                    [newPanel autorelease];
                                }];
                                [animation2 animate];
                            }];
                            [animation animate];
                        }
                        break;
                    }
                }
            }];
            
            __unsafe_unretained __block UIView *_reusedControl = reusedControl ? reusedControl : nil;
            [subPanelView fadeSubviews:trashSubviews hidden:YES duration:0.2 delay:0 animations:nil complete:^{
                @try {
                    if(weakSelf.blockObj) { weakSelf.blockObj.blockObject(_reusedControl); weakSelf.blockObj = nil; }
                    if(reloadImage) { [[MysticController controller] render:NO atSourceSize:NO complete:^(UIImage *image, id obj, id options, BOOL cancelled) {
//                        [[MysticController controller] logMenuItemClicked:nil];
                    }];  }
                }
                @catch (NSException *exception) {
                    
                    DLogError(@"there was an error reloading panel:  %@\n\n%@", exception.reason, ColorWrap(CallBackStackString(exception), COLOR_DULL));
                }
            }];
            break;
        }
            
        default:
        {
            switch (self.layerPanelView.visiblePanel.optionType)
            {
                case MysticObjectTypeSetting:
                default:
                {
                    
                    MysticPanelSubView *subPanel = (MysticPanelSubView *)[self.layerPanelView.contentView viewWithTag:MysticViewTypePanel+MysticViewTypeSubPanel];
                    __unsafe_unretained __block MysticSlider *adjustSlider = nil;
                    MysticLayerToolbar *toolbar = self.layerPanelView.bottomBarView.toolbar;
                    if(toolbar)
                    {
                        [toolbar setTitleEnabled:NO];
                        toolbar.titleBorderHidden = YES;
                        [toolbar setTitle:MysticObjectTypeTitleParent(__itemType, MysticObjectTypeUnknown) animated:self.layerPanelIsVisible];
                    }
                    int animCount = 0;
                    for (UIView *subSubView in subPanel.subviews) {
                        if([subSubView isEqual:tabBar]) continue;
                        if([subSubView isKindOfClass:[MysticSlider class]]) { adjustSlider = (id)subSubView; continue; }
                        animCount++;
                    }
                    if(animCount)
                    {
                        [UIView beginAnimations:@"hidesubpanelsubviews" context:nil];
                        [UIView setAnimationBeginsFromCurrentState:YES];
                        [UIView setAnimationDuration:0.2];
                        [UIView setAnimationRepeatCount:0];
                        [UIView setAnimationCurve:UIViewAnimationOptionCurveEaseInOut];
                        [UIView setAnimationDelegate:self];
                        [UIView setAnimationDidStopSelector:@selector(subPanelAnimationDidStop:finished:context:)];
                        for (UIView *subSubView in subPanel.subviews)
                        {
                            if([subSubView isEqual:tabBar] || (adjustSlider && [subSubView isEqual:adjustSlider])) continue;
                            subSubView.tag = subSubView.tag * MysticViewTypeRemove;
                            subSubView.alpha = 0;
                        }
                        [UIView commitAnimations];
                    }
                    
                    int contentSubViewsCount = subPanel.subviews.count - 1;
                    CGRect contentFrame = self.layerPanelView.contentView.frame;
                    contentFrame.size.height = MYSTIC_UI_PANEL_HEIGHT_SETTINGS_SLIDER;
                    CGRect sliderFrame = CGRectInset(contentFrame, 15, 0);
                    if(!adjustSlider)
                    {
                        adjustSlider = adjustSlider ? adjustSlider : [MysticSlider panelSliderWithFrame:sliderFrame];
                        adjustSlider.tag = MysticViewTypePanel + MysticViewTypeSlider;
                        adjustSlider.imageViewDelegate = weakSelf.controller;
                        adjustSlider.refreshAction = @selector(refreshSliderAction:);
                        adjustSlider.reloadAction = @selector(reloadSliderAction:);
                        adjustSlider.finishAction = @selector(finishSliderAction:);
                        adjustSlider.stillAction = @selector(stillSliderAction:);
                        [adjustSlider setupActionsForSetting:__itemType option:weakSelf.layerPanelView.targetOption animated:NO];
                        [subPanel addSubview:adjustSlider];
                    }
                    else
                    {
                        [adjustSlider setupActionsForSetting:__itemType option:weakSelf.layerPanelView.targetOption animated:YES];
                        [adjustSlider reset];
                        [adjustSlider setNeedsLayout];
                        adjustSlider.alpha = 1;
                    }
                    
                    if(adjustSlider.alpha < 1)
                    {
                        [adjustSlider retain];
                        [MysticUIView animateWithDuration:0.2 delay:0.15*contentSubViewsCount options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            adjustSlider.alpha = 1;
                        } completion:^(BOOL finished)
                         {
                             adjustSlider.alpha = 1;
                             [adjustSlider release];
                         }];
                    }
                    if(reloadImage) { [[MysticController controller] render:NO atSourceSize:NO complete:nil]; }
                    break;
                }
                    
            }
            
            break;
        }
    }
}



- (void)subPanelAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    MysticPanelSubView *subPanel = (MysticPanelSubView *)[self.layerPanelView.contentView viewWithTag:MysticViewTypePanel+MysticViewTypeSubPanel];
    
    for (UIView *subSubView in subPanel.subviews)
    {
        MysticSlider *sl = (MysticSlider *)subSubView;
        if(subSubView.alpha == 0 && subSubView.tag < MysticViewTypeRemove)
        {
            if([sl isKindOfClass:[MysticSlider class]])
            {
                [sl removeTarget:self.delegate action:@selector(sliderEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
                [sl removeTarget:self.delegate action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            }
            
            [subSubView removeFromSuperview];
        }
    }
    
    if(self.blockObj)
    {
        self.blockObj.block();
        self.blockObj = nil;
    }
    
    
}

- (void) tabBarDidScroll:(MysticTabBar *)tabBar;
{
    
}


#pragma mark - Control Delegate


- (void) updateToolbar:(MysticLayerToolbar *)toolbar panel:(MysticPanelObject *)panelObj option:(PackPotionOption *)option;
{
    __unsafe_unretained __block MysticLayerPanelViewController *weakSelf = (MysticLayerPanelViewController *)panelObj.delegate;
    NSString *toolbarTitle;
    
    toolbar = toolbar ? toolbar : [weakSelf toolbarForSection:panelObj];
    
    MysticObjectType otype = option ? option.type : panelObj.optionType;
    
    
    switch (otype) {
        case MysticObjectTypeFilter:
        {
            if(option)
            {
                if (toolbar)
                {
                    [toolbar setTitleEnabled:NO];
                    toolbar.titleBorderHidden = YES;
                    
                }
                
                MysticLayerToolbar *toolbar = [weakSelf toolbarForSection:weakSelf.layerPanelView.visiblePanel];
                MysticBarButtonItem *item = toolbar.items.count > 3 ? (MysticBarButtonItem *)[toolbar.items objectAtIndex:3] : nil;
                
                option = option && option.activeOption ? option.activeOption : option;
                
                if(item)
                {
                    CGRect sliderFrame = [item customView].bounds;
                    sliderFrame.size.width = 270;
                    MysticSlider *adjustSlider = nil;
                    MysticBarButtonItem *newItem = nil;
                    [self.layerPanelView updateWithTargetOption:option];
                    BOOL shouldAnimateSliderValue = NO;
                    BOOL foundSlider = NO;
                    if(item.toolType == MysticToolTypeSlider && [item.customView isKindOfClass:[MysticSlider class]])
                    {
                        newItem = item;
                        adjustSlider = (id)item.customView;
                        shouldAnimateSliderValue = YES;
                        foundSlider = YES;
//                        DLog(@"found filter slider: %2.2f", adjustSlider.value);
                    }
                    else
                    {
                        adjustSlider = [MysticSlider sliderWithFrame:(CGRect){-10.f,0,sliderFrame.size.width,toolbar.frame.size.height}];
                        newItem = [toolbar makeItemWithInfo:@{@"toolType":@(MysticToolTypeSlider),
                                                              @"view": adjustSlider,
                                                              @"width":@(adjustSlider.frame.size.width),
                                                              @"objectType":@(self.layerPanelView.targetOption.type),
                                                              @"target": [NSNull null],
                                                              @"action": [NSNull null],}];
                        adjustSlider.upperHandleImageNormal = [UIImage imageNamed:@"slider-mystic-handle"];
                        adjustSlider.upperHandleImageHighlighted = adjustSlider.upperHandleImageNormal;
                        
                        
                        newItem.width = adjustSlider.frame.size.width;
                        NSMutableArray *newItems = [NSMutableArray arrayWithArray:toolbar.items];
                        [newItems replaceObjectAtIndex:3 withObject:newItem];
                        [toolbar replaceItems:newItems animated:NO];
                    }
                    adjustSlider.imageViewDelegate = weakSelf.controller;
                    adjustSlider.refreshAction = @selector(refreshSliderAction:);
                    adjustSlider.reloadAction = @selector(reloadSliderAction:);
                    adjustSlider.finishAction = @selector(finishSliderAction:);
                    adjustSlider.stillAction = @selector(stillSliderAction:);
                    if(foundSlider)
                    {
                        option.intensity = adjustSlider.value;
                    }
                    [adjustSlider setupActionsForSetting:MysticSettingIntensity option:option animated:shouldAnimateSliderValue];
                    
                    
                }
                break;
            }
        }
        case MysticSettingVignette:
        case MysticSettingVignetteBlending:
        {
            [toolbar setTitleEnabled:NO];
            [toolbar setTitle:MysticObjectTypeTitleParent(otype, MysticObjectTypeUnknown) animated:NO];
            break;
        }
        default:
        {
            if(!MysticTypeHasPack(otype))
            {
                toolbarTitle = option ? [option.name uppercaseString] : MysticObjectTypeTitleParent(otype, 0);
                if(panelObj) panelObj.toolbarTitle = toolbarTitle;
                if(toolbar)
                {
                    [toolbar setTitleEnabled:NO];
                    toolbar.titleBorderHidden = YES;
                    [toolbar setTitle:toolbarTitle animated:self.layerPanelIsVisible];
                }
                
            }
            
            break;
        }
    }
}
- (void) effectControlWasDeselected:(UIControl *)effectControl effect:(MysticControlObject *)effect;
{
    [self.controller effectControlWasDeselected:effectControl effect:effect];
}
- (void) effectControl:(EffectControl *)effectControl accessoryTouched:(id)sender;
{
    [self.controller effectControl:effectControl accessoryTouched:sender];
}
- (NSInteger) effectControlVisibilityIndex:(EffectControl *)control;
{
    return [self.controller effectControlVisibilityIndex:control];
}
- (void) effectControlDidTouchUp:(UIControl *)_effectControl effect:(MysticControlObject *)effectObj;
{
    [self updateToolbar:nil panel:self.layerPanelView.visiblePanel option:(id)effectObj];
    [self.controller effectControlDidTouchUp:_effectControl effect:effectObj];
}

- (BOOL) isOptionActive:(PackPotionOption *)option shouldSelectActiveControls:(BOOL)ashouldSelectActiveControls index:(NSInteger)index scrollView:(id)scrollView;
{
    return [self.controller isOptionActive:option shouldSelectActiveControls:ashouldSelectActiveControls index:index scrollView:scrollView];
}

#pragma mark - Header Scroll Delegate

- (void) scrollHeader:(MysticScrollHeaderView *)headerView didTouchItem:(MysticButton *)sender;
{
    [(id)self.controller scrollHeader:headerView didTouchItem:sender];
}

@end
