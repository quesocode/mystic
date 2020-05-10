//
//  WDBrush.h
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2011-2013 Steve Sprang
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "WDCoding.h"
#import "WDProperty.h"
#import "WDStampGenerator.h"

@interface WDBrush : NSObject <NSCopying, WDCoding, WDPropertyDelegate, WDGeneratorDelegate> {
@private
}

@property (nonatomic, strong) WDStampGenerator *generator;
@property (nonatomic, retain) UIImage *noise;

@property (nonatomic, retain) WDProperty *weight;             // [1.0, 512.0] -- pixels
@property (nonatomic, retain) WDProperty *intensity;          // [0.0, 1.0]

@property (nonatomic, retain) WDProperty *angle;              // [0.0, 1.0];
@property (nonatomic, retain) WDProperty *spacing;            // [0.01, 2.0] -- percentage of brush width
@property (nonatomic, retain) WDProperty *rotationalScatter;  // [0.0, 1.0]
@property (nonatomic, retain) WDProperty *positionalScatter;  // [0.0, 1.0]

@property (nonatomic, retain) WDProperty *angleDynamics;     // [-1.0, 1.0]
@property (nonatomic, retain) WDProperty *weightDynamics;     // [-1.0, 1.0]
@property (nonatomic, retain) WDProperty *intensityDynamics;  // [-1.0, 1.0]

@property (nonatomic, retain) UIImage *strokePreview;
@property (nonatomic, readonly) float radius;

@property (nonatomic, retain) NSString *uuid;

+ (WDBrush *) primaryBrush;
+ (WDBrush *) secondaryBrush;


+ (WDBrush *) randomBrush;

+ (WDBrush *) brushWithGenerator:(WDStampGenerator *)generator;
- (id) initWithGenerator:(WDStampGenerator *)generator;

- (UIImage *) previewImageWithSize:(CGSize)size;

- (NSUInteger) numberOfPropertyGroups;
- (NSArray *) propertiesForGroupAtIndex:(NSUInteger)ix;
- (NSArray *) allProperties;

- (void) restoreDefaults;

@end

extern NSString *WDBrushPropertyChanged;
extern NSString *WDBrushGeneratorChanged;
extern NSString *WDBrushGeneratorReplaced;
