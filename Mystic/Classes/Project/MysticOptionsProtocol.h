//
//  MysticOptionsProtocol.h
//  Mystic
//
//  Created by Travis on 10/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#ifndef Mystic_MysticOptionsProtocol_h
#define Mystic_MysticOptionsProtocol_h

@class MysticOptions;

@protocol MysticOptionsDelegate <NSObject>

@optional

- (void)options:(MysticOptions *)options downloaded:(NSUInteger)totalDownloaded expectedSize:(long long)expectedSize;

@end


#endif
