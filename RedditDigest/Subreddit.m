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
#import "TFHpple.h"
@implementation Subreddit

@dynamic image;
@dynamic subreddit;
@dynamic url;
@dynamic post;
@dynamic isLocalSubreddit;
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

                NSString *urlString = [NSString stringWithFormat:@"http://www.reddit.com%@", subreddit.URL];
                NSURL *url = [NSURL URLWithString:urlString];
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if (data) {
                        TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:data];

                        NSArray *elements = [tutorialsParser searchWithXPathQuery:@"//img"];
                        NSString *thumnailSrc;
                        for (TFHppleElement *element in elements) {
                            NSString *idString = [element objectForKey:@"id"];
                            if ([idString isEqualToString:@"header-img"]) {
                                NSDictionary *nodeDict = [element attributes];
                                thumnailSrc = [nodeDict objectForKey:@"src"];
                            }
                        }

                        if (thumnailSrc.length > 10) {
                            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumnailSrc]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                savedSubreddit.image = data;
                                [managedObject save:nil];
                            }];
                        }else{
                            [managedObject save:nil];
                        }
                    }
                }];
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

+(void)addSingleSubredditToCoreData:(RKSubreddit *)selectedSubreddit withManagedObject:(NSManagedObjectContext *)managedObject{
    NSFetchRequest * subredditFetch = [[NSFetchRequest alloc] init];
    [subredditFetch setEntity:[NSEntityDescription entityForName:@"Subreddit" inManagedObjectContext:managedObject]];
    subredditFetch.predicate = [NSPredicate predicateWithFormat:@"subreddit == %@", selectedSubreddit.name];
    NSArray *results = [managedObject executeFetchRequest:subredditFetch error:nil];
    if (!results.count) {
        if (!selectedSubreddit.isCurrentlySubscribed) {
            Subreddit *savedSubreddit = [NSEntityDescription insertNewObjectForEntityForName:@"Subreddit" inManagedObjectContext:managedObject];
            savedSubreddit.subreddit = selectedSubreddit.name;
            savedSubreddit.url = selectedSubreddit.URL;
            savedSubreddit.isLocalSubreddit = [NSNumber numberWithBool:YES];
            if (selectedSubreddit.headerImageURL != nil) {
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:selectedSubreddit.headerImageURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
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

+(void)removeLocalPostsAndSubreddits:(NSManagedObjectContext *)managedObject{
    NSFetchRequest *localSubFetch = [[NSFetchRequest alloc] initWithEntityName:@"Subreddit"];
    localSubFetch.predicate = [NSPredicate predicateWithFormat:@"isLocalSubreddit == YES"];
    NSArray *results = [managedObject executeFetchRequest:localSubFetch error:nil];
    if (results.count) {
        for (Subreddit *subreddit in results) {
            NSLog(@"POST FROM DATA %@",subreddit);
            [managedObject deleteObject:subreddit];
            [managedObject save:nil];
        }
    }
}


@end
