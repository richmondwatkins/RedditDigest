//
//  PageWrapperViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "PageWrapperViewController.h"
#import "CommentTableViewCell.h"
#import "ExpandedCommentViewController.h"
@interface PageWrapperViewController () <UIWebViewDelegate, CommentCellDelegate>
@property Comment *selectedComment;
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


    [[RKClient sharedClient] linkWithFullName:self.post.postID completion:^(id object, NSError *error) {
        [[RKClient sharedClient] upvote:object completion:^(NSError *error) {
            NSLog(@"LINK ==============%@",self.post.subreddit);
        }];
    }];

    if (![self.post.viewed boolValue]) {
        self.post.viewed = [NSNumber numberWithBool:YES];
        [self.post.managedObjectContext save:nil];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.comments.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    NSDictionary *commentDictionary = self.comments[indexPath.row];
    Comment *comment = commentDictionary[@"parent"];
    NSString *partialComment = [self textToHtml:comment.body withCell:cell andComment:comment];

    cell.comment = comment;
    cell.delegate = self;
    cell.commentWebView.scrollView.scrollEnabled = NO;
    [cell.commentWebView loadHTMLString:partialComment baseURL:nil];
    cell.commentWebView.delegate = self;

    return cell;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSString *url = webView.request.URL.parameterString;
    NSLog(@"URL %@",url);
}

- (NSString*)textToHtml:(NSString*)string withCell:(CommentTableViewCell *)cell andComment:(Comment *)comment{

    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];

    if ([string length] >= 175){
        string = [string substringToIndex:175];
        string = [NSString stringWithFormat:@"%@…", string];
        cell.showMoreButton.hidden = NO;
    }
    return string;
}


-(void)onShowMoreButtonTapped:(CommentTableViewCell *)cell{
    self.selectedComment = cell.comment;
    switch (self.sourceViewIdentifier) {
        case 1:
            [self performSegueWithIdentifier:@"ImageSegue" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"VideoSegue" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"GifSegue" sender:self];
            break;
        case 4:
            [self performSegueWithIdentifier:@"SelfPostSegue" sender:self];
            break;
        case 5:
            [self performSegueWithIdentifier:@"WebSegue" sender:self];
            break;
        default:
            break;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ExpandedCommentViewController *commentViewController = segue.destinationViewController;
    commentViewController.comment = self.selectedComment;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return tableView.rowHeight;

}


@end
