//
//  ViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/1/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "ViewController.h"
#import <RedditKit.h>
#import <RKLink.h>
#import <RKSubreddit.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RKClient sharedClient] signInWithUsername:@"hankthedog" password:@"Duncan12" completion:^(NSError *error) {
        if (!error)
        {
            NSLog(@"Successfully signed in!");

            [[RKClient sharedClient] subscribedSubredditsWithCompletion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
                //                NSLog(@"%@",collection);

                RKSubreddit *subreddit = collection.firstObject;

                [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
                    NSLog(@"Links: %@", links);
                    [[RKClient sharedClient] upvote:links.firstObject completion:^(NSError *error) {
                        NSLog(@"Upvoted the link!");
                    }];
                }];
                
            }];
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
