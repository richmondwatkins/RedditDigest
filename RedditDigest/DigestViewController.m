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
#import "SettingsViewController.h"
#import "LoadingViewController.h"
#import "LoginViewController.h"
#import "Subreddit.h"
#import "DetailPostViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DigestPost.h"
#import <ZeroPush.h>
#import "MCSwipeTableViewCell.h"
#import "InternetConnectionTest.h"
#import "SettingsSlideDown.h"
#import "SettingsSlideUp.h"
#import "UserInteractionSettingsExit.h"
@interface DigestViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MCSwipeTableViewCellDelegate, UIActionSheetDelegate, UIViewControllerAnimatedTransitioning>

@property NSMutableArray *digestPosts;
@property UIRefreshControl *refreshControl;
@property UILabel *creatingYourDigestLabel;
@property NSString *dateToday;
@property CLLocationManager *locationManger;
@property CLLocation *userLocation;
@property BOOL didUpdateLocation;
@property NSCache *imageCache;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *todayBarButton;
@property DigestCellWithImageTableViewCell *longHoldCell;
@property NSTimer *snooTextTimer;
@property UserInteractionSettingsExit *interactiveTransition;
@end

@implementation DigestViewController

-(void)viewDidLoad{
    [super viewDidLoad];

    [self getDateString];
    self.navigationItem.title = self.dateToday;
    self.imageCache = [[NSCache alloc] init];

    self.digestTableView.contentOffset = CGPointMake(0, 0 - self.digestTableView.contentInset.top);
}

- (void)loadView
{
    [super loadView];
}

-(void)getDateString
{
    NSDateFormatter *dateFormat =[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
    NSString *todaysDate = [dateFormat stringFromDate:[NSDate date]];
    self.dateToday = todaysDate;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible == YES) {[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;}

    [UserRequests setUpRecommendationsOnServer:self.managedObjectContext]; //sets up the recommendations


    if (self.madeChangeToLocation) {
        [self performNewFetchedDataActions:YES];
    }

    [self.imageCache removeAllObjects];
    self.didUpdateLocation = NO;

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasSubscriptions"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WelcomViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
        welcomeViewController.managedObject = self.managedObjectContext;
        [self.parentViewController presentViewController:welcomeViewController animated:YES completion:nil];
    }
    [self checkForLocationServices];

    NSIndexPath *selectedRowIndexPath = [self.digestTableView indexPathForSelectedRow];
    if (selectedRowIndexPath) {
        [self.digestTableView reloadRowsAtIndexPaths:@[selectedRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self.digestTableView reloadData];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasFirstRecommendations"]) {
        [UserRequests setUpRecommendationsOnServer:self.managedObjectContext]; //sets up the recommendations
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasFirstRecommendations"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    // These two lines enable automatic cell resizing thanks to iOS 8 🐋
    self.digestTableView.estimatedRowHeight = 227.0;
    self.digestTableView.rowHeight = UITableViewAutomaticDimension;

    if (self.isComingFromSubredditSelectionView) {
        [self createLoadingSnoo];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }

    if (self.isFromPastDigest == NO && [[NSUserDefaults standardUserDefaults] boolForKey:@"HasSubscriptions"]) {
        [self initializeRefreshControl];

    }else if([[NSUserDefaults standardUserDefaults] boolForKey:@"HasSubscriptions"] && self.isFromPastDigest == YES){
        self.todayBarButton.title = @"Recent";
        [self.refreshControl endRefreshing];
        [self.refreshControl removeFromSuperview];
        self.refreshControl = nil;
        self.title = self.oldDigestDate;
    }
}

#pragma mark - Location Services
-(void)checkForLocationServices
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Location"] && [CLLocationManager locationServicesEnabled]) {
        self.locationManger = [[CLLocationManager alloc] init];
        self.locationManger.delegate = self;
        [self.locationManger startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (self.didUpdateLocation == NO) {
        for(CLLocation *location in locations){
//            if (location.verticalAccuracy < 100 && location.horizontalAccuracy < 100) {
                self.userLocation = location;
                [self findUsersLocationByCityName];
                [self.locationManger stopUpdatingLocation];
                self.didUpdateLocation = YES;
                break;
//            }
        }
    }
}

-(void)findUsersLocationByCityName{
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:self.userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if ((placemarks != nil) && (placemarks.count > 0)) {
            CLPlacemark *placeMark = placemarks.firstObject;
            NSDictionary *placeMarkDict = placeMark.addressDictionary;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [RedditRequests localSubredditRequest:placeMarkDict[@"City"] andStateAbbreviation:placeMarkDict[@"State"] withManagedObject:self.managedObjectContext withCompletion:^(NSMutableArray *posts) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                if (posts.count) {
                    for(Post *post in posts) {
                        [self.digestPosts insertObject:post atIndex:0];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        [self.digestTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }
            }];
        }
        else {
            // Handle the nil case if necessary.
        }
    }];
}

- (IBAction)onTodayButtonTouched:(id)sender {
    self.isFromPastDigest = NO;
    [self retrievePostsFromCoreData:NO withCompletion:^(BOOL completed) {
        if (!self.refreshControl) {
            self.todayBarButton.title = @"";
            [self initializeRefreshControl];
        }
    }];
}

#pragma mark - Animation

- (void)createLoadingSnoo
{
    NSArray *imageNames = @[@"loading_snoo0000", @"loading_snoo0001", @"loading_snoo0002", @"loading_snoo0003",
                            @"loading_snoo0004", @"loading_snoo0005", @"loading_snoo0006", @"loading_snoo0007",
                            @"loading_snoo0008", @"loading_snoo0009", @"loading_snoo0010", @"loading_snoo0011"];

    NSMutableArray *images = [NSMutableArray new];
    for (int i = 0; i < imageNames.count; i++) {
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    }

    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.tag = 1;

    // Add imageView for snoo
    UIImageView *animatingSnooImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 244, 345)];

    [animatingSnooImageView setFrame:({
        CGRect frame = animatingSnooImageView.frame;

        frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2.0;
        frame.origin.y = (self.view.frame.size.height - frame.size.height) / 2.0 - 50;

        CGRectIntegral(frame);
    })];

    //animatingSnooImageView.center = backgroundView.center;
    animatingSnooImageView.animationImages = images;
    animatingSnooImageView.animationDuration = 0.7;

    self.creatingYourDigestLabel = [UILabel new];
    self.creatingYourDigestLabel.text = @"Creating your digest.";
    [self.creatingYourDigestLabel sizeToFit];
    self.creatingYourDigestLabel.center = CGPointMake(self.view.bounds.size.width / 2, CGRectGetMaxY(animatingSnooImageView.frame) + 30);
    self.creatingYourDigestLabel.frame = UIEdgeInsetsInsetRect(self.creatingYourDigestLabel.frame, UIEdgeInsetsMake(0, 0, 0, -40));

    // Start timer that animates ellipse on the end of the "Creating your digest label..."
    if (!self.snooTextTimer) {
        self.snooTextTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerEllipse:) userInfo:nil repeats:YES];
    }

    [backgroundView addSubview:animatingSnooImageView];
    [animatingSnooImageView startAnimating];
    [backgroundView addSubview:self.creatingYourDigestLabel];
    [self.view addSubview:backgroundView];
}

-(void)timerEllipse:(NSTimer*)timer
{
    if ([self.creatingYourDigestLabel.text isEqualToString:@"Creating your digest"]) {
        self.creatingYourDigestLabel.text = @"Creating your digest.";
    } else if ([self.creatingYourDigestLabel.text isEqualToString:@"Creating your digest."]) {
        self.creatingYourDigestLabel.text = @"Creating your digest..";
    } else if ([self.creatingYourDigestLabel.text isEqualToString:@"Creating your digest.."]) {
        self.creatingYourDigestLabel.text = @"Creating your digest...";
    } else if ([self.creatingYourDigestLabel.text isEqualToString:@"Creating your digest..."]) {
        self.creatingYourDigestLabel.text = @"Creating your digest";
    }
}

#pragma mark - TableView Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.digestPosts.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DigestCellWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DigestCell"];

    [cell formatCellAndAllSubviews];

    cell.delegate = self;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnCell:)];
    [cell addGestureRecognizer:longPress];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UserIsLoggedIn"] && self.isFromPastDigest == NO) {
        [self setUpCellForDownVote:cell];
        [self setUpCellForUpVote:cell];
    }

    if (self.isFromPastDigest) {
        DigestPost *post = self.digestPosts[indexPath.row];

        cell.titleLabel.text = post.title;
        cell.subredditLabel.text = post.subreddit;
        cell.authorLabel.text = post.author;
        cell.upVoteDownVoteLabel.text = [self abbreviateNumber:post.voteRatio.integerValue];

        if ([post.image boolValue]) {
            cell.thumbnailImage.image = [self returnImageForCellFromData:post.postID withSubredditNameForKey:post.subreddit andFilePathPrefix:@"image-copy"];
        }else if([post.thumbnailImagePath boolValue]){
            cell.thumbnailImage.image = [self returnImageForCellFromData:post.postID withSubredditNameForKey:post.subreddit  andFilePathPrefix:@"thumbnail-copy"];
        }else if([post.subredditImage boolValue]){
            cell.thumbnailImage.image = [self returnImageForCellFromData:post.subreddit withSubredditNameForKey:post.subreddit andFilePathPrefix:@"subreddit-copy"];
        }else{
            cell.thumbnailImage.image = [UIImage imageNamed:@"snoo_camera_placeholder"];
        }
    }
    else {
        Post *post = self.digestPosts[indexPath.row];

        if (![post.isHidden boolValue]) {
            cell.titleLabel.text = post.title;
            cell.subredditLabel.text = post.subreddit.subreddit;
            cell.authorLabel.text = post.author;
            cell.upVoteDownVoteLabel.text = [self abbreviateNumber:post.voteRatio.integerValue];

            if ([post.viewed boolValue] == NO) {
                cell.checkmarkImageView.alpha = 0.0;
            }else{
                [UIView animateWithDuration:2.0 animations:^{
                    cell.checkmarkImageView.alpha = 0.3;
                }];
            }

            if ([post.isReported boolValue] == YES) {
                cell.checkmarkImageView.image = [UIImage imageNamed:@"warning"];
                cell.checkmarkImageView.alpha = 0.8;
            } 

            if ([post.image boolValue]) {
                cell.thumbnailImage.image = [self returnImageForCellFromData:post.postID withSubredditNameForKey:post.subreddit.subreddit andFilePathPrefix:@"image"];
            }else if([post.thumbnailImage boolValue]){
                cell.thumbnailImage.image = [self returnImageForCellFromData:post.postID withSubredditNameForKey:post.subreddit.subreddit andFilePathPrefix:@"thumbnail"];
            }else if([post.subreddit.image boolValue]){
                cell.thumbnailImage.image = [self returnImageForCellFromData:post.subreddit.subreddit withSubredditNameForKey:post.subreddit.subreddit andFilePathPrefix:@"subreddit"];
            }else{
                cell.thumbnailImage.image = [UIImage imageNamed:@"snoo_camera_placeholder"];
            }

            // Initialize vote status of cells
            if ([post.upvoted boolValue]) {
                cell.upvoteView.hidden = NO;
            }
            else {
                cell.upvoteView.hidden = YES;
            }

            if ([post.downvoted boolValue]) {
                cell.downvoteView.hidden = NO;
            }
            else {
                cell.downvoteView.hidden = YES;
            }

            if ([post.nsfw boolValue]) {
                UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
                effectView.frame = cell.thumbnailImage.bounds;
                [cell.thumbnailImage addSubview:effectView];
                cell.nsfwLabel.hidden = NO;
            }else{
                [[cell.thumbnailImage subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                cell.nsfwLabel.hidden = YES;
            }
        }
    }

    return cell;
}

- (UIView *)viewWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

-(UIImage *)returnImageForCellFromData:(NSString *)filePath withSubredditNameForKey:(NSString *)subreddit andFilePathPrefix:(NSString *)prefix{
    UIImage *image = [self.imageCache objectForKey:subreddit];
    if (image == nil) {
        NSData *imageData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:filePath withPrefix:prefix]];
        image = [UIImage imageWithData:imageData];
        if (image) {
            [self.imageCache setObject:image forKey:subreddit];
        }
    }
    return image;
}

- (NSString *)documentsPathForFileName:(NSString *)name withPrefix:(NSString *)prefix
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];

    NSString *pathCompenent = [NSString stringWithFormat:@"%@-%@",prefix, name];
    return [documentsPath stringByAppendingPathComponent:pathCompenent];
}

-(void)setUpCellForDownVote:(DigestCellWithImageTableViewCell *)cell{
    UIView *downVoteView = [self viewWithImageName:@"down_arrow_white"];
    UIColor *downVoteColor = [UIColor colorWithRed:0.58 green:0.58 blue:1 alpha:1];

    cell.downvoteView.backgroundColor = downVoteColor;

    [cell setSwipeGestureWithView:downVoteView color:downVoteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
     {
         DigestCellWithImageTableViewCell *swipedCell  = (DigestCellWithImageTableViewCell *)cell;
         NSIndexPath *swipedIndexPath = [self.digestTableView indexPathForCell:swipedCell];

         Post *post = [self.digestPosts objectAtIndex:swipedIndexPath.row];

         if ([post.downvoted boolValue]) {
             swipedCell.upvoteView.hidden = YES;
             swipedCell.downvoteView.hidden = YES;
             post.upvoted = [NSNumber numberWithBool:NO];
             post.downvoted = [NSNumber numberWithBool:NO];
             // Remove from reddit
             [self removeVoteFromReddit:post.postID];
         }
         else {
             swipedCell.upvoteView.hidden = YES;
             swipedCell.downvoteView.hidden = NO;
             post.upvoted = [NSNumber numberWithBool:NO];
             post.downvoted = [NSNumber numberWithBool:YES];
             // Send downvote to reddit
             [self sendDownVoteToReddit:post.postID];
         }
         [self.managedObjectContext save:nil];
     }];
}

-(void)setUpCellForUpVote:(DigestCellWithImageTableViewCell *)cell{

    UIView *upVoteView = [self viewWithImageName:@"up_arrow_white"];
    UIColor *upVoteColor = [UIColor colorWithRed:1 green:0.545 blue:0.376 alpha:1];
    cell.upvoteView.backgroundColor = upVoteColor;

    [cell setSwipeGestureWithView:upVoteView color:upVoteColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
     {
         DigestCellWithImageTableViewCell *swipedCell  = (DigestCellWithImageTableViewCell *)cell;
         NSIndexPath *swipedIndexPath = [self.digestTableView indexPathForCell:swipedCell];

         Post *post = [self.digestPosts objectAtIndex:swipedIndexPath.row];

         if ([post.upvoted boolValue]) {
             // Remove upvote
             swipedCell.upvoteView.hidden = YES;
             swipedCell.downvoteView.hidden = YES;
             post.upvoted = [NSNumber numberWithBool:NO];
             post.downvoted = [NSNumber numberWithBool:NO];
             // Remove from reddit
             [self removeVoteFromReddit:post.postID];
         }
         else {
             // Upvote
             swipedCell.upvoteView.hidden = NO;
             swipedCell.downvoteView.hidden = YES;
             post.upvoted = [NSNumber numberWithBool:YES];
             post.downvoted = [NSNumber numberWithBool:NO];
             // Send upvote to reddit
             [self sendUpVoteToReddit:post.postID];
         }
         [self.managedObjectContext save:nil];
     }];
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        //for example [activityIndicator stopAnimating];
        // Close the loading snoo when subreddit loading is done
        if (self.isComingFromSubredditSelectionView) {

            [self removeSnooFromView];

            //[self dismissViewControllerAnimated:YES completion:nil];
            self.isComingFromSubredditSelectionView = NO;
        }
    }
}

- (void)removeSnooFromView{
    UIView *viewToRemove = [self.view viewWithTag:1];
    [self.snooTextTimer invalidate];
    self.navigationItem.rightBarButtonItem.enabled = YES;

    // Fade out loading snoo
    [UIView animateWithDuration:0.3 delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{ viewToRemove.alpha = 0.0;}
                     completion:^(BOOL fin) {
                         if (fin) [viewToRemove removeFromSuperview];
                     }];
}

-(NSString *)abbreviateNumber:(NSInteger)num
{
    NSString *abbreviatedNumunber;
    float number = (float)num;

    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbreviations = @[@"k", @"m", @"b"];

        for (NSInteger i = abbreviations.count - 1; i >= 0; i--)
        {
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);

            if (size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];

                // Add the letter for the abbreviation
                abbreviatedNumunber = [NSString stringWithFormat:@"%@%@", numberString, [abbreviations objectAtIndex:i]];
            }
        }
    } else {
        // Numbers like: 999 returns 999 instead of NULL
        abbreviatedNumunber = [NSString stringWithFormat:@"%d", (int)number];
    }
    return abbreviatedNumunber;
}

- (NSString *) floatToString:(float) val
{
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];

    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    return ret;
}


#pragma mark - Fetch from Server

-(void)fetchNewData:(BOOL)isDigest withCompletion:(void (^)(UIBackgroundFetchResult))completionHandler
{
//    [Post removeAllPostsFromCoreData:self.managedObjectContext];
    [self.digestPosts removeAllObjects];
    NSArray *subreddits = [Subreddit retrieveAllSubreddits:self.managedObjectContext];
    [RedditRequests retrieveLatestPostFromArray:subreddits withManagedObject:self.managedObjectContext  withCompletion:^(BOOL completed) {
        [self performNewFetchedDataActions:isDigest];
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}

-(void)retrievePostsFromCoreData:(BOOL)isDigest withCompletion:(void (^)(BOOL))completionHandler
{

    self.digestPosts = [NSMutableArray array];

    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext]];
    NSSortDescriptor *voteSort = [[NSSortDescriptor alloc] initWithKey:@"voteRatio" ascending:NO];
    NSSortDescriptor *localSort = [[NSSortDescriptor alloc] initWithKey:@"isLocalPost" ascending:NO];
    fetch.predicate = [NSPredicate predicateWithFormat:@"isHidden != 1"];
    [fetch setSortDescriptors:@[localSort, voteSort]];

    NSArray * posts = [self.managedObjectContext executeFetchRequest:fetch error:nil];

    self.digestPosts = [NSMutableArray arrayWithArray:posts];

    if (self.digestPosts.count) {
        completionHandler(YES);
        [self.imageCache removeAllObjects];
        [self getDateString];
        [self.digestTableView reloadData];

        if (isDigest) {
            [DigestPost createNewDigestPosts:posts withManagedObject:self.managedObjectContext];
        }
    }
}

-(void)requestNewLinksFromRefresh
{
    self.isFromPastDigest = NO;
    [self requestNewLinks:NO];
}

-(void)requestNewLinks:(BOOL)isDigest
{

    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Subreddit" inManagedObjectContext:self.managedObjectContext]];

    NSArray *subreddits = [self.managedObjectContext executeFetchRequest:fetch error:nil];

    [RedditRequests retrieveLatestPostFromArray:subreddits withManagedObject:self.managedObjectContext withCompletion:^(BOOL completed) {
        [self performNewFetchedDataActions:isDigest];
    }];
}

-(void)performNewFetchedDataActions:(BOOL)isDigest
{
    [self retrievePostsFromCoreData:isDigest withCompletion:^(BOOL completed) {
        if (completed) {
            [self.refreshControl endRefreshing];
            [self.refreshControl endRefreshing];
        }
    }];
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PostSegue"])
    {
        DetailPostViewController *detailPostViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.digestTableView indexPathForSelectedRow];
        detailPostViewController.allPosts = self.digestPosts;
        detailPostViewController.index = indexPath.row;
        detailPostViewController.managedObjectContext = self.managedObjectContext;
        if (self.isFromPastDigest) {
            detailPostViewController.isFromPastDigest = YES;
        }

        self.navigationController.delegate = nil;
    }
    else if ([segue.identifier isEqualToString:@"SettingsSegue"])
    {
        self.navigationController.delegate = self; //for custom transition

        SettingsViewController *settingsController = segue.destinationViewController;
        settingsController.managedObject = self.managedObjectContext;
        settingsController.digestViewController = self;
    }

    [self.imageCache removeAllObjects];
    [self.refreshControl endRefreshing];
    [self.refreshControl removeFromSuperview];
    self.refreshControl = nil;
}

-(IBAction)unwindFromSubredditSelectionViewController:(UIStoryboardSegue *)segue
{
    if (self.isFromPastDigest) {
        [self.imageCache removeAllObjects];
        NSSortDescriptor *voteSort = [NSSortDescriptor sortDescriptorWithKey:@"voteRatio" ascending:NO];
        self.digestPosts = [NSMutableArray arrayWithArray:[self.oldDigest sortedArrayUsingDescriptors:[NSArray arrayWithObject:voteSort]]];

        [self.digestTableView reloadData];
    }

    if (self.isComingFromSubredditSelectionView) {
        [self.digestPosts removeAllObjects];
        [self requestNewLinks:NO];

        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"HasSubscriptions"]){

            UIApplication *application = [UIApplication sharedApplication];
            [ZeroPush engageWithAPIKey:@"QfpEFaa6fkgKYzUCYGQE" delegate:application];
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[ZeroPush shared] registerForRemoteNotifications];
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [application registerForRemoteNotifications];

            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasSubscriptions"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }


        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasFirstRecommendations"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasFirstRecommendations"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        [UserRequests setUpRecommendationsOnServer:self.managedObjectContext]; //sets up the recommendations
    }
}

-(void)convertToPostObjects:(NSArray *)digestPosts
{
    for (DigestPost *digestPost in digestPosts) {
        Post *post = [[Post alloc] init];
        post.title = digestPost.title;
        post.subreddit.subreddit = digestPost.subreddit;
        post.author = digestPost.author;
        post.voteRatio = digestPost.voteRatio;
        post.totalComments = digestPost.totalComments;
        post.postID = digestPost.postID;
        post.image = digestPost.image;
        post.subreddit.image = digestPost.subredditImage;

        [self.digestPosts addObject:post];
    }
    [self.digestTableView reloadData];
}

#pragma mark - Upvote & Downvote

-(void)sendUpVoteToReddit:(NSString *)postID{
    [[RKClient sharedClient] linkWithFullName:postID completion:^(id object, NSError *error) {
        [[RKClient sharedClient] upvote:object completion:^(NSError *error) {
            //NSLog(@"Upvote");
        }];
    }];
}

-(void)sendDownVoteToReddit:(NSString *)postID{
    [[RKClient sharedClient] linkWithFullName:postID completion:^(id object, NSError *error) {
        [[RKClient sharedClient] downvote:object completion:^(NSError *error) {
            //NSLog(@"Downvote");
        }];
    }];
}

-(void)initializeRefreshControl{

    [InternetConnectionTest testInternetConnectionWithViewController:self andCompletion:^(BOOL internet) {
        if (internet && !self.refreshControl) {
            self.refreshControl = [[UIRefreshControl alloc] init];

            [self.refreshControl addTarget:self action:@selector(requestNewLinksFromRefresh) forControlEvents:UIControlEventValueChanged];
            [self.digestTableView addSubview:self.refreshControl];
        }else{
            [self.refreshControl endRefreshing];
            [self.refreshControl removeFromSuperview];
            self.refreshControl = nil;
            [self.refreshControl endRefreshing];
            [self.refreshControl removeFromSuperview];
            self.refreshControl = nil;
        }
    }];
}

- (void)removeVoteFromReddit:(NSString *)postID
{
    [[RKClient sharedClient] linkWithFullName:postID completion:^(id object, NSError *error) {
        [[RKClient sharedClient] revokeVote:object completion:^(NSError *error) {
            //NSLog(@"Removed Vote");
        }];
    }];
}

-(void)hideButtonPressed{
    NSIndexPath *indexPath = [self.digestTableView indexPathForCell:self.longHoldCell];
    Post *objectToHide = [self.digestPosts objectAtIndex:indexPath.row];
    [Post removePhotoFromDocumentDirectory:objectToHide.postID];
    [objectToHide markPostAsHidden];
    [self.imageCache removeObjectForKey:objectToHide.subreddit.subreddit];
    [self.digestPosts removeObjectAtIndex:indexPath.row];
    [self.digestTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    [self.digestTableView reloadData];
}

-(void)reportPost{
    NSIndexPath *indexPath = [self.digestTableView indexPathForCell:self.longHoldCell];
    Post *objectToReport = [self.digestPosts objectAtIndex:indexPath.row];

    [[RKClient sharedClient] linkWithFullName:objectToReport.postID completion:^(RKLink *object, NSError *error) {
        [[RKClient sharedClient] reportLink:object completion:^(NSError *error) {
            [objectToReport markPostAsReported];
            [self.digestTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self reportPost];
    }else if (buttonIndex == 1){
        [self hideButtonPressed];
    }
}

-(void)longPressOnCell:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
       self.longHoldCell = (DigestCellWithImageTableViewCell *)[self.digestTableView cellForRowAtIndexPath:[self.digestTableView indexPathForRowAtPoint:[gesture locationInView:self.digestTableView]]];

        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Hide or Report"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Report"
                                                        otherButtonTitles:@"Hide", nil];

        [actionSheet showInView:self.view];
    }
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{

    if ([fromVC isKindOfClass:[self class]] && [toVC isKindOfClass:[SettingsViewController class]]) {
        SettingsSlideDown *customTransitions = [[SettingsSlideDown alloc] init];
        return customTransitions;
    }

    if ([toVC isKindOfClass:[DigestViewController class]] && [fromVC isKindOfClass:[SettingsViewController class]]) {
        SettingsSlideUp *customSlideUp = [[SettingsSlideUp alloc] init];
        return customSlideUp;
    }

    return nil;
}

-(id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{

    if (self.interactiveTransition.isInteractive) {
        return self.interactiveTransition;
    }

    return nil;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!self.interactiveTransition && [viewController isKindOfClass:[SettingsViewController class]]) {
        self.interactiveTransition = [[UserInteractionSettingsExit alloc] init];
    }
    [self.interactiveTransition addInteractionToViewController:viewController];
}

@end
