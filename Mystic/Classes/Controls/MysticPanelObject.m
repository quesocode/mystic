//
//  MysticPanelObject.m
//  Mystic
//
//  Created by Me on 3/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPanelObject.h"
#import "MysticLayerToolbar.h"

@implementation MysticPanelObject
{
    MysticSlider *_slider;
    MysticTabBar *_tabBar;
    MysticScrollView *_scrollView;
}
@synthesize title=_title, subtitle=_subtitle, state=_state;

+ (id) panelObjectWithPanelObject:(MysticPanelObject *)other;
{
    MysticPanelObject *p;
    if([other isKindOfClass:[MysticPanelObject class]]) return other;
    p = [[self class] info:([other isKindOfClass:[MysticViewObject class]]) ? (id)other.info : other];
    p.panel = [other isKindOfClass:[MysticViewObject class]] ? other.panel : nil;
    p.targetOption = [other isKindOfClass:[MysticViewObject class]] ? other.targetOption : nil;
    p.sectionType = [other isKindOfClass:[MysticViewObject class]] ?  other.sectionType : MysticPanelTypeUnknown;
    return p;
}
- (void) dealloc;
{
    if(self.panelDestroyedBlock)
    {
        self.panelDestroyedBlock(self);
        self.panelDestroyedBlock = nil;
    }
    Block_release(_panelIsReady);
    Block_release(_panelCancelledBlock);
    Block_release(_panelConfirmedBlock);
    Block_release(_panelTouchedBlock);
    Block_release(_panelDestroyedBlock);
    [_slider release];
    [_tabBar release];
    [_scrollView release];
    _slider = nil;
    _tabBar = nil;
    _scrollView=nil;
    [_title release];
    [_subtitle release];
    [_activeSubPanelObject release];
    [_parentPanelObject release];
    [_targetOption release];
    [_toolbarTitle release];
    [_pack release];
    _panel = nil;
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    if(self)
    {
        self.bottomBarHeight = MYSTIC_UI_PANEL_BOTTOMBAR_HEIGHT;
        self.animationTransition = MysticAnimationTransitionFade;
    }
    return self;
}
- (void) commonInit;
{
    [super commonInit];
    _state = MysticObjectTypeUnknown;
}
- (void) setView:(UIView *)view;
{
    if(!view) return;
    [super setView:view];
    self.scrollView=nil;
    self.tabBar=nil;
    self.slider=nil;
}
- (void) setActiveSubPanelObject:(MysticPanelObject *)obj;
{
    if(_activeSubPanelObject) [_activeSubPanelObject release], _activeSubPanelObject = nil;
    if(obj) obj.parentPanelObject = self;
    _activeSubPanelObject = obj ? [obj retain] : nil;
}
- (void) setInfo:(NSMutableDictionary *)info;
{
    MysticPanelType __section = [info objectForKey:@"panel"] ? [[info objectForKey:@"panel"] integerValue] : MysticPanelTypeUnknown;
    [info setObject:@(__section) forKey:@"__panelType"];
    [super setInfo:info];
    self.sectionType = __section;
    self.animationTransition = info[@"animationTransition"] ? [info[@"animationTransition"] integerValue] : self.animationTransition;
    self.bottomBarHeight = info[@"bottomBarHeight"] ? [info[@"bottomBarHeight"] floatValue] : self.bottomBarHeight;
    self.resetAll = [info objectForKey:@"resetAll"] ? [[info objectForKey:@"resetAll"] boolValue] : YES;
    self.panel = [info objectForKey:@"layerPanel"];
    self.pack = [info objectForKey:@"pack"] && [[info objectForKey:@"pack"] isKindOfClass:[MysticPack class]] ? [info objectForKey:@"pack"] : nil;
    _slider = nil;
}
- (void) setAnimationTransition:(MysticAnimationTransition)animationTransition;
{
    _animationTransition=animationTransition;
    self.info[@"animationTransition"]=@(animationTransition);
}
- (NSArray *) packs;
{
    return self.info && self.info[@"packs"] && [self.info[@"packs"] isKindOfClass:[NSArray class]] ? self.info[@"packs"] : nil;
}
- (void) setSectionType:(MysticPanelType)sectionType;
{
    _sectionType = sectionType;
    self.info[@"__currentPanelType"] = @(sectionType);
    // possibly a bug
    self.info[@"__panelType"] = @(sectionType);
    self.info[@"panel"] = @(sectionType);
}
- (void) setTitle:(NSString *)title;
{
    [_title release];
    _title = title ? [title retain] : @"";
    [self.info setObject:title forKey:@"title"];
}
- (void) setSubtitle:(NSString *)subtitle;
{
    [_subtitle release];
    subtitle = subtitle ? [subtitle retain] : @"";
    [self.info setObject:subtitle forKey:@"subtitle"];
}
- (NSString *) title;
{
    if(_title) return _title;
    id t = [self.info objectForKey:@"title"] ? [self.info objectForKey:@"title"] : nil;
    if(!t && self.optionType != MysticObjectTypeUnknown)
    {
        t = MysticObjectTypeTitleParent(self.optionType, MysticObjectTypeUnknown);
    }
    return t;
}
- (MysticPanelType) panelType;
{
    return self.sectionType;
}
- (void) setPanelType:(MysticPanelType)panelType;
{
    self.sectionType = panelType;
}
- (NSString *) subtitle;
{
    if(_subtitle) return _subtitle;
    return [self.info objectForKey:@"subtitle"] ? [self.info objectForKey:@"subtitle"] : nil;
}
- (void) setState:(MysticObjectType)state;
{
    _state = state;
    self.info[@"state"] = @(_state);
}
- (MysticObjectType) state;
{
    if(_state != MysticObjectTypeUnknown) return _state;
    if(self.setting != MysticObjectTypeUnknown) return self.setting;
    return [self.info objectForKey:@"state"] ? [[self.info objectForKey:@"state"] integerValue] : MysticObjectTypeUnknown;
}

- (MysticObjectType) optionType;
{
    return [self.info objectForKey:@"optionType"] ? [[self.info objectForKey:@"optionType"] integerValue] : MysticObjectTypeUnknown;
}

- (NSInteger) activeTab;
{
    return [self.info objectForKey:@"activeTab"] ? [[self.info objectForKey:@"activeTab"] integerValue] : NSNotFound;
}
- (UIView *) contentView;
{
    return self.view ? self.view : self.panel.contentView;
}

- (MysticScrollView *) scrollView;
{
//    return (id)[self.contentView viewWithTag:MysticViewTypeScrollView + MysticViewTypePanel];
    if(_scrollView) return _scrollView;
    self.scrollView = (id)[self.contentView viewWithTag:MysticViewTypeScrollView + MysticViewTypePanel];
    return _scrollView;
}

- (MysticPacksScrollView *) packsView;
{
    return (id)[self.contentView viewWithTag:MysticViewTypeScrollView2+ MysticViewTypePanel];
}
- (MysticSlider *) slider;
{
    return (id)[(MysticView *)self.contentView viewWithClass:[MysticSlider class]];
//    if(_slider) return _slider;
//    self.slider = (id)[(MysticView *)self.contentView viewWithClass:[MysticSlider class]];
//    if(!self.slider) self.slider = (id)[(MysticView *)self.subPanelView viewWithClass:[MysticSlider class]];
//    return _slider;
}
- (MysticTabBar *) tabBar;
{
//    return (id)[(MysticView *)self.contentView viewWithClass:[MysticTabBar class]];;
    if(_tabBar) return _tabBar;
    self.tabBar = (id)[(MysticView *)self.contentView viewWithClass:[MysticTabBar class]];
    return _tabBar;
}
- (MysticPanelSubView *) subPanelView;
{
    return (MysticPanelSubView *)[self.contentView viewWithTag:MysticViewTypePanel+MysticViewTypeSubPanel];
}

- (id <MysticLayerPanelViewDelegate>) delegate;
{
    return self.panel ? self.panel.delegate : nil;
}

- (void) willAppear;
{
    [super willAppear];
}
- (void) willDisappear;
{
    [super willDisappear];
}
- (void) didAppear;
{
    [super didAppear];
}
- (void) didDisappear;
{
    [super didDisappear];
}
- (void) didRemoveFromSuperview;
{
    [super didRemoveFromSuperview];
}
- (MysticPack *) pack;
{
    if(!_pack && self.optionType == MysticObjectTypeColorOverlay) return [MysticPack packForType:MysticObjectTypeColorOverlay];
    else if(!_pack) return [MysticPack pack:self.optionType];
    return _pack;
}
- (BOOL) isASubSection;
{
    return self.parentPanelObject || (self.panel && [self.panel.options objectForKey:@"section"] && ![[self.panel.options objectForKey:@"section"] isEqual:self]);
}

- (void) isReady;
{
    [super isReady];
    if(self.panelIsReady)
    {
        self.panelIsReady(self, YES);
        self.panelIsReady = nil;
    }
}


- (void) canceledOption:(PackPotionOption *)option setting:(MysticObjectType)setting finished:(MysticBlockObjBOOLBOOL)finished;
{
    BOOL refresh = NO;
    BOOL reload = NO;
    BOOL checkValue = YES;
    switch (self.sectionType)
    {
        case MysticPanelTypeHue:
        case MysticPanelTypeSaturation:
        case MysticPanelTypeTone:
        case MysticPanelTypeBrightness:
        case MysticPanelTypeContrast:
        case MysticPanelTypeHaze:
        case MysticPanelTypeGamma:
        case MysticPanelTypeExposure:
        case MysticPanelTypeShadows:
        case MysticPanelTypeHighlights:
        case MysticPanelTypeGrain:
        case MysticPanelTypeLevels:
        case MysticPanelTypeColorBalance:
        case MysticPanelTypeSlider:
        case MysticPanelTypeAdjust:
            refresh = YES; break;
        case MysticPanelTypeVignette:
        {
            reload=YES;
            refresh=YES;
            checkValue = NO;
            break;
        }
        default:
            reload = YES; break;
    }
    if(setting > MysticSettingImageProcessing) checkValue = NO;
    id value = refresh ? nil : [option tempValueForKey:MysticString(setting)];
    MysticSlider *theSlider = [self.slider retain];
    if((refresh||reload) && checkValue && theSlider)
    {
        value = @(theSlider.lastUpperValue);
        refresh = !refresh ? NO : theSlider.lastUpperValue != theSlider.value;
        reload = !reload ? NO : theSlider.lastUpperValue != theSlider.value;
        [theSlider autorelease];
    }
    if(refresh||reload) [option setValue:value forSetting:setting];
    if(finished) finished(value, reload, refresh);
}

- (void) reset:(BOOL)animated;
{
    if(self.slider) [_slider resetValue:animated];
    if(self.tabBar) [_tabBar deactivateAll];
    if(self.scrollView) [_scrollView reloadControls];
}
- (void) resetPanel;
{
    self.activeSubPanelObject = nil;
    self.sectionType = self.info[@"__panelType"] ? [self.info[@"__panelType"] integerValue] : self.sectionType;
}
- (void) canceledOption;
{
    MysticLayerPanelBottomBarView *toolbarContainer = self.panel.bottomBarView;
    MysticLayerToolbar *toolbar = (MysticLayerToolbar *)[toolbarContainer viewWithTag:MysticViewTypeToolbarPanel];
    if(toolbar)
    {
        MysticButton *btn = [toolbar buttonForType:MysticToolTypeCancel];
        if(btn) [btn tap];
    }
}
- (PackPotionOption *) targetOption;
{
    id option = _targetOption ? _targetOption : (self.panel ? self.panel.targetOption : nil);
    return option ? option : [self.info objectForKey:@"option"] && [[self.info objectForKey:@"option"] isKindOfClass:[PackPotionOption class]] ? [self.info objectForKey:@"option"] : nil;
}

- (void) ready:(MysticBlockObjBOOL)readyBlock;
{
    self.panelIsReady = readyBlock;
}

- (void) cancel:(MysticBlockObjObjBOOL)aBlock;
{
    self.panelCancelledBlock = aBlock;
}

- (void) confirm:(MysticBlockObjObjBOOL)aBlock;
{
    self.panelConfirmedBlock = aBlock;
}

- (void) touch:(MysticBlockObjObj)aBlock;
{
    self.panelTouchedBlock = aBlock;
}

- (void) destroy:(MysticBlockObject)aBlock;
{
    self.panelDestroyedBlock = aBlock;
}
- (void) panelTouched:(id)sender;
{
    if(self.panelTouchedBlock) self.panelTouchedBlock(sender, self);
}

- (void) panelCancelled:(id)sender;
{
    if(!self.panelCancelledBlock) return;
    self.panelCancelledBlock(sender, self, YES);
    self.panelCancelledBlock = nil;
}

- (void) panelConfirmed:(id)sender;
{
    if(!self.panelConfirmedBlock) return;
    self.panelConfirmedBlock(sender, self, YES);
    self.panelConfirmedBlock = nil;
}
- (NSString *) debugDescriptionStr;
{
    return [NSString stringWithFormat:@"Panel: %@%@", self.title, self.subtitle ? [@"-" stringByAppendingString:self.subtitle] : @""];
}
@end
