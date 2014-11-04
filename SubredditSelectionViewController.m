//
//  SubredditSelectionViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SubredditSelectionViewController.h"
#import "SubredditListCollectionViewCell.h"
#import <RedditKit.h>
#import <RKLink.h>
#import <RKSubreddit.h>
@interface SubredditSelectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *subredditCollectionView;
@property NSMutableArray *subreddits;
@property NSMutableArray *selectedSubreddits;
@end

@implementation SubredditSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedSubreddits = [[NSMutableArray alloc] init];

     [[RKClient sharedClient] signInWithUsername:@"hankthedog" password:@"Duncan12" completion:^(NSError *error) {
         [[RKClient sharedClient] subscribedSubredditsWithCompletion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
             self.subreddits = [[NSMutableArray alloc] initWithArray:collection];
             [self.subredditCollectionView reloadData];
         }];
     }];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.subreddits.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    RKSubreddit *subreddit = self.subreddits[indexPath.row];

    SubredditListCollectionViewCell *cell = [SubredditListCollectionViewCell createCellWithCollectionView:collectionView andSubreddit:subreddit andIndexPath:indexPath];
    cell.subredditTitleCell.layer.masksToBounds = YES;


    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    RKSubreddit *subreddit = self.subreddits[indexPath.row];
    [self.selectedSubreddits addObject:subreddit];
}


- (IBAction)finishSelectingSubreddits:(id)sender {
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//
//    RKSubreddit *subreddit = self.subreddits[indexPath.row];
//
//    return [subreddit.name sizeWithAttributes:NULL];
//}

@end
