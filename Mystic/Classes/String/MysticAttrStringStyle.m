//
//  MysticAttrStringStyle.m
//  Mystic
//
//  Created by Travis A. Weerts on 4/3/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticAttrStringStyle.h"

@implementation MysticAttrStringStyle

+ (MysticAttrString *) string:(id)string style:(MysticStringStyle) style;
{
    return [self string:string style:style state:UIControlStateNormal];
}
+ (MysticAttrString *) string:(id)string style:(MysticStringStyle) style state:(int)state;
{
    MysticAttrString *s = [string isKindOfClass:[MysticAttrString class]] ? string : [MysticAttrString string:string];
    if(s.length == 0)
    {
        NSAssert(s.length==0, @"Trying to style an empty string");
        return s;
    }
    @try {
        switch (style) {
            case MysticStringStyleInputToolbar: break;
            case MysticStringStyleInputPickerLabel:
            {
                s.fixLines = NO;
                s.font = [MysticFont gothamBold:8];
                s.kerning = 1.2;
                s.color = [[UIColor color:MysticColorTypeInputToolbarText] alpha:0.5];

                s.textAlignment=NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleInputToolbarBottom:
            {
                s.fixLines = NO;
                s.textAlignment=NSTextAlignmentCenter;
                s.font = [MysticFont gothamBold:MYSTIC_UI_MENU_LABEL_FONTSIZE_SMALL];
                s.kerning = MYSTIC_UI_LABEL_BTN_CHAR_SPACE_SMALL;
          
                switch (state) {
                    
                    case UIControlStateSelected: s.color = [UIColor color:MysticColorTypeInputToolbarText]; break;
                    case UIControlStateHighlighted: s.color = [UIColor color:MysticColorTypePink]; break;
                    case UIControlStateDisabled: s.color = [[UIColor hex:@"695D56"] darker:0.2]; break;
                    case UIControlStateNormal:
                    default: s.color = [UIColor hex:@"695D56"]; break;
                }
                break;
            }
            case MysticStringStyleInputBlack:
            {
                s.fixLines = NO;
                s.textAlignment=NSTextAlignmentCenter;
                s.font = [MysticFont gothamBlack:MYSTIC_UI_MENU_LABEL_FONTSIZE_SMALL];
                s.kerning = MYSTIC_UI_LABEL_BTN_CHAR_SPACE_SMALL;
                
                switch (state) {
                        
                    case UIControlStateSelected: s.color = [UIColor color:MysticColorTypeInputToolbarText]; break;
                    case UIControlStateHighlighted: s.color = [UIColor color:MysticColorTypePink]; break;
                    case UIControlStateDisabled: s.color = [[UIColor hex:@"695D56"] darker:0.2]; break;
                    case UIControlStateNormal:
                    default: s.color = [UIColor hex:@"695D56"]; break;
                }
                break;
            }
            case MysticStringStyleInputButton:
                
                break;
            case MysticStringStyleInputPickColor:
            {
                s.fixLines = NO;
                s.font = [MysticUI gothamMedium:MYSTIC_UI_MENU_LABEL_FONTSIZE];
                s.lineHeightMultiple=1.2;
                NSMutableParagraphStyle *p = [[NSMutableParagraphStyle alloc] init];
                p.alignment = NSTextAlignmentCenter;
                [s setAttributes:@{NSForegroundColorAttributeName: [UIColor color:MysticColorTypeInputToolbarText],
                                   NSKernAttributeName: @(MYSTIC_UI_LABEL_BTN_CHAR_SPACE*1.25),
                                   NSFontAttributeName: [MysticUI gothamBold:MYSTIC_UI_MENU_LABEL_FONTSIZE+0.75],
                                   NSParagraphStyleAttributeName: [p autorelease]} forLine:0];
                
                p = [[NSMutableParagraphStyle alloc] init];
                p.lineHeightMultiple = 1.25;
                p.alignment = NSTextAlignmentCenter;
                [s setAttributes:@{NSForegroundColorAttributeName: [[UIColor color:MysticColorTypeInputToolbarText] darker:0.35],
                                   NSKernAttributeName: @(MYSTIC_UI_LABEL_BTN_CHAR_SPACE*1.25),
                                   NSFontAttributeName: [MysticUI gothamBold:MYSTIC_UI_MENU_LABEL_FONTSIZE+.5],
                                   NSParagraphStyleAttributeName: [p autorelease]} forLines:@[@(2),@(3),@(4),@(5),@(6),@(7),]];
                [s setAttributes:@{NSForegroundColorAttributeName: [UIColor color:MysticColorTypeInputToolbarText],
                                   NSKernAttributeName: @(MYSTIC_UI_LABEL_BTN_CHAR_SPACE*1.25),
                                   NSFontAttributeName: [MysticFont gothamBlack:MYSTIC_UI_MENU_LABEL_FONTSIZE+0.5],
                                   } forString:MYSTIC_TEXT_PLUS];
                break;
            }
            case MysticStringStyleToolbarTitle:
            {
                [s.attrString setFont:[MysticUI gothamMedium:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor color:MysticColorTypeInputToolbarText]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:MYSTIC_UI_LABEL_BOTTOM_BAR_BRUSH];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleToolbarTitleDull:
            {
                [s.attrString setFont:[MysticUI gothamMedium:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
//                [s.attrString addAttribute:NSForegroundColorAttributeName
//                                     value:[UIColor colorWithRed:0.30 green:0.30 blue:0.27 alpha:1.00]
//                                     range:NSMakeRange(0, s.length)];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.25 green:0.22 blue:0.20 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                
                
                [s.attrString setCharacterSpacing:MYSTIC_UI_LABEL_BOTTOM_BAR_BRUSH];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleBrushPropertyTitle:
            {
                [s.attrString setFont:[MysticUI gothamMedium:8]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.84 green:0.82 blue:0.76 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:4];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleNavigationTitle:
            {
                [s.attrString setFont:[MysticUI gotham:11]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:3];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleSettingsNavButtonLeft:
            {
                [s.attrString setFont:[MysticUI gotham:11]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:3];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleSettingsCellTitle:
            {
                [s.attrString setFont:[MysticUI gothamBold:14]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:2];
                s.textAlignment = NSTextAlignmentLeft;
                break;
            }
            case MysticStringStyleAccessTitle:
            {
                [s.attrString setFont:[MysticFont gothamMedium:17]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:1];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleAccessDescription:
            {
                [s.attrString setFont:[MysticUI gotham:12]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.64 green:0.59 blue:0.56 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:1];
                s.textAlignment = NSTextAlignmentCenter;
                s.lineHeight = 20;
                break;
            }
            case MysticStringStyleAccessButton:
            {
                [s.attrString setFont:[MysticUI gothamBold:12]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:3];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleTipTitle:
            {
                [s.attrString setFont:[MysticUI gothamMedium:10]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:1];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleTipMessage:
            {
                [s.attrString setFont:[MysticUI gothamMedium:11]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:1];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleSettingsCellSubtitle:
            {
                [s.attrString setFont:[MysticUI gotham:12]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.37 green:0.35 blue:0.33 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:1];
                s.textAlignment = NSTextAlignmentLeft;
                break;
            }
            case MysticStringStyleSettingsCellDetail:
            {
                [s.attrString setFont:[MysticUI gotham:11]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.35 green:0.33 blue:0.30 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:2];
                s.textAlignment = NSTextAlignmentRight;
                break;
            }
            case MysticStringStyleMessage:
            {
                [s.attrString setFont:[MysticUI gotham:13]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:3];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleBrushSliderLabel:
            {
                [s.attrString setFont:[MysticUI gothamLight:40]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:0];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleDoneButton:
            {
                [s.attrString setFont:[MysticUI gothamMedium:MYSTIC_UI_MENU_LABEL_FONTSIZE]];
                switch (state) {
                    case UIControlStateHighlighted:
                        
                        [s.attrString addAttribute:NSForegroundColorAttributeName
                                             value:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00]
                                             range:NSMakeRange(0, s.length)];
                        break;
                        
                    default:
                        [s.attrString addAttribute:NSForegroundColorAttributeName
                                             value:[UIColor color:MysticColorTypeInputToolbarText]
                                             range:NSMakeRange(0, s.length)];
                        break;
                }
                
                [s.attrString setCharacterSpacing:4];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleStoreCategory:
            case MysticStringStyleStoreRestore:
            {
                [s.attrString setFont:[MysticUI gothamMedium:11]];
                switch (state) {
                    case UIControlStateHighlighted:
                        
                        [s.attrString addAttribute:NSForegroundColorAttributeName
                                             value:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00]
                                             range:NSMakeRange(0, s.length)];
                        break;
                        
                    default:
                        [s.attrString addAttribute:NSForegroundColorAttributeName
                                             value:[UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:1]
                                             range:NSMakeRange(0, s.length)];
                        break;
                }
                
                [s.attrString setCharacterSpacing:2];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleStoreItemTitle:
            {
                [s.attrString setFont:[MysticUI gothamMedium:12]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.90 green:0.85 blue:0.79 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:2];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleStoreItemSubtitle:
            {
                [s.attrString setFont:[MysticUI gothamBook:9]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.90 green:0.85 blue:0.79 alpha:0.5]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:3];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleStoreItemButton:
            {
                [s.attrString setFont:[MysticUI gothamBold:14]];
                switch (state) {
                    case UIControlStateHighlighted:
                        
                        [s.attrString addAttribute:NSForegroundColorAttributeName
                                             value:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00]
                                             range:NSMakeRange(0, s.length)];
                        break;
                    case UIControlStateSelected:
                    case UIControlStateDisabled:
                        [s.attrString addAttribute:NSForegroundColorAttributeName
                                             value:[UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:1.00]
                                             range:NSMakeRange(0, s.length)];
                        
                        
                        break;
                        
                    default:
                        [s.attrString addAttribute:NSForegroundColorAttributeName
                                             value:[UIColor color:MysticColorTypeInputToolbarText]
                                             range:NSMakeRange(0, s.length)];
                        break;
                }
                
                [s.attrString setCharacterSpacing:2];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleStoreDonateTitle:
            {
                [s.attrString setFont:[MysticFont gothamMedium:26]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.91 green:0.85 blue:0.78 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:1];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleStoreDonateDescription:
            {
                s.trimLineHeight = NO;
                [s.attrString setFont:[MysticUI gotham:15]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.64 green:0.59 blue:0.56 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:1.5];
                s.textAlignment = NSTextAlignmentCenter;
                s.lineHeightMultiple = 1.2;
                break;
            }
            case MysticStringStyleStoreDonateButton:
            {
                [s.attrString setFont:[MysticFont gothamBold:24]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.91 green:0.34 blue:0.42 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:1];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case MysticStringStyleStoreNevermindButton:
            {
                [s.attrString setFont:[MysticUI gothamBold:12]];
                [s.attrString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithRed:0.44 green:0.42 blue:0.38 alpha:1.00]
                                     range:NSMakeRange(0, s.length)];
                [s.attrString setCharacterSpacing:3];
                s.textAlignment = NSTextAlignmentCenter;
                break;
            }
            default:
                break;
        }
        return s;
    } @catch (NSException *exception) {
        DLogError(@"MysticAttrStringStyle: ERROR: %@", ExceptionString(exception));
        return s;
    }
}
@end
