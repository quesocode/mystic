//
//  MysticLogger.m
//  Mystic
//
//  Created by Me on 3/26/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticLogger.h"
#import "MysticColor.h"

@implementation MysticLogger

+ (void) setupLogger;
{
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:0.37 green:0.35 blue:0.33 alpha:1] backgroundColor:nil forFlag:DDLogFlagInfo];
}
- (id)init {
    if((self = [super init])) {
        threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
//        [threadUnsafeDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
        [threadUnsafeDateFormatter setDateFormat:@"ss:SSS"];

    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    NSString *dateColor = COLOR_DATE;
    NSString *msgColor;
    NSString *bgColor = nil;
    NSString *logMsg = logMessage->_message;
    NSString *prefix=@"";
    NSString *suffix = @"";
    
    
    
    switch ((NSUInteger)logMessage->_flag) {
        case MLogFlagError : { msgColor = (LOG_RED_COLOR); dateColor=[[UIColor string:msgColor] darker:0.7].fgString; break; }
        case MLogFlagWarning  : { msgColor = (LOG_YELLOW_COLOR); dateColor=[[UIColor string:msgColor] darker:0.7].fgString; break; }
        case MLogFlagInfo  : { msgColor = @"fg241,234,224;"; break; }
        case MLogFlagDebug : { msgColor = (LOG_BLUE_COLOR); dateColor=[[UIColor string:msgColor] darker:0.7].fgString; break; }
        case MLogFlagSuccess : { msgColor = (LOG_GREEN_COLOR); dateColor=[[UIColor string:msgColor] darker:0.7].fgString; break; };
        case MLogFlagHidden : { msgColor = LOG_HIDDEN_COLOR; break; }
        case MLogFlagRender : { msgColor = (LOG_PURPLE_COLOR); break; }
        case MLogFlagMemory : { msgColor = @"fg255,255,255;";
                                dateColor=@"fg212,116,116;";
                                bgColor=@"bg172,55,55;";
                                logMsg = [logMsg stringByAppendingString:@"    "];
                                break; }
        default             : { msgColor = @"fg145,143,141;"; break; }
    }
    BOOL hasBlanks = [logMsg containsString:@"#blank"];
    BOOL hasBlanksSuffix = [logMsg hasSuffix:@"#blank"];
    if(hasBlanks || hasBlanksSuffix) logMsg = [logMsg stringByReplacingOccurrencesOfString:@"#blank" withString:@""];
    
    NSString *dateAndTime = [threadUnsafeDateFormatter stringFromDate:(logMessage->_timestamp)];
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@"->" withString:ColorWrap(@" ╶─▶  ", COLOR_DOTS)];
    if([logMsg containsString:@"\n"])
    {
        logMsg = [logMsg stringByReplacingOccurrencesOfString:@"\n" withString:[NSString stringWithFormat:(XCODE_COLORS_RESET_FG @"\n" XCODE_COLORS_ESCAPE @"%@            " XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE @"%@"), dateColor, msgColor]];
        logMsg = !hasBlanksSuffix ? [logMsg stringByAppendingString:@"\n\n\n"] : logMsg;
    }
    
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@" NO " withString:[NSString stringWithFormat:(XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE LOG_RED_COLOR @" NO " XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE @"%@"), msgColor]];
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@" YES " withString:[NSString stringWithFormat:(XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE LOG_GREEN_COLOR @" YES " XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE @"%@"), msgColor]];
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@"$_SQ" withString:@"██"];
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@"$_B" withString:@"█"];
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@"$_D" withString:@"⁞"];
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@"$_FG:" withString:(XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE @"fg" )];
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@"$_BG:" withString:(XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE @"bg" )];
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@"_$" withString:@";"];
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@"$_ENDFG" withString:[NSString stringWithFormat:(XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE @"%@"), msgColor]];
    
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@"$_ENDBG" withString:[NSString stringWithFormat:(XCODE_COLORS_RESET_BG XCODE_COLORS_ESCAPE @"%@"), bgColor]];
    if(bgColor) return [NSString stringWithFormat:(@"%@" XCODE_COLORS_ESCAPE @"%@"   @"%@" XCODE_COLORS_ESCAPE "%@ %@ " XCODE_COLORS_RESET_FG XCODE_COLORS_ESCAPE @"%@    %@" XCODE_COLORS_RESET @"%@%@"),hasBlanks ? @"\n\n" : @"", prefix, bgColor, dateColor, dateAndTime, msgColor, logMsg, suffix, hasBlanksSuffix ? @"\n\n" : @""];
    
    logMsg = [logMsg stringByReplacingOccurrencesOfString:@"bg0,0,0;" withString:@""];

    
    
    return [NSString stringWithFormat:(@"%@"  XCODE_COLORS_ESCAPE @"%@"  @"%@ %@ " XCODE_COLORS_RESET XCODE_COLORS_ESCAPE @"%@    %@" XCODE_COLORS_RESET @"%@" @"%@"  ), hasBlanks ? @"\n\n" : @"", prefix, dateColor, dateAndTime, msgColor, logMsg, suffix, hasBlanksSuffix ? @"\n\n" : @""];
}

- (void)didAddToLogger:(id <DDLogger>)logger {
    loggerCount++;
    NSAssert(loggerCount <= 1, @"This logger isn't thread-safe");
}

- (void)willRemoveFromLogger:(id <DDLogger>)logger {
    loggerCount--;
}



@end



