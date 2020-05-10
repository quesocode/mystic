//
//  MysticJournalBlock.h
//  Mystic
//
//  Created by Me on 3/30/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//


typedef enum {
    MysticJournalBlockTypeUnknown = 0,
    MysticJournalBlockTypeBlock,
    MysticJournalBlockTypeText,
    MysticJournalBlockTypeImage,
    MysticJournalBlockTypeAttributedText,
    MysticJournalBlockTypeLink,
    MysticJournalBlockTypeButton,
    MysticJournalBlockTypeHTML,
    MysticJournalBlockTypeVideo,

    
} MysticJournalBlockType;


#import <Foundation/Foundation.h>
#import "MysticConstants.h"
#import "MysticCollectionItem.h"

@interface MysticJournalBlock : MysticCollectionItem




@end
