//
//  MysticFontStyleView1.m
//  Mystic
//
//  Created by Me on 3/11/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticFontStyleView1.h"
#import "MysticFontStyleLabelView.h"

@implementation MysticFontStyleView1



- (CGFloat) lineHeightScale;
{
    CGFloat l = self.option.lineHeightScale;
    l = l==NSNotFound ? MYSTIC_DEFAULT_RESIZE_LABEL_LINEHEIGHT_SCALE : l;
    return l;
}

- (void) updateWithEffect:(MysticLayerEffect)effect;
{
    [super updateWithEffect:effect];
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    CGFloat padding = 10;
    
    CGFloat x = self.contentBounds.origin.x;
    CGFloat y = self.contentBounds.origin.y;
    NSArray *theLines = self.lines;
    
    CGFloat theHeight = (self.lineHeight * theLines.count) + (padding * (theLines.count-1));
    
    y = (y + self.contentBounds.size.height/2) - theHeight/2;
    
    
    CGRect labelRect = CGRectMake(x, y, self.contentBounds.size.width, self.lineHeight);
    for (NSArray *line in theLines) {
        MysticFontStyleLabelView *label = [[MysticFontStyleLabelView alloc] initWithFrame:labelRect];
        label.fdAutoFitMode = FDAutoFitModeContrainedFrame;
        label.numberOfLines = 1;
        label.font = self.font;
        label.text = [line componentsJoinedByString:@""];
        [self addSubview:label];
        [label release];
        labelRect.origin.y += self.lineHeight + padding;
    }
}


@end
