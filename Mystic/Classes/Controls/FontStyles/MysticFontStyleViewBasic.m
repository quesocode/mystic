//
//  MysticFontStyleViewBasic.m
//  Mystic
//
//  Created by Me on 10/19/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticFontStyleViewBasic.h"
#import "MysticFontStyleLabelView.h"
#import "MysticCGLabel.h"

@implementation MysticFontStyleViewBasic


- (CGFloat) lineHeightScale;
{
    CGFloat l = self.option.lineHeightScale;
    l = l==NSNotFound ? MYSTIC_DEFAULT_RESIZE_LABEL_LINEHEIGHT_SCALE : l;
    return l;
}

- (void) updateWithEffect:(MysticLayerEffect)effect;
{
    [super updateWithEffect:effect];
//  
//    
//    CGFloat padding = 10;
//    
//    CGFloat x = self.contentBounds.origin.x;
//    CGFloat y = self.contentBounds.origin.y;
//    
//    CGFloat theHeight = self.lineHeight;
//    
//    y = (y + self.contentBounds.size.height/2) - theHeight/2;
//    
//    self.color = self.option.color;
    
//    CGRect labelRect = CGRectMake(x, y, self.contentBounds.size.width, self.lineHeight);
    
    
//    labelRect = CGRectApplyAffineTransform(labelRect, CGAffineTransformMakeScale(2, 2));
    
//    MysticFontStyleLabelView *label = [[MysticFontStyleLabelView alloc] initWithFrame:labelRect];
//    MysticCGLabel *label = [[MysticCGLabel alloc] initWithFrame:labelRect];

//    label.fdAutoFitMode = FDAutoFitModeContrainedFrame;
//    label.userInteractionEnabled = NO;
//    label.numberOfLines = 1;
//    label.transform = CGAffineTransformMakeScale(0.5, 0.5);
//    label.font = self.font;
//    label.text = self.text;
//    MBorder(label, nil, 1);
//    [self addSubview:label];
//    self.contentView = label;
//    [label release];
//    labelRect.origin.y += self.lineHeight + padding;
}

- (void) applyOptionsFrom:(MysticFontStyleViewBasic *)layerView;
{
//    MysticFontStyleViewBasic *clonedLayer = layerView;
//    self.option = clonedLayer.option;
//    self.font = clonedLayer.font;
//    self.fontSize = clonedLayer.fontSize;
//    self.label.textAlignment = clonedLayer.label.textAlignment;
//    self.lineHeight = clonedLayer.lineHeight;
//    self.textSpacing = clonedLayer.textSpacing;
//    self.rotation = clonedLayer.rotation;
//    self.text = clonedLayer.text;
//    self.color = clonedLayer.color;
//    self.alpha = clonedLayer.alpha;
}

@end
