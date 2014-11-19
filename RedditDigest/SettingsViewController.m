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
#import "PocketAPI.h"
#import "TSMessage.h"
@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *settingsArray;
@property NSArray *titlesArray;
@property CLLocationManager *locationManger;
@property CLLocationCoordinate2D userLocation;
@property (strong, nonatomic) IBOutlet UISwitch *locationSwitcher;
@property (strong, nonatomic) IBOutlet UISwitch *autoUpdatingSwitcher;
@property (weak, nonatomic) IBOutlet UILabel *linkPocketLabel;

@property (strong, nonatomic) IBOutlet UILabel *loginLogoutLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManger = [[CLLocationManager alloc] init];

    self.title = @"Settings";

    [self setupLoginCell];
    [self setupLocationCell];
    [self setupAutoUpdatingCell];
    [self setupLinkPocketCell];

    [self retrievePastDigestFromCoreData];
}

#pragma mark - Login

- (void)setupLoginCell
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UserIsLoggedIn"]) {
        self.loginLogoutLabel.text = [@"Logout - " stringByAppendingString:[self findUserName]];
    }
    else {
        self.loginLogoutLabel.text = @"Login";
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

- (void)setupLocationCell
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Location"]) {
        self.locationSwitcher.on = YES;
    } else {
        self.locationSwitcher.on = NO;
    }
}

- (IBAction)switchLocalization:(UISwitch *)sender
{
    if (sender.on) {
        [self.locationManger requestWhenInUseAuthorization];
        // TODO make this only happen when user has actually allowed app to use their location
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Location"];
        // if success
        [TSMessage showNotificationInViewController:self
                                              title:@"Enabled Local Subreddits"
                                           subtitle:@"If there are any subreddits for your current location, they will appear in your digest."
                                               type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic];
    }else{
       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Location"];
        [Subreddit removeLocalPostsAndSubreddits:self.managedObject];
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

#pragma mark - Auto Updating

- (void)setupAutoUpdatingCell
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BackgroundFetch"]) {
        self.autoUpdatingSwitcher.on = YES;
    } else {
        self.autoUpdatingSwitcher.on = NO;
    }
}

- (IBAction)switchAutoUpdating:(UISwitch *)sender
{
    if (sender.on) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"BackgroundFetch"];
        [TSMessage showNotificationInViewController:self
                                              title:@"Turned on Autoupdating!"
                                           subtitle:@"Now, the more often you use Reddit Digest you're content will be up to date"
                                               type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"BackgroundFetch"];
        [TSMessage showNotificationInViewController:self
                                              title:@"Turned off Autoupdating!"
                                           subtitle:nil
                                               type:TSMessageNotificationTypeError
                                           duration:1.5];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)retrievePastDigestFromCoreData
{
    NSFetchRequest *fetchDigests = [[NSFetchRequest alloc] initWithEntityName:@"Digest"];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    [fetchDigests setSortDescriptors:@[sorter]];

    NSArray *digests = [self.managedObject executeFetchRequest:fetchDigests error:nil];
    for (Digest *digest in digests) {
        NSLog(@"DIGESTSSS %@",digest.digestPost);
    }
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
    // SHARING
    else if ([indexPath section] == 3)
    {
        // LINK POCKET
        if (indexPath.row == 0)
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasAuthorizedPocket"]) {
                [self unlinkPocket];
            } else {
                [self linkPocket];
            }
        }
    }
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

#pragma mark - Link With Pocket

- (void)setupLinkPocketCell
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasAuthorizedPocket"]) {
        self.linkPocketLabel.text = @"Unlink Pocket";
    }
    else {
        self.linkPocketLabel.text = @"Link Pocket";
    }
}

- (void)linkPocket
{
    [[PocketAPI sharedAPI] loginWithHandler: ^(PocketAPI *API, NSError *error)
    {
        if (error)
        {
            NSLog(@"Error authorizing Pocket %@", error.localizedDescription);
            [TSMessage showNotificationInViewController:self
                                                  title:@"Error Authorizing Pocket!"
                                               subtitle:error.localizedDescription
                                                   type:TSMessageNotificationTypeError
                                               duration:2.5];
            self.linkPocketLabel.text = @"Link Pocket";
        }
        else
        {
            [TSMessage showNotificationInViewController:self
                                                  title:@"Authorized Pocket!"
                                               subtitle:nil
                                                   type:TSMessageNotificationTypeSuccess
                                               duration:1.5];
            self.linkPocketLabel.text = @"Unlink Pocket";
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasAuthorizedPocket"];
        }

    }];
}

- (void)unlinkPocket
{
    [[PocketAPI sharedAPI] logout];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasAuthorizedPocket"];
    self.linkPocketLabel.text = @"Link Pocket";
    [TSMessage showNotificationInViewController:self
                                          title:@"Unauthorized Pocket!"
                                       subtitle:nil
                                           type:TSMessageNotificationTypeError
                                       duration:1.5];
}




@end
