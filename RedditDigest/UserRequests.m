//
//  UserRequests.m
//  RedditDigest
//
//  Created by Richmond on 11/6/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "UserRequests.h"
#import <RedditKit.h>
#import "Subreddit.h"
@implementation UserRequests

+(void)retrieveUsersSubredditswithCompletion:(void (^)(NSDictionary *results))complete{
    NSString *deviceString = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceID"];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.0.180:3000/subreddits/%@",deviceString];

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

+(void)postSelectedSubreddits:(NSDictionary *)selectionsDictionary withCompletion:(void (^)(BOOL completed))complete{

    NSString *deviceString = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceID"];
    NSError *error;
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.0.180:3000/subreddits/%@",  deviceString];

    NSMutableArray *subsArray = [NSMutableArray array];
    for (RKSubreddit *selectableSubbreddit in selectionsDictionary[@"subreddits"]) {
        NSDictionary *subredditDict = [[NSDictionary alloc] initWithObjectsAndKeys:selectableSubbreddit.name, @"subreddit", selectableSubbreddit.URL, @"url", nil];
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

+(void)registerDevice:(NSString *)deviceID{
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];

    NSString* deviceURLString = @"http://192.168.0.180:3000/register/device";

    NSURL *url = [[NSURL alloc] initWithString:[deviceURLString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"INS URS RE %@",deviceID);
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

    NSString *deviceString = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceID"];

    NSString* urlString = @"http://192.168.0.180:3000/register/push";

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

+(void)retrieveRecommendedSubredditsWithCompletion:(void (^)(NSArray *results))complete{

    NSString *deviceString = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceID"];

    NSString *urlString = [NSString stringWithFormat:@"http://192.168.0.180:3000/recommendations/%@", deviceString];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (results) {
                NSArray *recommendations = results[@"recs"];
                complete(recommendations);
            }else{
                complete(nil);
            }
        }
    }];
}

+(void)setUpRecommendationsOnServer:(NSManagedObjectContext *)managedObject{
    NSMutableArray *usersSubreddits = [NSMutableArray arrayWithArray:[Subreddit retrieveAllSubreddits:managedObject]];

    NSMutableArray *recSubredditNames = [NSMutableArray array];
    __block int i = 0;
    for (Subreddit *subreddit in usersSubreddits) {
        [[RKClient sharedClient] recommendedSubredditsForSubreddits:@[subreddit.subreddit] completion:^(NSArray *collection, NSError *error) {
            i++;
            if (collection) {
                [recSubredditNames addObject:collection];
            }
            if (i == usersSubreddits.count) {
                [self retrieveSubredditInfoFromReddit:recSubredditNames];
            }
        }];
    }
}

+(void)retrieveSubredditInfoFromReddit:(NSMutableArray *)recSubNames{
    NSArray *flattenedSubNames = [recSubNames valueForKeyPath: @"@unionOfArrays.self"];
    __block int i = 0;
    NSMutableArray *recFromReddit = [NSMutableArray array];
    for (NSString *subName in flattenedSubNames) {
        [[RKClient sharedClient] subredditWithName:subName completion:^(RKSubreddit *object, NSError *error) {
            i++;
            if (object.totalSubscribers >= 5000) {
                [recFromReddit addObject:object];
            }

            if (i >= flattenedSubNames.count) {
                [self retrieveRecommendedSubredditsWithCompletion:^(NSArray *results) {
                    [self formatToSendToServer:recFromReddit andRecsFromUser:results];
                }];
            }

        }];
    }
}

+(void)formatToSendToServer:(NSMutableArray *)recsFromReddit andRecsFromUser:(NSArray *)recsFromUser{
    NSMutableArray *formattedRecsFromReddit = [NSMutableArray array];
    for (RKSubreddit *subreddit in recsFromReddit) {
            [formattedRecsFromReddit addObject:subreddit.name];
    }

    NSString *deviceString = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceID"];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.0.180:3000/recommendations/%@",deviceString];
    NSURL *url = [NSURL URLWithString:urlString];

    NSDictionary *dictionaryToPost = @{@"subreddits":formattedRecsFromReddit};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionaryToPost options:0 error:nil];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"Post";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"USER RECS %@",recsFromUser);
    }];


    NSLog(@"USER RECS %@",recsFromUser);
    NSLog(@"REDDit RECS %@",formattedRecsFromReddit);

}

@end
