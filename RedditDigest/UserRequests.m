//
//  UserRequests.m
//  RedditDigest
//
//  Created by Richmond on 11/6/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "UserRequests.h"

@implementation UserRequests

+(void)retrieveUsersSubreddits:(NSString *)deviceID withCompletion:(void (^)(NSDictionary *results))complete{


    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.4:3000/subreddits/%@",deviceID];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error == nil)
        {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            complete(results);
        }
    }];
    
    [dataTask resume];
}

+(void)postSelectedSubreddits:(NSString *)deviceID selections:(NSDictionary *)selectionsDictionary{
    NSError *error;

    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.4:3000/subreddits/%@",  deviceID];

    NSData *postData = [NSJSONSerialization dataWithJSONObject:selectionsDictionary options:0 error:&error];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            //                NSLog(@"%@",response);
        }
    }];
    [dataTask resume];
}

@end
