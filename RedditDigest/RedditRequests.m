//
//  RedditRequests.m
//  RedditDigest
//
//  Created by Richmond on 11/6/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "RedditRequests.h"
#import "Subreddit.h"
@implementation RedditRequests

+(void)retrieveLatestPostFromArray:(NSArray *)subreddits withManagedObject:(NSManagedObjectContext *)managedObjectContext withCompletion:(void (^)(BOOL completed))complete{
    if ([subreddits.firstObject isKindOfClass:[Subreddit class]]) {
        subreddits = [self formatSubredditsArray:subreddits];
    }

    __block int j = 0;
    for (NSDictionary *subredditDict in subreddits) {
        NSDictionary *setUpForRKKitObject = [[NSDictionary alloc] initWithObjectsAndKeys:subredditDict[@"subreddit"], @"name", subredditDict[@"url"], @"URL", nil];
        RKSubreddit *subreddit = [[RKSubreddit alloc] initWithDictionary:setUpForRKKitObject error:nil];

        [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
            RKLink *topPost = links.firstObject;
            if (topPost.stickied) {
                topPost = links[1];
            }

            [[RKClient sharedClient] commentsForLink:topPost completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
                [Post savePost:topPost withManagedObject:managedObjectContext withComments:collection andCompletion:^(BOOL completedFromCoreData) {
                    if (completedFromCoreData) {
                        j += 1;
                        if (j == subreddits.count) {
                            complete(YES);
                        }
                    }
                }];
            }];
        }];
    }
}

+(NSArray *)formatSubredditsArray:(NSArray *)subreddits{
    NSMutableArray *allSubreddits = [NSMutableArray array];
    for (Subreddit *subreddit in subreddits) {
        NSDictionary *tempSubDict = [[NSDictionary alloc] initWithObjectsAndKeys:subreddit.subreddit, @"subreddit", subreddit.url, @"url", nil];
        [allSubreddits addObject:tempSubDict];
    }
    return [NSArray arrayWithArray:allSubreddits];
}

+(void)localSubredditRequest:(NSString *)cityName andStateAbbreviation:(NSString *)stateAbbreviation withManagedObject:(NSManagedObjectContext *)managedObject withCompletion:(void (^)(Post *))complete{
    [[RKClient sharedClient] subredditWithName:cityName completion:^(RKSubreddit *object, NSError *error) {
        if (!error) {
            [[RKClient sharedClient] linksInSubreddit:object pagination:nil completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
                RKLink *topPost = collection.firstObject;
                if (topPost.stickied) {
                    topPost = collection[1];
                }

                [[RKClient sharedClient] commentsForLink:topPost completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
                    [Post savePost:topPost withManagedObject:managedObject withComments:collection andCompletion:^(BOOL completedFromCoreData) {
                        if (completedFromCoreData) {
                            NSFetchRequest * subredditFetch = [[NSFetchRequest alloc] init];
                            [subredditFetch setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:managedObject]];
                            subredditFetch.predicate = [NSPredicate predicateWithFormat:@"postID == %@", topPost.fullName];
                            NSArray *results = [managedObject executeFetchRequest:subredditFetch error:nil];
                            if (results) {
                                complete(results.firstObject);
                            }
                        }
                    }];
                }];
            }];
        }
    }];
}


@end
