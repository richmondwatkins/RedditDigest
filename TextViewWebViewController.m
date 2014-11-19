//
//  CommentWebViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/16/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "TextViewWebViewController.h"

@interface TextViewWebViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TextViewWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.urlToLoad];
    [self.webView loadRequest:request];
}

- (IBAction)dismissWebView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
