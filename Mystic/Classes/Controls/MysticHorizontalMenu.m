//
//  MysticHorizontalMenu.m
//  Mystic
//
//  Created by Me on 2/4/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticHorizontalMenu.h"
#import <QuartzCore/QuartzCore.h>

@interface MysticHorizontalMenu () <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger lastCurrentPage;
@property (nonatomic, readonly) CGSize buttonSize;
@property (nonatomic, retain) MysticScrollView *scrollView;


@end

@implementation MysticHorizontalMenu


@synthesize count, currentIndex=_currentIndex, items=_items, leftButton=_leftButton, rightButton=_rightButton, scrollView=_scrollView, delegate=_delegate, font=_font, lastCurrentPage=_lastCurrentPage;

- (void) dealloc;
{
    [super dealloc];
    [_scrollView release];
    [_items release];
    [_leftButton release];
    [_rightButton release];
    [_font release];
    _currentIndex = NSNotFound;
}
- (id)initWithFrame:(CGRect)frame items:(NSArray *)menuItems;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
        self.items = menuItems ? menuItems : [NSArray array];
    }
    return self;
}

- (void) commonInit;
{
    _lastCurrentPage = NSNotFound;
    _currentIndex = NSNotFound;
    self.tag = MysticViewTypeButtonMenu;
    self.font = [MysticUI gothamLight:14];
    
    __unsafe_unretained __block MysticHorizontalMenu *weakSelf = self;
    MysticButton *btn = [MysticButton backButton:^(id sender) {
       
        [weakSelf previous];
        
        
    }];
    self.leftButton = btn;
    
    btn = [MysticButton forwardButton:^(id sender) {
        
        [weakSelf next];
        
        
    }];
    
    self.rightButton = btn;
    
//
//    CGRect sFrame = CGRectSize(self.buttonSize);
//    sFrame.origin.x = self.leftButton ? self.leftButton.frame.origin.x + self.leftButton.frame.size.width : 0;
    MysticScrollView *sview = [[MysticScrollView alloc] initWithFrame:self.bounds];
    self.scrollView = sview;
    [sview release];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.tileSize = self.buttonSize;
    [self addSubview:self.scrollView];
    [self sendSubviewToBack:self.scrollView];
}

- (NSInteger) count;
{
    return _items.count;
}

- (void) setItems:(NSArray *)items;
{
    MysticButton *button;
    if(_items)
    {
        [_items release], _items=nil;
    }
    
    _items = [items retain];
    
    if(_items.count)
    {
        _currentIndex = 0;
    }
    for (button in self.scrollView.subviews) {
        if([button isKindOfClass:[MysticButton class]])
        {
            [button removeFromSuperview];
        }
    }

    int i = 0;
    for (NSDictionary *buttonInfo in _items) {
        
        
        button = [self buttonForIndex:i];
        [self.scrollView addSubview:button];
        self.scrollView.contentSize = CGSizeMake(button.frame.origin.x + button.frame.size.width, button.frame.size.height);
        i++;
    }
    
    self.leftButton.enabled = NO;
    self.rightButton.enabled = _items.count > 0;
    
    [self gotoIndex:_currentIndex];
    
}

- (NSDictionary *) itemAtIndex:(NSInteger) index;
{
    
    return index < _items.count ?  [_items objectAtIndex:index] : nil;
}

- (void) setLeftButton:(MysticButton *)newButton;
{
    if(_leftButton)
    {
        [_leftButton removeFromSuperview];
        [_leftButton release], _leftButton=nil;
    }
    if(newButton)
    {
        CGRect bFrame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
        newButton.imageEdgeInsets = UIEdgeInsetsMake(13, 4, 13, 4);
        MysticImage *img = [MysticImage image:@(MysticIconTypeBack) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeHorizontalNavButton]];
        [newButton setImage:img forState:UIControlStateNormal];
        img = [MysticImage image:@(MysticIconTypeBack) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeHorizontalNavButtonDisabled]];
        [newButton setImage:img forState:UIControlStateDisabled];
        newButton.frame = bFrame;
        newButton.adjustsImageWhenDisabled = NO;
        [self addSubview:newButton];
        _leftButton = [newButton retain];
    }
}
- (void) setRightButton:(MysticButton *)newButton;
{
    if(_rightButton)
    {
        [_rightButton removeFromSuperview];
        [_rightButton release], _rightButton=nil;
    }
    if(newButton)
    {
        CGRect bFrame = CGRectMake(self.bounds.size.width - self.bounds.size.height, 0, self.bounds.size.height, self.frame.size.height);
        newButton.imageEdgeInsets = UIEdgeInsetsMake(13, 4, 13, 4);
        MysticImage *img = [MysticImage image:@(MysticIconTypeForward) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeHorizontalNavButton]];
        [newButton setImage:img forState:UIControlStateNormal];
        img = [MysticImage image:@(MysticIconTypeForward) size:CGSizeMake(MYSTIC_NAVBAR_ICON_WIDTH, MYSTIC_NAVBAR_ICON_HEIGHT) color:[UIColor color:MysticColorTypeHorizontalNavButtonDisabled]];
        [newButton setImage:img forState:UIControlStateDisabled];
        newButton.frame = bFrame;
        newButton.adjustsImageWhenDisabled = NO;
        [self addSubview:newButton];
        _rightButton = [newButton retain];
    }
}
- (MysticButton *) buttonForIndex:(NSInteger)index;
{
    NSDictionary *buttonInfo = [_items objectAtIndex:index];
    
    NSString *title = [buttonInfo objectForKey:@"title"] ? [buttonInfo objectForKey:@"title"] : [@"Menu " stringByAppendingFormat:@"%d", (int)index+1];
    
    
    MysticButton *button = [MysticButton buttonWithTitle:title target:self sel:@selector(buttonTouched:)];
    [button setTitleColor:[UIColor color:MysticColorTypeHorizontalText] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor color:MysticColorTypeHorizontalTextSelected] forState:UIControlStateSelected];

    button.titleLabel.font = self.font;
    button.frame = [self frameForButtonAtIndex:index];
    button.tag = MysticViewTypeButtonMenuItem + index;
    
    return button;
}

- (CGRect) frameForButtonAtIndex:(NSInteger)index;
{
    CGRect bFrame = CGRectSize(self.buttonSize);
    
    bFrame.origin.x = index * bFrame.size.width;
    
    return bFrame;
}
- (CGSize) buttonSize;
{
    CGSize bSize = self.scrollView.bounds.size;
//    if(self.leftButton)
//    {
//        bSize.width -= self.leftButton.frame.size.width;
//    }
//    if(self.rightButton)
//    {
//        bSize.width -= self.rightButton.frame.size.width;
//    }
    return bSize;
    
}

- (void) buttonTouched:(MysticButton *)sender;
{
    int index = sender.tag - MysticViewTypeButtonMenuItem;
    [self gotoIndex:index];
    if(self.delegate && [self.delegate respondsToSelector:@selector(mysticHorizontalMenu:buttonTouchedAtIndex:)])
    {
        [self.delegate mysticHorizontalMenu:self buttonTouchedAtIndex:index];
    }
}

- (void) next;
{
    int i = self.currentIndex + 1;
    
    [self gotoIndex:i];
}
- (void) previous;
{
    int i = self.currentIndex - 1;
    
    [self gotoIndex:i];
}
- (void) gotoIndex:(NSInteger)index;
{
    index = MAX(0, index);
    index = MIN(index, self.count-1);
    MysticButton *button;
    
    for (button in self.buttons) {
        button.selected = NO;
    }
    
    button = (MysticButton *)[self.scrollView viewWithTag:MysticViewTypeButtonMenuItem + index];
    if(button)
    {
        button.selected = YES;
        [self.scrollView scrollRectToVisible:button.frame animated:YES];
    }
    
    self.currentIndex = index;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(mysticHorizontalMenu:indexChanged:)])
    {
        [self.delegate mysticHorizontalMenu:self indexChanged:index];
    }
    
}

- (void) setCurrentIndex:(NSInteger)currentIndex;
{
    _currentIndex = currentIndex;
    self.leftButton.enabled = _currentIndex > 0;
    self.rightButton.enabled = _currentIndex < self.count - 1;

}

- (NSArray *)buttons;
{
    MysticButton *button;
    NSMutableArray *b = [NSMutableArray array];
    for (button in self.scrollView.subviews) {
        if([button isKindOfClass:[MysticButton class]])
        {
            [b addObject:button];
        }
    }
    return b;
}

//- (void) scrollViewDidScroll:(UIScrollView *)scrollView;
//{
//    MysticScrollView *scroller = (id)scrollView;
//    MysticButton *button;
//    for (button in self.buttons) {
//        button.selected = NO;
//    }
//    
//    NSInteger cp = scroller.currentPage;
//    if(cp != self.lastCurrentPage && cp != self.currentIndex)
//    {
//        [self gotoIndex:cp];
//    }
//    self.lastCurrentPage = cp;
//    
//    
//}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    MysticScrollView *scroller = (id)scrollView;
    MysticButton *button;

    NSInteger cp = scroller.currentPage;
    if(cp != self.lastCurrentPage && cp != self.currentIndex)
    {
        [self gotoIndex:cp];
    }
    
    self.lastCurrentPage = cp;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
