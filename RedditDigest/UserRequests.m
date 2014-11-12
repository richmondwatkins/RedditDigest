//
//  UserRequests.m
//  RedditDigest
//
//  Created by Richmond on 11/6/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "UserRequests.h"
#import "SelectableSubreddit.h"
@implementation UserRequests

+(void)retrieveUsersSubreddits:(NSString *)deviceID withCompletion:(void (^)(NSDictionary *results))complete{

    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.4:3000/subreddits/%@",deviceID];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"ERROR %@",connectionError);
        if(connectionError == nil)
        {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&connectionError];
            complete(results);
        }
    }];
}

+(void)postSelectedSubreddits:(NSString *)deviceID selections:(NSDictionary *)selectionsDictionary withCompletion:(void (^)(BOOL completed))complete{

    NSError *error;

    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.4:3000/subreddits/%@",  deviceID];
    NSMutableArray *subsArray = [NSMutableArray array];
    for (SelectableSubreddit *selectableSubbreddit in selectionsDictionary[@"subreddits"]) {
        NSDictionary *subredditDict = [[NSDictionary alloc] initWithObjectsAndKeys:selectableSubbreddit.name, @"subreddit", selectableSubbreddit.url, @"url", nil];
        [subsArray addObject:subredditDict];
    }
    
    NSDictionary *dictionaryToPost = @{@"subreddits":subsArray};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionaryToPost options:0 error:&error];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            complete(YES);
        }
    }];
    [dataTask resume];
}

+(void)registerDevice{
    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    NSString* deviceURLString = @"http://192.168.1.4:3000/register/device";
    NSURL *url = [[NSURL alloc] initWithString:[deviceURLString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSError *error;
    NSDictionary *deviceIdDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:deviceString, @"deviceid", nil];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:deviceIdDictionary options:0 error:&error];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (error) {
            NSLog(@"Error from device registration %@",error);
        }
    }];

}

+(void)registerDeviceForPushNotifications:(NSString *)token{
    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];

    NSString* urlString = @"http://192.168.1.4:3000/register/push";

    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSError *error;
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSNumber *timezoneoffset =  [NSNumber numberWithFloat: ([timeZone secondsFromGMT] / 3600.0)];
    NSDictionary *deviceInfoDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:token, @"token", deviceString, @"deviceid", timezoneoffset, @"timeZone", nil];

    NSData *postData = [NSJSONSerialization dataWithJSONObject:deviceInfoDictionary options:0 error:&error];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];


    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (error) {
            NSLog(@"Push Notification Error: %@",error);
        }
    }];

}

@end
