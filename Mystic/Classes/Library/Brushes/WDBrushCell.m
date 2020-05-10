//
//  WDBrushCell.m
//  Brushes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2013 Steve Sprang
//

#import "WDBrush.h"
#import "WDBrushCell.h"
#import "WDCellSelectionView.h"
#import "MysticUtility.h"
#import "MysticFont.h"

@implementation WDBrushCell

@synthesize preview;
//@synthesize size;
//@synthesize editButton;
@synthesize brush;
@synthesize table;
@synthesize previewDirty;
- (BOOL) showsReorderControl; { return NO; }

- (void) awakeFromNib
{
    WDCellSelectionView *selectionView = [[WDCellSelectionView alloc] init];
    self.selectedBackgroundView = selectionView;
    self.indentationWidth = 0;
    self.preservesSuperviewLayoutMargins = NO;
    self.layoutMargins = UIEdgeInsetsZero;
    self.separatorInset = UIEdgeInsetsZero;
    self.number.font = [MysticFont gothamMedium:11];
    self.number.highlightedTextColor = [UIColor colorWithRed:0.41 green:0.36 blue:0.33 alpha:1.00];
    [super awakeFromNib];
}


- (void) brushChanged:(NSNotification *)aNotification
{
    [self setNeedsLayout];
    self.previewDirty = YES;
    
//    WDProperty *prop = [aNotification userInfo][@"property"];
//    if (prop && prop == brush.weight) {
//        size.text = [NSString stringWithFormat:@"%d px", (int) brush.weight.value];
//    }
}

- (void) setBrush:(WDBrush *)inBrush
{
    if (brush == inBrush) {
        return;
    }
    
    brush = inBrush;

    CGSize previewSize = preview.bounds.size;
//    previewSize.height *=.7;
    preview.image = [brush previewImageWithSize:previewSize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushChanged:) name:WDBrushPropertyChanged object:brush];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushChanged:) name:WDBrushGeneratorChanged object:brush];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brushChanged:) name:WDBrushGeneratorReplaced object:brush];
    
//    size.text = [NSString stringWithFormat:@"%d px", (int) brush.weight.value];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) disclose:(id)sender
{
    [table.delegate tableView:table accessoryButtonTappedForRowWithIndexPath:[table indexPathForCell:self]];
}

- (void) layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = self.contentView.frame;
    // make sure our width doesn't get smaller if the reorder view is made visible
    frame.size.width = CGRectGetWidth(self.superview.frame);
    self.contentView.frame = frame;
    CGPoint cntr = self.number.center;
    cntr.y = frame.size.height/2;
    self.number.center = cntr;
    if (self.previewDirty) {
        CGSize previewSize = preview.bounds.size;
//        previewSize.height *=.7;
        preview.image = [brush previewImageWithSize:previewSize];
        self.previewDirty = NO;
    }
    self.number.highlighted = self.selected;
}

- (void) setHighlighted:(BOOL)highlighted;
{
    [super setHighlighted:NO];
}
- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
{
    [super setHighlighted:NO animated:animated];
}
- (void) setSelected:(BOOL)selected;
{
    UIImageView *iv = (UIImageView *)self.editingAccessoryView;
    iv.highlighted = selected;
    [super setSelected:selected];
    self.number.highlighted = selected;

}
- (void) setSelected:(BOOL)selected animated:(BOOL)animated;
{
    UIImageView *iv = (UIImageView *)self.editingAccessoryView;
    iv.highlighted = selected;
    [super setSelected:selected animated:animated];
    self.number.highlighted = selected;

}
- (void) setDraggingSelected:(BOOL)draggingSelected;
{
    _draggingSelected=draggingSelected;
    self.highlighted = _draggingSelected;
    self.selected = _draggingSelected;
}

@end
