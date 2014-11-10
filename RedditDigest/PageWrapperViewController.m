//
//  PageWrapperViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "PageWrapperViewController.h"
#import "CommentTableViewCell.h"
@interface PageWrapperViewController () <UIWebViewDelegate>

@end

@implementation PageWrapperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageCommentsTableView.delegate = self;
    self.imageCommentsTableView.dataSource = self;

    self.selfPostCommentsTableView.delegate = self;
    self.selfPostCommentsTableView.dataSource = self;

    self.gifCommentsTableView.delegate = self;
    self.gifCommentsTableView.dataSource = self;

    self.videoCommentsTableView.delegate = self;
    self.videoCommentsTableView.dataSource = self;

    self.imageCommentsTableView.estimatedRowHeight = 43.0;
    self.imageCommentsTableView.rowHeight = UITableViewAutomaticDimension;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.comments.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    NSDictionary *commentDictionary = self.comments[indexPath.row];
    Comment *comment = commentDictionary[@"parent"];
    NSString *htmlString = [self textToHtml:comment.body];
    cell.commentWebView.scrollView.scrollEnabled = NO;
    [cell.commentWebView loadHTMLString:htmlString baseURL:nil];


    return cell;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [webView sizeToFit];
}

- (NSString*)textToHtml:(NSString*)string{

    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];

    return string;
}



@end
