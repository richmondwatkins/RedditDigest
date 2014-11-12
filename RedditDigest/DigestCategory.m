//
//  DigestCategory.m
//  RedditDigest
//
//  Created by Richmond on 11/11/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "DigestCategory.h"
#import "Subreddit.h"


@implementation DigestCategory

@dynamic name;
@dynamic subreddits;


+(void)addCategoryWithSubredditsToCoreData:(NSString *)categoryName withSubreddit:(Subreddit *)subreddit withManagedObject:(NSManagedObjectContext *)managedObject{
    NSFetchRequest *categoryFetch = [NSFetchRequest fetchRequestWithEntityName:@"DigestCategory"];
    categoryFetch.predicate = [NSPredicate predicateWithFormat:@"name = %@", categoryName];
    NSArray *results = [managedObject executeFetchRequest:categoryFetch error:nil];
   
    DigestCategory *category;
    if (!results.count) {
        category = [NSEntityDescription insertNewObjectForEntityForName:@"DigestCategory" inManagedObjectContext:managedObject];
    }else{
        category = results.firstObject;
    }
    category.name = categoryName;
    [category addSubredditsObject:subreddit];
    [managedObject save:nil];
}

+(void)removeFromCoreData:(NSString *)categoryName withManagedObject:(NSManagedObjectContext *)managedObject{
    NSFetchRequest * categoryFetch = [[NSFetchRequest alloc] initWithEntityName:@"DigestCategory"];
    categoryFetch.predicate = [NSPredicate predicateWithFormat:@"name == %@", categoryName];
    NSArray *results = [managedObject executeFetchRequest:categoryFetch error:nil];

    [managedObject deleteObject:results.firstObject];
    [managedObject save:nil];
}


@end
