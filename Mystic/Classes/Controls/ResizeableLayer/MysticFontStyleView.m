//
//  MysticFontStyle.m
//  Mystic
//
//  Created by Me on 3/8/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticFontStyleView.h"
#import "Mystic.h"
#import "MysticFontStyleLabelView.h"
#import "MysticQuoteViewController.h"
#import "AppDelegate.h"

@interface MysticFontStyleView () <MysticQuoteViewControllerDelegate>

@property (nonatomic, retain) MysticFontStyleLabelView *label;

@end

@implementation MysticFontStyleView

@dynamic label;

- (void) dealloc;
{
    [super dealloc];
    
}




- (void) setParentView:(UIView *)parentView;
{
    [super setParentView:parentView];
//    _label.debugParentView = parentView;
}
- (void) update;
{
//    self.font = self.option.font;
}




- (void) setFont:(UIFont *)font;
{
    [super setFont:font];
    [self updateWithEffect:self.effect];
    
}


- (void) setText:(NSString *)text;
{
    
    [super setText:text];
    [self updateWithEffect:self.effect];
    
}

- (NSArray *) lines;
{
    NSMutableArray *__lines = [NSMutableArray array];
    NSMutableArray *__line = [NSMutableArray array];
    CGSize lineSize = CGSizeMake(0, 0);
    NSArray *__w = super.words;
    for (int i = 0; i < __w.count; i++) {

        NSString *word = [__w objectAtIndex:i];
        [__line addObject:word];
        CGSize wordSize = [word sizeWithFont:self.font];
        lineSize.height = MAX(lineSize.height, wordSize.height);
        
        lineSize.width += wordSize.width;
//        ALLog(@"word", @[@"word", word, @"word size", SLogStr(wordSize), @"line size", SLogStr(lineSize), @"bounds", SLogStr(self.contentBounds.size)]);

        if(lineSize.width >= self.contentBounds.size.width)
        {
            [__lines addObject:__line];
            __line = [NSMutableArray array];
            lineSize = CGSizeZero;
        }
        else if(i == __w.count - 1)
        {
            [__lines addObject:__line];
        }
        
        

    }
    return __lines;
}







- (void) doubleTapped;
{
    [super doubleTapped];

    __unsafe_unretained __block MysticFontStyleView *weakSelf = self;

//    MysticQuoteViewController *quoteController = [[MysticQuoteViewController alloc] initWithQuote:self.text author:self.authorText];
//    quoteController.delegate = self;
//    
//    
//    [[AppDelegate instance].window.rootViewController presentViewController:quoteController animated:YES completion:^{
//    }];
//    
//    [quoteController release];
    

}

- (void) quoteViewController:(MysticQuoteViewController *)controller didChooseQuote:(id)quote;
{
    self.text = [[(MysticChoice *)quote attributedString] string];
    
    [[AppDelegate instance].window.rootViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void) quoteViewControllerDidCancel:(MysticQuoteViewController *)controller;
{
    [[AppDelegate instance].window.rootViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
