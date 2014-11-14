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
@implementation Subreddit

@dynamic image;
@dynamic subreddit;
@dynamic url;
@dynamic post;

+(void)addSubredditsToCoreData:(NSMutableArray *)selectedSubreddits withManagedObject:(NSManagedObjectContext *)managedObject{
    for (RKSubreddit *subreddit in selectedSubreddits) {
        NSFetchRequest * subredditFetch = [[NSFetchRequest alloc] init];
        [subredditFetch setEntity:[NSEntityDescription entityForName:@"Subreddit" inManagedObjectContext:managedObject]];
        subredditFetch.predicate = [NSPredicate predicateWithFormat:@"subreddit == %@", subreddit.name];
        NSArray *results = [managedObject executeFetchRequest:subredditFetch error:nil];
        if (!results.count) {
            if (!subreddit.isCurrentlySubscribed) {
                Subreddit *savedSubreddit = [NSEntityDescription insertNewObjectForEntityForName:@"Subreddit" inManagedObjectContext:managedObject];
                savedSubreddit.subreddit = subreddit.name;
                savedSubreddit.url = subreddit.URL;

                if (subreddit.headerImageURL != nil) {
                    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:subreddit.headerImageURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (data) {
                            NSLog(@"data %@",data);
                            savedSubreddit.image = data;
                            [managedObject save:nil];
                        }
                    }];
                }else{
                    NSError *error;
                    [managedObject save:&error];
                }
            }
        }
    }
}

+(void)removeFromCoreData:(NSString *)subreddit withManagedObject:(NSManagedObjectContext *)managedObject{
    [self deleteSubredditFromServer:subreddit];

    NSFetchRequest * subredditFetch = [[NSFetchRequest alloc] init];
    [subredditFetch setEntity:[NSEntityDescription entityForName:@"Subreddit" inManagedObjectContext:managedObject]];
//    subredditFetch.predicate = [NSPredicate predicateWithFormat:@"subreddit == %@", subreddit];
    NSArray *results = [managedObject executeFetchRequest:subredditFetch error:nil];
    for(Subreddit *sub in results){
        if ([sub.subreddit isEqualToString:subreddit]) {
            [managedObject deleteObject:sub];
            [managedObject save:nil];
        }
    }
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


+(void)deleteSubredditFromServer:(NSString *)subredditName{

    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subredditName, @"name", nil];

    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.4:3000/subreddits/delete/%@",  deviceString];

    NSDictionary *objectToDelete = [[NSDictionary alloc] initWithObjectsAndKeys:tempDict, @"subreddit", nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:objectToDelete options:0 error:&error];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!error) {
            //[self getter]; //THIS IS FOR TESTING THE SUBREDDIT GETTER METHOD
        }
    }];

}


@end
