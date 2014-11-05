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
#import "KTCenterFlowLayout.h"
#import "SubredditSelectionCollectionReusableView.h"

@interface SubredditSelectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *subredditCollectionView;
@property NSMutableArray *subreddits;
@property NSMutableArray *catagories;
@property NSMutableArray *selectedSubreddits;
@property NSMutableArray *posts; //remove when move to app delegate
@property SubredditListCollectionViewCell *sizingCell;
@property (weak, nonatomic) IBOutlet UIButton *doneSelectingSubredditsButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property BOOL hasRedditAccount;

@end

@implementation SubredditSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    KTCenterFlowLayout *layout = [KTCenterFlowLayout new];
    layout.minimumInteritemSpacing = 10.f;
    layout.minimumLineSpacing = 10.f;
    self.subredditCollectionView = [self.subredditCollectionView initWithFrame:self.view.frame collectionViewLayout:layout];

    self.doneSelectingSubredditsButton.alpha = 0.0;
    self.doneSelectingSubredditsButton.layer.borderWidth = 1.0;
    self.doneSelectingSubredditsButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.subredditCollectionView.allowsMultipleSelection = YES;

    self.posts = [NSMutableArray array];
    [self getAllPosts];
    self.selectedSubreddits = [[NSMutableArray alloc] init];

    // Logged in with reddit account
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasRedditAccount"])
    {
        [self.activityIndicator startAnimating];
        self.hasRedditAccount = YES;
        [[RKClient sharedClient] subscribedSubredditsWithCompletion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
             self.subreddits = [[NSMutableArray alloc] initWithArray:collection];
             [self.subredditCollectionView reloadData];
             [self.activityIndicator stopAnimating];
             self.activityIndicator.hidden = YES;
         }];
    }
    else // Didn't login with reddit account
    {
        self.hasRedditAccount = NO;
        self.activityIndicator.hidden = YES;
        self.catagories = [NSMutableArray arrayWithArray:@[@"fashion", @"beauty",@"health",@"US news",@"global news",@"politics",@"technology",@"film",@"science",@"humor",@"world explorer",@"books",@"business & finance",@"music",@"art & design",@"history",@"the future",@"surprise me!",@"offbeat",@"cooking",@"sports",@"geek",@"green",@"adventure"]];
    }


    // Regester cell for sizing template
    UINib *cellNib = [UINib nibWithNibName:@"SubredditSelectionCell" bundle:nil];
    [self.subredditCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"Cell"];
    self.sizingCell = [[cellNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.hasRedditAccount) {
        return self.subreddits.count;
    }
    else {
        return self.catagories.count;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubredditListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    [self configureCell:cell forIndexPath:indexPath];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasRedditAccount)
    {
        RKSubreddit *subreddit = self.subreddits[indexPath.row];

        if (self.selectedSubreddits.count < 10)
        {
            NSMutableDictionary *subredditDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subreddit.name, @"name",subreddit.URL, @"url", nil];
            [self.selectedSubreddits addObject:subredditDict];
            NSLog(@"SELECTED SUBREDDITS %@",self.selectedSubreddits);
            if (self.selectedSubreddits.count > 0) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.doneSelectingSubredditsButton.alpha = 1.0;
                }];
            }
        }
        else
        {
            [self.subredditCollectionView deselectItemAtIndexPath:indexPath animated: YES];
        }
    }
    else {
        if (self.selectedSubreddits.count < 10)
        {
            [self.selectedSubreddits addObject:self.catagories[indexPath.row]];
            if (self.selectedSubreddits.count > 0) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.doneSelectingSubredditsButton.alpha = 1.0;
                }];
            }
        }
        else {
            [self.subredditCollectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
    }

}

- (void)configureCell:(SubredditListCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasRedditAccount) {
        RKSubreddit *subreddit = self.subreddits[indexPath.row];
        cell.subredditTitleLabel.text = subreddit.name;
    }
    else {
        cell.subredditTitleLabel.text = self.catagories[indexPath.row];
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:self.sizingCell forIndexPath:indexPath];
    return [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasRedditAccount) {
        RKSubreddit *subreddit = self.subreddits[indexPath.row];

        NSMutableDictionary *subredditDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subreddit.name, @"name",subreddit.URL, @"url", nil];
        if ([self.selectedSubreddits containsObject:subredditDict]) {
            [self.selectedSubreddits removeObject:subredditDict];
            NSLog(@"sizelkj: %lu", (unsigned long)self.selectedSubreddits.count);
        }
    }
    else {
        [self.selectedSubreddits removeObject:self.catagories[indexPath.row]];
    }

    if (self.selectedSubreddits.count == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.doneSelectingSubredditsButton.alpha = 0.0;
        }];
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            self.doneSelectingSubredditsButton.alpha = 1.0;
        }];
    }
}

#pragma mark - Cell Spacing and Padding

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 15, 10, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
}

#pragma mark - Header

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;

    if (kind == UICollectionElementKindSectionHeader)
    {
        SubredditSelectionCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

        [headerView.textField addTarget:self action:@selector(searchForSubreddit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        reusableview = headerView;
    }

    return reusableview;
}

// Header Height and Width
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.hasRedditAccount) {
        return CGSizeMake(self.view.frame.size.width, 44.0);
    }
    else {
        return CGSizeMake(0, 0);
    }
}

#pragma mark - Search

- (void)searchForSubreddit:(UITextField *)textField
{
    NSString *subredditName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [[RKClient sharedClient] subredditWithName:subredditName completion:^(id subreddit, NSError *error) {
        NSLog(@"Subreddit %@", subreddit);
    }];

    textField.text = @"";
    [textField resignFirstResponder];
}

- (IBAction)finishSelectingSubreddits:(id)sender
{
    if (self.hasRedditAccount)
    {
        NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
        NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
        NSString *urlString = [NSString stringWithFormat:@"http://192.168.129.228:3000/subreddits/%@",  deviceString];

        NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.selectedSubreddits, @"subreddits", nil];
        NSError *error;
        NSLog(@"DATA DICTIONARY %@", dataDictionary);
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
    else
    {
        // load the subreddits here from the selected catagories
        NSLog(@"You've selected the following catagories: %@", self.selectedSubreddits);
    }

}

//testing GET for subreddits and recreating a RKSubreddit object
-(void)getAllPosts
{
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
            NSLog(@"ALL POSTSSS %@", self.posts);
        }
    }];

    [dataTask resume];
}

-(void)findTopPostsFromSubreddit:(RKSubreddit *)subreddit
{
    [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
        RKLink *topPost = links.firstObject;
        if (topPost.stickied) {
            topPost = links[1];
        }
        [self.posts addObject:topPost];
    }];
}

-(void)deleter:(RKSubreddit *)subreddit
{
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
