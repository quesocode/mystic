//
//  MysticRecipeProjectAboutView.h
//  Mystic
//
//  Created by travis weerts on 8/19/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
@class PackPotionOptionRecipe;

@interface MysticRecipeProjectAboutView : UIScrollView

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) OHAttributedLabel *textView;
- (void) setImageURL:(NSString *)url;
- (void) setRecipe:(PackPotionOptionRecipe *)recipe;

@end
