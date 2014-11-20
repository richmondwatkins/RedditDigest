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
                        savedSubreddit.image = [NSNumber numberWithBool:NO];

                        if (thumnailSrc.length > 10) {
                            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumnailSrc]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                savedSubreddit.image = [NSNumber numberWithBool:YES];
                                [self saveDataToDocumentsDirectory:data withFileNamePrefix:@"subreddit" andPostfix:savedSubreddit.subreddit];
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

    NSString *deviceString = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceID"];

    NSString *urlString = [NSString stringWithFormat:@"https://gentle-ocean-7650.herokuapp.com/subreddits/delete/%@",  deviceString];

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
    NSLog(@"SELECTED SUB %@",(selectedSubreddit.isLocalSubreddit) ? @"true" : @"false");
    NSFetchRequest * subredditFetch = [[NSFetchRequest alloc] init];
    [subredditFetch setEntity:[NSEntityDescription entityForName:@"Subreddit" inManagedObjectContext:managedObject]];
    subredditFetch.predicate = [NSPredicate predicateWithFormat:@"subreddit == %@", selectedSubreddit.name];
    NSArray *results = [managedObject executeFetchRequest:subredditFetch error:nil];
    if (results.count == 0) {
        if (!selectedSubreddit.isCurrentlySubscribed) {
            Subreddit *savedSubreddit = [NSEntityDescription insertNewObjectForEntityForName:@"Subreddit" inManagedObjectContext:managedObject];
            savedSubreddit.subreddit = selectedSubreddit.name;
            savedSubreddit.url = selectedSubreddit.URL;
            savedSubreddit.isLocalSubreddit = [NSNumber numberWithBool:YES];
            if (selectedSubreddit.headerImageURL != nil) {
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:selectedSubreddit.headerImageURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if (data) {
                        [self saveDataToDocumentsDirectory:data withFileNamePrefix:@"subreddit" andPostfix:savedSubreddit.subreddit];
                        savedSubreddit.image = [NSNumber numberWithBool:YES];
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

+(void)saveDataToDocumentsDirectory:(NSData *)data withFileNamePrefix:(NSString *)prefix andPostfix:(NSString *)postfix{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@",prefix, postfix]];
    [data writeToFile:filePath atomically:YES];
}

+(void)removeLocalPostsAndSubreddits:(NSManagedObjectContext *)managedObject{
    NSFetchRequest *localSubFetch = [[NSFetchRequest alloc] initWithEntityName:@"Subreddit"];
    localSubFetch.predicate = [NSPredicate predicateWithFormat:@"isLocalSubreddit == 1"];
    NSArray *results = [managedObject executeFetchRequest:localSubFetch error:nil];
    if (results.count) {
        for (Subreddit *subreddit in results) {
            NSLog(@"SUBBBBB %@",subreddit);
            [managedObject deleteObject:subreddit];
            [managedObject save:nil];
        }
    }
}

+(NSArray *)retrieveAllSubreddits:(NSManagedObjectContext *)managedObject{
    NSFetchRequest *subredditFetch = [[NSFetchRequest alloc] initWithEntityName:@"Subreddit"];
    subredditFetch.predicate = [NSPredicate predicateWithFormat:@"isLocalSubreddit = nil"];
    NSArray *results = [managedObject executeFetchRequest:subredditFetch error:nil];

    if (results) {
        return results;
    }else{
        return nil;
    }
}


@end
