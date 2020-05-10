//
//  MysticDefinitions.h
//  Mystic
//
//  Created by Travis on 10/9/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#ifndef Mystic_MysticDefinitions_h
#define Mystic_MysticDefinitions_h

#import "MysticLogs.h"

#include <stdlib.h>

#define ARC4RANDOM_MAX      0x100000000

// uncomment to download layer files
//#define MYSTIC_MAKE_CONFIG_LOCAL                            1



#define isMNull(value) [value isKindOfClass:[NSNull class]]

#define MYSTIC_APP_VERSION                                  1
#define USETESTURL                                          1
//#define MYSTIC_DEBUG                                        1
#define MYSTIC_BETA                                         1
#define DEBUG_FABRIC                                        1
//#define MYSTIC_ASK_TO_UPDATE                                1


#define MYSTIC_MAKE_CONFIG_LOCAL_FILTERS_PLIST              1
#define MYSTIC_MAKE_CONFIG_LOCAL_PACKS_FILTERS_PLIST        1
#define MYSTIC_ADMIN_MODE                                   1

#define MYSTIC_CAMERA_MODE                                  1
//
#ifdef DEBUG
//#define MYSTIC_USE_LAUNCH_PHOTO_NEW_PROJECT                 1
//#define MYSTIC_USE_LAST_PHOTO                               1




#define MYSTIC_USE_LAUNCH_PHOTO                         @"launchPhoto.jpg"



//#define MYSTIC_USE_LAUNCH_PHOTO                             @"skin_tone.jpg"
//#define MYSTIC_USE_LAUNCH_PHOTO                             @"launchPhoto-test.jpg"

//#define MYSTIC_USE_LAUNCH_PHOTO                             @"launchPhoto-rgb2.png"
#endif

//#ifdef DEBUG
////    #define MYSTIC_START_STATE                               43
////    #define MYSTIC_START_SUB_STATE                           277
////    #define MYSTIC_USE_LAST_PHOTO                            1
//    #ifndef MYSTIC_USE_LAST_PHOTO
//        #ifndef MYSTIC_USE_LAUNCH_PHOTO
//            #define MYSTIC_USE_LAUNCH_PHOTO                 @"launchPhoto.jpg"
//        #endif
//    #endif
//#endif
//#define MYSTIC_USE_SAMPLE_PROJECT                           1


//#define MYSTIC_START_WITH_FRESH_CACHE                       1
#define WRITEMECAM_FREE                                     1
#define SHOWTEXTURES                                        1
#define USEOLDPROCESSERIMAGE                                1

#define kMysticMessageFadeDelay                             0.5
#define kMysticMinimumMessageWidth                          80
#define kMysticImageMessageFadeDelay                        0.666f
#define kMysticImageMessageHeight                           100.f
#define kMysticImageMessageWidth                            180.f

#define MYSTIC_USE_TRANSFORMS                               1

#ifndef MYSTIC_LOG_COLORS

#define COLOR_GREEN                                         @"94,197,128"
#define COLOR_GREEN_BRIGHT                                  @"117,178,21"
#define COLOR_RED                                           @"227,76,76"
#define COLOR_WHITE                                         @"241,234,224"
#define COLOR_BLUE                                          @"0,204,192"
#define COLOR_YELLOW                                        @"236,206,38"
#define COLOR_PURPLE                                        @"209,23,154"
#define COLOR_DATE                                          @"fg22,22,21;"
#define COLOR_DOTS                                          @"60,60,59"
#define COLOR_BLOCK                                         @"40,40,39"
#define COLOR_DULL                                          @"111,111,110"
#define COLOR_PINK                                          @"237,87,105"
#define COLOR_BG                                            @"28,28,27"

#else

#define COLOR_GREEN                                         @""
#define COLOR_GREEN_BRIGHT                                  @""
#define COLOR_RED                                           @""
#define COLOR_WHITE                                         @""
#define COLOR_BLUE                                          @""
#define COLOR_YELLOW                                        @""
#define COLOR_PURPLE                                        @""
#define COLOR_DATE                                          @""
#define COLOR_DOTS                                          @""
#define COLOR_BLOCK                                         @""
#define COLOR_DULL                                          @""
#define COLOR_PINK                                          @""
#define COLOR_BG                                            @""



#endif

#define RAND_FROM_TO(min,max) (min + arc4random_uniform(max - min + 1))


#define Mk_DEBUG                                             @"Mk_DEBUG"
#define Mk_TIME                                              @"Mk_TIME"
#define Mk_SCALE                                             @"Mk_SCALE"
#define Mk_SHADER_WITH_FILE                                  @"Mk_SHADER_WITH_FILE"
#define Mk_FRAME                                             @"frame"

#define MYSTIC_NAME                                         @"Mystic"
#define MYSTIC_APPSTORE_ID                                  @"id625666038"
#define MYSTIC_WEB_ADDRESS                                  @"https://itunes.apple.com/us/app/mystic*/id625666038"

#define MYSTIC_UPLOAD_SHARED_PHOTOS                         0


#define MYSTIC_CONFIG_URL                                   @"http://files.mysti.ch.s3.amazonaws.com/config/config.plist"
#define MYSTIC_CONFIG_URL2                                  @"http://backstage.mysti.ch/app/config/?live=yes"
#define MYSTIC_CONFIG_URL_DEBUG                             @"http://backstage.mysti.ch/app/config/?live=no"

#define MYSTIC_JOURNAL_DATA_URL                             @"http://backstage.mysti.ch/journal/journal.plist"
#define MYSTIC_HINTS_URL                                    @"http://backstage.mysti.ch/assets/config/hints.plist"
#define MYSTIC_QUOTES_URL                                   @"http://backstage.mysti.ch/assets/config/quotes.plist"
#define MYSTIC_BACKGROUNDS_URL                              @"http://backstage.mysti.ch/assets/config/backgrounds.plist"
#define MYSTIC_COLOR_BACKGROUNDS_URL                        @"http://backstage.mysti.ch/assets/config/colors.plist"

// Constants used to represent your AWS Credentials.

#define MYSTIC_USER_PROJECT_NAMES                           @"MysticUser-Project-Names"
#define MYSTIC_USER_PROJECTS                                @"MysticUser-Projects"

//#define MYSTIC_ADJUST_COLORS_USE_SHADER                     NO

#define MYSTIC_JOURNAL_TITLE                                @"SNAP SHOTS"

#define MYSTIC_RATE_AFTER_OPENED_TIMES                      3
#define MYSTIC_RATE_AFTER_DELAY                             0.5f
#define MYSTIC_RATE_AGAIN_AFTER_DAYS                        2
#define MYSTIC_CONFIG_DICT_CACHE_EXP_TIME                   1800.f
//#define MYSTIC_CONFIG_DICT_CACHE_EXP_TIME                   10.f


//#define API_ENDPOINT                                        @"http://api.mysti.ch/"
#define API_ENDPOINT                                        @"http://backstage.mysti.ch/api/"

//#define API_VERSION                                         @"v1"
#define API_VERSION                                         @"v2"
#define ACCESS_KEY_ID                                       @"AKIAJYO3MLWYHGEP4QYA"
#define SECRET_KEY                                          @"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"
#define REACHABLE_HOST                                      @"www.google.com"
#define MYSTIC_API_INSTAGRAM_CLIENTID                       @"e0aedec6255f4dac99e4f2f1ee69215a"
#define MYSTIC_API_INSTAGRAM_CLIENTSECRET                   @"ff47451b48144ccb9ecd5365cbb3bfce"
#define MYSTIC_API_INSTAGRAM_TAG                            @"mysticapp"
#define MYSTIC_API_INSTAGRAM_USER                           @"mysticapp"
#define MYSTIC_API_INSTAGRAM_ENDPOINT                       @"https://api.instagram.com/"
#define MYSTIC_API_SINCERELY_KEY                            @"H5XX0ZNTC63X33IU0VLKWLPYO126QXAWRRNW5EWV"

#ifdef DEBUG
#define MYSTIC_LOAD_NEWEST_SHADER                           1
#endif
// Mystic AWS

// Constants for the Bucket and Object name.
#define FILES_BUCKET                                        @"files.mysti.ch"
#define PICTURE_BUCKET                                      @"i.mysti.ch"
#define PICTURE_USER_UPLOADS                                @"u"

#define MYSTIC_DATASIZE_NORMAL                              100000

#define MYSTIC_CACHE_RENDER_PREFIX                          @"userRender--";

#define MYSTIC_REFRESH_COMPLETE_NOTIFICATION                @"mystic-refresh-complete-notification";
#define MYSTIC_TRANSFORM_COMPLETE_NOTIFICATION              @"mystic-transform-complete-notification";

#define MYSTIC_SHARE_SUBJECT                                @"My Mystic Image";



#define MYSTIC_FLOAT_UNKNOWN                                -111122223333.0f

#define MYSTIC_SHADER_WRITE_TO_FILE                         1
#define MYSTIC_SHADER_INLINE_ADJUSTMENTS                    -1


#define kMysticSkin                                         0
#define kMysticSkinHue                                      0.05
#define kMysticSkinHueThreshold                             40.0
#define kMysticSkinMaxHueShift                              0.25
#define kMysticSkinMaxSaturationShift                       0.4
#define kMysticSkinUpperSkinToneColor                       0

#define MYSTIC_PROCESS_SAFE_MODE                            1
#define MYSTIC_PROCESS_LIVE_STATE                           1
#define MYSTIC_PROCESS_LAYERS_CACHE_ENABLED                 1
#define MYSTIC_PROCESS_LAYERS_PER_PASS                      5
#define MYSTIC_SAVE_LAYERS_PER_PASS                         3

#define MYSTIC_PROCESS_LAYERS_MAX_ADD                       50

#define MYSTIC_PROCESS_LAYERS_IMG_LEVEL                     999
#define MYSTIC_LAYER_CACHED_LEVEL                           999
#define MYSTIC_LAYER_EFFECT_RGB_RED                         0.92f
#define MYSTIC_LAYER_EFFECT_RGB_GREEN                       MYSTIC_LAYER_EFFECT_RGB_RED
#define MYSTIC_LAYER_EFFECT_RGB_BLUE                        MYSTIC_LAYER_EFFECT_RGB_RED
#define MYSTIC_LAYER_MASK_LEVEL                             999
//#define MYSTIC_PROCESS_STACK_CACHE_ENABLED                  @NO

#define MYSTIC_CHOICES_SCROLLVIEW_COLUMNS                   6


#define MYSTIC_FEATURED_MAX                                 30
#define MYSTIC_FEATURED_MAX_TOP                             12
#define MYSTIC_LIST_PACK_HEIGHT                             150.f
#define MYSTIC_LIST_SPECIAL_PACK_HEIGHT                     250.f

#define MYSTIC_RECENT_USED_MAX                              20


#define MYSTIC_SHOWBARS_DURATION                            0.2
#define MYSTIC_HIDEBARS_DURATION                            0.2


#define MYSTIC_MAX_FLOAT                                    112233445566778899.9999
#define MYSTIC_MIN_FLOAT                                    -112233445566778899.9999

#define MYSTIC_RENDER_TIMER_DELAY                           0.0002f
#define MYSTIC_TOOLS_RELOAD_INTERVAL                        0.025f

#define MYSTIC_OPTIONS_PRELOADER_MAX_CONCURRENT_DOWNLOADS   1
#define MYSTIC_OPTION_PRELOADER_MAX_CONCURRENT_DOWNLOADS    1

#define kSPUserResizableViewGlobalInset                     7.0f
#define kSPUserResizableViewBorderInset                     0.0f
#define kSPUserResizableViewBorderInset_X                   0.0f
#define kSPUserResizableViewBorderInset_Y                   0.0f


#define kMysticLongSide                                     14
#define kMysticTallSide                                     10
#define kMysticShortSide                                    3.5
#define kMysticHandleRadius                                 2
#define kMysticHandleBorderWidth                            3

#define MYSTIC_LAYER_MENU_POPUP_INSET_Y                     kSPUserResizableViewGlobalInset+kSPUserResizableViewBorderInset_Y+kMysticShortSide+8
#define MYSTIC_LAYER_MENU_POPUP_INSET_X                     0

#define MYSTIC_LAYER_CONTENT_INSET                          7.0f
#define MYSTIC_LAYER_CONTENT_INSET_TOP                      9.f
#define MYSTIC_LAYER_CONTENT_INSET_LEFT                     10.f
#define MYSTIC_LAYER_CONTENT_INSET_BTM                      9.f
#define MYSTIC_LAYER_CONTENT_INSET_RIGHT                    10.f


#define kSPUserResizableViewDefaultMinWidth                 5.0f
#define kSPUserResizableViewDefaultMinHeight                5.0f
#define kSPUserResizableViewDefaultMinWidthShape            1.0f
#define kSPUserResizableViewDefaultMinHeightShape           kSPUserResizableViewDefaultMinWidthShape
#define MYSTIC_UI_LAYER_BORDER                              2.5f
#define kSPUserResizableViewInteractiveBorderWidth          MYSTIC_UI_LAYER_BORDER
#define MYSTIC_UI_LAYER_BORDER_SIZE                         12.f

#define MYSTIC_LAYER_TYPE_HEIGHT                            90.f

#define MYSTIC_FLOAT                                        34587.34590f
#define MYSTIC_INT                                          2346345222


#define kMYSTICLAYERControlIconSize                         16.0f
#define kMYSTICLABELControlSize                             25.0f // for old layers
#define kMYSTICLABELControlInset_X                          0.5f
#define kMYSTICLABELControlInset_Y                          0.5f
#define kMYSTICLAYERControlInset_T                          0.5f
#define kMYSTICLAYERControlInset_B                          0.5f
#define kMYSTICLAYERControlInset_L                          0.5f
#define kMYSTICLAYERControlInset_R                          0.5f

#define kMYSTICLAYERControlHitInset                         10.f

#define kMYSTICLABELInsetSize                               MYSTIC_LAYER_CONTENT_INSET

#define MYSTIC_LAYER_RESIZE_SCALE_FACTOR                    1.2f

#define kMYSTICLAYERScaleFactor                             MYSTIC_LAYER_RESIZE_SCALE_FACTOR
#define MysticPackButtonImageViewAlphaOnSelect              0.25f
#define kMYSTICControlSelectedImageViewAlpha                0.25f
#define kMYSTICControlSelectedImageViewAlphaLayer           0.f

#define kColumnPadding                                      0
#define kExtraWidth                                         4

#define MYSTIC_UI_DRAWER_LEFT_WIDTH                         220.f
#define MYSTIC_UI_DRAWER_RIGHT_WIDTH                        240.f

#define MYSTIC_MAX_LINEHEIGHT_SCALE                         4.f
#define MYSTIC_DEFAULT_LINEHEIGHT_SCALE                     0.9f

#define MYSTIC_AUTO_SCROLL_TO_SELECTED_INDEX                -11

#define MYSTIC_ICON_WIDTH                                   18.f
#define MYSTIC_ICON_HEIGHT                                  18.f
#define MYSTIC_ICON_LINE_WIDTH                              2.f

#define MYSTIC_UI_IMAGEVIEW_INSET_NAV_VIEWS_OFFSET          0.f

#define MYSTIC_UI_IMAGEVIEW_INSET_NAV_OFFSET                0.f
#define MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_OFFSET             0.f
#define MYSTIC_UI_IMAGEVIEW_INSET_NAV_HIDDEN_OFFSET         0.f
#define MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_HIDDEN_OFFSET      0.f

#define MYSTIC_UI_IMAGEVIEW_INSET_HOME                      18.f
//#define MYSTIC_UI_IMAGEVIEW_INSET_EDIT                      22.f
#define MYSTIC_UI_IMAGEVIEW_INSET_EDIT                      18.f

#define MYSTIC_UI_IMAGEVIEW_INSET_EDIT_TEXT                 22.f
#define MYSTIC_UI_IMAGEVIEW_INSET_LAYERS                    0.f
#define MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_X                  0.f
#define MYSTIC_UI_IMAGEVIEW_INSET_LAYERS_Y                  10.f

#define MYSTIC_UI_TOOLS_INSET_EDIT_TEXT_X                   -10.f
#define MYSTIC_UI_TOOLS_INSET_EDIT_TEXT_Y                   44.f

#define MYSTIC_UI_TOOLS_TAG                                 13453
#define MYSTIC_UI_TOOLS_INSET_EDIT                          5.f
#define MYSTIC_UI_TOOLS_INSET_HOME                          5.f
#define MYSTIC_UI_TOOLS_HIT_INSET                           20.f
#define MYSTIC_UI_TOOLS_HIT_INSET_SMALL                     12.f

#define MYSTIC_LAYERS_BOUNDS_INSET                          30.f

#define MYSTIC_NAVBAR_ICON_SHARE_WIDTH                      25.f
#define MYSTIC_NAVBAR_ICON_SHARE_HEIGHT                     25.f
#define MYSTIC_NAVBAR_ICON_WIDTH                            40.f
#define MYSTIC_NAVBAR_ICON_HEIGHT                           40.f
#define MYSTIC_NAVBAR_HEIGHT_NORMAL                         58.f
#define MYSTIC_NAVBAR_HEIGHT                                60.f

#define MYSTIC_SECTION_HEADER_HEIGHT                        56.f
#define MYSTIC_SECTION_HEADER_TOOLBAR_HEIGHT                56.f

#define MYSTIC_NAVBAR_TOOLICON_WIDTH                        40.f
#define MYSTIC_NAVBAR_TOOLICON_HEIGHT                       40.f
#define MYSTIC_NAVBAR_ICON_WIDTH_CANCEL                     15.f
#define MYSTIC_NAVBAR_ICON_HEIGHT_CANCEL                    15.f
#define MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM                    22.f
#define MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM                   15.f
#define MYSTIC_NAVBAR_ICON_WIDTH_CONFIRM_SKETCH             19.f
#define MYSTIC_NAVBAR_ICON_HEIGHT_CONFIRM_SKETCH            13.f
#define MYSTIC_NAVBAR_ICON_WIDTH_ADD                        25.f
#define MYSTIC_NAVBAR_ICON_HEIGHT_ADD                       25.f
#define MYSTIC_BRUSH_ICON_BOTTOMBAR                         24.f
#define MYSTIC_BRUSH_ICON_CELL                              23.f
#define MYSTIC_LAYERS_ICON_CELL                             30.f

#define MYSTIC_UI_TOOLBAR_HIDE_HEIGHT                       38.f

#define MYSTIC_SHARE_NAVBAR_ICON_WIDTH_CANCEL               23.f
#define MYSTIC_SHARE_NAVBAR_ICON_HEIGHT_CANCEL              23.f

#define MYSTIC_SHARE_NAVBAR_ICON_WIDTH_SETTINGS             25.f
#define MYSTIC_SHARE_NAVBAR_ICON_HEIGHT_SETTINGS            25.f


//#define MYSTIC_NAVBAR_ICON_WIDTH_LAYERS                     22.f
//#define MYSTIC_NAVBAR_ICON_HEIGHT_LAYERS                    22.f
#define MYSTIC_NAVBAR_ICON_WIDTH_LAYERS                     19.f
#define MYSTIC_NAVBAR_ICON_HEIGHT_LAYERS                    10.f


#define MYSTIC_NAVBAR_ICON_WIDTH_SETTINGS                   22.f
#define MYSTIC_NAVBAR_ICON_HEIGHT_SETTINGS                  22.f
#define MYSTIC_NAVBAR_ICON_WIDTH_BACK                       22.f
#define MYSTIC_NAVBAR_ICON_HEIGHT_BACK                      22.f
#define MYSTIC_NAVBAR_ACCESSORY_SIZE                        30.f

#define MYSTIC_LAYER_CELL_ACCESSORY_SIZE                    25.f
#define MYSTIC_SHARE_CELL_ACCESSORY_SIZE                    31.f

#define MYSTIC_ICON_BIG_WIDTH                               30.f
#define MYSTIC_ICON_BIG_HEIGHT                              30.f

#define MYSTIC_IMAGESIZE_UPLOAD_WIDTH                       1024.f
#define MYSTIC_IMAGESIZE_UPLOAD_HEIGHT                      1024.f


#define MYSTIC_HUD_FONTSIZE                                 12.0f
#define MYSTIC_HUD_SPEED                                    0.3f
#define MYSTIC_HUD_DURATION                                 0.07f
#define MYSTIC_HUD_HIDE_DELAY                               0.4f
#define MYSTIC_HUD_HIDE_DELAY_LONG                          1.4f
#define MYSTIC_HUD_HIDE_MIN_DURATION                        0.35f


#define MYSTIC_DRAWER_LAYER_ICON_WIDTH                      54.0f
#define MYSTIC_DRAWER_LAYER_ICON_HEIGHT                     54.0f

#define MYSTIC_DRAWER_LAYER_CELL_HEIGHT                     82.f
#define MYSTIC_DRAWER_LAYER_CELL_LAYOUT_PADDING_LEFT        12.f
#define MYSTIC_DRAWER_LAYER_CELL_LAYOUT_PADDING_RIGHT       20.f
#define MYSTIC_DRAWER_LAYER_CELL_LAYOUT_PADDING_TOP         13.f
#define MYSTIC_DRAWER_LAYER_CELL_LAYOUT_PADDING_BOTTOM      13.f
#define MYSTIC_DRAWER_LAYER_CELL_LAYOUT_OFFSET_LEFT         3.f
#define MYSTIC_DRAWER_LAYER_CELL_LAYOUT_TITLE_SPACE_Y       5.f

#define MYSTIC_HOLD_INTERVAL_SLOW                           0.15f
#define MYSTIC_HOLD_INTERVAL_MEDIUM                         0.1f
#define MYSTIC_HOLD_INTERVAL_NORMAL                         0.05f
#define MYSTIC_HOLD_INTERVAL_FAST                           0.015f

#define MYSTIC_DEFAULT_NEW_OVERLAY_SCALE_WIDTH              0.5f
#define MYSTIC_DEFAULT_NEW_OVERLAY_SCALE_HEIGHT             0.5f


#define MYSTIC_UI_DRAWER_LAYERS_BOTTOMVIEW_HEIGHT           60.f

#define MYSTIC_DEFAULT_RESIZE_LABEL_SCALE_WIDTH             0.6f
#define MYSTIC_DEFAULT_RESIZE_LABEL_TEXTALIGN               NSTextAlignmentCenter
#define MYSTIC_DEFAULT_RESIZE_LABEL_LINEHEIGHT_SCALE        1.f
#define MYSTIC_DEFAULT_RESIZE_LABEL_FONTSIZE                20.0f
#define MYSTIC_DEFAULT_RESIZE_LABEL_FONT                    @"HelveticaNeue"
#define MYSTIC_UI_RESIZABLE_CONTROL_BORDER            3.f
#define MYSTIC_UI_RESIZABLE_CONTROL_CORNER_RADIUS           0.f

#define MYSTIC_TEXT_PLUS                                    @"✚"

#define MYSTIC_DEFAULT_FONTSIZE                             30.f
#define MYSTIC_DEFAULT_QUOTE                                @"Double Tap to Edit"
#define MYSTIC_DEFAULT_INPUT_TEXT                           @"Type here..."
//#define MYSTIC_IGNORE_DEFAULT_TEXT                          1
#define MYSTIC_DEFAULT_FONT_TEXT                            MYSTIC_DEFAULT_QUOTE
#define MYSTIC_DEFAULT_FONTSTYLE_TEXT                       MYSTIC_DEFAULT_FONT_TEXT

#define MYSTIC_UI_BADGE_DURATION                            0.26f
#define MYSTIC_UI_TABBAR_DELAY                              0.25f


#define MYSTIC_UI_IMAGEVIEW_INSET_TOP                       0.f
#define MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM                    0.f
#define MYSTIC_UI_IMAGEVIEW_INSET_LEFT                      0.f
#define MYSTIC_UI_IMAGEVIEW_INSET_RIGHT                     0.f

#define MYSTIC_UI_IMAGEVIEW_INSET_TOP_IPAD                  10
#define MYSTIC_UI_IMAGEVIEW_INSET_BOTTOM_IPAD               54.f
#define MYSTIC_UI_IMAGEVIEW_INSET_LEFT_IPAD                 10
#define MYSTIC_UI_IMAGEVIEW_INSET_RIGHT_IPAD                10

#define MYSTIC_UI_CORNER_RADIUS                             10.0f
#define MYSTIC_UI_BLUR_RADIUS                               30.f

#define MYSTIC_UI_TOOL_BLUR_RADIUS                          40.f

#define MYTIC_UI_BUTTON_TEXT_TOP_PADDING                    5.0f

#define MYSTIC_NAVIGATION_BTN_MARGIN                        7.f



#define MYSTIC_UI_GALLERY_IMAGE_PADDING                     10.0f
#define MYSTIC_UI_GALLERY_IMAGE_DURATION                    0.4f

#define MYSTIC_UI_CONTROLS_NUMBER                           3
#define MYSTIC_UI_CONTROLS_NUMBER_MORE                      6

#define MYSTIC_UI_CONTROLS_MARGIN                           7
#define MYSTIC_UI_CONTROLS_MARGIN_WIDE                      8

#define MYSTIC_UI_PANEL_CONTROLS_SPACING                    5.f




#define MYSTIC_UI_CONTROL_FADE_DURATION                     0.4f

#define MYSTIC_UI_CONTROL_SELECTED_ALPHA_BLEND              0.0f
#define MYSTIC_UI_CONTROL_SELECTED_ALPHA_TEXT               0.0f
#define MYSTIC_UI_CONTROL_SELECTED_ALPHA_TEXTURE            0.0f
#define MYSTIC_UI_CONTROL_SELECTED_ALPHA_SETTINGS           0.0f
#define MYSTIC_UI_CONTROL_SELECTED_ALPHA_FILTER             0.0f
#define MYSTIC_UI_CONTROL_SELECTED_ALPHA_COLOR              0.0f
#define MYSTIC_UI_CONTROL_SELECTED_ALPHA_FRAME              0.0f
#define MYSTIC_UI_CONTROL_SELECTED_ALPHA_LIGHT              0.0f
#define MYSTIC_UI_CONTROL_SELECTED_ALPHA_FONT               0.0f
#define MYSTIC_UI_CONTROL_SELECTED_ALPHA_RECIPE             0.0f
#define MYSTIC_UI_CONTROL_SELECTED_BORDER             2.5f

#define MYSTIC_UI_CONTROL_PAGE_CONTROL_HEIGHT               18.0f
#define MYSTIC_UI_CONTROL_PAGE_CONTROL_OFFSET               3.0f
#define MYSTIC_UI_CONTROL_PAGE_CONTROL_CONTENT_OFFSET       5.0f

#define MYSTIC_UI_CONTROL_SUBBTN_SIZE                       29.f
#define MYSTIC_UI_CONTROL_SUBBTN_IMG_INSET                  6.f
#define MYSTIC_UI_CONTROL_SUBBTN_OFFSETY                    11.f
#define MYSTIC_UI_CONTROL_TOGGLER_OFFSETY                   20.f

#define MYSTIC_UI_CONTROL_LABEL_HEIGHT_SMALL                18.f
#define MYSTIC_UI_CONTROL_LABEL_HEIGHT_MED                  21.f

#define MYSTIC_UI_HORIZ_MENU_HEIGHT                         40.f

#define MYSTIC_TOOLS_TAP_FADEOUT_DELAY                      5.0f
#define MYSTIC_TOOLS_FADEIN_SHOWTIME                        1.2f
#define MYSTIC_TOOLS_FADEIN_DELAY                           2.5
#define MYSTIC_UI_TOOLS_MARGIN_X                            18.0f
#define MYSTIC_UI_TOOLS_MARGIN_Y                            18.0f
#define MYSTIC_UI_TOOLS_TOOL_SIZE                       42.0f
#define MYSTIC_UI_TOOLS_TOOL_SIZE_SMALL                 36.0f
#define MYSTIC_UI_TRANSFORM_TOOL_ICON_SIZE                  12.0f
#define MYSTIC_UI_TRANSFORM_TOOL_ICON_WIDTH                 9.0f
#define MYSTIC_UI_TRANSFORM_TOOL_ICON_HEIGHT                15.0f
#define MYSTIC_UI_TRANSFORM_TOOL_ICON_WIDTH_LANDSCAPE       15.0f
#define MYSTIC_UI_TRANSFORM_TOOL_ICON_HEIGHT_LANDSCAPE      9.0f
#define MYSTIC_UI_TRANSFORM_TOOL_ROTATE_WIDTH               15.0f
#define MYSTIC_UI_TRANSFORM_TOOL_ROTATE_HEIGHT              15.0f
#define MYSTIC_UI_TRANSFORM_TOOL_MINUS_WIDTH                15.0f
#define MYSTIC_UI_TRANSFORM_TOOL_MINUS_HEIGHT               7.0f
#define MYSTIC_UI_TRANSFORM_TOOL_PLUS_WIDTH                 15.0f
#define MYSTIC_UI_TRANSFORM_TOOL_PLUS_HEIGHT                15.0f

#define MYSTIC_UI_TRANSFORM_TOOL_FLIP_VERT_HEIGHT           18.f
#define MYSTIC_UI_TRANSFORM_TOOL_FLIP_VERT_WIDTH            22.f

#define MYSTIC_UI_TRANSFORM_TOOL_FLIP_HORIZ_HEIGHT           22.f
#define MYSTIC_UI_TRANSFORM_TOOL_FLIP_HORIZ_WIDTH            18.f

#define MYSTIC_UI_FONT_TOOL_ICONSIZE                        20.0f
#define MYSTIC_UI_FONT_TOOL_ICONSIZE_FONT                   18.0f


#define MYSTIC_UI_CONTROL_BORDER                      0.f
#define MYSTIC_UI_CONTROL_IMAGE_INSET                       7.0f
#define MYSTIC_UI_CONTROL_IMAGE_INSET_SHAPE                 15.0f

#define MYSTIC_UI_PANEL_HEIGHT                              100.f

#define MYSTIC_UI_PANEL_TOGGLER_HEIGHT                      32.f
#define MYSTIC_UI_PANEL_HEIGHT_DEFAULT                      100.f
#define MYSTIC_UI_PANEL_HEIGHT_MIN                          20.f
#define MYSTIC_UI_PANEL_HEIGHT_MAX                          120.f

#define MYSTIC_UI_PANEL_BORDER                  2
#define MYSTIC_UI_PANEL_OFFSETY                       10.f
#define MYSTIC_UI_PANEL_OPENINSET                     10.f
#define MYSTIC_UI_PANEL_CLOSEDINSET                   10.f

#define MYSTIC_UI_PANEL_HEIGHT_SMALL                        65.f
#define MYSTIC_UI_PANEL_HEIGHT_MED                          82.f
#define MYSTIC_UI_PANEL_HEIGHT_BLEND                        82.f
#define MYSTIC_UI_PANEL_HEIGHT_FILTER                       70.f
#define MYSTIC_UI_PANEL_HEIGHT_COLORS                       75.f


#define MYSTIC_UI_PANEL_HEIGHT_LABEL                        92.f
#define MYSTIC_UI_PANEL_HEIGHT_SLIDER                       62.f
#define MYSTIC_UI_PANEL_HEIGHT_SLIDER_SMALL                 40.f
#define MYSTIC_UI_PANEL_HEIGHT_MORE                         75.f
#define MYSTIC_UI_PANEL_HEIGHT_FONT                         50.f
#define MYSTIC_UI_PANEL_HEIGHT_FONTSTYLE                    80.f
#define MYSTIC_UI_PANEL_HEIGHT_SHAPE                        70.f
#define MYSTIC_UI_PANEL_HEIGHT_FONTSIZE                     44.f
#define MYSTIC_UI_PANEL_HEIGHT_MOVE                         44.f
#define MYSTIC_UI_PANEL_HEIGHT_LAYER                        90.f
#define MYSTIC_UI_PANEL_HEIGHT_LAYER_COLOR_OVERLAY          90.f
#define MYSTIC_UI_PANEL_HEIGHT_POTIONS                      99.f

#define MYSTIC_UI_PANEL_HEIGHT_FONT_TABS                    80.f

#define MYSTIC_UI_PANEL_HEIGHT_SETTINGS                     140.f
#define MYSTIC_UI_PANEL_HEIGHT_SETTINGS_TABS                86.f
#define MYSTIC_UI_PANEL_HEIGHT_SKETCH_TABS                  60.f

#define MYSTIC_UI_PANEL_HEIGHT_SETTINGS_SLIDER              70.f


#define MYSTIC_UI_CONTROLS_TILEWIDTH_SMALL                  56.0f
#define MYSTIC_UI_CONTROLS_TILEWIDTH_NORMAL                 68.0f
#define MYSTIC_UI_CONTROLS_TILEWIDTH_MED                    78.0f
#define MYSTIC_UI_CONTROLS_TILEWIDTH_BIG                    88.0f
#define MYSTIC_UI_CONTROLS_TILEWIDTH_HUGE                   100.0f
#define MYSTIC_UI_CONTROLS_TILEWIDTH_FONT                   80.0f
#define MYSTIC_UI_CONTROLS_TILEWIDTH_SHAPE                  80.f
#define MYSTIC_UI_CONTROLS_TILEWIDTH_LAYER                  90.0f
#define MYSTIC_UI_CONTROLS_TILEWIDTH_BLEND                  68.0f
#define MYSTIC_UI_CONTROLS_TILEWIDTH_LAYER_COLOR_OVERLAY    90.0f
#define MYSTIC_UI_CONTROLS_TILEWIDTH_COLOR                  40.0f
#define MYSTIC_UI_CONTROLS_TILEWIDTH_POTIONS                MYSTIC_UI_PANEL_HEIGHT_POTIONS



#define MYSTIC_UI_PANEL_CONTENT_TRANSITION_TIME_IN    0.2f
#define MYSTIC_UI_PANEL_CONTENT_TRANSITION_TIME_OUT   0.07f

#define MYSTIC_UI_PANEL_TABBAR_TITLE_FONTSIZE               10.f

#define MYSTIC_UI_PANEL_TABBAR_INSET_TOP                    6.f
#define MYSTIC_UI_PANEL_TABBAR_INSET_BOTTOM                 3.f
#define MYSTIC_UI_PANEL_TABBAR_INSET_LEFT                   10.f
#define MYSTIC_UI_PANEL_TABBAR_INSET_RIGHT                  10.f
#define MYSTIC_UI_PANEL_TABBAR_FONT_INSET_LEFT              0.f
#define MYSTIC_UI_PANEL_TABBAR_FONT_INSET_RIGHT             0.f
#define MYSTIC_UI_PANEL_TABBAR_SHAPE_INSET_LEFT              0.f
#define MYSTIC_UI_PANEL_TABBAR_SHAPE_INSET_RIGHT             0.f

#define MYSTIC_UI_PANEL_SPACING                             0.f
#define MYSTIC_UI_PANEL_BG_ALPHA                            0.8f
#define MYSTIC_UI_PANEL_HEIGHT_BIG                          120.f

#define MYSTIC_UI_PANEL_BOTTOMBAR_HEIGHT              55.0f
#define MYSTIC_UI_PANEL_BOTTOMBAR_HEIGHT_SMALL        50.f
#define MYSTIC_UI_PANEL_SEGMENTS_HEIGHT               32.f
#define MYSTIC_UI_PANEL_SEGMENTS_OFFSETY              1.0f
#define MYSTIC_UI_PANEL_TOGGLE_HEIGHT                 8.f
#define MYSTIC_UI_PANEL_TOGGLE_WIDTH                  14.f


#define MYSTIC_UI_SEGMENT_WIDTH_PADDING                     13.f
#define MYSTIC_UI_SEGMENT_WIDTH_PADDING_IMAGE               13.f
#define MYSTIC_UI_SEGMENT_WIDTH_PADDING_LAST                13.f
#define MYSTIC_UI_SEGMENT_TEXTSIZE                          12.f

#define MYSTIC_UI_TOPIC_CORNER_RADIUS                       6.0f
#define MYSTIC_UI_TOPIC_BORDERWIDTH                         1.0f
#define MYSTIC_UI_TOPIC_FONTSIZE                            30.f

#define MYSTIC_UI_GALLERY_IMAGE_BORDER                14.0f

#define MYSTIC_UI_BOTTOMBAR_HEIGHT_SMALL                    86.f
#define MYSTIC_UI_BOTTOMBAR_HEADER_HEIGHT_SLIDER            45.f

#define MYSTIC_UI_TOOLBAR_HEIGHT_PADDING                    6.f
#define MYSTIC_UI_TOOLBAR_MARGIN                            12.0f
#define MYSTIC_UI_TOOLBAR_NOMARGIN                          -15.0f
#define MYSTIC_UI_TOOLBAR_NOMARGIN_LEFT                     -15.0f
#define MYSTIC_UI_TOOLBAR_NOMARGIN_RIGHT                    -15.0f


#define MYSTIC_UI_NAVBAR_FONTSIZE                           14.f
//#define MYSTIC_UI_NAVBAR_FONTSIZE                           18.f

#define kHuePickerHeight                                    22
#define kColorPickerSpacing                                 11
#define kColorPickerHueArrowsSize                           7

#define MYSTIC_UI_LABEL_BTN_PADDING_X                       11.f
#define MYSTIC_UI_LABEL_BTN_HEIGHT                          27.f
#define MYSTIC_UI_LABEL_BTN_BORDER                    1.5f
#define MYSTIC_UI_LABEL_BTN_BORDER_RADIUS                   6.f
#define MYSTIC_UI_MENU_LABEL_FONTSIZE                       11.f
#define MYSTIC_UI_MENU_LABEL_FONTSIZE_SMALL                 10.5f

#define MYSTIC_UI_LABEL_BTN_CHAR_SPACE                      2.2f
#define MYSTIC_UI_LABEL_BTN_CHAR_SPACE_SMALL                1.8f
#define MYSTIC_UI_LABEL_BOTTOM_BAR_BRUSH                    10.f

#define MYSTIC_UI_INPUT_MIN_BRIGHT                          .35f


#define MYSTIC_UI_CATEGORY_FONTSIZE                         11.5f
#define MYSTIC_UI_CATEGORY_GET_MORE_FONTSIZE                10.5f
#define MYSTIC_UI_SUBSETTINGS_FONTSIZE                      11.f

#define MYSTIC_UI_COLOR_SLIDER_INDICATOR                    3.f


#define MYSTIC_UI_BOTTOM_HEADER_PADDING                     10.0f
#define MYSTIC_UI_TOOLBAR_HEIGHT                            60.0f
#define MYSTIC_UI_TOOLBAR_SKETCH_HEIGHT                     44.0f
#define MYSTIC_UI_TOOLBAR_ACCESSORY_HEIGHT                  40.f
#define MYSTIC_UI_TABLE_SECTION_HEIGHT                      30.0f
#define MYSTIC_UI_TABLE_SECTION_HEIGHT_TOOLBAR              50.0f

#define MYSTIC_UI_PICKER_HEADER_FONTSIZE                    14.f
#define MYSTIC_UI_PICKER_HEADER_CHAR_SPACING                2.5f

#define MYSTIC_UI_DRAWER_NAV_TOOLBAR_HEIGHT                 60.0f
#define MYSTIC_UI_DRAWER_NAV_TEXTSIZE                       30.0f
#define MYSTIC_UI_DRAWER_NAV_TEXTSIZE_SMALL                 15.0f
#define MYSTIC_UI_DRAWER_CELL_BORDER                        1.f
#define MYSTIC_UI_DRAWER_CELL_CORNER_RADIUS                 6.f

#define MYSTIC_UI_TABBAR_HEIGHT                             60.0f
#define MYSTIC_UI_TABBAR_SHOW_TITLES                        1
#define MYSTIC_UI_TABBAR_TITLE_HEIGHT                       15.f
#define MYSTIC_UI_TABBAR_TITLE_FONTSIZE                     9.f
//#define MYSTIC_UI_TABBAR_TITLE_SPACE_BTWN_ICON              6.0f


#define MYSTIC_UI_SUB_BTN_ICON_OFFSET                       3.f
#define MYSTIC_UI_SUB_BTN_ICON_OFFSET_TOP                   17.f
#define MYSTIC_UI_SUB_BTN_ICON_OFFSET_LEFT                  17.f
#define MYSTIC_UI_SUB_BTN_ICON_OFFSET_BOTTOM                2.f
#define MYSTIC_UI_SUB_BTN_ICON_OFFSET_RIGHT                 17.f
#define MYSTIC_UI_SUB_BTN_ICON_OFFSET_TITLE                 1.f
#define MYSTIC_UI_TABBAR_TITLE_SPACE_BTWN_ICON              6.f

#define MYSTIC_UI_SUBBTN_ADD_OFFSET_TOP                     0
#define MYSTIC_UI_SUBBTN_ADD_OFFSET_BOTTOM                  0
#define MYSTIC_UI_SUBBTN_ADD_OFFSET_LEFT                    0
#define MYSTIC_UI_SUBBTN_ADD_OFFSET_RIGHT                   0


#define MYSTIC_UI_SUB_BTN_ACTIVE_ICON_OFFSET                3.f
#define MYSTIC_UI_SUB_BTN_ACTIVE_ICON_ALPHA                 1.f
#define MYSTIC_UI_SUB_BTN_ACTIVE_CIRCLE_OFFSET              1.0f
#define MYSTIC_UI_SUB_BTN_ACTIVE_CIRCLE_ALPHA               MYSTIC_UI_SUB_BTN_ACTIVE_ICON_ALPHA
#define MYSTIC_UI_SUB_BTN_ACTIVE_CIRCLE_SIZE                2.0f


#define MYSTIC_UI_TAB_BADGE_SIZE                            17.0f
#define MYSTIC_UI_TAB_BADGE_ALPHA                           1.f
#define MYSTIC_UI_TAB_BADGE_OFFSETY                         -2.f
#define MYSTIC_UI_TAB_BADGE_OFFSETX                         4.f
#define MYSTIC_UI_TAB_BADGE_SCALE                           0.8f


#define MYSTIC_UI_SUB_BTN_CORNER_RADIUS                     0.0f
#define MYSTIC_UI_SUB_BTN_HORIZONTAL_SPACING                2.0f
#define MYSTIC_UI_SUB_BTN_COUNT_IPHONE                      5
#define MYSTIC_UI_SUB_BTN_COUNT_IPAD                        10

#define MYSTIC_UI_TABBAR_TABS_SHOWNEXT_COUNT_IPHONE         4.75
#define MYSTIC_UI_TABBAR_TABS_SHOWNEXT_COUNT_IPAD           9.5

#define MYSTIC_UI_SHARE_CELL_LABEL_OFFSET                   6.f
#define MYSTIC_UI_SHARE_CELL_SUBLABEL_OFFSET                15.f

#define MYSTIC_UI_SHARE_BG_BLUR                             0.7
#define MYSTIC_UI_SHARE_BG_BLUR_FRAMES                      9
#define MYSTIC_UI_SHARE_BG_BLUR_FRAMERATE                   33

//#define MYSTIC_UI_SHARE_ANIM_DURATION                       0.2f
//#define MYSTIC_UI_SHARE_ANIM_OUT_DURATION                   MYSTIC_UI_SHARE_ANIM_DURATION
//#define MYSTIC_UI_SHARE_ANIM_BLUR_DURATION                  MYSTIC_UI_SHARE_ANIM_DURATION
//#define MYSTIC_UI_SHARE_ANIM_BLUR_OUT_DURATION              MYSTIC_UI_SHARE_ANIM_DURATION

#define MYSTIC_UI_SHARE_ANIM_DURATION                       0.25f
#define MYSTIC_UI_SHARE_ANIM_OUT_DURATION                   0.25f
#define MYSTIC_UI_SHARE_ANIM_BLUR_DURATION                  0.3f
#define MYSTIC_UI_SHARE_ANIM_BLUR_OUT_DURATION              MYSTIC_UI_SHARE_ANIM_BLUR_DURATION

#define MYSTIC_UI_MENU_HEIGHT                               42.f
#define MYSTIC_UI_SHARE_CELL_HEIGHT                         65.f
#define MYSTIC_UI_SHARE_BUTTONS_TOOLBAR_HEIGHT              MYSTIC_UI_PANEL_BOTTOMBAR_HEIGHT
#define MYSTIC_SHARE_VISIBLE_ROWS                           3.7f


#define MYSTIC_CAM_CONTROLS_BOTTOM_BAR_HEIGHT               108.0f
#define MYSTIC_CAM_CONTROLS_SHUTTER_HEIGHT                  86.0f
#define MYSTIC_CAM_CONTROLS_ALBUM_HEIGHT                    50.0f
#define MYSTIC_CAM_CONTROLS_PASTE_HEIGHT                    50.0f
#define MYSTIC_CAM_CONTROLS_PADDING                         28.0f
#define MYSTIC_CAM_CONTROLS_BUTTON_ALPHA                    0.2f
#define MYSTIC_CAM_CONTROLS_BUTTON_FONTSIZE                 10.0f
#define MYSTIC_CAM_CONTROLS_RADIUS                          15.0f
#define MYSTIC_CAM_CONTROLS_IMAGEVIEW_ALPHA                 0.7f
#define MYSTIC_CAM_CONTROLS_IMAGEVIEW_DURATION              0.3f
#define MYSTIC_CAM_CONTROLS_EXPANDABLE_BUTTON_VERT_PADDING  5.0f


#define MYSTIC_SHAPE_START_WIDTH                            200.0f
#define MYSTIC_SHAPE_START_HEIGHT                           200.0f


#define MYSTIC_RESIZEABLE_IMAGEVIEW_SCALE                   2.0f

#define MYSTIC_BARBUTTON_SIZE_WIDTH                         40.0f
#define MYSTIC_BARBUTTON_SIZE_HEIGHT                        40.0f



#define MYSTIC_WEAR_MAX                                     1.0f
#define MYSTIC_WEAR_MIN                                     -1.0f
#define MYSTIC_WEAR_DEFAULT                                 0.0f


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define LOG_EXPR(_X_) do{\
 	__typeof__(_X_) _Y_ = (_X_);\
 	const char * _TYPE_CODE_ = @encode(__typeof__(_X_));\
 	NSString *_STR_ = VTPG_DDToStringFromTypeAndValue(_TYPE_CODE_, &_Y_);\
 	if(_STR_)\
 		NSLog(@"%s = %@", #_X_, _STR_);\
 	else\
 		NSLog(@"Unknown _TYPE_CODE_: %s for expression %s in function %s, file %s, line %d", _TYPE_CODE_, #_X_, __func__, __FILE__, __LINE__);\
 }while(0)


#endif


