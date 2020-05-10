//
//  MysticAPI.m
//  Mystic
//
//  Created by travis weerts on 6/23/13.
//  Copyright (c) 2013 Blackpulp. All rights reserved.
//

#import "MysticAPI.h"
#import "NSDictionary+Merge.h"
#import "AFNetworking.h"

@implementation MysticAPI
static NSInteger api_build_number = NSNotFound;

+ (void) setBuildNumber:(int)value;
{
    api_build_number = value;
}
+ (NSInteger) buildNumber;
{
    return api_build_number;
}
+ (void) post:(NSString *)uri params:(NSDictionary *)params progress:(MysticBlockAPIUpload)progressBlock complete:(MysticBlockAPI)completed;
{
    [MysticAPI upload:uri params:params uploads:@[] progress:progressBlock complete:completed];
}
+ (void) upload:(NSString *)uri params:(NSDictionary *)params upload:(NSDictionary *)uploadInfo progress:(MysticBlockAPIUpload)progressBlock complete:(MysticBlockAPI)completed;
{
    [MysticAPI upload:uri params:params uploads:(uploadInfo ? [NSArray arrayWithObject:uploadInfo] : @[]) progress:progressBlock complete:completed];
}
+ (void) upload:(NSString *)uri params:(NSDictionary *)params uploads:(NSArray *)uploads progress:(MysticBlockAPIUpload)progressBlock complete:(MysticBlockAPI)completed;
{
    @try {
        uri = [NSString stringWithFormat:@"%@/%@", API_VERSION, uri];
        uri = [NSString stringWithFormat:@"%@%@%@", API_VERSION, [uri hasPrefix:@"/"] ? @"" : @"/",  uri];


//        NSMutableArray *_uploads = [NSMutableArray array];
//        for (NSDictionary *uploadInfo in uploads) {
//            NSData *data = [uploadInfo objectForKey:@"data"];
//            NSString *name = [uploadInfo objectForKey:@"name"] ? [uploadInfo objectForKey:@"name"] : @"file";
//            NSString *filename = [uploadInfo objectForKey:@"filename"] ? [uploadInfo objectForKey:@"filename"] : @"filename";
//            NSString *mime = [uploadInfo objectForKey:@"mime"] ? [uploadInfo objectForKey:@"mime"] : @"image/jpeg";
//
//            NSDictionary *upload = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data",
//                                    name, @"name",
//                                    filename, @"filename",
//                                    mime, @"mime", nil];
//            
//            [_uploads addObject:upload];
//        }
//        
//        NSError *error = nil;
//        NSURL *URL = [NSURL URLWithString:[API_ENDPOINT stringByAppendingString:uri]];
//        
//        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://example.com/upload" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//            for (NSDictionary *obj in _uploads) {
//                [formData appendPartWithFileData:[obj objectForKey:@"data"] name:[obj objectForKey:@"name"] fileName:[obj objectForKey:@"filename"] mimeType:[obj objectForKey:@"mime"]];
//            }
//            
//        }];
//        
//        
//        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//        op.responseSerializer = [AFJSONResponseSerializer serializer];
//        if(progressBlock) [op setUploadProgressBlock:progressBlock];
//        
//        
//        if(completed)
//        {
//            [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//                completed(responseObject, nil);
//                
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
//                if (cachedResponse != nil &&
//                    [[cachedResponse data] length] > 0)
//                {
//                    AFHTTPRequestOperation *json = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//                    json.responseSerializer = [AFJSONResponseSerializer serializer];
//                    
//                    id jsonObj = [NSJSONSerialization JSONObjectWithData:cachedResponse.data options:nil error:&error];
//                    
//                    completed(jsonObj, nil);
//                    [json autorelease];
//                }
//                else
//                {
//                    completed(nil, error);
//                }
//            }];
//            
//        }
//        [[NSOperationQueue mainQueue] addOperation:[op autorelease]];
        
        
    
//    
//        NSURL *url = [NSURL URLWithString:API_ENDPOINT];

//        
//        
//        
//        uri = [NSString stringWithFormat:@"%@%@%@", API_VERSION, [uri hasPrefix:@"/"] ? @"" : @"/",  uri];
//        NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:uri parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
//            for (NSDictionary *obj in _uploads) {
//
//                [formData appendPartWithFileData:[obj objectForKey:@"data"] name:[obj objectForKey:@"name"] fileName:[obj objectForKey:@"filename"] mimeType:[obj objectForKey:@"mime"]];
//            }
//            
//        }];
//        
//        AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
//        if(progressBlock) [operation setUploadProgressBlock:progressBlock];
//        if(completed)
//        {
//            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//                
//                    NSError *error=nil;
//
//                
//                    completed(responseObject, error);
//                
//                
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                
//                    completed(nil, error);
//                
//            }];
//        }
//        [httpClient enqueueHTTPRequestOperation:[operation autorelease]];
//        
    }
    @catch (NSException *exception) {
        NSError *err = [NSError errorWithDomain:@"upload-exception-mystic" code:1 userInfo:@{@"exception":exception}];
        completed(nil, err);
    }
}



+ (void) get:(NSString *)uri params:(NSDictionary *)params complete:(MysticBlockAPI)completed;
{
    NSMutableArray *_uploads = [NSMutableArray array];
    uri = [NSString stringWithFormat:@"%@/%@", API_VERSION, uri];
    uri = [NSString stringWithFormat:@"%@%@%@", API_VERSION, [uri hasPrefix:@"/"] ? @"" : @"/",  uri];

    
    NSError *error = nil;
    NSURL *URL = [NSURL URLWithString:[API_ENDPOINT stringByAppendingString:uri]];
//    
//    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://example.com/upload" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        for (NSDictionary *obj in _uploads) {
//            [formData appendPartWithFileData:[obj objectForKey:@"data"] name:[obj objectForKey:@"name"] fileName:[obj objectForKey:@"filename"] mimeType:[obj objectForKey:@"mime"]];
//        }
//        
//    }];
//    
//    
//    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    op.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    
//    
//    if(completed)
//    {
//        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
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
//                id jsonObj = [NSJSONSerialization JSONObjectWithData:cachedResponse.data options:nil error:&error];
//                
//                completed(jsonObj, nil);
//                [json autorelease];
//
//            }
//            else
//            {
//                completed(nil, error);
//            }
//        }];
//        
//    }
//    [[NSOperationQueue mainQueue] addOperation:[op autorelease]];
    
    
    

}

+ (void) dictionaryFromURL:(NSString *)urlStr finished:(MysticBlockObjBOOL)finished;
{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    NSString *filePath = [[Mystic configDirSubPath:@"api"] stringByAppendingString:[NSString stringWithFormat:@"/%@.plist", [Mystic md5:urlStr]]];
    NSDictionary *results = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        results = [[[NSDictionary alloc] initWithContentsOfFile:filePath] autorelease];
        if(finished) finished(results, YES);
        return;
    }
    
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if(data)
    {

        if ([data writeToFile:filePath atomically:YES])
        {
            results = [[[NSDictionary alloc] initWithContentsOfFile:filePath] autorelease];
            if(finished) finished(results, YES);
            return;
        }
    
    }
    if(finished) finished(results, NO);

}

+ (NSURL *) url:(NSString *)uri;
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@", API_ENDPOINT, API_VERSION, [uri hasPrefix:@"/"] ? @"" : @"/",  uri]];

}

@end
