//
//  RedditRequests.m
//  RedditDigest
//
//  Created by Richmond on 11/6/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "RedditRequests.h"

@implementation RedditRequests

+(void)retrieveLatestPostFromArray:(NSArray *)subreddits withManagedObject:(NSManagedObjectContext *)managedObjectContext withCompletion:(void (^)(BOOL completed))complete{

    __block int j = 0;
    for (NSDictionary *subredditDict in subreddits) {
        NSDictionary *setUpForRKKitObject = [[NSDictionary alloc] initWithObjectsAndKeys:subredditDict[@"subreddit"], @"name", subredditDict[@"url"], @"URL", nil];
        RKSubreddit *subreddit = [[RKSubreddit alloc] initWithDictionary:setUpForRKKitObject error:nil];

        [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
            RKLink *topPost = links.firstObject;
            if (topPost.stickied) {
                topPost = links[1];
            }
            [Post savePost:topPost withManagedObject:managedObjectContext];

            j += 1;

            if (j  == subreddits.count) {
                complete(YES);
            }
        }];
    }

}

@end
