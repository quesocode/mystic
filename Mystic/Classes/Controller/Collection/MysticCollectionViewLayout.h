//
//  MysticCollectionViewLayout.h
//  Mystic
//
//  Created by Me on 5/6/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MysticCollectionViewLayoutDelegate<UICollectionViewDelegateFlowLayout>
@optional
- (BOOL)shouldStickHeaderToTopInSection:(NSUInteger)section;
- (BOOL)shouldHeaderDragInSection:(NSUInteger)section;
- (BOOL)shouldShowFooterOnStart:(NSUInteger)section;
- (BOOL)shouldHideFooterOnScroll:(NSUInteger)section;
- (BOOL)shouldHideHeaderOnScroll:(NSUInteger)section;
- (BOOL)shouldShowHeaderOnStart:(NSUInteger)section;
@end

@interface MysticCollectionViewLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CGFloat sectionHeaderTopBorderWidth;
@end
