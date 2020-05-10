//
//  MysticSpotColorView.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/18/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "MysticCIView.h"

@interface MysticSpotColorView : MysticCIView <MysticCIViewProtocol>

@property (nonatomic, strong) UIColor *oldColor, *color, *oldColor2, *color2, *oldColor3, *color3;
@property (nonatomic, assign) BOOL makeMask, useMedian;
@property (nonatomic, assign) int mode;
@property (nonatomic, assign) float closeness, closeness2, closeness3, contrast, contrast2, contrast3, noise, sharpness, bias;
- (void) nextMode;

@end
