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
@property NSMutableArray *posts; //remove when move to app delegate
@property SubredditListCollectionViewCell *sizingCell;

@end

@implementation SubredditSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.posts = [NSMutableArray array];
    [self getAllPosts];
    self.selectedSubreddits = [[NSMutableArray alloc] init];

     [[RKClient sharedClient] signInWithUsername:@"hankthedog" password:@"Duncan12" completion:^(NSError *error) {
         [[RKClient sharedClient] subscribedSubredditsWithCompletion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
             self.subreddits = [[NSMutableArray alloc] initWithArray:collection];
             [self.subredditCollectionView reloadData];
         }];
     }];

    // Regester cell for sizing template
    UINib *cellNib = [UINib nibWithNibName:@"SubredditSelectionCell" bundle:nil];
    [self.subredditCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"Cell"];
    self.sizingCell = [[cellNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.subreddits.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubredditListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    [self _configureCell:cell forIndexPath:indexPath];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RKSubreddit *subreddit = self.subreddits[indexPath.row];
    NSError *error;
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subreddit.name, @"name",subreddit.URL, @"url", nil];
    //    NSData *subredditData = [NSJSONSerialization dataWithJSONObject:tempDict options:0 error:&error];
    [self.selectedSubreddits addObject:tempDict];
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    CollectionViewCell *aSelectedCell = (CollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    [aSelectedCell mmmmmmmm];
//    //aSelectedCell dra
//
//}

- (void)_configureCell:(SubredditListCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    //cell.layer.cornerRadius = 8.0;
    //cell.layer.masksToBounds = YES;
    RKSubreddit *subreddit = self.subreddits[indexPath.row];
    cell.subredditTitleLabel.text = subreddit.name;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self _configureCell:_sizingCell forIndexPath:indexPath];

    return [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}

#pragma mark - Cell Spacing and Padding

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{

    return 5.0;
}

- (IBAction)finishSelectingSubreddits:(id)sender {

    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.129.228:3000/subreddits/%@",  deviceString];

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
-(void)getAllPosts{
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.129.228:3000/subreddits/%@",deviceString];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error == nil)
        {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSArray *usersSubredditsArray = results[@"subreddits"];

            for (NSDictionary *subredditDict in usersSubredditsArray) {
                NSDictionary *setUpForRKKitObject = [[NSDictionary alloc] initWithObjectsAndKeys:subredditDict[@"subreddit"], @"name", subredditDict[@"url"], @"URL", nil];
                RKSubreddit *subreddit = [[RKSubreddit alloc] initWithDictionary:setUpForRKKitObject error:nil];
                [self findTopPostsFromSubreddit:subreddit];
            }
            NSLog(@"ALL POSTSSS",self.posts);
        }
    }];

    [dataTask resume];

}

-(void)findTopPostsFromSubreddit:(RKSubreddit *)subreddit{
    [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
        RKLink *topPost = links.firstObject;
        if (topPost.stickied) {
            topPost = links[1];
        }
        [self.posts addObject:topPost];
    }];
}

-(void)deleter:(RKSubreddit *)subreddit{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subreddit.name, @"name",subreddit.URL, @"url", nil];//testing puproses


    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.129.228:3000/subreddits/delete/%@",  deviceString];

    NSDictionary *objectToDelete = [[NSDictionary alloc] initWithObjectsAndKeys:tempDict, @"subreddit", nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:objectToDelete options:0 error:&error];
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

//-(void)getAllPosts{
//    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
//
//    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
//    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
//    NSString *urlString = [NSString stringWithFormat:@"http://192.168.129.228:3000/subreddits/%@",deviceString];
//    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
//
//    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSLog(@"%@",error);
//        if(error == nil)
//        {
//            NSDictionary *tester = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//            NSLog(@"THIS IS THE REsponSEEEEE %@", tester);
//            NSArray *testArry = tester[@"subreddits"];
//            NSDictionary *testDict = testArry.firstObject;
//            NSDictionary *woo = [[NSDictionary alloc] initWithObjectsAndKeys:testDict[@"subreddit"], @"name", testDict[@"url"], @"URL", nil];
//            RKSubreddit *subreddit = [[RKSubreddit alloc] initWithDictionary:woo error:nil];
//
//            [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
//                NSLog(@"Links: %@", links);
//
//            }];
//        }
//
//    }];
//    
//    [dataTask resume];
//}


@end
