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


@interface DigestViewController () <UITableViewDataSource, UITableViewDelegate, DigestCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *digestTableView;
@property NSMutableArray *digestPosts;
@property UIRefreshControl *refreshControl;
@property UILabel *creatingYourDigestLabel;
@property NSTimer *snooTextTimer;

@end

@implementation DigestViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(requestNewLinks) forControlEvents:UIControlEventValueChanged];
    [self.digestTableView addSubview:self.refreshControl];
}

- (void)loadView
{
    [super loadView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // If user is coming from selecting subreddits for their digest then show the loading snoo
//        if (self.isComingFromSubredditSelectionView) {
//            LoadingViewController *loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadingView"];
//            loadingViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//            loadingViewController.view.tag = 1;
//
////            CGRect fixedFrame = loadingViewController.view.frame;
////            fixedFrame.origin.y = self.view.frame.origin.y/2;
////            NSLog(@"%f", self.view.frame.origin.y);
////            loadingViewController.view.frame = fixedFrame;
//
//            loadingViewController.view.center = self.view.center;
//            [self.view addSubview:loadingViewController.view];
//            //[self presentViewController:loadingViewController animated:YES completion:nil];
//        }

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
}

- (void)createLoadingSnoo
{
    NSArray *imageNames = @[@"loading_snoo0000", @"loading_snoo0001", @"loading_snoo0002", @"loading_snoo0003",
                            @"loading_snoo0004", @"loading_snoo0005", @"loading_snoo0006", @"loading_snoo0007",
                            @"loading_snoo0008", @"loading_snoo0009", @"loading_snoo0010", @"loading_snoo0011"];

    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames.count; i++) {
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    }

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    [blurEffectView setFrame:self.view.bounds];
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
    cell.post = post;
    cell.delegate = self;
    cell.titleLabel.text = post.title;
    cell.subredditLabel.text = post.subreddit;
    cell.authorLabel.text = post.author;
    cell.upVoteDownVoteLabel.text = [self abbreviateNumber:post.voteRatio.integerValue];
    cell.commentsLabel.text = [self abbreviateNumber:post.totalComments.integerValue];

    if (!post.thumbnailImage) {
        cell.thumbnailImage.image = [self squareCropImageToSideLength:[UIImage imageNamed:@"snoo_camera_placeholder"] sideLength:50];
        cell.thumbnailImage.alpha = 0.5;
    }
    else {
        cell.thumbnailImage.image = [self squareCropImageToSideLength:[UIImage imageWithData:post.thumbnailImage] sideLength:50];
    }

    if (post.viewed) {cell.thumbnailImage.alpha = 0.2;}

    if ([post.upvoted boolValue]) {cell.upVoteButton.backgroundColor = [UIColor orangeColor];}
    if ([post.downvoted boolValue]) {cell.downVoteButton.backgroundColor = [UIColor blueColor];}

    cell.thumbnailImage.layer.cornerRadius = 2.0;
    cell.thumbnailImage.layer.masksToBounds = YES;

    return cell;
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

-(void)fireLocalNotificationAndMarkComplete
{
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

-(void)retrievePostsFromCoreData:(void (^)(BOOL))completionHandler
{
    self.digestPosts = [NSMutableArray array];

    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext]];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"subreddit" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];

    [fetch setSortDescriptors:@[sorter]];

    NSArray * posts = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    self.digestPosts = [NSMutableArray arrayWithArray:posts];
    if (self.digestPosts.count) {
        completionHandler(YES);
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
            [self.digestTableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"PostSegue"]) {
        PostViewController *postViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.digestTableView indexPathForSelectedRow];
        postViewController.allPosts = self.digestPosts;
        postViewController.index = indexPath.row;
    }else if ([segue.identifier isEqualToString:@"SettingsSegue"]){
        SettingsViewController *settingsController = segue.destinationViewController;
        settingsController.managedObject = self.managedObjectContext;
    }
}


-(IBAction)unwindFromSubredditSelectionViewController:(UIStoryboardSegue *)segue
{
    [Post removeAllPostsFromCoreData:self.managedObjectContext];

    [RedditRequests retrieveLatestPostFromArray:self.subredditsForFirstDigest withManagedObject:self.managedObjectContext withCompletion:^(BOOL completed) {
        if (completed) {
            [self performNewFetchedDataActions];
        }
    }];
}

-(void)upVoteButtonPressed:(DigestCellWithImageTableViewCell*)cell{
    cell.post.upvoted = [NSNumber numberWithBool:YES];
    cell.post.downvoted = [NSNumber numberWithBool:NO];
    [self.managedObjectContext save:nil];

    cell.upVoteButton.backgroundColor = [UIColor orangeColor];
    cell.downVoteButton.backgroundColor = [UIColor whiteColor];
}

-(void)downVoteButtonPressed:(DigestCellWithImageTableViewCell *)cell{
    cell.post.downvoted = [NSNumber numberWithBool:YES];
    cell.post.upvoted = [NSNumber numberWithBool:NO];
    [self.managedObjectContext save:nil];

    cell.downVoteButton.backgroundColor = [UIColor blueColor];
    cell.upVoteButton.backgroundColor = [UIColor whiteColor];
}

@end
