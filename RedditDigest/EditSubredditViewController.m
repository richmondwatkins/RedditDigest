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
#import "Subreddit.h"
@interface EditSubredditViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (strong) NSMutableArray *digestPosts;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSIndexPath *editingIndex;


@end

@implementation EditSubredditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self fetchNewData];
    [self fetchSubredditsFromCoreData];
    [self.tableView reloadData];
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
    Subreddit *subreddit = self.digestPosts[indexPath.row];

//    NSData *yourData = [temp objectForKey:(id)];
//    UIImage *subredditLogo = [UIImage imageWithData:yourData];
    cell.textLabel.text = subreddit.subreddit;
//    cell.imageView.image = subredditLogo;
    return cell;
}

#pragma mark - Delete Row & Data from Table

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {


        self.editingIndex = indexPath;
        UIAlertView *alertView = [[UIAlertView alloc]init];
        alertView.delegate = self;
        alertView.title = @"Are you sure?";
        [alertView addButtonWithTitle:@"Delete"];
        [alertView addButtonWithTitle:@"Cancel"];
        [alertView show];

    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 0) {
//        NSLog(@"SELECTED TO DELETE %@",self.digestPosts[self.editingIndex.row] );
        [self deleter:self.digestPosts[self.editingIndex.row]];
        [self.digestPosts removeObjectAtIndex:self.editingIndex.row];
        [self.tableView deleteRowsAtIndexPaths:@[self.editingIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }

}

#pragma mark - Fetching Data

-(void)fetchNewData{
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.4:3000/subreddits/%@",deviceString];
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil)
            return;

        dispatch_async(dispatch_get_main_queue(), ^{
            id error;
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSMutableArray *usersSubredditsArray = [results[@"subreddits"] mutableCopy];
            self.digestPosts = usersSubredditsArray;
//            NSLog(@"self.digestPosts %@", self.digestPosts);
//            NSLog(@"userSubredditsArray %@", usersSubredditsArray);
            [self.tableView reloadData];
        });
    }];
    [dataTask resume];
}




#pragma mark - Delete from Database

-(void)deleter:(Subreddit *)subreddit
{
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subreddit.subreddit, @"name", subreddit.url, @"url", nil];//testing puproses

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
            //[self getter]; //THIS IS FOR TESTING THE SUBREDDIT GETTER METHOD
        }
    }];
    [dataTask resume];
}

-(void)fetchSubredditsFromCoreData{
    NSFetchRequest *fetchSubreddits = [[NSFetchRequest alloc] initWithEntityName:@"Subreddit"];
    NSArray *subreddits = [self.managedObject executeFetchRequest:fetchSubreddits error:nil];
    NSLog(@"SUBSSS %@",subreddits);
    self.digestPosts = [NSMutableArray arrayWithArray:subreddits];
}




@end
