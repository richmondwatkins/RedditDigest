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
@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *settingsArray;
@property NSArray *titlesArray;
@property NSString *currentUserName;
@property CLLocationManager *locationManger;
@property CLLocationCoordinate2D userLocation;
@property (strong, nonatomic) IBOutlet UISwitch *locationSwitcher;
@property (strong, nonatomic) IBOutlet UISwitch *autoUpdatingSwitcher;

@property (strong, nonatomic) IBOutlet UILabel *loginLogoutLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManger = [[CLLocationManager alloc] init];

    [self findUserName];
    self.title = self.currentUserName;

    if (self.currentUserName == nil){
        self.loginLogoutLabel.text = @"Login";
    }else{
        self.loginLogoutLabel.text = @"Logout";
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Location"]) {
        self.locationSwitcher.on = YES;
    }else{
        self.locationSwitcher.on = NO;
    }
}

#pragma mark - Login Credentials and Login or Logout

-(void)findUserName
{
    NSArray *array = [SSKeychain accountsForService:@"friendsOfSnoo"];
    NSDictionary *accountInfoDictionary = array.firstObject;
    NSString *username = accountInfoDictionary[@"acct"];
    self.currentUserName = username;
}



#pragma mark - Unwind from Edit Subreddits
- (IBAction)unwindToSettingsViewController:(UIStoryboardSegue *)segue {

}


- (IBAction)switchLocalization:(UISwitch *)sender {
    if (sender.on) {
        [self.locationManger requestWhenInUseAuthorization];

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Location"];
    }else{
       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Location"];
        [Subreddit removeLocalPostsAndSubreddits:self.managedObject];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAutoUpdating:(UISwitch *)sender {
    if (sender.on) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"BackgroundFetch"];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"BackgroundFetch"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
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
