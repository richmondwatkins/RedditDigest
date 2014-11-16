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

@interface DigestViewController () <UITableViewDataSource, UITableViewDelegate, DigestCellDelegate, CLLocationManagerDelegate>

@property NSMutableArray *digestPosts;
@property UIRefreshControl *refreshControl;
@property UILabel *creatingYourDigestLabel;
@property NSTimer *snooTextTimer;
@property NSString *dateToday;
@property CLLocationManager *locationManger;
@property CLLocation *userLocation;
@property BOOL didUpdateLocation;
@property NSCache *imageCache;
@end

@implementation DigestViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(requestNewLinks) forControlEvents:UIControlEventValueChanged];
    [self.digestTableView addSubview:self.refreshControl];
    [self getDateString];
    self.navigationItem.title = self.dateToday;
    [self checkForLocationServices];

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
    self.imageCache = [[NSCache alloc] init];
    self.didUpdateLocation = NO;

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasSubscriptions"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WelcomViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
        welcomeViewController.managedObject = self.managedObjectContext;
        [self.parentViewController presentViewController:welcomeViewController animated:YES completion:nil];
    }

//    [self performNewFetchedDataActions];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // These two lines enable automatic cell resizing thanks to iOS 8 🐋
    self.digestTableView.estimatedRowHeight = 68.0;
    self.digestTableView.rowHeight = UITableViewAutomaticDimension;

    if (self.isComingFromSubredditSelectionView) {
        [self createLoadingSnoo];
    }
//    [self.digestTableView reloadData];
}

#pragma mark - Location Services
-(void)checkForLocationServices{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Location"] && [CLLocationManager locationServicesEnabled]) {
        self.locationManger = [[CLLocationManager alloc] init];
        self.locationManger.delegate = self;
        [self.locationManger startUpdatingLocation];
    }
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if (self.didUpdateLocation == NO) {
        for(CLLocation *location in locations){
            if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
                self.userLocation = location;
                [self findUsersLocationByCityName];
                [self.locationManger stopUpdatingLocation];
                self.didUpdateLocation = YES;
                break;
            }
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

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    blurEffectView.frame = self.view.bounds;
    blurEffectView.tag = 1;
    [self.view addSubview:blurEffectView];

    // Add imageView for snoo
    UIImageView *animatingSnooImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 244, 345)];
    animatingSnooImageView.translatesAutoresizingMaskIntoConstraints = NO;
    animatingSnooImageView.center = blurEffectView.center;
    animatingSnooImageView.animationImages = images;
    animatingSnooImageView.animationDuration = 0.7;

    // Add creating your digest label
    self.creatingYourDigestLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, animatingSnooImageView.frame.size.width + 20, 20)];
    self.creatingYourDigestLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.creatingYourDigestLabel.text = @"Creating your digest.";

    // Start timer that animates ellipse on the end of the "Creating your digest label..."
    if (!self.snooTextTimer) {
        self.snooTextTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerEllipse:) userInfo:nil repeats:YES];
    }

    [blurEffectView.contentView addSubview:animatingSnooImageView];
    [animatingSnooImageView startAnimating];
    [blurEffectView.contentView addSubview:self.creatingYourDigestLabel];

    NSLayoutConstraint *blurEffectViewTop = [NSLayoutConstraint constraintWithItem:blurEffectView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:0];
    [self.view addConstraint:blurEffectViewTop];


    NSLayoutConstraint *blurEffectViewLeft = [NSLayoutConstraint constraintWithItem:blurEffectView
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:0];
    [self.view addConstraint:blurEffectViewLeft];

    NSLayoutConstraint *blurEffectViewRight = [NSLayoutConstraint constraintWithItem:blurEffectView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:0];
    [self.view addConstraint:blurEffectViewRight];

    NSLayoutConstraint *blurEffectViewBottom = [NSLayoutConstraint constraintWithItem:blurEffectView
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.view
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0
                                                                            constant:0];
    [self.view addConstraint:blurEffectViewBottom];

    // Animating snoo constraints
    NSLayoutConstraint *snooWidth = [NSLayoutConstraint constraintWithItem:animatingSnooImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:244];
    [animatingSnooImageView addConstraint:snooWidth];

    NSLayoutConstraint *snooTop = [NSLayoutConstraint constraintWithItem:animatingSnooImageView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:blurEffectView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:45];
    [blurEffectView addConstraint:snooTop];

    NSLayoutConstraint *snooCenterX = [NSLayoutConstraint constraintWithItem:animatingSnooImageView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:blurEffectView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0.0];

    [blurEffectView addConstraint:snooCenterX];

    NSLayoutConstraint *snooBottom = [NSLayoutConstraint constraintWithItem:animatingSnooImageView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:blurEffectView
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:-85.0];
    [blurEffectView addConstraint:snooBottom];

    NSLayoutConstraint *snooAspectRatio = [NSLayoutConstraint constraintWithItem:animatingSnooImageView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:animatingSnooImageView
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.66
                                                                        constant:0.0];

    [animatingSnooImageView addConstraint:snooAspectRatio];

    // Creating your digest label constratins
    NSLayoutConstraint *creatingDigestTextLabelBottom = [NSLayoutConstraint constraintWithItem:self.creatingYourDigestLabel
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:animatingSnooImageView
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                    multiplier:1.0
                                                                                      constant:20.0];

    [blurEffectView addConstraint:creatingDigestTextLabelBottom];

    NSLayoutConstraint *creatingDigestTextLabelCenterX = [NSLayoutConstraint constraintWithItem:self.creatingYourDigestLabel
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:blurEffectView
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                     multiplier:1.0
                                                                                       constant:0.0];
    
    [blurEffectView addConstraint:creatingDigestTextLabelCenterX];
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

    Post *post = self.digestPosts[indexPath.row];
    cell.delegate = self;
    cell.titleLabel.text = post.title;
    cell.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.titleLabel.numberOfLines = 0;

    cell.titleLabel.shadowColor = [UIColor grayColor];
    cell.titleLabel.shadowOffset = CGSizeMake(0, -1.0);

    cell.subredditLabel.text = post.subreddit.subreddit;
    cell.authorLabel.text = post.author;
    cell.upVoteDownVoteLabel.text = [self abbreviateNumber:post.voteRatio.integerValue];
    cell.commentsLabel.text = [self abbreviateNumber:post.totalComments.integerValue];

    if (post.image) {
        cell.thumbnailImage.image = [self returnImageForCellFromData:post.image withSubredditNameForKey:post.subreddit.subreddit];
    }else if(post.thumbnailImage){
        cell.thumbnailImage.image = [self returnImageForCellFromData:post.thumbnailImage withSubredditNameForKey:post.subreddit.subreddit];
    }else if(post.subreddit.image){
        cell.thumbnailImage.image = [self returnImageForCellFromData:post.subreddit.image withSubredditNameForKey:post.subreddit.subreddit];
    }else{
        cell.thumbnailImage.image = [UIImage imageNamed:@"snoo_camera_placeholder"];
    }


    cell.thumbnailImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.thumbnailImage.alpha = 0.4;
    //    (post.viewed) ? cell.thumbnailImage.alpha = 0.2 : (cell.thumbnailImage.alpha = 1);

    if ([post.upvoted boolValue] == YES) {
        [cell.upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvote_arrow_selected"] forState:UIControlStateNormal];
    }else{
        [cell.upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvote_arrow"] forState:UIControlStateNormal];
    }
    if ([post.downvoted boolValue] == YES) {
        [cell.downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvote_arrow_selected"] forState:UIControlStateNormal];
    }else{
        [cell.downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvote_arrow"] forState:UIControlStateNormal];
    }

    cell.thumbnailImage.layer.cornerRadius = 2.0;
    cell.thumbnailImage.layer.masksToBounds = YES;

    return cell;
}

-(UIImage *)returnImageForCellFromData:(NSData *)imageData withSubredditNameForKey:(NSString *)subreddit{
    UIImage *image = [self.imageCache objectForKey:subreddit];
    if (image == nil) {
        image = [UIImage imageWithData:imageData];
        [self.imageCache setObject:image forKey:subreddit];
    }
    return image;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        //for example [activityIndicator stopAnimating];
        // Close the loading snoo when subreddit loading is done
        if (self.isComingFromSubredditSelectionView) {
            UIView *viewToRemove = [self.view viewWithTag:1];
            [self.snooTextTimer invalidate];

            // Fade out loading snoo
            [UIView animateWithDuration:0.3 delay:0.0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{ viewToRemove.alpha = 0.0;}
                             completion:^(BOOL fin) {
                                 if (fin) [viewToRemove removeFromSuperview];
                             }];

            //[self dismissViewControllerAnimated:YES completion:nil];
            self.isComingFromSubredditSelectionView = NO;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  200;
}

-(NSString *)abbreviateNumber:(int)num
{
    NSString *abbrevNum;
    float number = (float)num;

    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"k", @"m", @"b"];

        for (int i = abbrev.count - 1; i >= 0; i--)
        {
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);

            if (size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];

                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
        }
    } else {
        // Numbers like: 999 returns 999 instead of NULL
        abbrevNum = [NSString stringWithFormat:@"%d", (int)number];
    }
    return abbrevNum;
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

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [Post removeAllPostsFromCoreData:self.managedObjectContext];
    [self.digestPosts removeAllObjects];
    NSArray *subreddits = [Subreddit retrieveAllSubreddits:self.managedObjectContext];
    [RedditRequests retrieveLatestPostFromArray:subreddits withManagedObject:self.managedObjectContext withCompletion:^(BOOL completed) {
        [self performNewFetchedDataActions];
        completionHandler(UIBackgroundFetchResultNewData);
        [self fireLocalNotificationAndMarkComplete];
    }];

}

-(void)fireLocalNotificationAndMarkComplete
{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = @"Your reddit digest is ready for viewing";
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeObject = [NSNumber numberWithDouble:timeInMiliseconds];
    [userDefaults setObject:timeObject forKey:@"LastDigest"];

    NSNumber *currentDigest = [userDefaults objectForKey:@"NextDigest"];
    [userDefaults setObject:currentDigest forKey:@"LastScheduled"];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *eveningComponents = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    eveningComponents.hour = 20;
    eveningComponents.timeZone = [NSTimeZone localTimeZone];
    NSDate *eveningDate = [calendar dateFromComponents:eveningComponents];
    NSTimeInterval eveningDigest = [eveningDate timeIntervalSince1970];

    NSDateComponents *morningComponents = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    morningComponents.hour = 8;
    morningComponents.timeZone = [NSTimeZone localTimeZone];
    NSDate *morningDate = [calendar dateFromComponents:morningComponents];
    NSTimeInterval morningDigest = [morningDate timeIntervalSince1970];

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now < eveningDigest) {
        [userDefaults setObject:[NSNumber numberWithDouble:eveningDigest] forKey:@"NextDigest"];
    }else{
        [userDefaults setObject:[NSNumber numberWithDouble:morningDigest] forKey:@"NextDigest"];
    [userDefaults synchronize];
    }
}

-(void)retrievePostsFromCoreData:(void (^)(BOOL))completionHandler
{
    self.digestPosts = [NSMutableArray array];

    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext]];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"voteRatio" ascending:NO];

    [fetch setSortDescriptors:@[sorter]];

    NSArray * posts = [self.managedObjectContext executeFetchRequest:fetch error:nil];

    self.digestPosts = [NSMutableArray arrayWithArray:posts];

    if (self.digestPosts.count) {
        completionHandler(YES);
        [self.digestTableView reloadData];
    }
}


-(void)requestNewLinks
{
    [Post removeAllPostsFromCoreData:self.managedObjectContext];

    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Subreddit" inManagedObjectContext:self.managedObjectContext]];

    NSArray *subreddits = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    
    [RedditRequests retrieveLatestPostFromArray:subreddits withManagedObject:self.managedObjectContext withCompletion:^(BOOL completed) {
        [self performNewFetchedDataActions];
    }];
}

-(void)performNewFetchedDataActions
{
    [self retrievePostsFromCoreData:^(BOOL completed) {
        if (completed) {
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
    }
    else if ([segue.identifier isEqualToString:@"SettingsSegue"])
    {
        SettingsViewController *settingsController = segue.destinationViewController;
        settingsController.managedObject = self.managedObjectContext;
    }
}

-(IBAction)unwindFromSubredditSelectionViewController:(UIStoryboardSegue *)segue
{
    [Post removeAllPostsFromCoreData:self.managedObjectContext];
    [self.digestPosts removeAllObjects];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasSubscriptions"];
    [[NSUserDefaults standardUserDefaults] synchronize];


    if (self.isComingFromSubredditSelectionView) {
        [self requestNewLinks];
    }
}

#pragma mark - Buttons & Gestures

-(void)upVoteButtonPressed:(DigestCellWithImageTableViewCell*)cell{

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasRedditAccount"]){

        NSIndexPath *indexPath = [self.digestTableView indexPathForCell:cell];
        Post *selectedPost = [self.digestPosts objectAtIndex:indexPath.row];

        selectedPost.upvoted = [NSNumber numberWithBool:YES];
        selectedPost.downvoted = [NSNumber numberWithBool:NO];
        [self.managedObjectContext save:nil];

        [cell.upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvote_arrow_selected"] forState:UIControlStateNormal];
        [cell.downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvote_arrow"] forState:UIControlStateNormal];

        [self sendUpVoteToReddit:selectedPost.postID];
    }
}

-(void)downVoteButtonPressed:(DigestCellWithImageTableViewCell *)cell{

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasRedditAccount"]){
        
        NSIndexPath *indexPath = [self.digestTableView indexPathForCell:cell];
        Post *selectedPost = [self.digestPosts objectAtIndex:indexPath.row];

        selectedPost.downvoted = [NSNumber numberWithBool:YES];
        selectedPost.upvoted = [NSNumber numberWithBool:NO];
        [self.managedObjectContext save:nil];

        [cell.downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvote_arrow_selected"] forState:UIControlStateNormal];
        [cell.upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvote_arrow"] forState:UIControlStateNormal];

        UIView *view = [[UIView alloc] init];
        view.frame = cell.frame;
        view.center = cell.center;
//        [cell addSubview:view];
//        view.backgroundColor = [UIColor blueColor];
//        view.alpha = 1.0;
////        cell.backgroundColor = [UIColor blueColor];
////        cell.titleLabel.backgroundColor = [UIColor blueColor];
////        cell.subredditLabel.backgroundColor = [UIColor blueColor];
////        cell.authorLabel.backgroundColor = [UIColor blueColor];
//        [UIView animateWithDuration:0.3 animations:^{
//            view.alpha = 0;
//            view.backgroundColor = [UIColor whiteColor];
////            cell.backgroundColor = [UIColor whiteColor];
////            cell.titleLabel.backgroundColor = [UIColor whiteColor];
////            cell.subredditLabel.backgroundColor = [UIColor whiteColor];
////            cell.authorLabel.backgroundColor = [UIColor whiteColor];
//        }];



        [self sendDownVoteToReddit:selectedPost.postID];
    }
}

- (IBAction)onRightSwipeGesture:(UISwipeGestureRecognizer *)rightSwipe
{

    CGPoint location = [rightSwipe locationInView:self.digestTableView];
    NSIndexPath *swipedIndexPath = [self.digestTableView indexPathForRowAtPoint:location];
    DigestCellWithImageTableViewCell *swipedCell  = (DigestCellWithImageTableViewCell *)[self.digestTableView cellForRowAtIndexPath:swipedIndexPath];
    Post *post = [self.digestPosts objectAtIndex:swipedIndexPath.row];
    post.upvoted = [NSNumber numberWithBool:YES];
    

    [self upVoteButtonPressed:swipedCell];
}

- (IBAction)onLeftSwipeGesture:(UISwipeGestureRecognizer *)leftSwipe
{
    CGPoint location = [leftSwipe locationInView:self.digestTableView];
    NSIndexPath *swipedIndexPath = [self.digestTableView indexPathForRowAtPoint:location];
    DigestCellWithImageTableViewCell *swipedCell  = (DigestCellWithImageTableViewCell *)[self.digestTableView cellForRowAtIndexPath:swipedIndexPath];
    Post *post = [self.digestPosts objectAtIndex:swipedIndexPath.row];
    post.downvoted = [NSNumber numberWithBool:YES];

        [self downVoteButtonPressed:swipedCell];
}

-(void)sendUpVoteToReddit:(NSString *)postID{
    [[RKClient sharedClient] linkWithFullName:postID completion:^(id object, NSError *error) {
        [[RKClient sharedClient] upvote:object completion:^(NSError *error) {
            NSLog(@"Upvote");
        }];
    }];
}

-(void)sendDownVoteToReddit:(NSString *)postID{
    [[RKClient sharedClient] linkWithFullName:postID completion:^(id object, NSError *error) {
        [[RKClient sharedClient] downvote:object completion:^(NSError *error) {
            NSLog(@"Downvote");
        }];
    }];
}

@end
