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
@interface DigestViewController ()

@end

@implementation DigestViewController
///
- (void)viewDidLoad {
    [super viewDidLoad];

    //PFUser *currentUser = [PFUser currentUser];
    BOOL currentUser = NO;
    if (currentUser) {
        //NSLog(@"The current user is: %@", currentUser.username);
       // [self.tabBarController.tabBar setHidden:NO];
        //[self getMyfollowersImages];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];

        [self.parentViewController presentViewController:welcomeViewController animated:YES completion:nil];


        //[self presentViewController:welcomeViewController animated:YES completion:nil];
        //[self performSegueWithIdentifier:@"ShowLoginSegue" sender:self];
    }

    /*
    [[RKClient sharedClient] signInWithUsername:@"hankthedog" password:@"Duncan12" completion:^(NSError *error) {
        if (!error)
        {
            NSLog(@"Successfully signed in!");

            [[RKClient sharedClient] subscribedSubredditsWithCompletion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
                //                NSLog(@"%@",collection);

                RKSubreddit *subreddit = collection.firstObject;

                [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
//                    NSLog(@"Links: %@", links);
                    [[RKClient sharedClient] upvote:links.firstObject completion:^(NSError *error) {
                        NSLog(@"Upvoted the link!");
                    }];
                }];
                
            }];
        }
    }];
     */

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
