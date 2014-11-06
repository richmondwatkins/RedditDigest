//
//  ViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/1/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "DigestViewController.h"
#import <RedditKit.h>
#import <RKLink.h>
#import <RKSubreddit.h>
#import <SSKeychain/SSKeychain.h>
#import "Post.h"
#import <CoreData/CoreData.h>
#import "PostViewController.h"
@interface DigestViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *digestTableView;
@property NSMutableArray *digestPosts;
@end

@implementation DigestViewController

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];

        [self.parentViewController presentViewController:welcomeViewController animated:YES completion:nil];

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}


#pragma mark - TableView Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.digestPosts.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DigestCell"];
    RKLink *post = self.digestPosts[indexPath.row];

    cell.textLabel.text = post.title;
    cell.detailTextLabel.text = post.subreddit;

    return cell;
}


#pragma mark - Fetch from Server

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [self clearOutCoreData];

    self.digestPosts = [NSMutableArray array];

    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.129.228:3000/subreddits/%@",deviceString];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error == nil)
        {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSArray *usersSubredditsArray = results[@"subreddits"];
            [self findTopPostsFromSubreddit:usersSubredditsArray withCompletionHandler:completionHandler];
        }
    }];

    [dataTask resume];
}

-(void)findTopPostsFromSubreddit:(NSArray *)subreddits withCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{

    __block int j = 0;
    for (NSDictionary *subredditDict in subreddits) {
        NSDictionary *setUpForRKKitObject = [[NSDictionary alloc] initWithObjectsAndKeys:subredditDict[@"subreddit"], @"name", subredditDict[@"url"], @"URL", nil];
        RKSubreddit *subreddit = [[RKSubreddit alloc] initWithDictionary:setUpForRKKitObject error:nil];

        [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
            RKLink *topPost = links.firstObject;
            if (topPost.stickied) {
                topPost = links[1];
            }

            [self.digestPosts addObject:topPost];
            [self addPostToCoreData:topPost];

            j += 1;

            if (j  == subreddits.count) {
                [self performNewFetchedDataActionsWithDataArray];
                completionHandler(UIBackgroundFetchResultNewData);
                [self fireLocalNotificationAndMarkComplete];
            }
        }];
    }
}

-(void)fireLocalNotificationAndMarkComplete{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = @"Your reddit digest is ready for viewing";
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];


    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpdateDate = [NSDate date];
    [userDefaults setObject:lastUpdateDate forKey:@"LastDigest"];
    [userDefaults synchronize];

}

#pragma mark - Core Data Methods

-(void)addPostToCoreData:(RKLink *)post{

    Post *savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
    savedPost.title = post.title;
    savedPost.subreddit = post.subreddit;
    savedPost.url = [post.URL absoluteString];
    savedPost.nsfw = [NSNumber numberWithBool:post.NSFW];
    savedPost.author = post.author;
    savedPost.voteRatio = [NSNumber numberWithFloat:post.score];

    NSURLRequest *thumbnailRequest = [NSURLRequest requestWithURL:post.thumbnailURL];
    [NSURLConnection sendAsynchronousRequest:thumbnailRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        savedPost.thumbnailImage = data;

        if (post.isImageLink) {
            savedPost.isImageLink = [NSNumber numberWithBool:YES];
            NSURLRequest *mainImageRequest = [NSURLRequest requestWithURL:post.URL];
            [NSURLConnection sendAsynchronousRequest:mainImageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                savedPost.image = data;
            }];
        }else{
            savedPost.isImageLink = [NSNumber numberWithBool:NO];

            if (post.isSelfPost) {
                savedPost.isSelfPost = [NSNumber numberWithBool:YES];
                savedPost.selfText = post.selfText;
            }else{
                savedPost.isWebPage = [NSNumber numberWithBool:YES];
//                NSURL *urlReadabilityURL= [NSURL URLWithString:[NSString stringWithFormat:@"http://www.readability.com/m?url=%@", [post.URL absoluteString]]];

//                NSLog(@"URL READBILITYYYY %@",urlReadabilityURL);

                NSData *data = [NSData dataWithContentsOfURL:post.URL];
                [[NSFileManager defaultManager] createFileAtPath:[self cacheFile:post.title] contents:data attributes:nil];
//                savedPost.html = [NSString stringWithContentsOfURL:urlReadabilityURL encoding:NSUTF8StringEncoding error:nil];
            }
        }
        [self.managedObjectContext save:nil];
    }];
}

-(NSString*)cacheFile:(NSString *)title{
//    
//    NSRange range = [title rangeOfString:@"#"];
//    NSString *shortString = [title substringToIndex:range.location];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", title]];
}

-(void)clearOutCoreData{
    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext]];
    [allCars setIncludesPropertyValues:NO];

    NSError * error = nil;
    NSArray * posts = [self.managedObjectContext executeFetchRequest:allCars error:&error];
    //error handling goes here
    for (NSManagedObject * post in posts) {
        [self.managedObjectContext deleteObject:post];
    }
    [self.managedObjectContext save:nil];
    [self clearOutCacheDirectory];
}

-(void)clearOutCacheDirectory{
    // Path to the Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];

        // Print out the path to verify we are in the right place
        NSString *directory = [paths objectAtIndex:0];
        NSLog(@"Directory: %@", directory);

        // For each file in the directory, create full path and delete the file
        for (NSString *file in [fileManager contentsOfDirectoryAtPath:directory error:&error])
        {
            NSString *filePath = [directory stringByAppendingPathComponent:file];
            NSLog(@"File : %@", filePath);

            BOOL fileDeleted = [fileManager removeItemAtPath:filePath error:&error];
            
            if (fileDeleted != YES || error != nil)
            {
                NSLog(@"NOT DELETED");
            }else{
                NSLog(@"DELTED");
            }
        }
        
    }
}

-(void)retrievePostsFromCoreData{
    NSFetchRequest * allPosts = [[NSFetchRequest alloc] init];
    [allPosts setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext]];
    NSArray * posts = [self.managedObjectContext executeFetchRequest:allPosts error:nil];
    self.digestPosts = [NSMutableArray arrayWithArray:posts];
}

-(void)requestNewLinks{
    [self clearOutCoreData];

    self.digestPosts = [NSMutableArray array];

    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];

    NSString *urlString = [NSString stringWithFormat:@"http://192.168.129.228:3000/subreddits/%@",deviceString];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error == nil)
        {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"RESULTS %@",results);
            NSArray *usersSubredditsArray = results[@"subreddits"];
            [self findTopPostsFromSubreddit:usersSubredditsArray];
        }
    }];

    [dataTask resume];

}

-(void)findTopPostsFromSubreddit:(NSArray *)subreddits{

    __block int j = 0;
    for (NSDictionary *subredditDict in subreddits) {
        NSDictionary *setUpForRKKitObject = [[NSDictionary alloc] initWithObjectsAndKeys:subredditDict[@"subreddit"], @"name", subredditDict[@"url"], @"URL", nil];
        RKSubreddit *subreddit = [[RKSubreddit alloc] initWithDictionary:setUpForRKKitObject error:nil];

        [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
            RKLink *topPost = links.firstObject;
            if (topPost.stickied) {
                topPost = links[1];
            }

            [self addPostToCoreData:topPost];

            j += 1;

            if (j  == subreddits.count) {
                [self performNewFetchedDataActionsWithDataArray];
                [self fireLocalNotificationAndMarkComplete];
            }
        }];
    }
}

-(void)performNewFetchedDataActionsWithDataArray{
    [self retrievePostsFromCoreData];
    [self.digestTableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"PostSegue"]) {
        PostViewController *postViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.digestTableView indexPathForSelectedRow];

        if ([self.digestPosts[indexPath.row] isKindOfClass:[Post class]]) {
            postViewController.selectedPost = self.digestPosts[indexPath.row];
        }else{
            postViewController.selectedLink = self.digestPosts[indexPath.row];
        }
    }
}


-(IBAction)unwindFromSubredditSelectionViewController:(UIStoryboardSegue *)segue{
    [self runFirstDigest:self.subredditsForFirstDigest];
}

-(void)runFirstDigest:(NSArray *)subreddits{
    [self clearOutCoreData];

    __block int j = 0;
    for (NSDictionary *subredditDict in subreddits) {
        NSDictionary *setUpForRKKitObject = [[NSDictionary alloc] initWithObjectsAndKeys:subredditDict[@"name"], @"name", subredditDict[@"url"], @"URL", nil];
        RKSubreddit *subreddit = [[RKSubreddit alloc] initWithDictionary:setUpForRKKitObject error:nil];

        [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
            RKLink *topPost = links.firstObject;
            if (topPost.stickied) {
                topPost = links[1];
            }
            [self addPostToCoreData:topPost];

            j += 1;

            if (j  == subreddits.count) {
                [self performNewFetchedDataActionsWithDataArray];
            }
        }];
    }
}


@end
