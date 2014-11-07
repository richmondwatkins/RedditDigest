//
//  UserRequests.h
//  RedditDigest
//
//  Created by Richmond on 11/6/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface UserRequests : NSObject

+(void)retrieveUsersSubreddits:(NSString *)deviceID withCompletion:(void (^)(NSDictionary *results))complete;
+(void)postSelectedSubreddits:(NSString *)deviceID selections:(NSDictionary *)selectionsDictionary withCompletion:(void (^)(BOOL completed))complete;
@end
