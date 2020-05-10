//
//  MysticPageControl.h
//  Mystic
//
//  Created by Me on 11/14/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticButton.h"
#import "Mystic.h"

@class MysticPageControl;

@protocol MysticPageControlDelegate <NSObject>

@optional
- (void) pageControlDidChangePage:(MysticPageControl *)pageControl page:(NSInteger)pageNumber;
- (void) pageControlDidChangePageCount:(MysticPageControl *)pageControl count:(NSInteger)numberOfPages;


@end




@interface MysticPageControl : MysticButton

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, readonly) NSInteger previousPage;
@property (nonatomic, readonly) NSInteger nextPage;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) BOOL hidesOnEmpty;
@property (nonatomic, assign) CGSize pageDotSize;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) id<MysticPageControlDelegate> delegate;
@property (nonatomic, retain) UIColor *bgColor;
- (id)initWithNumberOfPages:(NSInteger)pageCount;
- (CGSize) sizeForNumberOfPages:(NSInteger)pageCount;

- (NSInteger) gotoFirstPage;
- (NSInteger) gotoLastPage;

- (NSInteger) gotoNextPage;
- (NSInteger) gotoPreviousPage;
- (NSInteger) gotoPage:(NSInteger)pageNumber;

- (UIColor *) dotColorForPage:(NSInteger)page;




@end
