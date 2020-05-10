//
//  MysticCollectionView.m
//  Mystic
//
//  Created by Me on 10/15/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticCollectionView.h"

@implementation MysticCollectionView

- (void) setContentInset:(UIEdgeInsets)contentInset;
{
    if(contentInset.top >= 60)
    {
        contentInset.top = 0;

        
        
    }
    
    
    [super setContentInset:contentInset];
    
}

@end
