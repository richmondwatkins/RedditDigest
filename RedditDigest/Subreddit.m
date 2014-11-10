//
//  Subreddit.m
//  RedditDigest
//
//  Created by Richmond on 11/9/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "Subreddit.h"


@implementation Subreddit

@dynamic subreddit;
@dynamic url;


+(void)addSubredditsToCoreData:(NSMutableArray *)selectedSubreddits withManagedObject:(NSManagedObjectContext *)managedObject{
    for (NSDictionary *subreddit in selectedSubreddits) {

        if (![subreddit[@"currentlySubscribed"] boolValue]) {
            Subreddit *savedSubreddit = [NSEntityDescription insertNewObjectForEntityForName:@"Subreddit" inManagedObjectContext:managedObject];
            savedSubreddit.subreddit = subreddit[@"subreddit"];
            savedSubreddit.url = subreddit[@"url"];
            [managedObject save:nil];
        }

    }
}

+(void)removeFromCoreData:(NSString *)subreddit withManagedObject:(NSManagedObjectContext *)managedObject{
    NSLog(@"REMOVE FROM CORE DAA %@",subreddit);
    NSFetchRequest * subredditFetch = [[NSFetchRequest alloc] init];
    [subredditFetch setEntity:[NSEntityDescription entityForName:@"Subreddit" inManagedObjectContext:managedObject]];
    subredditFetch.predicate = [NSPredicate predicateWithFormat:@"subreddit == %@", subreddit];
    NSArray *results = [managedObject executeFetchRequest:subredditFetch error:nil];
    [managedObject deleteObject:results.firstObject];
    [managedObject save:nil];
}

//+(void)addSubredditsToCoreData:(NSMutableArray *)selectedSubreddits withManagedObject:(NSManagedObjectContext *)managedObject{
//    for (NSDictionary *subreddit in selectedSubreddits) {
//        NSFetchRequest * subredditFetch = [[NSFetchRequest alloc] initWithEntityName:@"Subreddit"];
//        subredditFetch.predicate = [NSPredicate predicateWithFormat:@"subreddit == %@", subreddit[@"subreddit"]];
//        NSArray *results = [managedObject executeFetchRequest:subredditFetch error:nil];
//        if (!results.count) {
//            Subreddit *savedSubreddit = [NSEntityDescription insertNewObjectForEntityForName:@"Subreddit" inManagedObjectContext:managedObject];
//            savedSubreddit.subreddit = subreddit[@"subreddit"];
//            savedSubreddit.url = subreddit[@"url"];
//            [managedObject save:nil];
//        }
//    }
//}


@end
