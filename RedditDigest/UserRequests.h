//
//  UserRequests.h
//  RedditDigest
//
//  Created by Richmond on 11/6/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface UserRequests : NSObject

+(void)retrieveUsersSubredditswithCompletion:(void (^)(NSDictionary *results))complete;
+(void)postSelectedSubreddits:(NSDictionary *)selectionsDictionary withCompletion:(void (^)(BOOL completed))complete;
+(void)registerDevice:(NSString *)deviceID;
+(void)registerDeviceForPushNotifications:(NSString *)token;
+(void)retrieveRecommendedSubredditsWithCompletion:(void (^)(NSArray *results))complete;
+(void)setUpRecommendationsOnServer:(NSManagedObjectContext *)managedObject;
@end
