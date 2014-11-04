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
    NSError *error;
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subreddit.name, @"name",subreddit.URL, @"url", nil];
//    NSData *subredditData = [NSJSONSerialization dataWithJSONObject:tempDict options:0 error:&error];
    [self.selectedSubreddits addObject:tempDict];
}


- (IBAction)finishSelectingSubreddits:(id)sender {

    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.4:3000/subreddits/%@",  deviceString];

    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.selectedSubreddits, @"subreddits", nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&error];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSLog(@"%@",response);
            //[self getter]; //THIS IS FOR TESTING THE SUBREDDIT GETTER METHOD
        }
    }];
    [dataTask resume];

}

//testing GET for subreddits and recreating a RKSubreddit object
-(void)getter{
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.4:3000/subreddits/%@",deviceString];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",error);
        if(error == nil)
        {
            NSDictionary *tester = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"THIS IS THE REsponSEEEEE %@", tester);
            NSArray *testArry = tester[@"subreddits"];
            NSDictionary *testDict = testArry.firstObject;
            NSDictionary *woo = [[NSDictionary alloc] initWithObjectsAndKeys:testDict[@"subreddit"], @"name", testDict[@"url"], @"URL", nil];
            RKSubreddit *subreddit = [[RKSubreddit alloc] initWithDictionary:woo error:nil];

            [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
                NSLog(@"Links: %@", links);
                [[RKClient sharedClient] upvote:links.firstObject completion:^(NSError *error) {
                    NSLog(@"Upvoted the link!");
                }];
            }];
        }

    }];

    [dataTask resume];

}


@end
