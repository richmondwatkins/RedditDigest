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

    if (!post.thumbnailImage) {
        cell.thumbnailImage.image = [self squareCropImageToSideLength:[UIImage imageNamed:@"snoo_camera_placeholder"] sideLength:50];
        cell.thumbnailImage.alpha = 0.5;
    }
    else {
        cell.thumbnailImage.image = [self squareCropImageToSideLength:[UIImage imageWithData:post.thumbnailImage] sideLength:50];
    }
    cell.thumbnailImage.layer.cornerRadius = 2.0;
    cell.thumbnailImage.layer.masksToBounds = YES;

    return cell;
}

- (UIImage *)squareCropImageToSideLength:(UIImage *)sourceImage sideLength:(CGFloat)sideLength;
{
    // input size comes from image
    CGSize inputSize = sourceImage.size;

    // round up side length to avoid fractional output size
    sideLength = ceilf(sideLength);

    // output size has sideLength for both dimensions
    CGSize outputSize = CGSizeMake(sideLength, sideLength);

    // calculate scale so that smaller dimension fits sideLength
    CGFloat scale = MAX(sideLength / inputSize.width,
                        sideLength / inputSize.height);

    // scaling the image with this scale results in this output size
    CGSize scaledInputSize = CGSizeMake(inputSize.width * scale,
                                        inputSize.height * scale);

    // determine point in center of "canvas"
    CGPoint center = CGPointMake(outputSize.width/2.0,
                                 outputSize.height/2.0);

    // calculate drawing rect relative to output Size
    CGRect outputRect = CGRectMake(center.x - scaledInputSize.width/2.0,
                                   center.y - scaledInputSize.height/2.0,
                                   scaledInputSize.width,
                                   scaledInputSize.height);

    // begin a new bitmap context, scale 0 takes display scale
    UIGraphicsBeginImageContextWithOptions(outputSize, YES, 0);

    // optional: set the interpolation quality.
    // For this you need to grab the underlying CGContext
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);

    // draw the source image into the calculated rect
    [sourceImage drawInRect:outputRect];

    // create new image from bitmap context
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();

    // clean up
    UIGraphicsEndImageContext();

    // pass back new image
    return outImage;
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

-(void)retrievePostsFromCoreData:(void (^)(BOOL))completionHandler{
    self.digestPosts = [NSMutableArray array];

    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext]];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"subreddit" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];

    [fetch setSortDescriptors:@[sorter]];

    NSArray * posts = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    self.digestPosts = [NSMutableArray arrayWithArray:posts];
    NSLog(@"RETRIEVED ALL POSTS FROM CORE DATA %@",posts);
    if (self.digestPosts.count) {
        completionHandler(YES);
    }
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
    [self retrievePostsFromCoreData:^(BOOL completed) {
        if (completed) {
            [self.digestTableView reloadData];
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"PostSegue"]) {
        PostViewController *postViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.digestTableView indexPathForSelectedRow];
        postViewController.allPosts = self.digestPosts;
        postViewController.index = indexPath.row;
    }
}


-(IBAction)unwindFromSubredditSelectionViewController:(UIStoryboardSegue *)segue{
    [Post removeAllPostsFromCoreData:self.managedObjectContext];

    [RedditRequests retrieveLatestPostFromArray:self.subredditsForFirstDigest withManagedObject:self.managedObjectContext withCompletion:^(BOOL completed) {
        if (completed) {
            [self performNewFetchedDataActions];
        }
    }];
}


@end
