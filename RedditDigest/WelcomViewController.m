//
//  WelcomViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "WelcomViewController.h"
#import "SubredditSelectionViewController.h"
@interface WelcomViewController ()

@end

@implementation WelcomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)onContinueWithoutRedditAccountButtonPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasRedditAccount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
