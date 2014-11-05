//
//  EditSubredditViewController.m
//  RedditDigest
//
//  Created by Christopher on 11/4/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "EditSubredditViewController.h"
#import <RKLink.h>
#import <RKSubreddit.h>

@interface EditSubredditViewController () <UITableViewDelegate, UITableViewDataSource>
@property NSMutableArray *digestPosts;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSIndexPath *editingIndex;


@end

@implementation EditSubredditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchNewData];
}


#pragma mark - Table View Delegate & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.digestPosts.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *temp = self.digestPosts[indexPath.row];
    NSString *subredditTitle = [temp objectForKey:@"subreddit"];
    cell.textLabel.text = subredditTitle;
    NSLog(@"Dictionary %@ and key %@", temp, subredditTitle);
    return cell;
}

#pragma mark - Delete Row from Table

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
//        self.editingIndex = indexPath;
//        [self.digestPosts removeObjectAtIndex:indexPath.row];
//        [self.tableView deleteRowsAtIndexPaths:@[self.editingIndex] withRowAnimation:UITableViewRowAnimationFade];

//        [self deleter:self.digestPosts[indexPath.row]];
        [tableView reloadData];
    }
}


#pragma mark - Fetching Data

-(void)fetchNewData{
    self.digestPosts = [NSMutableArray array];

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
            NSMutableArray *usersSubredditsArray = results[@"subreddits"];
            self.digestPosts = usersSubredditsArray;
            NSLog(@"self.digestPosts %@", self.digestPosts);
            NSLog(@"userSubredditsArray %@", usersSubredditsArray);
            [self.tableView reloadData];
        }

    }];

    [dataTask resume];
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



@end
