//
//  CommentViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/11/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentTableViewCell.h"
#import "Post.h"
#import "TextViewWebViewController.h"
@interface CommentViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITabBarControllerDelegate, UITextViewDelegate>

@property Comment *selectedComment;
@property CGFloat cellHeight;
@property NSMutableArray *tableCells;
@property NSURL *urlToSend;
@end

@implementation CommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.constant = 44.0;
    //self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    CGRect blurView = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [visualEffectView setFrame:blurView];
    [self.view insertSubview:visualEffectView belowSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    NSDictionary *commentDictionary = self.comments[indexPath.row];
    Comment *comment = commentDictionary[@"parent"];

    NSString *partialComment = [self textToHtml:comment.body withCell:cell andComment:comment];
    cell.commentTextView.text = comment.html;
    [cell.commentTextView sizeToFit];
    self.cellHeight = cell.commentTextView.frame.size.height;
    cell.commentTextView.scrollEnabled = NO;
    cell.commentTextView.delegate = self;
    cell.commentTextView.text = partialComment;
    cell.comment = comment;

    if (indexPath.row % 2) {
        cell.commentTextView.backgroundColor = [UIColor colorWithRed:0.914 green:0.914 blue:0.914 alpha:1];
    } else {
        cell.commentTextView.backgroundColor = [UIColor whiteColor];
    }

    return cell;
}

//- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
//{
//    if(indexPath.row % 2 == 0)
//        cell.backgroundColor = [UIColor redColor];
//    else
//        cell.backgroundColor = [UIColor whiteColor];
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{

    self.urlToSend = URL;
    [self performSegueWithIdentifier:@"TextViewWebSegue" sender:self];

    return NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"TextViewWebSegue"]) {
        TextViewWebViewController *commentWebCtrl = segue.destinationViewController;
        commentWebCtrl.urlToLoad = self.urlToSend;
    }
}

- (NSString*)textToHtml:(NSString*)string withCell:(CommentTableViewCell *)cell andComment:(Comment *)comment
{
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@""];

    return string;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

- (void)reloadTableWithCommentsFromCurrentPost:(Post *)selectedPost
{
    self.comments = [self getcommentsFromSelectedPost:selectedPost];
    [self.tableView reloadData];
}

- (NSMutableArray *)getcommentsFromSelectedPost:(Post *)selectedPost
{
    NSArray *allComments = [self commentSorter:[selectedPost.comments allObjects]];
    NSMutableArray *comments = [self matchChildCommentsToParent:allComments];
    return comments;
}

-(NSArray *)commentSorter:(NSArray *)comments
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

    return [comments sortedArrayUsingDescriptors:sortDescriptors];
}

-(NSMutableArray *)matchChildCommentsToParent:(NSArray *)parentComments
{
    NSMutableArray *matchedComments = [NSMutableArray array];

    for(Comment *comment in parentComments) {
        NSArray *childComments = [self commentSorter:[comment.childcomments allObjects]];
        NSDictionary *parentChildComment = [[NSDictionary alloc] initWithObjectsAndKeys:comment, @"parent", childComments, @"children", nil];
        [matchedComments addObject:parentChildComment];
    }

    return matchedComments;
}

@end
