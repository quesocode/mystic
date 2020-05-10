//
//  WDLabel.h
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2008-2013 Steve Sprang
//

#import <UIKit/UIKit.h>
#import "MysticBlurBackgroundView.h"


@interface WDLabel : UILabel {

}

@end


@interface MysticMessage : MysticBlurBackgroundView
@property (weak, nonatomic) UILabel *label;
@property (assign, nonatomic) id text;
@end