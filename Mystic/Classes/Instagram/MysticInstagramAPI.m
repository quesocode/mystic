//
//  MysticInstagramAPI.m
//  Mystic
//
//  Created by travis weerts on 9/12/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticInstagramAPI.h"
#import "NSDictionary+Merge.h"
//#import "AFJSONRequestOperation.h"
#import "AFNetworking.h"

@implementation MysticInstagramAPI

+ (void) recentPhotos:(MysticBlockObjBOOL)finished;
{
    [MysticInstagramAPI photosForTag:MYSTIC_API_INSTAGRAM_TAG finished:finished];
}
+ (void) photosForTag:(NSString *)tagName finished:(MysticBlockObjBOOL)finished;
{
    NSString *photosUri = [NSString stringWithFormat:@"tags/%@/media/recent?client_id=%@", tagName, MYSTIC_API_INSTAGRAM_CLIENTID];
    [MysticInstagramAPI get:photosUri params:Nil complete:^(NSDictionary *results, NSError *error) {
        if(error)
        {
            if(finished) finished(results, NO);
            return;
        }
        else
        {
            NSArray *data = [results objectForKey:@"data"];
            NSMutableArray *_photos = [NSMutableArray array];
            if(data && data.count)
            {
                for (NSDictionary *photoInfo in data) {
                    [_photos addObject:[MysticInstagramPhoto photoWithDictionary:photoInfo]];
                }
            }
            if(finished) finished(_photos, YES);
        }
    }];
    
    
    
}

+ (void) get:(NSString *)uri params:(NSDictionary *)params complete:(MysticBlockAPI)completed;
{
    NSURL *url = [NSURL URLWithString:MYSTIC_API_INSTAGRAM_ENDPOINT];
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
//    uri = [NSString stringWithFormat:@"v1/%@", uri];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//        
//    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:uri parameters:params];
//    
//    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
//    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
//    [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
//        return nil;
//    }];
    
    NSError *error = nil;
    NSURL *URL = [NSURL URLWithString:[MYSTIC_API_INSTAGRAM_ENDPOINT stringByAppendingString:uri]];
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:[MYSTIC_API_INSTAGRAM_ENDPOINT stringByAppendingString:uri] parameters:params error:&error];
    [manager GET:[MYSTIC_API_INSTAGRAM_ENDPOINT stringByAppendingString:uri] parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completed(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completed(nil, error);
    }];
//    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    op.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    
//    
//    if(completed)
//    {
//        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"JSON: %@", responseObject);
//            completed(responseObject, nil);
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
//            if (cachedResponse != nil &&
//                [[cachedResponse data] length] > 0)
//            {
//                AFHTTPRequestOperation *json = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//                json.responseSerializer = [AFJSONResponseSerializer serializer];
//                
////                
////                AFJSONRequestOperation *json = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:nil failure:nil];
////                json.responseData = cachedResponse.data;
//                
//                id jsonObj = [NSJSONSerialization JSONObjectWithData:cachedResponse.data options:nil error:&error];
//                
//                completed(jsonObj, nil);
//
//            }
//            else
//            {
//                completed(nil, error);
//            }
//        }];
//
//    }
//    [[NSOperationQueue mainQueue] addOperation:op];
}
+ (BOOL) hasInstagramApp;
{
    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://tag?name=%@", MYSTIC_API_INSTAGRAM_TAG]];
    return [[UIApplication sharedApplication] canOpenURL:instagramURL];
}
+ (void) openTagInInstagram:(NSString *)tagName;
{

    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://tag?name=%@", tagName ? tagName : MYSTIC_API_INSTAGRAM_TAG]];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instagram Required" message:@"To see inspiration, you need to install the instagram app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

    }
    
}

+ (void) openUserInInstagram:(NSString *)username;
{
    
    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", username ? username : @"mysticapp"]];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instagram Required" message:@"To see this user's profile, you need to install the instagram app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    
}

+ (void) openMediaInInstagram:(NSString *)mediaId;
{
    
    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://media?id=%@", mediaId ? mediaId : @"unknown_media_id"]];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instagram Required" message:@"To see this photo, you need to install the instagram app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    
}


+ (void) openLocationInInstagram:(NSString *)locationId;
{
    
    NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://location?id=%@", locationId ? locationId : @"unknown_location_id"]];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instagram Required" message:@"To see this location, you need to install the instagram app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    
}

@end
