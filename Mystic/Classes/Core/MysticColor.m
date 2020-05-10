//
//  MysticColor.m
//  Mystic
//
//  Created by travis weerts on 6/25/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//



#import "MysticColor.h"
#import "MysticGradient.h"


@implementation MysticColor
+ (BOOL) color:(UIColor *)color equals:(UIColor *)color2;
{
    if(color.red != color2.red || color.green != color2.green || color.blue != color2.blue || color.alpha != color2.alpha)
    {
        return NO;
    }
    return YES;
}
+ (UIColor *) color:(id)color;
{
    if(!color || [color isKindOfClass:[UIColor class]]) return color;
    if([color isKindOfClass:[NSString class]])
    {
        return [UIColor fromString:color];
    }
    if([color respondsToSelector:@selector(integerValue)])
    {
        return [MysticColor colorWithType:(MysticColorType)[color integerValue]];
    }
    return color;
}
+ (UIColor *) colorForObject:(MysticObjectType)objType orColor:(UIColor *)dcolor;
{
    MysticColorType ctype = [MysticColor colorTypeForObject:objType or:MysticColorTypeNone];
    if(MysticColorIsEmpty(ctype))
    {
        return dcolor;
    }
    return [MysticColor colorWithType:ctype];
}
+ (UIColor *) colorForObject:(MysticObjectType)objType or:(MysticColorType)dtype;
{
    return [MysticColor colorWithType:[MysticColor colorTypeForObject:objType or:dtype]];

}
+ (MysticColorType) colorTypeForObject:(MysticObjectType)objType or:(MysticColorType)dtype;
{
    MysticColorType activeColor = dtype;
    switch (objType) {
        case MysticSettingBadge:
        case MysticObjectTypeBadge:
            activeColor = MysticColorTypeObjectText;
            break;
        case MysticSettingText:
        case MysticObjectTypeText:
            activeColor = MysticColorTypeObjectText;
            break;
        case MysticSettingFrame:
        case MysticObjectTypeFrame:
            activeColor = MysticColorTypeObjectFrame;
            break;
        case MysticSettingTexture:
        case MysticObjectTypeTexture:
            activeColor = MysticColorTypeObjectTexture;
            break;
        case MysticObjectTypeMixture:
        case MysticSettingMixtures:
            activeColor = MysticColorTypeObjectMixture;
            break;
        case MysticSettingRecipeProjects:
        case MysticSettingRecipe:
        case MysticObjectTypeRecipe:
            activeColor = MysticColorTypeObjectRecipe;
            break;
        case MysticSettingLighting:
        case MysticObjectTypeLight:
            activeColor = MysticColorTypeObjectLight;
            break;
        case MysticSettingFilter:
        case MysticObjectTypeFilter:
        case MysticSettingColorFilter:
        
            activeColor = MysticColorTypeObjectFilter;
            break;
        case MysticSettingSettings:
        case MysticObjectTypeSetting:
            activeColor = MysticColorTypeObjectFilter;
            break;
        case MysticSettingType:
        case MysticObjectTypeFont:
            activeColor = MysticColorTypeObjectFont;
            break;
        case MysticSettingBlending:
        case MysticObjectTypeBlend:
            activeColor = MysticColorTypeObjectBlend;
            break;
        case MysticSettingChooseColor:
        case MysticObjectTypeColor:
            activeColor = MysticColorTypeObjectColor;
            break;
        default: break;
    }
    return activeColor;
}
+ (UIColor *) colorWithType:(MysticColorType)colorType;
{
    switch (colorType) {
        case MysticColorTypeMenuIconRedo:
        case MysticColorTypeMenuIconUndo: return [UIColor colorWithRed:0.84 green:0.82 blue:0.75 alpha:1.00];
        case MysticColorTypeMenuIconRedoDisabled:
        case MysticColorTypeMenuIconUndoDisabled: return [UIColor colorWithRed:0.41 green:0.36 blue:0.33 alpha:1.00];
        case MysticColorTypePink: return [UIColor hex:@"e8566b"];
        case MysticColorTypeClear: return [UIColor clearColor];
        case MysticColorTypeWhite: return [UIColor hex:@"FFFDF4"];
        case MysticColorTypeBlack:
        case MysticColorTypeBackgroundBlack: return [UIColor hex:@"141412"];
        case MysticColorTypeShareBackground: return [UIColor color:MysticColorTypeShareButtonBackground];
        case MysticColorTypeShareToolbarBackground: return [UIColor color:MysticColorTypeCollectionSectionHeaderBackground];
        case MysticColorTypeShareToolbarText:
        case MysticColorTypeShareToolbarSubText: return [UIColor color:MysticColorTypeWhite];
        case MysticColorTypeTabIconActive: return [UIColor hex:@"E8DAC7"];
        case MysticColorTypeShareToolbarIcon: return [UIColor color:MysticColorTypeShareButtonImage];
        case MysticColorTypeShareToolbarTextHighlighted:
        case MysticColorTypeShareToolbarSubTextHighlighted:
        case MysticColorTypeShareButtonImageFinished:
        case MysticColorTypeShareToolbarIconHighlighted: return [UIColor color:MysticColorTypePink];
        case MysticColorTypeTabIconDisabled: return [UIColor hex:@"3D3834"];
        case MysticColorTypeShareToolbarCancelIconHighlighted: return [UIColor color:MysticColorTypeMenuIconHighlighted];
        case MysticColorTypeShareToolbarTitle: return [[UIColor hex:@"e0dbd2"] colorWithAlphaComponent:0.7];
        case MysticColorTypeShareToolbarCancelIcon: return [[UIColor hex:@"c1bdb6"] colorWithAlphaComponent:0.46];
        case MysticColorTypeShareButtonBorder: return [UIColor color:MysticColorTypeCollectionSectionHeaderBackground];
        case MysticColorTypeShareButtonText: return [UIColor hex:@"b4af9d"];
        case MysticColorTypeShareButtonTextFinished: return [UIColor color:MysticColorTypeShareButtonText];
        case MysticColorTypeShareButtonAccessory: return [[UIColor color:MysticColorTypeShareButtonImage] colorWithAlphaComponent:0.35];
        case MysticColorTypeShareButtonTextHighlighted: return [UIColor color:MysticColorTypeWhite];
        case MysticColorTypeShareButtonImage: return [UIColor hex:@"b4af9d"];
        case MysticColorTypeShareButtonImageHighlighted: return [UIColor hex:@"2f2f2f"];
        case MysticColorTypeShareButtonBackground: return [UIColor color:MysticColorTypeBlack];
        case MysticColorTypeShareButtonBackgroundHighlighted: return [UIColor color:MysticColorTypePink];
        case MysticColorTypeSliderMin: return [UIColor color:MysticColorTypePink];
        case MysticColorTypeSliderMax: return [UIColor colorWithHexString:@"473b37"];
        case MysticColorTypeSliderMinLight: return [UIColor color:MysticColorTypePink];
        case MysticColorTypeSliderMaxLight: return [self colorWithType:MysticColorTypeSegmentControl];
        case MysticColorTypeBottomBarButtonIcon:
        case MysticColorTypeBottomBarButtonTitle: return [UIColor colorWithHexString:@"fcfaf0"];
        case MysticColorTypeBottomBarButtonIconSelected:
        case MysticColorTypeBottomBarButtonIconHighlighted:
        case MysticColorTypeBottomBarButtonTitleSelected:
        case MysticColorTypeBottomBarButtonTitleHighlighted: return [UIColor colorWithHexString:@"fcfaf0"];
        case MysticColorTypeBottomBarButtonBackgroundSelected:
        case MysticColorTypeBottomBarButtonBackgroundHighlighted: return [UIColor color:MysticColorTypePink];
        case MysticColorTypeBottomBarButtonBackground: return [UIColor colorWithHexString:@"2e2724"];
        case MysticColorTypeHorizontalNavButton: return [UIColor colorWithHexString:@"464646"];
        case MysticColorTypeHorizontalNavButtonDisabled: return [UIColor colorWithHexString:@"191919"];
        case MysticColorTypeHorizontalText: return [UIColor colorWithHexString:@"565656"];
        case MysticColorTypeHorizontalTextSelected: return [UIColor color:MysticColorTypeWhite];
        case MysticColorTypePopup: return [UIColor color:MysticColorTypeBottomBarBackground];
        case MysticColorTypePopupHighlighted: return [UIColor color:MysticColorTypePink];
        case MysticColorTypeControlIconActive: return [self colorWithType:MysticColorTypeWhite];
        case MysticColorTypeControlIconHighlighted: return [UIColor hex:@"3F3834"];
        case MysticColorTypeControlIconSelected: return [self colorWithType:MysticColorTypePink];
        case MysticColorTypeControlIcon:
        case MysticColorTypeControlBorderActive: return [self colorWithType:MysticColorTypeWhite];
        case MysticColorTypeControlBorderInactive: return [UIColor hex:@"463F3B"];
        case MysticColorTypeControlIconInactive: return [UIColor hex:@"FFFCF3"];
        case MysticColorTypeDrawerIconBackground: return [self colorWithType:MysticColorTypeDrawerBackgroundCellBorder];
        case MysticColorTypeBarButtonIconSelectedToggle:
        case MysticColorTypeBarButtonIconInactive: return [UIColor hex:@"2f2b26"];
        case MysticColorTypeBarButtonIconSelected: return [MysticColor color:@(MysticColorTypePink)];
        case MysticColorTypeButtonText: return [UIColor hex:@"8a807a"];
        case MysticColorTypeControlActiveDark: return [UIColor hex:@"181515"];
        case MysticColorTypeTabBarBackground: return [UIColor hex:@"242422"];
        case MysticColorTypeControlsBackground: return [UIColor hex:@"181818"];
        case MysticColorTypeControlSubBtn: return [self colorWithType:MysticColorTypeWhite];
        case MysticColorTypeMainBackground: return [UIColor hex:@"2f2f2f"];
        case MysticColorTypeControlInactiveOverlay: return [UIColor hex:@"242422"];
        case MysticColorTypeControlInactive: return [UIColor hex:@"2f2f2f"];
        case MysticColorTypeTabTitle:
        case MysticColorTypeTabTitleDisabled: return [UIColor hex:@"6b5f58"];
        case MysticColorTypeTabCircle: return [UIColor hex:@"8e857c"];
        case MysticColorTypePinkMuted: return [UIColor hex:@"8d4d49"];
        case MysticColorTypeCollectionToolbarBackground: return [UIColor hex:@"101010"];
        case MysticColorTypeCollectionToolbarText: return [UIColor color:MysticColorTypeMenuTextSelected];
        case MysticColorTypeCollectionToolbarTextHighlighted: return [UIColor color:MysticColorTypeMenuTextHighlighted];
        case MysticColorTypeCollectionToolbarIcon: return [UIColor color:MysticColorTypeMenuTextUnselected];
        case MysticColorTypeCollectionToolbarIconSelected: return [UIColor color:MysticColorTypeMenuTextSelected];
        case MysticColorTypeCollectionToolbarIconHighlighted: return [UIColor color:MysticColorTypeMenuTextHighlighted];
        case MysticColorTypeCollectionBackground:
        case MysticColorTypeCollectionSectionBackground: return [UIColor hex:@"151515"];
        case MysticColorTypeCollectionFeaturedSectionBackground: return [UIColor hex:@"222221"];
        case MysticColorTypeCollectionBackgroundIcon: return [UIColor hex:@"564c45"];
        case MysticColorTypeCollectionTopBarBackground:
        case MysticColorTypeCollectionSectionHeaderBackground: return [UIColor hex:@"222221"];
        case MysticColorTypeCollectionNavBarBackground: return [UIColor hex:@"222221"];
        case MysticColorTypeCollectionNavBarIcon:
        case MysticColorTypeCollectionSectionHeaderIcon: return [UIColor hex:@"85756b"];
        case MysticColorTypeCollectionSectionHeaderText:
        case MysticColorTypeCollectionNavBarText: return [UIColor hex:@"9f9a94"];
        case MysticColorTypePanelSubContentBackground: return [UIColor hex:@"1f1f1d"];
        case MysticColorTypeCollectionSectionHeaderTextLight: return [UIColor hex:@"d3cfcf"];
        case MysticColorTypeCollectionNavBarHighlighted:
        case MysticColorTypeCollectionSectionHeaderHighlighted: return [self colorWithType:MysticColorTypePink];
        case MysticColorTypePackTitle: return [UIColor color:MysticColorTypeWhite];
        case MysticColorTypeJournalCellBackground: return [UIColor color:MysticColorTypeWhite];
        case MysticColorTypeJournalCellHighlighted: return [UIColor color:MysticColorTypeWhite];
        case MysticColorTypeJournalCellTitle: return [UIColor color:MysticColorTypeWhite];
        case MysticColorTypeJournalCellSubtitle: return [UIColor color:MysticColorTypeBlack];
        case MysticColorTypeIntroHint: return [UIColor hex:@"6c635d"];
        case MysticColorTypeIntroButtonText: return [UIColor hex:@"deded4"];
        case MysticColorTypeFontToolbar: return [self colorWithType:MysticColorTypeControlInactive];
        case MysticColorTypeTabBadge: return [UIColor hex:@"3fbdbc"];
        case MysticColorTypeTabBadgeHighlighted: return [UIColor hex:@"ddad38"];
        case MysticColorTypeTabBadgeText: return [self colorWithType:MysticColorTypePink];
        case MysticColorTypeTabBadgeTextHighlighted: return [UIColor hex:@"282828"];
        case MysticColorTypeTabIconInactive: return [UIColor hex:@"D6D0BF"];
        case MysticColorTypeControlActive: return [self colorWithType:MysticColorTypePink];
        case MysticColorTypeTabBackground: return [UIColor clearColor];
        case MysticColorTypeTabBackgroundActive: return [[[UIColor colorWithRed:93.0/255.0 green:83.0/255.0 blue:79.0/255.0 alpha:1.000] darker:0.1] colorWithAlphaComponent:0.6];
        case MysticColorTypeWhiteBarActive: return [UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)59/255 blue:(CGFloat)55/255 alpha:1.0f];
        case MysticColorTypeWhiteBarInactive: return [UIColor hex:@"aca89d"];
        case MysticColorTypePanelTabBackground: return [UIColor hex:@"303030"];
        case MysticColorTypeBackgroundCameraControls: return [self colorWithType:MysticColorTypeCollectionNavBarBackground];
        case MysticColorTypePinkDark: return [UIColor hex:@"9a534e"];
        case MysticColorTypeBeige: return [UIColor colorWithRed:(CGFloat)252/255 green:(CGFloat)250/255 blue:(CGFloat)240/255 alpha:1.0f];
        case MysticColorTypeBottomBar: return [UIColor hex:@"212121"];
        case MysticColorTypeNavBar: return [self colorWithType:MysticColorTypeCollectionNavBarBackground];
        case MysticColorTypeNavBarIconDark: return [UIColor hex:@"85756b"];
        case MysticColorTypeNavBarIconDull: return [UIColor hex:@"c1ad9a"];
        case MysticColorTypeNavBarIcon: return [UIColor hex:@"b4af9d"];
        case MysticColorTypeNavBarText:
        case MysticColorTypeNavBarIconConfirmHighlighted: return [UIColor hex:@"eee9d9"];
        case MysticColorTypeNavBarIconCancel: return [UIColor hex:@"6c5f59"];
        case MysticColorTypeNavBarIconSelected: return [UIColor hex:@"FFFDF3"];
        case MysticColorTypeBlurTintHUD:
        case MysticColorTypeHUDBackground: return [[self colorWithType:MysticColorTypeTransformToolBackground] colorWithAlphaComponent:0.40];
        case MysticColorTypeNavBarIconConfirm:
        case MysticColorTypeNavBarIconHighlighted:
        case MysticColorTypeNavBarIconCancelHighlighted: return [UIColor color:MysticColorTypePink];
        case MysticColorTypeBlurTint: return [self colorWithType:MysticColorTypeHUDBackground];
        case MysticColorTypeBlurTintTransformTool: return [[self colorWithType:MysticColorTypeTransformToolBackground] colorWithAlphaComponent:0.4];
        case MysticColorTypeTransformToolBackground: return [UIColor hex:@"242422"];
        case MysticColorTypeTransformToolIcon: return [UIColor hex:@"ede2ce"];
        case MysticColorTypeTransformToolBorder: return [UIColor color:MysticColorTypeWhite];
        case MysticColorTypeLayerPanelBackground: return [[UIColor hex:@"232323"] colorWithAlphaComponent:0.9];
        case MysticColorTypeLayerPanelBottomBarBorder: return [[UIColor hex:@"565656"] colorWithAlphaComponent:0.6];
        case MysticColorTypeResizableControlBorder: return [UIColor color:MysticColorTypeWhite];
        case MysticColorTypePanelBottomIcon:
        case MysticColorTypePanelConfirm: return [UIColor hex:@"6e6760"];
        case MysticColorTypePanelBottomIconHighlighted:
        case MysticColorTypePanelConfirmHighlighted: return [self colorWithType:MysticColorTypePink];
#pragma mark - Segment control
        case MysticColorTypeSegmentControl: return [UIColor hex:@"454545"];
        case MysticColorTypeSegmentControlImageColor:
        case MysticColorTypeSegmentControlTextColor: return [UIColor hex:@"777777"];
        case MysticColorTypeSegmentControlImageColorSelected:
        case MysticColorTypeSegmentControlTextColorSelected: return [self colorWithType:MysticColorTypeWhite];
        case MysticColorTypeSegmentControlImageColorHighlighted:
        case MysticColorTypeSegmentControlTextColorHighlighted: return [UIColor hex:@"fffff3"];
        case MysticColorTypeSegmentControlImageColorDisabled:
        case MysticColorTypeSegmentControlTextColorDisabled: return [[UIColor hex:@"8e857c"] colorWithAlphaComponent:0.4];
        case MysticColorTypeTabTitleHighlighted:
        case MysticColorTypeTabTitleSelected:
        case MysticColorTypeTabTitleActive: return [[UIColor color:MysticColorTypePink] lighter:0.07];

#pragma mark - Knob & Layer Slideout
        case MysticColorTypeKnob: return [UIColor colorWithType:MysticColorTypeWhite];
        case MysticColorTypeKnobDisabled: return [UIColor colorWithType:MysticColorTypeWhite];
        case MysticColorTypeKnobHighlighted: return [UIColor colorWithType:MysticColorTypeWhite];
        case MysticColorTypeKnobSelected: return [UIColor hex:@"464646"];
        case MysticColorTypeKnobBackground: return [[UIColor hex:@"050505"] colorWithAlphaComponent:0.4];
        case MysticColorTypeKnobBackgroundOpen: return [[UIColor hex:@"050505"] colorWithAlphaComponent:0.4];
        case MysticColorTypeKnobBackgroundHighlighted: return [UIColor hex:@"000000"];
        case MysticColorTypeDrawerSection: return [self colorWithType:MysticColorTypePinkDark];
        case MysticColorTypeDrawerSectionText: return [UIColor hex:@"5D534F"];
        case MysticColorTypeDrawerBackgroundCellAddBasic:
        case MysticColorTypeDrawerBackgroundCellAddSpecial:
        case MysticColorTypeDrawerBackgroundCell:
        case MysticColorTypeDrawerSectionToolbar:
        case MysticColorTypeDrawerNavBar:
        case MysticColorTypeDrawerToolbar: return [UIColor hex:@"1c1b1b"];
        case MysticColorTypeShutterDisabled: return [UIColor hex:@"91887F"];
        case MysticColorTypeShutter: return [UIColor hex:@"E9DBC8"];
        case MysticColorTypeInputAccessoryIcon: return [UIColor hex:@"685C54"];
        case MysticColorTypeInputAccessoryIconDisabled: return [UIColor hex:@"48433F"];
        case MysticColorTypeInputAccessoryIconHighlighted: return [self colorWithType:MysticColorTypePink];
        case MysticColorTypeInputAccessoryIconSelected: return [UIColor hex:@"FFFDF3"];
        case MysticColorTypeLibrary:
        case MysticColorTypeCameraInfo:
        case MysticColorTypeCameraX: return [UIColor hex:@"E9DBC8"];
        case MysticColorTypeCameraXHighlighted:
        case MysticColorTypeLibraryHighlighted:
        case MysticColorTypeCameraInfoHighlighted:
        case MysticColorTypeShutterHighlighted: return [[self class] colorWithType:MysticColorTypePink];
        case MysticColorTypeDrawerBackground: return [UIColor hex:@"1c1b1b"];
        case MysticColorTypeDrawerBackgroundCellMain:
        case MysticColorTypeDrawerMainBackground: return [UIColor hex:@"2d2525"];
        case MysticColorTypeDrawerBackgroundCellLayers: return [UIColor hex:@"1c1b1b"];
        case MysticColorTypeDrawerMainCellBorder: return [UIColor hex:@"3a3030"];
        case MysticColorTypeDrawerBackgroundCellBorder: return [UIColor hex:@"544b47"];
        case MysticColorTypeDrawerIconImageOverlay: return [UIColor hex:@"716f68"];
        case MysticColorTypeDrawerCellImageViewBackground: return [UIColor hex:@"3f3f3f"];
        case MysticColorTypeDrawerBorder: return [UIColor hex:@"252525"];
        case MysticColorTypeLayerIconBackground: return [UIColor hex:@"2f2b2a"];
        case MysticColorTypeDrawerText: return [UIColor hex:@"b2aa9b"];
        case MysticColorTypeDrawerTextAdd: return [UIColor hex:@"EEEBDE"];
        case MysticColorTypeDrawerIconBorder: return [MysticColor color:@(MysticColorTypeDrawerAccessory)];
        case MysticColorTypeDrawerIconImage: return [UIColor hex:@"fffae9"];
        case MysticColorTypeDrawerTextSubtitle: return [UIColor hex:@"463e3a"];
        case MysticColorTypeDrawerIcon: return [UIColor hex:@"ECE5CE"];
        case MysticColorTypeDrawerIconAdd: return [UIColor hex:@"ECE5CE"];
        case MysticColorTypeDrawerNavBarLogo: return [UIColor hex:@"5f544e"];
        case MysticColorTypeDrawerNavBarText: return [UIColor hex:@"5f544e"];
        case MysticColorTypeDrawerNavBarButton:
        case MysticColorTypeDrawerNavBarButtonDim: return [UIColor hex:@"5f544e"];
        case MysticColorTypeDrawerNavBarButtonAction: return [MysticColor color:@(MysticColorTypePink)];
        case MysticColorTypeTopicBackgroundSelected: return [MysticColor color:@(MysticColorTypePink)];
        case MysticColorTypeTopicBackgroundHighlighted: return [MysticColor color:@(MysticColorTypeDrawerBorder)];
        case MysticColorTypeTopicBackground: return [MysticColor color:@(MysticColorTypeDrawerBackgroundCell)];
        case MysticColorTypeTopicBorderSelected: return [MysticColor color:@(MysticColorTypePink)];
        case MysticColorTypeTopicBorderHighlighted: return [MysticColor color:@(MysticColorTypeDrawerBorder)];
        case MysticColorTypeTopicBorder: return [MysticColor color:@(MysticColorTypeDrawerBorder)];
        case MysticColorTypeMoreArtArrow: return [UIColor hex:@"EFE0D0"];
        case MysticColorTypeTopicText: return [UIColor hex:@"ece5ce"];
        case MysticColorTypeTopicTextSelected: return [UIColor hex:@"ece5ce"];
        case MysticColorTypeTopicTextHighlighted: return [MysticColor color:@(MysticColorTypeTopicText)];
        case MysticColorTypeToolbarSeparator: return [UIColor hex:@"2f2f2f"];
        case MysticColorTypeDrawerToolbarSearch: return [UIColor hex:@"2f2f2f"];
 
        case MysticColorTypeDrawerToolbarText: return [UIColor hex:@"73716f"];
        case MysticColorTypeDrawerToolbarIcon:
        case MysticColorTypeDrawerToolbarIconDark: return [UIColor hex:@"5f544e"];
        case MysticColorTypeDrawerToolbarIconHighlighted: return [MysticColor color:@(MysticColorTypePink)];
        case MysticColorTypeDrawerAccessory: return [MysticColor color:@(MysticColorTypeDrawerTextSubtitle)];
        case MysticColorTypeDrawerAccessoryHighlighted: return [MysticColor color:@(MysticColorTypePink)];
        case MysticColorTypeIconDark: return [UIColor colorWithRed:(CGFloat)66/255 green:(CGFloat)56/255 blue:(CGFloat)51/255 alpha:1.0f];
        case MysticColorTypeIconLight: return [UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)248/255 blue:(CGFloat)238/255 alpha:1.0f];
        case MysticColorTypeToolbarIcon:
        case MysticColorTypeSizeControlIcon: return [UIColor hex:@"8e857c"];
        case MysticColorTypeToolbarText:
        case MysticColorTypeSizeControlText: return [UIColor color:MysticColorTypeWhite];
        case MysticColorTypeSizeControlTextDisabled: return [UIColor hex:@"8e857c"];
        case MysticColorTypeRightDrawerNavBarTitle: return [UIColor hex:@"52453d"];
        case MysticColorTypeHUDIconDisabled: return [UIColor hex:@"aca89d"];
        case MysticColorTypeHUDIconEnabled: return [UIColor hex:@"8dd9f0"];
        case MysticColorTypeHUDIcon: return [UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)248/255 blue:(CGFloat)238/255 alpha:1.0f];
        case MysticColorTypeObjectColor:
        case MysticColorTypeObjectFont:
        case MysticColorTypeObjectBlend: return [UIColor hex:@"a65e64"];
        case MysticColorTypeObjectText: return [UIColor colorWithRed:(CGFloat)212/255 green:(CGFloat)108/255 blue:(CGFloat)108/255 alpha:1.0f];
        case MysticColorTypeObjectTexture: return [UIColor colorWithRed:(CGFloat)107/255 green:(CGFloat)161/255 blue:(CGFloat)153/255 alpha:1.0f];
        case MysticColorTypeObjectMixture: return [UIColor colorWithRed:(CGFloat)107/255 green:(CGFloat)161/255 blue:(CGFloat)153/255 alpha:1.0f];
        case MysticColorTypeObjectRecipe: return [UIColor hex:@"b35e86"];
        case MysticColorTypeObjectFrame: return [UIColor hex:@"e2b458"];
        case MysticColorTypeObjectLight: return [UIColor colorWithRed:(CGFloat)135/255 green:(CGFloat)162/255 blue:(CGFloat)137/255 alpha:1.0f];
        case MysticColorTypeControlOverlaySelected:
        case MysticColorTypeControlOverlayHighlighted: return [self colorWithType:MysticColorTypePink];
        case MysticColorTypeControlOverlay: return [UIColor hex:@"6A5D54"];
        case MysticColorTypeInputToolbarBackground: return [UIColor hex:@"141412"];
        case MysticColorTypeInputConfirm: return [UIColor hex:@"FDFBE4"];
        case MysticColorTypeInputToolbarTextPrefix: return [UIColor hex:@"564C47"];
        case MysticColorTypeInputBackground: return [UIColor hex:@"201F1F"];
        case MysticColorTypeInputToolbarText: return [UIColor hex:@"E8DAC8"];
        case MysticColorTypeObjectFilter: return[UIColor hex:@"a65e64"];
        case MysticColorTypeObjectSettings:
           return [UIColor colorWithRed:(CGFloat)134/255 green:(CGFloat)131/255 blue:(CGFloat)125/255 alpha:1.0f];
        case MysticColorTypeInputPickerLabel: return [UIColor hex:@"201F1F"];
        case MysticColorTypeInputToolbarBorder:
        case MysticColorTypePanelBorderColor: return[UIColor hex:@"34312F"];
        case MysticColorTypeNipple: return[UIColor hex:@"3F3834"];
        case MysticColorTypeBottomBarBackground: return[UIColor hex:@"1c1c1b"];
        case MysticColorTypeBottomBarBackgroundDark: return[UIColor colorWithRed:(CGFloat)27/255 green:(CGFloat)23/255 blue:(CGFloat)21/255 alpha:1.0f];
        case MysticColorTypeBottomBarBackgroundLight: return[UIColor colorWithRed:(CGFloat)239/255 green:(CGFloat)237/255 blue:(CGFloat)227/255 alpha:1.0f];
        case MysticColorTypeBrown:
        case MysticColorTypeBackgroundBrown: return[UIColor colorWithRed:(CGFloat)27/255 green:(CGFloat)23/255 blue:(CGFloat)21/255 alpha:1.0f];
        case MysticColorTypeBackgroundWhite: return[UIColor colorWithRed:(CGFloat)252/255 green:(CGFloat)250/255 blue:(CGFloat)240/255 alpha:1.0f];
        case MysticColorTypeKhaki: return [UIColor colorWithRed:(CGFloat)206/255 green:(CGFloat)202/255 blue:(CGFloat)192/255 alpha:1.0f];
        case MysticColorTypePanelToolbarBackground: return [UIColor hex:@"3F3835"];
        case MysticColorTypePanelBackground:
        case MysticColorTypePanelContentBackground: return [UIColor hex:@"403735"];
//            return [UIColor hex:@"3F3835"];
        case MysticColorTypeBackgroundGray: return [UIColor hex:@"303030"];
        case MysticColorTypeBackgroundLightGray: return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)216/255 blue:(CGFloat)204/255 alpha:1.0f];
        case MysticColorTypeRed: return [UIColor red];
        case MysticColorTypeBlue: return [UIColor blueColor];
        case MysticColorTypeGreen: return [UIColor greenColor];
        case MysticColorTypeOrange: return [UIColor hex:@"DD9038"];
        case MysticColorTypeGold:
        case MysticColorTypeYellow: return [UIColor yellowColor];
        case MysticColorTypeBackground: return [UIColor hex:@"2f2f2f"];
        case MysticColorTypeChoice1: return [UIColor whiteColor];
        case MysticColorTypeClearButton: return [[UIColor hex:@"b5b5b5"] colorWithAlphaComponent:0.7];
        case MysticColorTypeMenuTextSelected:
        case MysticColorTypeMenuText: return [UIColor colorFromHexString:@"e8dac8"];
        case MysticColorTypeMenuTextUnselected:
        case MysticColorTypeMenuTextDark: return [[UIColor colorFromHexString:@"6f6561"] colorWithAlphaComponent:0.75];
        case MysticColorTypeMenuTextHighlighted: return [self colorWithType:MysticColorTypePink];
        case MysticColorTypeMenuIcon: return [UIColor colorFromHexString:@"e8dac8"];
        case MysticColorTypeMenuIconHighlighted: return [self colorWithType:MysticColorTypePink];
        case MysticColorTypeMenuIconConfirm: return [UIColor hex:@"E8DAC8"];
        case MysticColorTypeMenuIconCancel: return [UIColor colorWithRed:0.41 green:0.36 blue:0.33 alpha:1.00];
        case MysticColorTypeMenuIconSelected: return [self colorWithType:MysticColorTypePink];
        case MysticColorTypeBorderOnLight: return [UIColor hex:@"ada696"];
            
#pragma mark - Blacks
        case MysticColorTypeChoice2: return [UIColor blackColor];
        case MysticColorTypeChoice3: return [UIColor black75PercentColor];
        case MysticColorTypeChoice4: return [UIColor black50PercentColor];
        case MysticColorTypeChoice5: return [UIColor black25PercentColor];
        case MysticColorTypeChoice6: return [UIColor warmGrayColor];
        case MysticColorTypeChoice7: return [UIColor coolGrayColor];
        case MysticColorTypeChoice8: return [UIColor charcoalColor];
            
#pragma mark - Whites
        case MysticColorTypeChoice9: return [UIColor antiqueWhiteColor];
        case MysticColorTypeChoice10: return [UIColor oldLaceColor];
        case MysticColorTypeChoice11: return [UIColor ivoryColor];

#pragma mark - Yellows
        case MysticColorTypeChoice12: return [UIColor goldenrodColor];
        case MysticColorTypeChoice13: return [UIColor mustardColor];
        case MysticColorTypeChoice14: return [UIColor creamColor];
        case MysticColorTypeChoice15: return [UIColor beigeColor];
        case MysticColorTypeChoice16: return [UIColor wheatColor];

#pragma mark - Oranges
        case MysticColorTypeChoice17: return [UIColor peachColor];
        case MysticColorTypeChoice18: return [UIColor burntOrangeColor];
        case MysticColorTypeChoice19: return [UIColor pastelOrangeColor];
        case MysticColorTypeChoice20: return [UIColor cantaloupeColor];
        case MysticColorTypeChoice21: return [UIColor carrotColor];
        case MysticColorTypeChoice22: return [UIColor mandarinColor];
            
            
            
#pragma mark - Browns
        case MysticColorTypeChoice23: return [UIColor chiliPowderColor];
        case MysticColorTypeChoice24: return [UIColor burntSiennaColor];
        case MysticColorTypeChoice25: return [UIColor chocolateColor];
        case MysticColorTypeChoice26: return [UIColor coffeeColor];
        case MysticColorTypeChoice27: return [UIColor cinnamonColor];
        case MysticColorTypeChoice28: return [UIColor almonColor];
        case MysticColorTypeChoice29: return [UIColor eggshellColor];
        case MysticColorTypeChoice30: return [UIColor sandColor];
        case MysticColorTypeChoice31: return [UIColor mudColor];
        case MysticColorTypeChoice32: return [UIColor siennaColor];
        case MysticColorTypeChoice33: return [UIColor dustColor];

#pragma mark - Reds
        case MysticColorTypeChoice34: return [UIColor red];
        case MysticColorTypeChoice35: return [UIColor salmonColor];
        case MysticColorTypeChoice36: return [UIColor brickRedColor];
        case MysticColorTypeChoice37: return [UIColor easterPinkColor];
        case MysticColorTypeChoice38: return [UIColor grapefruitColor];
        case MysticColorTypeChoice39: return [UIColor pinkColor];
        case MysticColorTypeChoice40: return [UIColor indianRedColor];
        case MysticColorTypeChoice41: return [UIColor strawberryColor];
        case MysticColorTypeChoice42: return [UIColor coralColor];
        case MysticColorTypeChoice43: return [UIColor maroonColor];
        case MysticColorTypeChoice44: return [UIColor watermelonColor];
        case MysticColorTypeChoice45: return [UIColor tomatoColor];
        case MysticColorTypeChoice46: return [UIColor pinkLipstickColor];
        case MysticColorTypeChoice47: return [UIColor paleRoseColor];
        case MysticColorTypeChoice48: return [UIColor crimsonColor];
            
#pragma mark - Purples
        case MysticColorTypeChoice49: return [UIColor eggplantColor];
        case MysticColorTypeChoice50: return [UIColor pastelPurpleColor];
        case MysticColorTypeChoice51: return [UIColor palePurpleColor];
		case MysticColorTypeChoice52: return [UIColor coolPurpleColor];
		case MysticColorTypeChoice53: return [UIColor violetColor];
		case MysticColorTypeChoice54: return [UIColor plumColor];
		case MysticColorTypeChoice55: return [UIColor lavenderColor];
		case MysticColorTypeChoice56: return [UIColor raspberryColor];
		case MysticColorTypeChoice57: return [UIColor fuschiaColor];
		case MysticColorTypeChoice58: return [UIColor grapeColor];
		case MysticColorTypeChoice59: return [UIColor periwinkleColor];
		case MysticColorTypeChoice60: return [UIColor orchidColor];
            
#pragma mark - Blues
            
		case MysticColorTypeChoice61: return [UIColor tealColor];
		case MysticColorTypeChoice62: return [UIColor steelBlueColor];
		case MysticColorTypeChoice63: return [UIColor robinEggColor];
		case MysticColorTypeChoice64: return [UIColor pastelBlueColor];
		case MysticColorTypeChoice65: return [UIColor turquoiseColor];
		case MysticColorTypeChoice66: return [UIColor skyeBlueColor];
		case MysticColorTypeChoice67: return [UIColor indigoColor];
		case MysticColorTypeChoice68: return [UIColor denimColor];
		case MysticColorTypeChoice69: return [UIColor blueberryColor];
		case MysticColorTypeChoice70: return [UIColor cornflowerColor];
		case MysticColorTypeChoice71: return [UIColor babyBlueColor];
		case MysticColorTypeChoice72: return [UIColor midnightBlueColor];
		case MysticColorTypeChoice73: return [UIColor fadedBlueColor];
		case MysticColorTypeChoice74: return [UIColor icebergColor];
		case MysticColorTypeChoice75: return [UIColor waveColor];
            
#pragma mark - Greens
            
		case MysticColorTypeChoice76: return [UIColor emeraldColor];
		case MysticColorTypeChoice77: return [UIColor grassColor];
		case MysticColorTypeChoice78: return [UIColor pastelGreenColor];
		case MysticColorTypeChoice79: return [UIColor seafoamColor];
		case MysticColorTypeChoice80: return [UIColor paleGreenColor];
		case MysticColorTypeChoice81: return [UIColor cactusGreenColor];
		case MysticColorTypeChoice82: return [UIColor chartreuseColor];
		case MysticColorTypeChoice83: return [UIColor hollyGreenColor];
		case MysticColorTypeChoice84: return [UIColor oliveColor];
		case MysticColorTypeChoice85: return [UIColor oliveDrabColor];
		case MysticColorTypeChoice86: return [UIColor moneyGreenColor];
		case MysticColorTypeChoice87: return [UIColor honeydewColor];
		case MysticColorTypeChoice88: return [UIColor limeColor];
		case MysticColorTypeChoice89: return [UIColor cardTableColor];
            
#pragma mark - System Colors
        case MysticColorTypeInfo:
		case MysticColorTypeChoice90: return [UIColor infoBlueColor];
        case MysticColorTypeSuccess:
		case MysticColorTypeChoice91: return [UIColor successColor];
        case MysticColorTypeWarning:
		case MysticColorTypeChoice92: return [UIColor warningColor];
        case MysticColorTypeFailure:
        case MysticColorTypeError:
		case MysticColorTypeChoice93: return [UIColor dangerColor];
            
#pragma mark - First Colors
        case MysticColorTypeChoice94: return [UIColor color:MysticColorTypeObjectRecipe];
        case MysticColorTypeChoice95: return [UIColor color:MysticColorTypeObjectText];
        case MysticColorTypeChoice96: return [UIColor color:MysticColorTypeObjectFrame];
        case MysticColorTypeChoice97: return [UIColor color:MysticColorTypeObjectLight];
        case MysticColorTypeChoice98: return [UIColor color:MysticColorTypeObjectTexture];
        case MysticColorTypeChoice99: return [UIColor color:MysticColorTypeObjectSettings];
        case MysticColorTypeChoice100: return [UIColor color:MysticColorTypePink];
        case MysticColorTypeChoice101: return [UIColor color:MysticColorTypeBlue];
            
#pragma mark - Blend Colors
        case  MysticColorTypeChoice102: return [UIColor hex:@"9e654b"];
        case  MysticColorTypeChoice103: return [UIColor hex:@"7b3e45"];
        case  MysticColorTypeChoice104: return [UIColor hex:@"ae7d75"];
        case  MysticColorTypeChoice105: return [UIColor hex:@"877666"];
        case  MysticColorTypeChoice106: return [UIColor hex:@"79957e"];
        case  MysticColorTypeChoice107: return [UIColor hex:@"d47270"];
        case  MysticColorTypeChoice108: return [UIColor hex:@"c38a67"];
        case  MysticColorTypeChoice109: return [UIColor hex:@"dea58a"];
        case  MysticColorTypeChoice110: return [UIColor hex:@"b1ba8f"];
        case  MysticColorTypeChoice111: return [UIColor hex:@"b49090"];
        case  MysticColorTypeChoice112: return [UIColor hex:@"c09f7c"];
        case  MysticColorTypeChoice113: return [UIColor hex:@"b3a87b"];
        case  MysticColorTypeChoice114: return [UIColor hex:@"b99645"];
        case  MysticColorTypeChoice115: return [UIColor hex:@"a35b6f"];
        case  MysticColorTypeChoice116: return [UIColor hex:@"65662c"];
        case  MysticColorTypeChoice117: return [UIColor hex:@"373415"];
        case  MysticColorTypeChoice118: return [UIColor hex:@"a5d4c0"];
        case  MysticColorTypeChoice119: return [UIColor hex:@"8c615b"];
        case  MysticColorTypeChoice120: return [UIColor hex:@"e19c66"];
        case  MysticColorTypeChoice121: return [UIColor hex:@"a8b96d"];
        case MysticColorTypeRandom: return [UIColor randomColor];
        default: return [UIColor blackColor];
    }
    return [UIColor blackColor];
}

+ (void) printColors;
{
    [self printColorHeaders];
    [self printColorTypes];
}
+ (void) printColorHeaders;
{
    int start = 51;
    int last = 93;
    
    NSString *constants = @"";
    for (int i = start; i<=last; i++) {
        constants = [constants stringByAppendingFormat:@"\tMysticColorTypeChoice%d,\r\n", i];
    }
    DLog(@"Color Constants: \r\n\r\n%@\r\n\r\n------------------------------------------------\r\n\r\n", constants);
}

+ (void) printColorTypes;
{
    int start = 51;
//    int len = 39;
    
    NSArray *colors = [NSArray arrayWithObjects:@"palePurpleColor", @"coolPurpleColor", @"violetColor", @"plumColor", @"lavenderColor", @"raspberryColor", @"fuschiaColor", @"grapeColor", @"periwinkleColor", @"orchidColor", @"tealColor", @"steelBlueColor", @"robinEggColor", @"pastelBlueColor", @"turquoiseColor", @"skyBlueColor", @"indigoColor", @"denimColor", @"blueberryColor", @"cornflowerColor", @"babyBlueColor", @"midnightBlueColor", @"fadedBlueColor", @"icebergColor", @"waveColor", @"emeraldColor", @"grassColor", @"pastelGreenColor", @"seafoamColor", @"paleGreenColor", @"cactusGreenColor", @"chartreuseColor", @"hollyGreenColor", @"oliveColor", @"oliveDrabColor", @"moneyGreenColor", @"honeydewColor", @"limeColor", @"cardTableColor", @"infoBlueColor", @"successColor", @"warningColor", @"dangerColor",nil];
    
    NSString *constants = @"";
    for (NSString *colorCode in colors) {
        constants = [constants stringByAppendingFormat:@"\t\tcase MysticColorTypeChoice%d:\r\n\t\t\treturn [UIColor %@];\r\n", start, colorCode];
        start++;
    }
    DLog(@"Color Types: \r\n\r\n%@\r\n\r\n------------------------------------------------\r\n\r\n", constants);
}

+ (CGFloat) brightness:(UIColor *)color;
{
    CGFloat l = color.red + color.green + color.blue;
    l = l/3;
    return l;
}
+ (MysticColorType) brightnessColorType:(UIColor *)color;
{
    CGFloat l = [self brightness:color];
    
    if(l <= 0.3)
    {
        return MysticColorTypeDark;
    }
    else if(l <= 0.6)
    {
        return MysticColorTypeNeutral;
    }
    
    return MysticColorTypeBright;
    
}
@end
