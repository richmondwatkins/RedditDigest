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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.digestPosts.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DigestCell"];
    RKLink *post = self.digestPosts[indexPath.row];

    cell.textLabel.text = post.title;
//    cell.detailTextLabel.text = post.subreddit;

    return cell;
}

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
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
    [self clearOutCoreData];

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

-(void)addPostToCoreData:(RKLink *)post{

//    @dynamic thumbnailImage;
//    @dynamic isImageLink;
//    @dynamic voteRatio;
//    @dynamic subreddit;
//    @dynamic isSelfPost;
//    @dynamic nsfw;
//    @dynamic author;

    Post *savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
    savedPost.title = post.title;

    if (post.isImageLink) {
        //download image and save data to core data
    }else{
        savedPost.url = [NSString stringWithFormat:@"%@", post.URL];
    }

    int totalComments = (int)post.totalComments;
    savedPost.totalComments = [NSNumber numberWithInt:totalComments];
    if (post.isSelfPost) {
        savedPost.selfText = post.selfText;
    }
    [self.managedObjectContext save:nil];
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
}


-(void)retrievePostsFromCoreData{
    NSFetchRequest * allPosts = [[NSFetchRequest alloc] init];
    [allPosts setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext]];
    NSArray * posts = [self.managedObjectContext executeFetchRequest:allPosts error:nil];
    self.digestPosts = [NSMutableArray arrayWithArray:posts];
    NSLog(@"THIS IS FROM CORE DATA %@",posts);

}

-(void)requestNewLinks{
    self.digestPosts = [NSMutableArray array];

    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];

    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.4:3000/subreddits/%@",deviceString];
//    NSString *urlString = [NSString stringWithFormat:@"http://192.168.129.228:3000/subreddits/%@",deviceString];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",data);
        if(error == nil)
        {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSArray *usersSubredditsArray = results[@"subreddits"];
            [self findTopPostsFromSubreddit:usersSubredditsArray];
        }
    }];

    [dataTask resume];

}

-(void)findTopPostsFromSubreddit:(NSArray *)subreddits{
    [self clearOutCoreData];

    __block int j = 0;
    for (NSDictionary *subredditDict in subreddits) {
        NSDictionary *setUpForRKKitObject = [[NSDictionary alloc] initWithObjectsAndKeys:subredditDict[@"subreddit"], @"name", subredditDict[@"url"], @"URL", nil];
        RKSubreddit *subreddit = [[RKSubreddit alloc] initWithDictionary:setUpForRKKitObject error:nil];

        [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
            RKLink *topPost = links.firstObject;
            if (topPost.stickied) {
                topPost = links[1];
            }
            NSLog(@"LINK : %@",topPost);
            [self.digestPosts addObject:topPost];
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
    [self.digestTableView reloadData];
}



@end
