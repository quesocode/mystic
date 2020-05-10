//
//  ILTunePickerView.h
//  Mystic
//
//  Created by Travis A. Weerts on 4/4/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "ILRGBPickerView.h"


@interface ILTunePickerView : ILRGBPickerView

@property (nonatomic, assign) MysticTune tune;
@property (nonatomic, assign) MysticThreshold threshold,originalThreshold;

@end
