//
//  MysticLayerTypeView.h
//  Mystic
//
//  Created by Me on 12/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticLayerBaseView.h"
#import "MysticLayerViewAbstract.h"
#import "MysticDrawTypeView.h"

@interface MysticLayerTypeView : MysticLayerBaseView <MysticLayerViewAbstract>

@property (nonatomic, retain) NSString *text, *subText;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) CGFloat lineHeight, lineHeightScale, textSpacing, fontSize, lineSpacing;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) MysticDrawTypeView *drawView;
@property (nonatomic, retain) MysticAttrString *attributedText;
@property (nonatomic, readonly) MysticAttrString *attributedTextRastered;
@property (nonatomic, retain) MysticDrawingContext *rasteredAttrStringDrawContext;
+ (MysticAttrString *) attributedText:(NSString *)str layer:(MysticLayerTypeView *)layer;

@end
