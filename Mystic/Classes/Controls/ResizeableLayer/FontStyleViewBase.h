//
//  FontStyleViewBase.h
//  Mystic
//
//  Created by Me on 3/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerView.h"
#import "PackPotionOptionFontStyle.h"
#import "MysticResizeableLabelOld.h"

@interface FontStyleViewBase : MysticResizeableLabelOld

@property (nonatomic, retain) NSString *authorText;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) BOOL adjustsFontSizeToFitWidth;
@property (nonatomic, readonly) NSArray *lines, *words, *textLines;
@property (nonatomic, readonly) NSString *longestWord;
@property (nonatomic, assign) CGFloat lineHeight, actualLineHeight, lineHeightScale;
@property (nonatomic, assign) NSTextAlignment textAlignment;


- (void) applyOptionsFrom:(id <MysticLayerViewAbstract>)layerView;
- (void) update;

@end
