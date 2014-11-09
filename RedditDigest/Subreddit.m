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
          Subreddit *savedSubreddit = [NSEntityDescription insertNewObjectForEntityForName:@"Subreddit" inManagedObjectContext:managedObject];

        savedSubreddit.subreddit = subreddit[@"subreddit"];
        savedSubreddit.url = subreddit[@"url"];
        [managedObject save:nil];
    }
}


@end
