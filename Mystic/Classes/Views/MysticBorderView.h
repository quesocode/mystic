//
//  MysticBorderView.h
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticView.h"
#import "Mystic.h"

@interface MysticBorderView : MysticView

@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) UIEdgeInsets borderInsets, contentInsets;
@property (nonatomic, assign) BOOL showBorder, drawBorderIntegral;
@property (nonatomic, assign) MysticPosition borderPosition, borderAnchorPosition;
@property (nonatomic, assign) int numberOfDivisions;
@property (nonatomic) BOOL dashed;
@property (nonatomic) CGRect contentBounds;
@property (nonatomic) CGSize dashSize;
@property (nonatomic) CGPoint contentCenter, borderOffset;

+ (CGFloat) borderWidth;



@end
