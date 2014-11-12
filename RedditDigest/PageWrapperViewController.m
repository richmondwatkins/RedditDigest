//
//  PageWrapperViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "PageWrapperViewController.h"
#import "CommentTableViewCell.h"

@implementation PageWrapperViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![self.post.viewed boolValue]) {
        self.post.viewed = [NSNumber numberWithBool:YES];
        [self.post.managedObjectContext save:nil];
    }
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSURL *url = webView.request.URL;
    NSLog(@"URL %@",url);
}


@end
