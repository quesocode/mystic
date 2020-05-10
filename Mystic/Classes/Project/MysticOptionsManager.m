//
//  MysticOptions.m
//  Mystic
//
//  Created by travis weerts on 8/21/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticOptionsManager.h"
#import "MysticPreloaderImage.h"
#import "MysticEffectsManager.h"
#import "MysticController.h"
#import "NSArray+Mystic.h"
#import <CommonCrypto/CommonDigest.h>

@interface MysticOptionsManager ()
{
    NSMutableArray *_passes;
    NSInteger _currentPass;
    NSInteger __numberOfPasses;
}


@end
@implementation MysticOptionsManager

@dynamic delegate;
@synthesize pass=_pass, hasMultiplePasses, isLastPass, hasAnotherPass=_hasAnotherPass, numberOfOptionsPerPass=_numberOfOptionsPerPass;

+ (id) managerWithOptions:(MysticOptions *)theOptions;
{
    MysticOptionsManager *manager = [[self class] managerWithOptions:theOptions passes:nil];
    
    return manager;
}

+ (id) managerWithOptions:(MysticOptions *)theOptions passes:(NSArray *)passes;
{
    BOOL needsRender = theOptions.needsRender;
    MysticOptionsManager *manager = [MysticOptionsManager duplicate:theOptions];
    manager.numberOfOptionsPerPass = [passes isKindOfClass:[NSNumber class]] ? [(NSNumber *)passes intValue] : MYSTIC_PROCESS_LAYERS_PER_PASS;
    if(passes && ![passes isKindOfClass:[NSNumber class]]) {
        DLog(@"uses passes: %@", passes);
        [manager usePasses:passes];
    }
    manager.needsRender = needsRender;
    return manager;
}
- (void) dealloc;
{
    
    [_passes release];
    [super dealloc];
}


- (id) init;
{
    self = [super init];
    if(self)
    {
        
        self.index = 999;
        _ignoreOptionsWithoutInput = YES;
        _numberOfOptionsPerPass = MYSTIC_PROCESS_LAYERS_PER_PASS;
        _currentPass = 0;
        __numberOfPasses = NSNotFound;
    }
    return self;
}

- (void) resetManager;
{
//    DLog(@"reset manager");
    __numberOfPasses = NSNotFound;
    [_passes release], _passes = nil;
    _currentPass = 0;
    
}
+ (id) duplicate:(MysticOptions *)optionsSource;
{
    MysticOptionsManager *manager = [super duplicate:optionsSource];
    manager.settings |= MysticRenderOptionsManager;
    return manager;
}

- (BOOL) hasMultiplePasses;
{
    return self.numberOfPasses > 1;
    
}
- (BOOL) hasAnotherPass;
{
    return _currentPass < self.numberOfPasses;
}


- (NSInteger) numberOfPasses;
{
    return [self numberOfPassesWithMax:self.numberOfOptionsPerPass];
}
- (NSInteger) numberOfPassesWithMax:(NSInteger)max;
{
    if(__numberOfPasses != NSNotFound) return __numberOfPasses;
    
//    NSInteger c = self.sortedOptionsCount;
    NSInteger passCount = 0;
    NSArray *opts = [self sortedRenderOptions];
    NSInteger c = opts.count;
    if(c > (max+1))
    {
        NSInteger inputsInPass = 1;
        for (PackPotionOption *option in opts)
        {
            if(!self.ignoreOptionsWithoutInput || (option.hasInput && !option.ignoreActualRender)) inputsInPass++;
            
            if(inputsInPass >= max)
            {
                inputsInPass = 1;
                passCount++;
            }
        }
    }
    __numberOfPasses = MAX(1,passCount);
    
//    NSInteger n = c < 1 || c == max ? 1 : (int)ceil((float)c/(float)max);
    
    return __numberOfPasses;
    
}
- (NSInteger) nextPassIndex;
{
    return _currentPass;
}
- (void) increment;
{
    _currentPass++;
}
- (MysticOptions *) currentPass;
{
    MysticOptions *n = [self.passes objectAtIndex:_currentPass];
        _currentPass++;
        return n;
    
}
- (MysticOptions *) nextPass;
{
    MysticOptions *n=nil;
    
    
    if(_currentPass >= self.numberOfPasses) return nil;
    n = [self.passes objectAtIndex:_currentPass];
    _currentPass++;
    
    return n;
}
- (NSArray *) passes;
{
    if(_passes) return _passes;
    _passes = [[NSMutableArray alloc] initWithArray:[self passesWithMax:self.numberOfOptionsPerPass]];
    return _passes;
}

- (NSInteger) sortedOptionsCount;
{
    NSArray *opts = [self sortedRenderOptions];
    return opts.count;
}

- (NSArray *) passesWithMax:(NSInteger)max;
{
    NSMutableArray *passes = [NSMutableArray array];
    NSInteger offset = 0;
    int i = 0;
    BOOL isLast = NO;
    NSArray *opts = [self sortedRenderOptions];
    NSInteger c = opts.count;
    NSInteger totalPasses = self.numberOfPasses;
    NSString *newTagPrefix = [NSString stringWithString:self.tagPrefix ? self.tagPrefix : @""];
//    ALLog(@"making passes", @[@"numberOfOptionsPerPass", @(self.numberOfOptionsPerPass),
//                              @"max options", @(max),
//                              @"total passes", @(totalPasses+1),
//                              
//                              @"inputs", @(self.numberOfInputs),
//                              @"-",
//                              @"options count", @(c),
//                              @"opts array", @(opts.count),
//                              @"-", @"opts", opts,
//                              ]);
    
    
    for (i=0; i<totalPasses; i++) {
//        NSInteger len = remainder - 1;
        
        if(offset >= c) break;
        isLast = i == (totalPasses - 1);
        
        MysticOptions *subObj = [[MysticOptions alloc] init];
        subObj.tagPrefix = newTagPrefix;
        subObj.index = i;
        subObj.passIndex = i;
        subObj.manager = self;
        subObj.settings = self.settings;
        subObj.settings |= isLast ? MysticRenderOptionsPassLast : MysticRenderOptionsPass;
        if(!isLast) subObj.settings |= MysticRenderOptionsClearFiltersOnComplete;
        subObj.settings = subObj.settings & ~MysticRenderOptionsManager;
        subObj.size = self.size;
        

        NSMutableArray *subOptsArray = [NSMutableArray array];
        NSInteger inputsInPass = 1;
        NSInteger subCount = 0;
        for (int x = offset; x < c; x++) {
            PackPotionOption *option = [opts objectAtIndex:x];
            [subOptsArray addObject:option];
            if(!self.ignoreOptionsWithoutInput || (option.hasInput && !option.ignoreActualRender)) {
                inputsInPass++;
            }
            subCount++;
            
            if(inputsInPass >= max) break;
        }
//        ALLog([NSString stringWithFormat: @"pass #%@",  @(i)], @[
//                         @"offset", @(offset),
//                         @"subOpts", MObj(subOptsArray),
//                         ]);
        [subObj addOptions:subOptsArray];
        [passes addObject:subObj];
        offset += subCount;
        newTagPrefix = subObj.tag;
        [subObj release];

    }
    
//    ALLog(@"finished making passes:", @[@"passes", @(passes.count),
//                                        @"passes", passes,
//                                        @"offset", @(offset),
//                                        ]);
 
    
    return passes;
}

- (void) usePasses:(NSArray *)thePasses;
{
    if(_passes) [_passes release], _passes=nil;
    __numberOfPasses = thePasses ? thePasses.count : NSNotFound;
    _currentPass = 0;
    _passes = thePasses ? [[NSMutableArray arrayWithArray:thePasses] retain] : nil;
    if(_passes)
    {
        int i = 0;
        BOOL isLast = NO;
        NSString *newTagPrefix = [NSString stringWithString:self.tagPrefix ? self.tagPrefix : @""];

        
        for (i=0; i<__numberOfPasses; i++) {
            isLast = i == (__numberOfPasses - 1);
            MysticOptions *subObj = [_passes objectAtIndex:i];
            subObj.tagPrefix = newTagPrefix;
            subObj.index = i;
            subObj.passIndex = i;
            subObj.manager = self;
            subObj.settings = self.settings;
            subObj.settings |= isLast ? MysticRenderOptionsPassLast : MysticRenderOptionsPass;
            if(!isLast) subObj.settings |= MysticRenderOptionsClearFiltersOnComplete;
            subObj.settings = subObj.settings & ~MysticRenderOptionsManager;
            subObj.size = self.size;
            newTagPrefix = subObj.tag;
            
          
        }
    }
}

- (void) enable:(MysticRenderOptions)newOption;
{
    [super enable:newOption];
    for (MysticOptions *pass in self.passes) {
        [pass enable:newOption];
    }
}

- (void) disable:(MysticRenderOptions)newOption;
{
    [super disable:newOption];
    for (MysticOptions *pass in self.passes) {
        [pass disable:newOption];
    }
}

@end
