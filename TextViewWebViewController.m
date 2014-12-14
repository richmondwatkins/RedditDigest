//
//  CommentWebViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/16/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "TextViewWebViewController.h"
#import "SelfPostTextView.h"
#import <RedditKit.h>
@interface TextViewWebViewController () <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet SelfPostTextView *selfPostTextiView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@end

@implementation TextViewWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidesWhenStopped = YES;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSString *urlString = [self.urlToLoad absoluteString];

    if ([urlString containsString:@"reddit.com/r/"]) {
        [self loadPostInternally:urlString];
        self.selfPostTextiView.hidden = NO;
    }else{
        [self loadPostExternally:urlString];
        self.selfPostTextiView.hidden = YES;
    }
}

- (void)loadPostInternally:(NSString *)urlString{
    if (![urlString containsString:@"http"]) {
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    urlString = [urlString stringByAppendingString:@".json"];
    NSLog(@"URL STRING %@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSArray *resultsArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSDictionary *result = resultsArray[0][@"data"][@"children"][0][@"data"];

        if ([result[@"is_self"] boolValue]) {
            [self downloadSelfPost:result];
        }else{
            self.selfPostTextiView.hidden = YES;
            [self loadPostExternally:urlString];
        }
    }];
}

- (void)loadPostExternally:(NSString *)urlString{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.webView loadRequest:request];
}

- (void)downloadSelfPost:(NSDictionary *)post{
    self.navBar.title = post[@"title"];

    [self.selfPostTextiView htmlToTextAndSetViewsText:post[@"selftext"]];

    [self.activityIndicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (IBAction)dismissWebView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

@end
