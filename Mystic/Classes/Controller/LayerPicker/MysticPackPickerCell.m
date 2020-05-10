//
//  MysticPackPickerCell.m
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticPackPickerCell.h"
#import "Mystic.h"
#import "NSAttributedString+Attributes.h"
#import "UIImageView+WebCache.h"
#import "MysticPackPickerItem.h"

#define MYSTIC_PAX_LABEL_PADDING                            22.f
#define MYSTIC_PAX_HIGHLIGHT_ALPHA                          1.f
#define MYSTIC_PAX_DEFAULT_IMG_ALPHA                        0.2f

#define MYSTIC_PAX_SPEC_TITLE_FONTSIZE                      31.f
#define MYSTIC_PAX_TITLE_FONTSIZE                           22.f
#define MYSTIC_PAX_SPEC_SUBTITLE_FONTSIZE                   12.f
#define MYSTIC_PAX_SUBTITLE_FONTSIZE                        12.f
#define MYSTIC_PAX_SPEC_LINE_SPACE                          1.0f
#define MYSTIC_PAX_LINE_SPACE                               1.8f

@interface MysticPackPickerCell ()

@property (nonatomic, assign) CGFloat titleFontSize, subTitleFontSize, imageViewAlpha, activeImageViewAlpha, currentImageViewAlpha;
@property (nonatomic, assign) BOOL isSpecial, isFeatured, isFeaturedOrSpecial, hasCustomControlImage, applyVignette;
@property (nonatomic, assign) UIColor *activeBackgroundColor, *normalBackgroundColor;
@property (nonatomic, assign) MysticObjectType packType;
@property (nonatomic, assign) NSInteger itemIndex;
@property (nonatomic, retain) NSString *titleColorStr, *subTitleColorStr;
@property (nonatomic, assign) MysticColorType defaultBackgroundColorType, customBackgroundColorType;


@end


@implementation MysticPackPickerCell

@dynamic titleLabel, title;

- (void) dealloc;
{
    [_titleColorStr release];
    [_subTitleColorStr release];
    [super dealloc];
}
- (void) commonStyle;
{
    [super commonStyle];
    self.isSpecial = NO;
    self.applyVignette = YES;
    self.packType = MysticObjectTypeUnknown;
    self.defaultBackgroundColorType = MysticColorTypeCollectionSectionBackground;
    self.backgroundColor = [UIColor color:self.defaultBackgroundColorType];

    self.titleFontSize = MYSTIC_PAX_TITLE_FONTSIZE;
    self.subTitleFontSize = MYSTIC_PAX_SUBTITLE_FONTSIZE;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.backgroundColor = [UIColor clearColor];
    self.backgroundView = imgView;
    [imgView release];

    imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView = imgView;
    [imgView release];
    

    CGRect labelFrame = CGRectInset(self.bounds, MYSTIC_PAX_LABEL_PADDING, MYSTIC_PAX_LABEL_PADDING);
    labelFrame.size.height = 50;
    labelFrame.origin.y = self.bounds.size.height - labelFrame.size.height - MYSTIC_PAX_LABEL_PADDING;
    OHAttributedLabel *label = [[OHAttributedLabel alloc] initWithFrame:labelFrame];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    label.backgroundColor = [UIColor clearColor];
    self.titleLabel = [label autorelease];
    [self.contentView addSubview:self.titleLabel];
    
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = /*[UIColor color:MysticColorTypeJournalCellTitle] */ [UIColor hex:@"d1ccc7"];
    self.titleLabel.centerVertically = YES;
    self.clipsToBounds = YES;
}
- (UIImageView *) normalImageView;
{
    return (id)self.backgroundView;
}
- (UIImageView *) selectedImageView;
{
    return (id)self.selectedBackgroundView;
}
- (BOOL)isFeaturedOrSpecial;
{
    return self.isFeatured || self.isSpecial;
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.isFeatured = NO;
    self.isSpecial = NO;
    self.applyVignette = YES;
    self.titleLabel.text = @"";
    self.normalImageView.image = nil;
    self.selectedImageView.image = nil;
    self.hasCustomControlImage = NO;
    [self.normalImageView cancelCurrentImageLoad];

}

- (void) setPackType:(MysticObjectType)packType;
{
    _packType = packType;
    switch (_packType)
    {
        case MysticObjectTypeFrame:
        case MysticObjectTypeBadge:
        case MysticObjectTypeText:
        {
            if(self.hasCustomControlImage)
            {
                self.normalImageView.contentMode = UIViewContentModeScaleAspectFill;
            }
            else
            {
                self.normalImageView.contentMode = UIViewContentModeScaleAspectFit;
            }
            break;
        }
        case MysticObjectTypeLight:
        case MysticObjectTypeTexture:
        {
            if(!self.hasCustomControlImage)
            {
                self.normalImageView.contentMode = UIViewContentModeScaleToFill;
            }
            self.hasCustomControlImage=YES;
            break;
        }
        default:
        {
            self.normalImageView.contentMode = UIViewContentModeScaleAspectFill;
            break;
        }
    }
    self.selectedImageView.contentMode = self.normalImageView.contentMode;
}


- (CGFloat) activeImageViewAlpha;
{
    CGFloat a = 1;
    switch (self.packType) {
        case MysticObjectTypeLight:
        case MysticObjectTypeTexture:
            a = self.isFeaturedOrSpecial ? 1 : 0.4;
            break;
            
        default:
            a = MYSTIC_PAX_HIGHLIGHT_ALPHA;
            break;
    }
    return a;
}
- (CGFloat) currentImageViewAlpha;
{
    return self.selected || self.highlighted ? self.activeImageViewAlpha : self.imageViewAlpha;
    
}

- (CGFloat) imageViewAlpha;
{
    CGFloat a = 1;
    switch (self.packType) {
        case MysticObjectTypeLight:
        case MysticObjectTypeTexture:
            a = self.isFeaturedOrSpecial ? 1 : 0.6;
            break;
            
        default:
            a = self.hasCustomControlImage ? 1 : MYSTIC_PAX_DEFAULT_IMG_ALPHA;
            break;
    }
    return a;
}

- (UIColor *) normalBackgroundColor;
{
    switch (self.packType) {
        case MysticObjectTypeLight:
        case MysticObjectTypeTexture:
//            return [[UIColor hex:@"6b625e"] darker:0.3];
            
        default: break;
    }
    
    
    UIColor *c =  self.hasCustomControlImage || self.isFeatured ? [UIColor color:self.defaultBackgroundColorType] : [[UIColor color:self.customBackgroundColorType] darker:0.5];

    return c;
}
- (UIColor *) activeBackgroundColor;
{
    return [UIColor color:MysticColorTypePink];
}


- (void) setHighlighted:(BOOL)highlighted;
{

    [super setHighlighted:highlighted];


}
- (void) setSelected:(BOOL)selected;
{
    [super setSelected:selected];
//    self.imageView.alpha = self.imageViewAlpha;
    if(!selected)
    {
        [self didDeselect:nil];
    }
}

- (NSString *) subTitleColorStr;
{
    NSString *subColStr = _subTitleColorStr;
    if(!subColStr && self.isFeaturedOrSpecial)
    {
        subColStr = [[UIColor color:MysticColorTypePink] hexStringWithoutHash];
    }
    else if(!subColStr)
    {
        switch (self.packType) {
            case MysticObjectTypeLight:
            case MysticObjectTypeTexture:
                //subColStr = @"3b3b3b";
                break;
                
            default: break;
        }
    }
    return subColStr;
}

- (void) setTitle:(NSString *)title; { [self setTitle:title subtitle:nil]; }
- (void) setTitle:(NSString *)title subtitle:(NSString *)subtitle;
{
//    title = [title uppercaseString];
//    subtitle = [subtitle uppercaseString];
    NSString *_title = title && subtitle ? [title stringByAppendingFormat:@"\n%@", subtitle] : title;
    NSInteger strLength = [_title length];
    NSInteger titleLength = [title length];
    NSInteger subTitleLength = [subtitle length];
    NSInteger diffLength = strLength - titleLength - subTitleLength;
    NSInteger subTitleStart = titleLength+diffLength;
    NSRange strRange = NSMakeRange(0, strLength);
    NSRange titleRange = NSMakeRange(0, titleLength);
    NSRange subTitleRange = NSMakeRange(subTitleStart, subTitleLength);
    
    
    NSMutableAttributedString *str = [NSMutableAttributedString attributedStringWithString:NSLocalizedString(_title, nil) ];
//    [str setCharacterSpacing:1.8];
    [str setFont:(self.isSpecial ? [MysticFont gothamXLight:self.titleFontSize] : [MysticFont gothamBook:self.titleFontSize]) range:titleRange];
    [str setFont:(self.isSpecial ? [MysticFont gothamMedium:self.subTitleFontSize] : [MysticFont gothamMedium:self.subTitleFontSize]) range:subTitleRange];

    UIColor *tColor = [UIColor hex:@"d1ccc7"];
    
    NSString *subColStr = self.subTitleColorStr;
    
    
    if(!self.titleColorStr && !subColStr)
    {
        [str setTextColor:tColor range:strRange];
    }
    else
    {
        if(self.titleColorStr)
        {
            tColor = [UIColor string:self.titleColorStr];
        }
        
        [str setTextColor:tColor range:titleRange];
        
        
        tColor = [UIColor hex:@"d1ccc7"];
        if(subColStr)
        {
            tColor = [UIColor string:subColStr];
        }
        
        [str setTextColor:tColor range:subTitleRange];

        
    }

//    [str setTextColor:[UIColor color:MysticColorTypeJournalCellTitle] range:strRange];



    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    [style setLineSpacing:self.isFeaturedOrSpecial ? MYSTIC_PAX_SPEC_LINE_SPACE : MYSTIC_PAX_LINE_SPACE];
    [str addAttribute:NSParagraphStyleAttributeName
                value:style
                range:strRange];
    
    
    
    self.titleLabel.attributedText = str;
    self.titleLabel.centerVertically = YES;
    [style release];
    [self setNeedsLayout];
}



- (void) setCollectionItem:(MysticPackPickerItem *)collectionItem;
{
    __block MysticPackPickerCell *weakSelf = [self retain];
    self.hasCustomControlImage = collectionItem.pack.hasCustomControlImageURL;
    self.packType = collectionItem.pack.groupType;
    self.isSpecial = collectionItem.pack.isSpecial;
    self.isFeatured = collectionItem.pack.featuredPack;
    self.itemIndex = collectionItem.indexPath.item;
    if(!self.isSpecial && collectionItem.pack.featuredPack && collectionItem.indexPath.item == 0)
    {
        self.isSpecial = YES;
    }
    self.applyVignette = !self.isSpecial;
    self.titleColorStr = collectionItem.pack.titleColorStr;
    self.subTitleColorStr = collectionItem.pack.subTitleColorStr;
    MysticColorType controlColorType = MysticColorTypeControlBackground1 + self.itemIndex;
    controlColorType = controlColorType >= MysticColorTypeLastChoice ? (controlColorType - MysticColorTypeLastChoice) + MysticColorTypeControlBackground1 : controlColorType;
    
    self.defaultBackgroundColorType = collectionItem.pack.featuredPack ? MysticColorTypeCollectionFeaturedSectionBackground : MysticColorTypeCollectionSectionBackground;
    self.customBackgroundColorType = controlColorType;
    if(self.isSpecial)
    {
        NSNumber *fs = [MysticSettings settingForKey:[NSString stringWithFormat:@"%@_special_title_fontsize", MysticObjectTypeKey(collectionItem.pack.groupType)] default:@(MYSTIC_PAX_SPEC_TITLE_FONTSIZE)];
        if(fs)
        {
            self.titleFontSize = [fs floatValue];
        }
        
        NSNumber *sfs = [MysticSettings settingForKey:[NSString stringWithFormat:@"%@_special_subtitle_fontsize", MysticObjectTypeKey(collectionItem.pack.groupType)] default:@(MYSTIC_PAX_SPEC_SUBTITLE_FONTSIZE)];
        if(sfs)
        {
            self.subTitleFontSize = [sfs floatValue];
        }
    }
    else
    {
        self.titleFontSize = MYSTIC_PAX_TITLE_FONTSIZE;
        self.subTitleFontSize = MYSTIC_PAX_SUBTITLE_FONTSIZE;
    }

    [self setTitle:collectionItem.title subtitle:collectionItem.subtitle];
    

    NSURL *thumbURL = collectionItem.thumbnailURL;

//    ALLog(@"set collection item", @[@"item", @(self.itemIndex),
//                                    @"pack", collectionItem.pack.name,
//                                    @"thumb", MObj(thumbURL),
//                                    @"has custom", MBOOL(self.hasCustomControlImage),
//                                    @"normal bg", self.normalBackgroundColor.hexString,
//                                    ]);
    if(thumbURL)
    {
        [self.normalImageView cancelCurrentImageLoad];
        [self.normalImageView setImageWithURL:thumbURL placeholderImage:nil options:0 manager:MysticCache.uiManager progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

//        [self.normalImageView setImageWithURL:thumbURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
            [weakSelf setupBackgroundViews:image];
            
            [weakSelf release];
            
            
            
        }];
    }
    else
    {
        [weakSelf release];
    }
    self.backgroundColor = self.normalBackgroundColor;

    
}

- (void) setupBackgroundViews:(UIImage *)image;
{
    self.imageView.image = image;
    /*
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.normalBackgroundColor setFill];
    CGContextFillRect(context, self.bounds);
    
    
    
    CGRect drawRect = CGRectWithContentMode(CGRectSize(image.size), self.bounds, self.normalImageView.contentMode);

    
    BOOL applyVin = self.applyVignette;
    if(self.hasCustomControlImage)
    {
        [image drawInRect:drawRect blendMode:kCGBlendModeNormal alpha:self.imageViewAlpha];

    }
    else
    {
        CGBlendMode bMode = kCGBlendModeLuminosity;
        switch (self.packType) {
            case MysticObjectTypeFrame:
            case MysticObjectTypeBadge:
            case MysticObjectTypeText:
                drawRect = MysticPositionRect(drawRect, self.bounds, MysticPositionRight);
                drawRect = UIEdgeInsetsInsetRect(drawRect, UIEdgeInsetsMake(7, -20, 7, 0));
                bMode = kCGBlendModeScreen;
                applyVin = NO;
                break;
                
            default:
                applyVin = NO;
                break;
        }
        [image drawInRect:drawRect blendMode:bMode alpha:self.imageViewAlpha];
    }
    
    if(applyVin)
    {
        [[UIImage imageNamed:@"pack_overlay.png"] drawInRect:self.bounds blendMode:kCGBlendModeNormal alpha:0.2];
    }
    
    UIImage *normalImg = UIGraphicsGetImageFromCurrentImageContext();
    self.normalImageView.image = normalImg;
    
    
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [self.activeBackgroundColor setFill];
    CGContextFillRect(context, self.bounds);
    
    CGBlendMode bMode = kCGBlendModeSoftLight;
    switch (self.packType) {
        case MysticObjectTypeText:

            bMode = kCGBlendModeScreen;
            
            break;
            
        default: break;
    }
    [image drawInRect:drawRect blendMode:bMode alpha:self.activeImageViewAlpha];
    

    
    UIImage *activeImg = UIGraphicsGetImageFromCurrentImageContext();
    
    self.selectedImageView.image = activeImg;

    
    UIGraphicsEndImageContext();
    */
}


- (void) didDeselect:(MysticBlockObjBOOL)selectBlock; {     [self didSelect:selectBlock animated:YES]; }
- (void) didSelect:(MysticBlockObjBOOL)selectBlock; {       [self didSelect:selectBlock animated:YES]; }
- (void) didSelect:(MysticBlockObjBOOL)selectBlock animated:(BOOL)animated;
{
    BOOL __selected = self.selected;
    __unsafe_unretained __block MysticBlockObjBOOL __selectBlock = selectBlock ? Block_copy(selectBlock) : nil;
    __unsafe_unretained __block MysticPackPickerCell *weakSelf = self;
    
//    ALLog(@"didSelect", @[@"item", @(self.itemIndex),
//                          @"selected", MBOOL(__selected),
//                          @"background", MObj(self.background),
//                          @"bg alpha", @(self.background.alpha)]);

    MysticBlock animBlock = ^{

        if(!__selected && weakSelf.overlayView)
        {
            weakSelf.overlayView.alpha = 0;
        }
        else if(weakSelf.overlayView)
        {
            weakSelf.overlayView.alpha = 1;
        }
    };
    
    MysticBlockBOOL finishedBlock = ^(BOOL finished) {
        if(__selectBlock)
        {
            __selectBlock(self, __selected); Block_release(__selectBlock);
        }
    };
    
    if(animated)
    {
        [MysticUIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animBlock completion:finishedBlock];
    }
    else
    {
        animBlock();
        finishedBlock(YES);
    }
    
}

- (void) layoutSubviews;
{
    [super layoutSubviews];
    CGRect insetRect = CGRectInset(self.bounds, MYSTIC_PAX_LABEL_PADDING, MYSTIC_PAX_LABEL_PADDING);
    CGRect labelRect = insetRect;
    labelRect.size.height = self.titleFontSize+self.subTitleFontSize+10;
    labelRect.origin.y = insetRect.origin.y + insetRect.size.height - labelRect.size.height;
    self.titleLabel.frame = labelRect;
    self.normalImageView.frame = self.bounds;
}




//
//- (void) drawRect:(CGRect)rect;
//{
//    [super drawRect:rect];
//    if(self.shouldDraw)
//    {
////        ALLog(@"drawing cell", @[@"image", ILogStr(self.imageView.image),
////                                 @"selected", MBOOL(self.selected),
////                                 @"highlighted", MBOOL(self.highlighted),
////                                 @"background", MObj(self.background),
////                                 @"imageViewAlpha", @(self.imageViewAlpha),
////                                 ]);
//        
//        
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        [self.activeBackgroundColor setFill];
//        CGContextFillRect(context, rect);
//        
//        //return;
//        if(self.imageView.image)
//        {
//            if(self.selected || self.highlighted)
//            {
////                [self.activeBackgroundColor setFill];
////                CGContextFillRect(context, self.imageView.frame);
//                [self.imageView.image drawInRect:self.imageView.frame blendMode:kCGBlendModeLuminosity alpha:self.imageViewAlpha];
//                
//            }
//            else
//            {
//                
//                [self.imageView.image drawInRect:self.imageView.frame blendMode:kCGBlendModeLuminosity alpha:self.imageViewAlpha];
//                
//            }
//            
//            
//        }
//    }
//}


@end
