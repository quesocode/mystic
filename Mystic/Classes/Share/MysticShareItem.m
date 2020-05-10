//
//  MysticShareItem.m
//  Mystic
//
//  Created by Travis A. Weerts on 8/23/15.
//  Copyright (c) 2015 Blackpulp. All rights reserved.
//

#import "MysticShareItem.h"
#import "MysticConstants.h"

char * MYCFStringCopyUTF8String(CFStringRef aString) {
    if (aString == NULL) {
        return NULL;
    }
    
    CFIndex length = CFStringGetLength(aString);
    CFIndex maxSize =
    CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
    char *buffer = (char *)malloc(maxSize);
    if (CFStringGetCString(aString, buffer, maxSize,
                           kCFStringEncodingUTF8)) {
        return buffer;
    }
    return NULL;
}


@implementation MysticShareItem

+ (id) itemWithImage:(UIImage *)img subject:(NSString *)subject;
{
    MysticShareItem *item =  [[self class] alloc];
    item.image = img;
    item.subject = subject;
    return [item autorelease];
    
}

- (void) dealloc;
{
    [_image release];
    [_subject release];
    [_thumbnail release];
    [super dealloc];
}
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return self.image;
}

- (id)activityViewController:(UIActivityViewController * )activityViewController
                   itemForActivityType:(NSString * )activityType
{
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        return self.image;
    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return self.image;
    } else {
        return self.image;
    }
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController
                       subjectForActivityType:(NSString *)activityType
{
    return self.subject ? self.subject : MYSTIC_SHARE_SUBJECT;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController
            dataTypeIdentifierForActivityType:(NSString *)activityType
{
    return [NSString stringWithCString:MYCFStringCopyUTF8String(kUTTypeImage) encoding:NSASCIIStringEncoding];
}
- (UIImage *)activityViewController:(UIActivityViewController * )activityViewController
                thumbnailImageForActivityType:(NSString * )activityType
                                suggestedSize:(CGSize)size
{
    return self.image;
}
@end
