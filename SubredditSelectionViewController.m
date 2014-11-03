//
//  SubredditSelectionViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SubredditSelectionViewController.h"
#import <RedditKit.h>
#import <RKLink.h>
#import <RKSubreddit.h>
@interface SubredditSelectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property NSMutableArray *subreddits;
@end

@implementation SubredditSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

     [[RKClient sharedClient] signInWithUsername:@"hankthedog" password:@"Duncan12" completion:^(NSError *error) {
         [[RKClient sharedClient] subscribedSubredditsWithCompletion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
             self.subreddits = [[NSMutableArray alloc] initWithArray:collection];
             NSLog(@"%@",self.subreddits);
         }];
     }];

}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.subreddits.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
