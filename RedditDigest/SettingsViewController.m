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

#pragma mark - Login Credentials and Login or Logout

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

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Location"];
    }else{
       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Location"];
        [Subreddit removeLocalPostsAndSubreddits:self.managedObject];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Auto Updating

- (void)setupAutoUpdatingCell
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BackgroundFetch"]) {
        self.autoUpdatingSwitcher.on = YES;
    } else {
        self.locationSwitcher.on = NO;
    }
}

- (IBAction)switchAutoUpdating:(UISwitch *)sender
{
    if (sender.on) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"BackgroundFetch"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"BackgroundFetch"];
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
    if ([indexPath section] == 1)
    {
        if (indexPath.row == 0) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UserIsLoggedIn"]) {
                [self logout];
            }
        }
        else if (indexPath.row == 3) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasAuthorizedPocket"]) {
                [self unlinkPocket];
            } else {
                [self linkPocket];
            }
        }
    }
}

#pragma mark -  Segue

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
            [TSMessage showNotificationInViewController:self.parentViewController
                                                  title:@"Error Authorizing Pocket!"
                                               subtitle:error.localizedDescription
                                                   type:TSMessageNotificationTypeError
                                               duration:2.5];
            self.linkPocketLabel.text = @"Link Pocket";
        }
        else
        {
            [TSMessage showNotificationInViewController:self.parentViewController
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
    [TSMessage showNotificationInViewController:self.parentViewController
                                          title:@"Unauthorized Pocket!"
                                       subtitle:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:1.5];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

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
    }
}


@end
