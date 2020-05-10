//
//  MysticTextField.m
//  Mystic
//
//  Created by Travis A. Weerts on 10/15/15.
//  Copyright © 2015 Blackpulp. All rights reserved.
//

#import "MysticHiddenTextField.h"
#import "UIColor+Mystic.h"

@implementation MysticHiddenTextField

- (instancetype) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.keyboardAppearance = UIKeyboardAppearanceDark;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.spellCheckingType = UITextSpellCheckingTypeYes;
        self.tintColor = [UIColor color:MysticColorTypePink];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
