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
#import "RedditRequests.h"
#import "UserRequests.h"
#import "DigestCellWithImageTableViewCell.h"
#import "WelcomViewController.h"
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
        [self performNewFetchedDataActions];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WelcomViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
        welcomeViewController.managedObject = self.managedObjectContext;
        [self.parentViewController presentViewController:welcomeViewController animated:YES completion:nil];

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // These two lines enable automatic cell resizing thanks to iOS 8 💃
    self.digestTableView.estimatedRowHeight = 68.0;
    self.digestTableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - TableView Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.digestPosts.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    DigestCellWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DigestCell"];

    Post *post = self.digestPosts[indexPath.row];
    cell.titleLabel.text = post.title;
    cell.subredditAndAuthorLabel.text = post.subreddit;
//        cell.imageView.image = [UIImage imageWithData:post.thumbnailImage];

    return cell;
}


#pragma mark - Fetch from Server

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [Post removeAllPostsFromCoreData:self.managedObjectContext];

    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    [UserRequests retrieveUsersSubreddits:deviceString withCompletion:^(NSDictionary *results) {
        [RedditRequests retrieveLatestPostFromArray:results[@"subreddits"] withManagedObject:self.managedObjectContext withCompletion:^(BOOL completed) {
            [self performNewFetchedDataActions];
            completionHandler(UIBackgroundFetchResultNewData);
            [self fireLocalNotificationAndMarkComplete];
        }];
    }];

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

-(void)retrievePostsFromCoreData{
    self.digestPosts = [NSMutableArray array];

    NSFetchRequest * allPosts = [[NSFetchRequest alloc] init];
    [allPosts setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext]];
    NSArray * posts = [self.managedObjectContext executeFetchRequest:allPosts error:nil];
    self.digestPosts = [NSMutableArray arrayWithArray:posts];
}

-(void)requestNewLinks{
    [Post removeAllPostsFromCoreData:self.managedObjectContext];

    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    [UserRequests retrieveUsersSubreddits:deviceString withCompletion:^(NSDictionary *results) {

        [RedditRequests retrieveLatestPostFromArray:results[@"subreddits"] withManagedObject:self.managedObjectContext withCompletion:^(BOOL completed) {
            [self performNewFetchedDataActions];
            [self fireLocalNotificationAndMarkComplete];
        }];
    }];

}


-(void)performNewFetchedDataActions{
    [self retrievePostsFromCoreData];
    [self.digestTableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"PostSegue"]) {
        PostViewController *postViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.digestTableView indexPathForSelectedRow];
        postViewController.allPosts = self.digestPosts;
        if ([self.digestPosts[indexPath.row] isKindOfClass:[Post class]]) {
            postViewController.selectedPost = self.digestPosts[indexPath.row];
        }else{
            postViewController.selectedLink = self.digestPosts[indexPath.row];
        }
    }
}


-(IBAction)unwindFromSubredditSelectionViewController:(UIStoryboardSegue *)segue{
    [RedditRequests retrieveLatestPostFromArray:self.subredditsForFirstDigest withManagedObject:self.managedObjectContext withCompletion:^(BOOL completed) {
        if (completed) {
            [self performNewFetchedDataActions];
        }
    }];
}


@end
