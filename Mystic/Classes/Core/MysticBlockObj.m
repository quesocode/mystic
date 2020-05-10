//
//  MysticBlockObj.m
//  Mystic
//
//  Created by Me on 3/25/14.
//  Copyright (c) 2014 Blackpulp. All rights reserved.
//

#import "MysticBlockObj.h"

@implementation MysticBlockObj

@synthesize block=_block;
@synthesize blockObject=_blockObject, blockBOOL=_blockBOOL;
@synthesize key=_key;

+ (id) objectWithKey:(NSString *)theKey block:(MysticBlock)ablock;
{
    MysticBlockObj *obj = [[[self class] alloc] init];
    obj.key = theKey ? theKey : [NSString stringWithFormat:@"%@-%p", [obj class], obj];
    obj.block = ablock;
    return [obj autorelease];
}

+ (id) objectWithKey:(NSString *)theKey blockObject:(MysticBlockObject)ablock;
{
    MysticBlockObj *obj = [[[self class] alloc] init];
    obj.key = theKey ? theKey : [NSString stringWithFormat:@"%@-%p", [obj class], obj];
    obj.blockObject = ablock;
    return [obj autorelease];
}
+ (id) objectWithKey:(NSString *)theKey blockObjObj:(MysticBlockObjObj)ablock;
{
    MysticBlockObj *obj = [[[self class] alloc] init];
    obj.key = theKey ? theKey : [NSString stringWithFormat:@"%@-%p", [obj class], obj];
    obj.blockObjectObject = ablock;
    return [obj autorelease];
}

+ (id) objectWithKey:(NSString *)theKey blockBOOL:(MysticBlockBOOL)ablock;
{
    MysticBlockObj *obj = [[[self class] alloc] init];
    obj.key = theKey ? theKey : [NSString stringWithFormat:@"%@-%p", [obj class], obj];
    obj.blockBOOL = ablock;
    return [obj autorelease];
}
- (void) dealloc;
{
    Block_release(_blockBOOL);
    Block_release(_block);
    Block_release(_blockObject);
    Block_release(_blockObjectObject);

    Block_release(_buttonBlock);
    [_key release];
    [super dealloc];
}


@end

@implementation MysticImageBlockObj

+ (id) imageDone:(MysticBlockObjObj)aBlock;
{
    return [self objectWithKey:nil blockObjObj:aBlock];
}
+ (id) save:(UIImage *)image done:(MysticBlockObjObj)aBlock;
{
    MysticImageBlockObj *obj = [self imageDone:aBlock];
    [obj save:image];
    return obj;
}

- (void) save:(UIImage *)image;
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void) image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(id)context;
{
    if(self.blockObjectObject)
    {
        self.blockObjectObject(error, self);
        self.blockObjectObject = nil;
    }
}
@end