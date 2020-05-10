//
//  DataModel.h
//  instagrampopular
//
//  Created by Bebek, Taha on 11/3/12.
//  Copyright (c) 2012 Bebek, Taha. All rights reserved.
//

#ifndef instagrampopular_DataModel_h
#define instagrampopular_DataModel_h


@interface From : NSObject


@property(nonatomic,strong) NSString* username;
@property(nonatomic,strong) NSString* ID;
@property(nonatomic,strong) NSString* profile_picture;
@property(nonatomic,strong) NSString* full_name;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation From


@synthesize username;
@synthesize ID;
@synthesize profile_picture;
@synthesize full_name;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.username = [dict valueForKey:@"username"];
    self.ID = [dict valueForKey:@"id"];
    self.profile_picture = [dict valueForKey:@"profile_picture"];
    self.full_name = [dict valueForKey:@"full_name"];
    return self;
}


@end




@interface Data : NSObject


@property(nonatomic,strong) From* from;
@property(nonatomic,strong) NSString* ID;
@property(nonatomic,strong) NSString* created_time;
@property(nonatomic,strong) NSString* text;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation Data


@synthesize from;
@synthesize ID;
@synthesize created_time;
@synthesize text;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.from = [[From alloc] initWithDictionary:[dict valueForKey:@"from"]];
    self.ID = [dict valueForKey:@"id"];
    self.created_time = [dict valueForKey:@"created_time"];
    self.text = [dict valueForKey:@"text"];
    return self;
}


@end




@interface Comments : NSObject


@property(nonatomic,strong) NSNumber* count;
@property(nonatomic,strong) NSMutableArray* data;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation Comments


@synthesize count;
@synthesize data;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.count = [dict valueForKey:@"count"];
    self.data = [NSMutableArray array];
    NSArray* dataArray = [dict valueForKey:@"data"];
    for (int index = 0; index < dataArray.count; index++){
        id object = [dataArray objectAtIndex:index];
        [self.data addObject:[[Data alloc] initWithDictionary:object]];
    }
    return self;
}


@end




@interface From1 : NSObject


@property(nonatomic,strong) NSString* username;
@property(nonatomic,strong) NSString* ID;
@property(nonatomic,strong) NSString* profile_picture;
@property(nonatomic,strong) NSString* full_name;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation From1


@synthesize username;
@synthesize ID;
@synthesize profile_picture;
@synthesize full_name;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.username = [dict valueForKey:@"username"];
    self.ID = [dict valueForKey:@"id"];
    self.profile_picture = [dict valueForKey:@"profile_picture"];
    self.full_name = [dict valueForKey:@"full_name"];
    return self;
}


@end




@interface Caption : NSObject


@property(nonatomic,strong) From1* from1;
@property(nonatomic,strong) NSString* ID;
@property(nonatomic,strong) NSString* created_time;
@property(nonatomic,strong) NSString* text;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation Caption


@synthesize from1;
@synthesize ID;
@synthesize created_time;
@synthesize text;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.from1 = [[From1 alloc] initWithDictionary:[dict valueForKey:@"from1"]];
    self.ID = [dict valueForKey:@"id"];
    self.created_time = [dict valueForKey:@"created_time"];
    self.text = [dict valueForKey:@"text"];
    return self;
}


@end




@interface Data1 : NSObject


@property(nonatomic,strong) NSString* username;
@property(nonatomic,strong) NSString* ID;
@property(nonatomic,strong) NSString* profile_picture;
@property(nonatomic,strong) NSString* full_name;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation Data1


@synthesize username;
@synthesize ID;
@synthesize profile_picture;
@synthesize full_name;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.username = [dict valueForKey:@"username"];
    self.ID = [dict valueForKey:@"id"];
    self.profile_picture = [dict valueForKey:@"profile_picture"];
    self.full_name = [dict valueForKey:@"full_name"];
    return self;
}


@end




@interface Likes : NSObject


@property(nonatomic,strong) NSNumber* count;
@property(nonatomic,strong) NSMutableArray* data;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation Likes


@synthesize count;
@synthesize data;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.count = [dict valueForKey:@"count"];
    self.data = [NSMutableArray array];
    NSArray* dataArray = [dict valueForKey:@"data"];
    for (int index = 0; index < dataArray.count; index++){
        id object = [dataArray objectAtIndex:index];
        [self.data addObject:[[Data alloc] initWithDictionary:object]];
    }
    return self;
}


@end




@interface Low_Resolution : NSObject


@property(nonatomic,strong) NSString* url;
@property(nonatomic,strong) NSNumber* width;
@property(nonatomic,strong) NSNumber* height;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation Low_Resolution


@synthesize url;
@synthesize width;
@synthesize height;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.url = [dict valueForKey:@"url"];
    self.width = [dict valueForKey:@"width"];
    self.height = [dict valueForKey:@"height"];
    return self;
}


@end




@interface Standard_Resolution : NSObject


@property(nonatomic,strong) NSString* url;
@property(nonatomic,strong) NSNumber* width;
@property(nonatomic,strong) NSNumber* height;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation Standard_Resolution


@synthesize url;
@synthesize width;
@synthesize height;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.url = [dict valueForKey:@"url"];
    self.width = [dict valueForKey:@"width"];
    self.height = [dict valueForKey:@"height"];
    return self;
}


@end




@interface Thumbnail : NSObject


@property(nonatomic,strong) NSString* url;
@property(nonatomic,strong) NSNumber* width;
@property(nonatomic,strong) NSNumber* height;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation Thumbnail


@synthesize url;
@synthesize width;
@synthesize height;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.url = [dict valueForKey:@"url"];
    self.width = [dict valueForKey:@"width"];
    self.height = [dict valueForKey:@"height"];
    return self;
}


@end




@interface Images : NSObject


@property(nonatomic,strong) Low_Resolution* low_resolution;
@property(nonatomic,strong) Standard_Resolution* standard_resolution;
@property(nonatomic,strong) Thumbnail* thumbnail;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation Images


@synthesize low_resolution;
@synthesize standard_resolution;
@synthesize thumbnail;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.low_resolution = [[Low_Resolution alloc] initWithDictionary:[dict valueForKey:@"low_resolution"]];
    self.standard_resolution = [[Standard_Resolution alloc] initWithDictionary:[dict valueForKey:@"standard_resolution"]];
    self.thumbnail = [[Thumbnail alloc] initWithDictionary:[dict valueForKey:@"thumbnail"]];
    return self;
}


@end




@interface User : NSObject


@property(nonatomic,strong) NSString* username;
@property(nonatomic,strong) NSString* full_name;
@property(nonatomic,strong) NSString* profile_picture;
@property(nonatomic,strong) NSString* website;
@property(nonatomic,strong) NSString* ID;
@property(nonatomic,strong) NSString* bio;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation User


@synthesize username;
@synthesize full_name;
@synthesize profile_picture;
@synthesize website;
@synthesize ID;
@synthesize bio;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.username = [dict valueForKey:@"username"];
    self.full_name = [dict valueForKey:@"full_name"];
    self.profile_picture = [dict valueForKey:@"profile_picture"];
    self.website = [dict valueForKey:@"website"];
    self.ID = [dict valueForKey:@"id"];
    self.bio = [dict valueForKey:@"bio"];
    return self;
}


@end




@interface Post : NSObject


@property(nonatomic,strong) NSString* ID;
@property(nonatomic,strong) Comments* comments;
@property(nonatomic,strong) NSString* created_time;
@property(nonatomic,strong) Caption* caption;
@property(nonatomic,strong) NSString* link;
@property(nonatomic,strong) NSMutableArray* tags;
@property(nonatomic,strong) Likes* likes;
@property(nonatomic,strong) NSString* type;
@property(nonatomic,strong) id location;
@property(nonatomic,strong) NSString* filter;
@property(nonatomic,strong) Images* images;
@property(nonatomic,strong) User* user;
@property(nonatomic,strong) id attribution;


-(id)initWithDictionary:(NSDictionary*)dict;


@end






@implementation Post


@synthesize ID;
@synthesize comments;
@synthesize created_time;
@synthesize caption;
@synthesize link;
@synthesize tags;
@synthesize likes;
@synthesize type;
@synthesize location;
@synthesize filter;
@synthesize images;
@synthesize user;
@synthesize attribution;


-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    self.ID = [dict valueForKey:@"id"];
    self.comments = [[Comments alloc] initWithDictionary:[dict valueForKey:@"comments"]];
    self.created_time = [dict valueForKey:@"created_time"];
    self.caption = [[Caption alloc] initWithDictionary:[dict valueForKey:@"caption"]];
    self.link = [dict valueForKey:@"link"];
    self.tags = [NSMutableArray array];
    NSArray* dataArray = [dict valueForKey:@"tags"];
    for (int index = 0; index < dataArray.count; index++){
        id object = [dataArray objectAtIndex:index];
        [self.tags addObject:object];
    }
    self.likes = [[Likes alloc] initWithDictionary:[dict valueForKey:@"likes"]];
    self.type = [dict valueForKey:@"type"];
    self.location = [dict valueForKey:@"location"];
    self.filter = [dict valueForKey:@"filter"];
    self.images = [[Images alloc] initWithDictionary:[dict valueForKey:@"images"]];
    self.user = [[User alloc] initWithDictionary:[dict valueForKey:@"user"]];
    self.attribution = [dict valueForKey:@"attribution"];
    return self;
}


@end

#endif
