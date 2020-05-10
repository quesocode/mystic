//
//  LLog.m
//  Mystic
//
//  Created by Travis A. Weerts on 2/3/16.
//  Copyright © 2016 Blackpulp. All rights reserved.
//

#import "LLog.h"
#import "NSString+Mystic.h"
#import "UIColor+Mystic.h"


@interface LLog ()
{
    
}
@property (nonatomic, retain) NSMutableArray *objs;

@end

static id LLogInstance = nil;

@implementation LLog

+ (id) logger;
{
    if(LLogInstance) return LLogInstance;
    LLogInstance = [[[self class] alloc] init];
    return LLogInstance;
}
- (void) dealloc;
{
    if(_objs) [_objs release];
    [super dealloc];
}
- (id) init;
{
    self = [super init];
    self.objs = [NSMutableArray array];
    return self;
}

- (instancetype) space;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[SPACE]];
    return l;
}
- (instancetype) line;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[LINE]];
    return l;
}

- (instancetype) dark;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[kBGd]];
    return l;
}

- (instancetype) light;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[kBGb]];
    return l;
}

- (instancetype) black;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[kBGk]];
    return l;
}
- (instancetype) bg;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[kBG]];
    return l;
}

- (instancetype) set:(id)value;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[kNullKey, value ? value : @"", SPACE]];
    return l;
}

- (instancetype)set:(id)key use:(id)value;
{
    LLog *l = self;
    id o = value;
    if([o isKindOfClass:[UIView class]]) o = VLLogStr(o);
    [l.objs addObjectsFromArray:@[key ? key : @"^", o ? o : @""]];
    return l;
}
- (instancetype)set:(id)key fl:(float)value;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[key ? key : @"^", @(value)]];
    return l;
}
- (instancetype)set:(id)key int:(int)value;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[key ? key : @"^", @(value)]];
    return l;
}
- (instancetype)set:(id)key b:(BOOL)value;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[key ? key : @"^", b(value)]];
    return l;
}
- (instancetype)set:(id)key f:(CGRect)value;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[key ? key : @"^", fpad(value)]];
    return l;
}
- (instancetype)set:(id)key view:(UIView *)value;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[key ? key : @"^", VLLogStr(value)]];
    return l;
}
- (instancetype)set:(id)key s:(CGSize)value;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[key ? key : @"^", s(value)]];
    return l;
}
- (instancetype)set:(id)key p:(CGPoint)value;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[key ? key : @"^", p(value)]];
    
    return l;
}
- (instancetype)set:(id)key sc:(CGScale)value;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[key ? key : @"^", sc(value)]];
    
    return l;
}
- (instancetype)set:(id)key ins:(UIEdgeInsets)value;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[key ? key : @"^", ins(value)]];
    
    return l;
}
- (instancetype)set:(id)key trans:(CGAffineTransform)value;
{
    LLog *l = self;
    [l.objs addObjectsFromArray:@[key ? key : @"^", trans(value)]];
    
    return l;
}
- (instancetype) add:(NSArray *)keyValues;
{
    LLog *l = self;
    if(keyValues && keyValues.count)
    {
        NSMutableArray *a = [NSMutableArray arrayWithCapacity:keyValues.count];
        for (id o in keyValues) {
            if([o isKindOfClass:[UIView class]]) o = VLLogStr(o);
            [a addObject:o];
        }
        [l.objs addObjectsFromArray:a];
    }
    return l;
}

- (instancetype) line:(NSArray *)keyValues;
{
    NSMutableArray *kv = [NSMutableArray arrayWithObject:LINE];
    [kv addObjectsFromArray:keyValues ? keyValues : @[]];
    return [self add:kv];
}
- (instancetype) space:(NSArray *)keyValues;
{
    NSMutableArray *kv = [NSMutableArray arrayWithObject:SPACE];
    [kv addObjectsFromArray:keyValues ? keyValues : @[]];
    return [self add:kv];
}
- (instancetype) bg:(NSArray *)keyValues;
{
    NSMutableArray *kv = [NSMutableArray arrayWithObject:kBG];
    [kv addObjectsFromArray:keyValues ? keyValues : @[]];
    return [self add:kv];
}
- (instancetype) dark:(NSArray *)keyValues;
{
    NSMutableArray *kv = [NSMutableArray arrayWithObject:kBGd];
    [kv addObjectsFromArray:keyValues ? keyValues : @[]];
    return [self add:kv];
}
- (instancetype) light:(NSArray *)keyValues;
{
    NSMutableArray *kv = [NSMutableArray arrayWithObject:kBGb];
    [kv addObjectsFromArray:keyValues ? keyValues : @[]];
    return [self add:kv];
}
- (instancetype) black:(NSArray *)keyValues;
{
    NSMutableArray *kv = [NSMutableArray arrayWithObject:kBGk];
    [kv addObjectsFromArray:keyValues ? keyValues : @[]];
    return [self add:kv];
}
- (instancetype) indent;
{
    int i = self.objs.count - 2;
    if(i<=self.objs.count-1)
    {
        NSString *key = [self.objs objectAtIndex:i];
        [self.objs replaceObjectAtIndex:i withObject:[key prefix:@"\t"]];
    }
    return self;
}
- (instancetype) color:(id)color;
{
    int i = self.objs.count - 2;
    if(i<=self.objs.count-1)
    {
        int i3 = self.objs.count-3;
        int i2 = self.objs.count-1;
        if(i3<=self.objs.count && i3>=0 && [[self.objs lastObject] isEqualToString:SPACE] && [[self.objs objectAtIndex:i3] isEqualToString:kNullKey])
        {
            i = i3;
            i2 = self.objs.count-2;
        }
        NSString *key = [self.objs objectAtIndex:i];
        if ([key equals:kNullKey]) {
            NSString *value = [self.objs objectAtIndex:self.objs.count-1];
            [self.objs replaceObjectAtIndex:i2 withObject:ColorWrap(value, color)];
            return self;
        }
        [self.objs replaceObjectAtIndex:i withObject:[key suffix:[NSString format:@"%@;", [MysticColor color:color].hexString]]];
    }
    return self;
        
}
- (instancetype) colorKey:(id)color;
{
    int i = self.objs.count - 2;
    if(i<=self.objs.count-1)
    {
        NSString *key = [self.objs objectAtIndex:i];
        if (![key equals:kNullKey] && ![key equals:@"^"]) {
            [self.objs replaceObjectAtIndex:i withObject:[key prefix:[NSString format:@"%@;", [MysticColor color:color].hexString]]];
        }
        
    }
    return self;
}

- (instancetype) green; { return [self color:COLOR_GREEN]; }
- (instancetype) greenKey; { return [self colorKey:COLOR_GREEN ]; }
- (instancetype) greenBright; { return [self color:COLOR_GREEN_BRIGHT]; }
- (instancetype) greenBrightKey; { return [self colorKey:COLOR_GREEN_BRIGHT ]; }
- (instancetype) date; { return [self color:COLOR_DATE]; }
- (instancetype) dateKey; { return [self colorKey:COLOR_DATE ]; }
- (instancetype) dull; { return [self color:COLOR_DULL]; }
- (instancetype) dullKey; { return [self colorKey:COLOR_DULL]; }
- (instancetype) dots; { return [self color:COLOR_DOTS]; }
- (instancetype) dotsKey; { return [self colorKey:COLOR_DOTS ]; }
- (instancetype) purple; { return [self color:COLOR_PURPLE]; }
- (instancetype) purpleKey; { return [self colorKey:COLOR_PURPLE ]; }
- (instancetype) yellow; { return [self color:COLOR_YELLOW]; }
- (instancetype) yellowKey; { return [self colorKey:COLOR_YELLOW]; }
- (instancetype) blue; { return [self color:COLOR_BLUE]; }
- (instancetype) blueKey; { return [self colorKey:COLOR_BLUE ]; }
- (instancetype) white; { return [self color:COLOR_WHITE]; }
- (instancetype) whiteKey; { return [self colorKey:COLOR_WHITE ]; }
- (instancetype) red; { return [self color:COLOR_RED]; }
- (instancetype) redKey; { return [self colorKey:COLOR_RED ]; }
- (instancetype) pink; { return [self color:COLOR_PINK]; }
- (instancetype) pinkKey; { return [self colorKey:COLOR_PINK ]; }
- (instancetype) bgColor; { return [self color:COLOR_BG]; }
- (instancetype) bgColorKey; { return [self colorKey:COLOR_BG]; }
- (instancetype) cyan; { return [self color:[UIColor cyan]]; }
- (instancetype) cyanKey; { return [self colorKey:[UIColor cyan]]; }

+ (void) log;
{
    [[self class] log:nil values:nil];
}
+ (void) log:(NSString *)name;
{
    [[self class] log:name values:nil];
}
+ (void) log:(NSString *)name values:(NSArray *)values;
{
    LLog *l = [[self class] logger];
    [l log:name values:values];
}
- (void) log;
{
    [self log:nil values:nil];
}
- (void) log:(NSString *)name;
{
    [self log:name values:nil];
}
- (void) log:(NSString *)name values:(NSArray *)values;
{
    LLog *l = self;
    if(values && values.count) [l.objs addObjectsFromArray:values];
    if(l.objs.count)
    {
        ALLog(name, l.objs);
        [LLogInstance release]; LLogInstance=nil;
    }
}


+ (void) clear;
{
    LLog *l = [[self class] logger];
    [l.objs removeAllObjects];
}
+ (instancetype) start;
{
    [[self class] clear];
    LLog *l = [[[self class] alloc] init];
    return [l autorelease];
}

+ (instancetype) black; { return [[[self class] logger] black]; }
+ (instancetype) bg; { return [[[self class] logger] bg]; }
+ (instancetype) light; { return [[[self class] logger] light]; }
+ (instancetype) dark; { return [[[self class] logger] dark]; }
+ (instancetype) line; { return [(LLog *)[[self class] logger] line]; }
+ (instancetype) space; { return [[[self class] logger] space]; }
+ (instancetype) set:(id)value; { return [[[self class] logger] set:value]; }
+ (instancetype)set:(id)key view:(UIView *)value; { return [[[self class] logger]set:key view:value]; }
+ (instancetype)set:(id)key use:(id)value; { return [[[self class] logger]set:key use:value]; }
+ (instancetype)set:(id)key b:(BOOL)value; { return [[[self class] logger]set:key b:value]; }
+ (instancetype)set:(id)key f:(CGRect)value; { return [[[self class] logger]set:key f:value]; }
+ (instancetype)set:(id)key s:(CGSize)value; { return [[[self class] logger]set:key s:value]; }
+ (instancetype)set:(id)key p:(CGPoint)value; { return [[[self class] logger]set:key p:value]; }
+ (instancetype)set:(id)key sc:(CGScale)value; { return [[[self class] logger]set:key sc:value]; }
+ (instancetype)set:(id)key ins:(UIEdgeInsets)value; { return [[[self class] logger]set:key ins:value]; }
+ (instancetype)set:(id)key fl:(float)value; { return [[[self class] logger]set:key fl:value]; }
+ (instancetype)set:(id)key int:(int)value; { return [[[self class] logger]set:key int:value]; }
+ (instancetype)set:(id)key trans:(CGAffineTransform)value; { return [[[self class] logger]set:key trans:value]; }

+ (instancetype) add:(NSArray *)keyValues; { return [[[self class] logger] add:keyValues]; }


- (void) logObjs;
{
    NSMutableString *s = [NSMutableString string];
    LLog *l = [[self class] logger];
    int i = 0;
    for (id obj in l.objs) {
        NSString *ss = [NSString stringWithFormat:@"%@:   %@%@", i?@"\n\t\tValue":@"\n\tKey",obj, i?@"\n":@""];
        ss = i?ColorWrap(ss, COLOR_BLUE):ss;
        [s appendString:ss];
        i = i?0:1;
    }
    
    DLog(@"LLog:\n\n%@",s);
}

@end