//
//  SettingsAboutRedditViewController.m
//  RedditDigest
//
//  Created by Christopher on 11/6/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SettingsAboutRedditViewController.h"
#import "LoginViewController.h"

@interface SettingsAboutRedditViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property BOOL isFromSettings;

@end

@implementation SettingsAboutRedditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *urlString = @"http://www.reddit.com/about/";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation




@end
