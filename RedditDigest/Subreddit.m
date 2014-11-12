//
//  Subreddit.m
//  
//
//  Created by Richmond on 11/11/14.
//
//

#import "Subreddit.h"
#import "Post.h"
#import "DigestCategory.h"
#import "SelectableSubreddit.h"
@implementation Subreddit

@dynamic image;
@dynamic subreddit;
@dynamic url;
@dynamic post;


+(void)addSubredditsToCoreData:(NSMutableArray *)selectedSubreddits withManagedObject:(NSManagedObjectContext *)managedObject{
    for (SelectableSubreddit *subreddit in selectedSubreddits) {
        if (!subreddit.currentlySubscribed) {
            Subreddit *savedSubreddit = [NSEntityDescription insertNewObjectForEntityForName:@"Subreddit" inManagedObjectContext:managedObject];
            savedSubreddit.subreddit = subreddit.name;
            savedSubreddit.url = subreddit.url;
            if (subreddit.categoryName) {
                [DigestCategory addCategoryWithSubredditsToCoreData:subreddit.categoryName withSubreddit:savedSubreddit withManagedObject:managedObject];
            }
            if (subreddit.imageLink != nil) {
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:subreddit.imageLink]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if (data) {
                        NSLog(@"data %@",data);
                        savedSubreddit.image = data;
                        [managedObject save:nil];
                    }
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

+(void)removeAllSubredditsFromCoreData:(NSManagedObjectContext *)managedObjectContext{
    NSFetchRequest * allSubreddits = [[NSFetchRequest alloc] init];
    [allSubreddits setEntity:[NSEntityDescription entityForName:@"Subreddit" inManagedObjectContext:managedObjectContext]];
    [allSubreddits setIncludesPropertyValues:NO];

    NSError * error = nil;
    NSArray * subreddits = [managedObjectContext executeFetchRequest:allSubreddits error:&error];

    for (NSManagedObject * subreddit in subreddits) {
        [managedObjectContext deleteObject:subreddit];
    }
    [managedObjectContext save:nil];
}





@end
