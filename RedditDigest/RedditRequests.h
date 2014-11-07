//
//  RedditRequests.h
//  RedditDigest
//
//  Created by Richmond on 11/6/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RedditKit.h>
#import <RKLink.h>
#import <RKSubreddit.h>
#import "Post.h"
@interface RedditRequests : NSObject

+(void)retrieveLatestPostFromArray:(NSArray *)subbreddits withManagedObject:(NSManagedObjectContext *)managedObjectContext withCompletion:(void (^)(BOOL completed))complete;

@end
