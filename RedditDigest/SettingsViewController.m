//
//  SettingsViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/4/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SettingsViewController.h"
#import "RKUser.h"
#import <SSKeychain/SSKeychain.h>
#import "LoginViewController.h"
#import "SubredditSelectionViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Subreddit.h"
#import "RecommendedSubredditsViewController.h"
#import "Digest.h"
#import "PastDigestsViewController.h"
#import "TSMessage.h"
#import "InternetConnectionTest.h"
@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *settingsArray;
@property NSArray *titlesArray;
@property CLLocationManager *locationManger;
@property CLLocationCoordinate2D userLocation;
@property (strong, nonatomic) IBOutlet UISwitch *locationSwitcher;
@property (strong, nonatomic) IBOutlet UILabel *loginLogoutLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *editDigestCell;

@property (strong, nonatomic) IBOutlet UITableViewCell *recCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *archiveCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *loginCell;
@property BOOL madChangeToLocation;
@property (strong, nonatomic) IBOutlet UISwitch *nsfwSwitcher;

@property (weak, nonatomic) IBOutlet UIView *footerView;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManger = [[CLLocationManager alloc] init];

    self.title = @"Settings";

    [self setUpCells];

    self.tableView.scrollEnabled = NO;

    [InternetConnectionTest testInternetConnectionWithViewController:self andCompletion:^(BOOL internet) {
            if (internet == NO) {
                self.recCell.userInteractionEnabled = NO;
                self.archiveCell.userInteractionEnabled = NO;
                self.loginCell.userInteractionEnabled = NO;
                self.editDigestCell.userInteractionEnabled = NO;
            }
    }];

    self.digestViewController.madeChangeToLocation = NO;
    [self retrievePastDigestFromCoreData];


    NSString *deviceModel = [UIDevice currentDevice].model; // no room for bottom button corner on iphone 4

    if (![deviceModel containsString:@"iPhone4"]) {
        [self.navigationItem setHidesBackButton:YES];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self
                   action:@selector(popViewController:)
         forControlEvents:UIControlEventTouchUpInside];
        UIImage *closeImage = [UIImage imageNamed:@"closeButton"];

        [button setBackgroundImage:closeImage forState:UIControlStateNormal];
        button.frame = CGRectMake(5, self.tableView.frame.size.height - 100, 25, 25);
        [self.view addSubview:button];

    }

}

#pragma mark - Cells

-(void)setUpCells{
    //login cell
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UserIsLoggedIn"]) {
        self.loginLogoutLabel.text = [@"Logout - " stringByAppendingString:[self findUserName]];
    }
    else {
        self.loginLogoutLabel.text = @"Login";
    }

    //nsfw cell
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HideNSFW"]) {
        self.nsfwSwitcher.on = YES;
    }else{
        self.nsfwSwitcher.on = NO;
    }

    //location cell
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Location"]) {
        self.locationSwitcher.on = YES;
    } else {
        self.locationSwitcher.on = NO;
    }
}

-(NSString *)findUserName
{
    NSArray *array = [SSKeychain accountsForService:@"friendsOfSnoo"];
    NSDictionary *accountInfoDictionary = array.firstObject;
    NSString *username = accountInfoDictionary[@"acct"];
    return username;
}

- (void)logout
{
    [[RKClient sharedClient] signOut];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasRedditAccount"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"UserIsLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *message = [@"Logged out " stringByAppendingString:[self findUserName]];

    [TSMessage showNotificationInViewController:self
                                          title:message
                                       subtitle:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:1.3];

    // Remove user from keychain
    [SSKeychain deletePasswordForService:@"friendsOfSnoo" account:[self findUserName]];

    self.loginLogoutLabel.text = @"Login";
}

#pragma mark - Unwind from Edit Subreddits
- (IBAction)unwindToSettingsViewController:(UIStoryboardSegue *)segue {

}

#pragma mark - Location

- (IBAction)switchLocalization:(UISwitch *)sender
{
    if (sender.on) {
        [self.locationManger requestWhenInUseAuthorization];
        // TODO make this only happen when user has actually allowed app to use their location
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Location"];
        // if success
        [TSMessage showNotificationInViewController:self
                                              title:@"Enabled Local subreddits"
                                           subtitle:@"If there are any subreddits local to your area they will show up in your digest."
                                               type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic];
    }else{
       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Location"];
        [Subreddit removeLocalPostsAndSubreddits:self.managedObject];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.digestViewController.madeChangeToLocation = YES;
}


- (IBAction)nsfwSwitched:(UISwitch *)sender {

    if (sender.on) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HideNSFW"];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HideNSFW"];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}

// TODO figure out why this method isn't being called and make it get called
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    [manager stopUpdatingLocation];
    self.locationSwitcher.on = NO;
    if ([error domain] == kCLErrorDomain) {
        switch([error code])
        {
            case kCLErrorNetwork:
            {
                [TSMessage showNotificationInViewController:self
                                                      title:@"Network Error"
                                                   subtitle:@"Please check your network connection or that you are not in airplane mode"
                                                       type:TSMessageNotificationTypeError
                                                   duration:TSMessageNotificationDurationAutomatic];

                break;
            }
            case kCLErrorDenied:
            {
                [TSMessage showNotificationInViewController:self
                                                      title:nil
                                                   subtitle:@"In the future if you would like to turn on local subreddits, go to your location settings and allow Reddit Digest"
                                                       type:TSMessageNotificationTypeError
                                                   duration:TSMessageNotificationDurationAutomatic];
                break;
            }
            default:
            {
                NSLog(@"Unknown location error");
                break;
            }
        }

    }
}


-(void)retrievePastDigestFromCoreData
{
//    NSFetchRequest *fetchDigests = [[NSFetchRequest alloc] initWithEntityName:@"Digest"];
//    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
//    [fetchDigests setSortDescriptors:@[sorter]];
//
//    NSArray *digests = [self.managedObject executeFetchRequest:fetchDigests error:nil];
//    for (Digest *digest in digests) {
//        NSLog(@"DIGESTSSS %@",digest.digestPost);
//    }
}

#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // ACCOUNT
    if ([indexPath section] == 2)
    {
        // LOGIN/LOGOUG
        if (indexPath.row == 0) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UserIsLoggedIn"]) {
                [self logout];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark -  Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"SubredditCollectionView"]) {
        UINavigationController *selectionControllerNavigationParentVC = segue.destinationViewController;
        SubredditSelectionViewController *selectionController = selectionControllerNavigationParentVC.childViewControllers.firstObject;
        selectionController.isFromSettings = YES;
        selectionController.managedObject = self.managedObject;
    } else if([segue.identifier isEqualToString:@"SettingsToLogin"]){
        LoginViewController *loginController = segue.destinationViewController;
        loginController.managedObject = self.managedObject;
        loginController.isFromSettings = YES;
    } else if([segue.identifier isEqualToString:@"RecommendedSegue"]){
        RecommendedSubredditsViewController *recController = segue.destinationViewController;
        recController.managedObject = self.managedObject;
    } else if ([segue.identifier isEqualToString:@"PastDigestSegue"]){
        PastDigestsViewController *pastController = segue.destinationViewController;
        pastController.managedObject = self.managedObject;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{

    if ([identifier isEqualToString:@"SettingsToLogin" ]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UserIsLoggedIn"]) {
            return NO;
        }
        else {
            return YES;
        }
    }
    return YES;
}

- (void)popViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
