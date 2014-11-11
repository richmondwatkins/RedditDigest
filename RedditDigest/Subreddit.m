//
//  Subreddit.m
//  
//
//  Created by Richmond on 11/11/14.
//
//

#import "Subreddit.h"
#import "Post.h"


@implementation Subreddit

@dynamic image;
@dynamic subreddit;
@dynamic url;
@dynamic post;


+(void)addSubredditsToCoreData:(NSMutableArray *)selectedSubreddits withManagedObject:(NSManagedObjectContext *)managedObject{
    for (NSDictionary *subreddit in selectedSubreddits) {
        if (subreddit[@"categoryName"]) {
            NSLog(@"CATEGORY %@", subreddit[@"categoryName"]);
        }
        if (![subreddit[@"currentlySubscribed"] boolValue]) {
            Subreddit *savedSubreddit = [NSEntityDescription insertNewObjectForEntityForName:@"Subreddit" inManagedObjectContext:managedObject];
            savedSubreddit.subreddit = subreddit[@"subreddit"];
            savedSubreddit.url = subreddit[@"url"];
            if (subreddit[@"image"] != nil) {
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:subreddit[@"image"]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
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






@end
