//
//  MysticDrawTypeView.h
//  Mystic
//
//  Created by Me on 12/12/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticDrawLayerView.h"

@interface MysticDrawTypeView : MysticDrawLayerView
@property (nonatomic, assign) BOOL redrawText;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) MysticAttrString *attributedText, *scaledAttributedText;
- (void) setAttributedText:(MysticAttrString *)attributedText rebuild:(BOOL)rebuild;
+ (CGRect) boundsForContent:(id)content target:(CGSize)targetSize context:(MysticDrawingContext **)_context scale:(CGFloat)scale;

@end
