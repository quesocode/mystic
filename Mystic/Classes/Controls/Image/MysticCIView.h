//
//  MysticCIView.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/18/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "MysticCommon.h"

@protocol MysticCIViewProtocol <NSObject>

@required

@property (nonatomic, strong) id filters;

- (UIImage *) updateFilters:(BOOL)andDisplay save:(BOOL)save;

@end

typedef enum {
    MysticCITypeUnknown,
    MysticCITypeSpotColor,
    MysticCITypeSpotLight,
    
} MysticCIType;

@interface MysticCIView : UIView
{
    @private
    GLKView *_previewView;
    CIContext *_ciContext;
    EAGLContext *_eaglContext;
    CGRect _previewViewBounds;


}
@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) id filters;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) float sourceImageScale;

+ (Class) classForCIType:(MysticCIType)type;

- (void) setup;
- (UIImage *) display;
- (UIImage *) display:(BOOL)save;
- (UIImage *) drawFilter:(id)filter save:(BOOL)save;
- (CIImage *) filter:(id)filterOrFilters source:(CIImage *)sourceImage;

@end
