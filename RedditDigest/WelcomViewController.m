//
//  WelcomViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "WelcomViewController.h"
#import "SubredditSelectionViewController.h"
#import "CustomButton.h"
#import "LoginViewController.h"
#import "InternetConnectionTest.h"
@interface WelcomViewController ()

@property (weak, nonatomic) IBOutlet CustomButton *signInWithRedditAccountButton;
@property (weak, nonatomic) IBOutlet CustomButton *signInWithoutRedditAccountButton;


@end

@implementation WelcomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.signInWithoutRedditAccountButton.layer.borderWidth = 0.5;
    self.signInWithoutRedditAccountButton.layer.cornerRadius = 5.0;
    self.signInWithoutRedditAccountButton.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;

    self.signInWithRedditAccountButton.layer.borderWidth = 0.5;
    self.signInWithRedditAccountButton.layer.cornerRadius = 5.0;
    self.signInWithRedditAccountButton.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;

    [InternetConnectionTest testInternetConnectionWithViewController:self andCompletion:^(BOOL internet) {
        if (internet == NO) {
            self.signInWithoutRedditAccountButton.enabled = NO;
            self.signInWithRedditAccountButton.enabled = NO;
        }
    }];
}



- (IBAction)onContinueWithoutRedditAccountButtonPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasRedditAccount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        LoginViewController *logInViewController = segue.destinationViewController;
        logInViewController.managedObject = self.managedObject;
    }else{
        // SubredditSelectionViewController is embeded in a Navigation Controller so the color of the status bar
        // could be set correctly. Thus the following extra step is needed.
        UINavigationController *selectionControllerNavigationParentVC = segue.destinationViewController;
        SubredditSelectionViewController *selectionController = selectionControllerNavigationParentVC.childViewControllers.firstObject;
        selectionController.managedObject = self.managedObject;
    }
}


@end
