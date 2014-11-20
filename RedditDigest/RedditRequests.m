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

+(void)retrieveLatestPostFromArray:(NSArray *)subreddits withManagedObject:(NSManagedObjectContext *)managedObjectContext withCompletion:(void (^)(BOOL))complete{
    if ([subreddits.firstObject isKindOfClass:[Subreddit class]]) {
        subreddits = [self formatSubredditsArray:subreddits];
    }

    __block int j = 0;
    NSMutableArray *topPosts = [NSMutableArray array];
    for (NSDictionary *subredditDict in subreddits) {
        NSDictionary *setUpForRKKitObject = [[NSDictionary alloc] initWithObjectsAndKeys:subredditDict[@"subreddit"], @"name", subredditDict[@"url"], @"URL", nil];
        RKSubreddit *subreddit = [[RKSubreddit alloc] initWithDictionary:setUpForRKKitObject error:nil];

        [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
            RKLink *topPost = links.firstObject;
            if (topPost.stickied) {
                topPost = links[1];
            }
            [topPosts addObject:topPost];
            j += 1;
            if (j == subreddits.count) {
                [Post savePosts:topPosts withManagedObject:managedObjectContext andCompletion:^(BOOL completedFromCoreData) {
                    if (completedFromCoreData) {
                        complete(YES);

                    }
                }];
            }
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

+(void)localSubredditRequest:(NSString *)cityName andStateAbbreviation:(NSString *)stateAbbreviation withManagedObject:(NSManagedObjectContext *)managedObject withCompletion:(void (^)(NSMutableArray *))complete{
    [[RKClient sharedClient] subredditWithName:cityName completion:^(RKSubreddit *object, NSError *error) {
        if (!error) {
            NSMutableArray *localSubs = [NSMutableArray array];
            [self handleLocalSubredditResponse:object withManagedObject:managedObject withCompletion:^(Post *cityPost) {
                if (cityPost) {[localSubs addObject:cityPost];}
                [[RKClient sharedClient] subredditWithName:[self returnStateFromAbbreviation:stateAbbreviation] completion:^(RKSubreddit *object, NSError *error) {
                    [self handleLocalSubredditResponse:object withManagedObject:managedObject withCompletion:^(Post *statePost) {
                        if (statePost) {[localSubs addObject:statePost];}
                        complete(localSubs);
                    }];
                }];
            }];
        }
    }];
}

+(void)handleLocalSubredditResponse:(RKSubreddit *)subreddit withManagedObject:(NSManagedObjectContext *)managedObject withCompletion:(void (^)(Post *))complete{
    subreddit.isLocalSubreddit = YES;
    [Subreddit addSingleSubredditToCoreData:subreddit withManagedObject:managedObject];

    [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
        RKLink *topPost = collection.firstObject;
        topPost.isLocalPost = YES;
        if (topPost.stickied) {
            topPost = collection[1];
        }

        if (![RedditRequests existsInCoreData:topPost.fullName withManagedObject:managedObject]) {
            [[RKClient sharedClient] commentsForLink:topPost completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
                NSMutableArray *topPostArray = [NSMutableArray arrayWithObjects:topPost, nil];
                [Post savePosts:topPostArray withManagedObject:managedObject andCompletion:^(BOOL completed) {
                    if (complete) {
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
        }else{
            complete(nil);
        }
    }];
}


+(BOOL)existsInCoreData:(NSString *)postID withManagedObject:(NSManagedObjectContext *)managedObject{
    NSFetchRequest * subredditFetch = [[NSFetchRequest alloc] init];
    [subredditFetch setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:managedObject]];
    subredditFetch.predicate = [NSPredicate predicateWithFormat:@"postID == %@", postID];
    NSArray *results = [managedObject executeFetchRequest:subredditFetch error:nil];

    if (results.firstObject) {
        return YES;
    }else{
        return NO;
    }
}

+(NSString *)returnStateFromAbbreviation:(NSString *)abbreviation{
    NSDictionary *nameAbbreviations = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"alabama", @"AL",
                         @"alaska", @"AK",
                         @"arizona", @"AZ",
                         @"arkansas", @"AR",
                         @"california", @"CA",
                         @"colorado", @"CO",
                         @"connecticut", @"CT",
                         @"delaware", @"DE",
                         @"district of columbia", @"DC",
                         @"florida", @"FL",
                         @"georgia", @"GA",
                         @"hawaii", @"HI",
                         @"idaho", @"ID",
                         @"illinois", @"IL",
                         @"indiana", @"IN",
                         @"iowa", @"IA",
                         @"kansas", @"KS",
                         @"kentucky", @"KY",
                         @"louisiana", @"LA",
                         @"maine", @"ME",
                         @"maryland", @"MD",
                         @"massachusetts", @"MA",
                         @"michigan", @"MI",
                         @"minnesota", @"MN",
                         @"mississippi",  @"MS",
                         @"missouri", @"MO",
                         @"montana", @"MT",
                         @"nebraska", @"NE",
                         @"nevada", @"NV",
                         @"new hampshire", @"NH",
                         @"new jersey", @"NJ",
                         @"new mexico", @"NM",
                         @"new york", @"NY",
                         @"north carolina", @"NC",
                         @"north dakota", @"ND",
                         @"ohio", @"OH",
                         @"oklahoma", @"OK",
                         @"oregon", @"OR",
                         @"pennsylvania", @"PA",
                         @"rhode island", @"RI",
                         @"south carolina", @"SC",
                         @"south dakota", @"SD",
                         @"tennessee", @"TN",
                         @"texas", @"TX",
                         @"utah", @"UT",
                         @"vermont", @"VT",
                         @"virginia", @"VA",
                         @"washington", @"WA",
                         @"west virginia", @"WV",
                         @"wisconsin", @"WI",
                         @"wyoming", @"WY",
                         nil];

    return [nameAbbreviations objectForKey:abbreviation];
}



@end
