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
            NSLog(@"adfqweoij %@",subreddit[@"image"]);

            if (subreddit[@"image"] != nil) {
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:subreddit[@"image"]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    NSLog(@"DATA %@",data);
                    [managedObject save:nil];

                }];
            }else{
                
                [managedObject save:nil];
            }
        }
    }
}

+(void)removeFromCoreData:(NSString *)subreddit withManagedObject:(NSManagedObjectContext *)managedObject{
    NSFetchRequest * subredditFetch = [[NSFetchRequest alloc] init];
    [subredditFetch setEntity:[NSEntityDescription entityForName:@"Subreddit" inManagedObjectContext:managedObject]];
    subredditFetch.predicate = [NSPredicate predicateWithFormat:@"subreddit == %@", subreddit];
    NSArray *results = [managedObject executeFetchRequest:subredditFetch error:nil];
    [managedObject deleteObject:results.firstObject];
    [managedObject save:nil];
}

@end
