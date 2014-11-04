//
//  EditSubredditViewController.m
//  RedditDigest
//
//  Created by Christopher on 11/4/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "EditSubredditViewController.h"

@interface EditSubredditViewController () <UITableViewDelegate, UITableViewDataSource>
@property NSArray *digestPosts;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

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


#pragma mark - Fetching Data

-(void)fetchNewData{
    self.digestPosts = [NSArray array];

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
            self.digestPosts = usersSubredditsArray;
            NSLog(@"self.digestPosts %@", self.digestPosts);
            NSLog(@"userSubredditsArray %@", usersSubredditsArray);
            [self.tableView reloadData];
        }

    }];

    [dataTask resume];
}



@end
