//
//  MysticShaderConstants.h
//  Mystic
//
//  Created by travis weerts on 7/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticVertexConstants.h"

#ifndef Mystic_MysticShaderConstants_h
#define Mystic_MysticShaderConstants_h



typedef enum MysticShaderKey {
    MysticShaderKeyUnknown                      = -1,
    MysticShaderKeyMain                         = 0,
    MysticShaderKeyControlOutput                = 1,
    MysticShaderKeyOutColor                     = 2,
    MysticShaderKeyInColor                      = 3,
    MysticShaderKeyFragColor                    = 4,
    MysticShaderKeyPrefixInOut                  = 5,
    MysticShaderKeyPrefixPreviousOutputColor    = 6,
    MysticShaderKeyPrefixMain                   = 7,
    MysticShaderKeyUniformMain                  = 8,
    MysticShaderKeyMains                        = 9,
    MysticShaderKeyMainIndex                    = 10,
    MysticShaderKeyMainIndexSub                 = 11,
    MysticShaderKeyMainIndexTexture             = 12,
    
    MysticShaderKeyVertexPosition               = 13,
    MysticShaderKeyVertexMain                   = 14,
    MysticShaderKeyVertexMainClose              = 15,
    MysticShaderKeyVertexGLPosition             = 16,
    
    MysticShaderKeyUniformMainCoord             = 50,
    
    MysticShaderKeyVertexTransform              = 100,
    MysticShaderKeyVertexTransform2              = 101,
    MysticShaderKeyVertexTransform3              = 102,
    MysticShaderKeyVertexTransform4              = 103,
    MysticShaderKeyVertexTransform5              = 104,
    MysticShaderKeyVertexTransform6              = 105,
    MysticShaderKeyVertexTransform7              = 106,
    MysticShaderKeyVertexTransform8              = 107,

    MysticShaderKeyVertexTxtCoordinate          = 120,
    MysticShaderKeyVertexTxtCoordinate2          = 121,
    MysticShaderKeyVertexTxtCoordinate3          = 122,
    MysticShaderKeyVertexTxtCoordinate4          = 123,
    MysticShaderKeyVertexTxtCoordinate5          = 124,
    MysticShaderKeyVertexTxtCoordinate6          = 125,
    MysticShaderKeyVertexTxtCoordinate7          = 126,
    MysticShaderKeyVertexTxtCoordinate8          = 127,

    
    
    MysticShaderKeyVertexInputCoordinate        = 140,
    MysticShaderKeyVertexInputCoordinate2        = 141,
    MysticShaderKeyVertexInputCoordinate3        = 142,
    MysticShaderKeyVertexInputCoordinate4        = 143,
    MysticShaderKeyVertexInputCoordinate5        = 144,
    MysticShaderKeyVertexInputCoordinate6        = 145,
    MysticShaderKeyVertexInputCoordinate7        = 146,
    MysticShaderKeyVertexInputCoordinate8        = 147,

    
    MysticShaderKeyVertexTxtCoordinateValue     = 200,
    MysticShaderKeyVertexTxtCoordinateValue2    = 201,
    MysticShaderKeyVertexTxtCoordinateValue3    = 202,
    MysticShaderKeyVertexTxtCoordinateValue4    = 203,
    MysticShaderKeyVertexTxtCoordinateValue5    = 204,
    MysticShaderKeyVertexTxtCoordinateValue6    = 205,
    MysticShaderKeyVertexTxtCoordinateValue7    = 206,
    MysticShaderKeyVertexTxtCoordinateValue8    = 207,
    MysticShaderKeyVertexTxtCoordinateValue9    = 208,
    
    
    MysticShaderKeyIntensity                    = 300,


} MysticShaderKey;

typedef enum MysticShaderLayerLevel {
    MysticShaderLayerLevel1,
    MysticShaderLayerLevel2,
    MysticShaderLayerLevel3,
    MysticShaderLayerLevel4,
    MysticShaderLayerLevel5,
    MysticShaderLayerLevel6,
    MysticShaderLayerLevel7,
    MysticShaderLayerLevel8,
    MysticShaderLayerLevel9,
    MysticShaderLayerLevel10
} MysticShaderLayerLevel;

extern NSString * const MysticShaderMainsTemplate;
extern NSString * const MysticShaderMainsTextureTemplate;
extern NSString * const MysticShaderMainsTextureTemplatePreviousCoord;

extern NSString * const kMysticShaderOutputColor;

#pragma mark -
#pragma mark Colors

extern NSString * const MysticShaderColorWhite;
extern NSString * const MysticShaderColorBlack;
extern NSString * const MysticShaderColorGreen;
extern NSString * const MysticShaderColorCyan;
extern NSString * const MysticShaderColorMagenta;
extern NSString * const MysticShaderColorBlue;
extern NSString * const MysticShaderColorRed;
extern NSString * const MysticShaderColorYellow;
extern NSString * const MysticShaderColorW;

#pragma mark -
#pragma mark Header

extern NSString *const MysticShaderHeader;


#pragma mark -
#pragma mark Filters
extern NSString * const MysticShaderControlOutput;
extern NSString * const MysticShaderColorBalance;
extern NSString * const MysticShaderBrightness;
extern NSString * const MysticShaderGamma;
extern NSString * const MysticShaderExposure;
extern NSString * const MysticShaderTiltShift;
extern NSString * const MysticShaderHaze;
extern NSString * const MysticShaderContrast;
extern NSString * const MysticShaderSharpness;
extern NSString * const MysticShaderShadows;
extern NSString * const MysticShaderHighlights;
extern NSString * const MysticShaderLevels;
extern NSString * const MysticShaderUnsharpMask;
extern NSString * const MysticShaderVignette;
extern NSString * const MysticShaderTemperature;
extern NSString * const MysticShaderSaturation;





#pragma mark -
#pragma mark Prefixes



#pragma mark -
#pragma mark Blends




#pragma mark -
#pragma mark Functions

extern NSString * const MysticShaderLum;
extern NSString * const MysticShaderClipColor;
extern NSString * const MysticShaderSetLum;
extern NSString * const MysticShaderSat;
extern NSString * const MysticShaderMid;
extern NSString * const MysticShaderSetSat;


#pragma mark -
#pragma mark Headers

extern NSString * const MysticShaderMain;

extern NSString * const MysticShaderOne;
extern NSString * const MysticShaderTwo;
extern NSString * const MysticShaderThree;
extern NSString * const MysticShaderFour;
extern NSString * const MysticShaderFive;
extern NSString * const MysticShaderSix;
extern NSString * const MysticShaderSeven;
extern NSString * const MysticShaderEight;

extern NSString * const MysticShaderOneUniform;
extern NSString * const MysticShaderTwoUniform;
extern NSString * const MysticShaderThreeUniform;
extern NSString * const MysticShaderFourUniform;
extern NSString * const MysticShaderFiveUniform;
extern NSString * const MysticShaderSixUniform;
extern NSString * const MysticShaderSevenUniform;
extern NSString * const MysticShaderEightUniform;

#endif
