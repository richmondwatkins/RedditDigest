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
//    NSLog(@"COMMENT DICT %@",commentDictionary);
//    Comment *comment = commentDictionary[@"parent"];
//    NSString *html = [self textToHtml:comment.body];
//    cell.commentWebView.userInteractionEnabled = NO;
//    cell.commentWebView.delegate = self;
//    [cell.commentWebView loadHTMLString:html baseURL:nil];

  

//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//
//    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//
//        dispatch_async(dispatch_get_main_queue(), ^(void){
//            cell.textLabel.attributedText = attrStr;
//            cell.detailTextLabel.text = comment.author;
//        });
//    });
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
