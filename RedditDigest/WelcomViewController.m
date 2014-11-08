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

@interface WelcomViewController ()

@property (weak, nonatomic) IBOutlet CustomButton *signInWithRedditAccountButton;
@property (weak, nonatomic) IBOutlet CustomButton *signInWithoutRedditAccountButton;

@end

@implementation WelcomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.signInWithoutRedditAccountButton.layer.borderWidth = 0.5;
    self.signInWithoutRedditAccountButton.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;
    self.signInWithoutRedditAccountButton.layer.cornerRadius = 5.0;

    self.signInWithRedditAccountButton.layer.borderWidth = 0.5;
    self.signInWithRedditAccountButton.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;
    self.signInWithRedditAccountButton.layer.cornerRadius = 5.0;
}



- (IBAction)onContinueWithoutRedditAccountButtonPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasRedditAccount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
