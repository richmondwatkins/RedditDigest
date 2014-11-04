//
//  EditSubredditViewController.m
//  RedditDigest
//
//  Created by Christopher on 11/4/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "EditSubredditViewController.h"

@interface EditSubredditViewController ()
@property NSArray *digestPosts;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EditSubredditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchNewData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.digestPosts.count;
}

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
