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
@interface PageWrapperViewController () <UIWebViewDelegate, CommentCellDelegate, UITextViewDelegate>
@property Comment *selectedComment;
@property CGFloat cellHeight;
@property NSMutableArray *tableCells;
@end

@implementation PageWrapperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTableDelegatesAndDataSource];

    if (![self.post.viewed boolValue]) {
        self.post.viewed = [NSNumber numberWithBool:YES];
        [self.post.managedObjectContext save:nil];
    }

//    self.tableCells = [NSMutableArray array];
//    for (Comment *comment in self.comments) {
//        <#statements#>
//    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.comments.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    NSDictionary *commentDictionary = self.comments[indexPath.row];
    Comment *comment = commentDictionary[@"parent"];
    NSString *partialComment = [self textToHtml:comment.body withCell:cell andComment:comment];
    cell.textView.text = comment.body;

    [cell.textView sizeToFit];
    self.cellHeight = cell.textView.frame.size.height;
    cell.commentWebView.frame = CGRectMake(cell.commentWebView.frame.origin.x, cell.commentWebView.frame.origin.y, cell.commentWebView.frame.size.width, self.cellHeight);
    cell.comment = comment;
    cell.delegate = self;
    cell.commentWebView.scrollView.scrollEnabled = NO;
    [cell.commentWebView loadHTMLString:partialComment baseURL:nil];
    cell.commentWebView.delegate = self;
    cell.textView.delegate = self;

    return cell;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [webView sizeToFit];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSURL *url = webView.request.URL;
    NSLog(@"URL %@",url);
}

- (NSString*)textToHtml:(NSString*)string withCell:(CommentTableViewCell *)cell andComment:(Comment *)comment{

    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];

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

-(void)setTableDelegatesAndDataSource{
    switch (self.sourceViewIdentifier) {
        case 1:
            self.imageCommentsTableView.delegate = self;
            self.imageCommentsTableView.dataSource = self;
            self.imageCommentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

            break;
        case 2:
            self.videoCommentsTableView.delegate = self;
            self.videoCommentsTableView.dataSource = self;
            self.videoCommentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

            break;
        case 3:
            self.gifCommentsTableView.delegate = self;
            self.gifCommentsTableView.dataSource = self;
            self.gifCommentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

            break;
        case 4:
            self.selfPostCommentsTableView.delegate = self;
            self.selfPostCommentsTableView.dataSource = self;
            self.selfPostCommentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

            break;
        case 5:

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

    return self.cellHeight;
}


@end
