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
#import "CommentsNavBarContainerViewController.h"

@interface CommentViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITabBarControllerDelegate, UITextViewDelegate>

@property Comment *selectedComment;
@property CGFloat cellHeight;
@property NSMutableArray *tableCells;
@property NSURL *urlToSend;
@property (nonatomic, weak) CommentsNavBarContainerViewController *customNavBarContainerViewController;

@end

@implementation CommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.constant = 44.0;

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    CGRect blurView = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [visualEffectView setFrame:blurView];
    visualEffectView.tag = 2;
    [self.view insertSubview:visualEffectView belowSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.tableView.estimatedRowHeight = 45.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Table View Delegate Methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    NSDictionary *commentDictionary = self.comments[indexPath.row];
    Comment *comment = commentDictionary[@"parent"];

    NSString *partialComment = [self textToHtml:comment.body withCell:cell andComment:comment];
    cell.commentTextView.text = comment.html;
   // [cell.commentTextView sizeToFit];
    //self.cellHeight = cell.commentTextView.frame.size.height;
    cell.commentTextView.scrollEnabled = NO;
    cell.commentTextView.delegate = self;
    cell.commentTextView.text = partialComment;
    // This label is used to make the cell apear the correct size. Then it is hidden. The content is
    // shown in the textView
    cell.hiddenLabelForCellSize.text = partialComment;
    cell.comment = comment;

    if (indexPath.row % 2) {
        cell.commentTextView.backgroundColor = [UIColor whiteColor];
    } else {
        cell.commentTextView.backgroundColor = [UIColor colorWithRed:0.937 green:0.969 blue:1 alpha:1];
    }

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{

    self.urlToSend = URL;
    [self performSegueWithIdentifier:@"TextViewWebSegue" sender:self];

    return NO;
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"TextViewWebSegue"]) {
        TextViewWebViewController *commentWebCtrl = segue.destinationViewController;
        commentWebCtrl.urlToLoad = self.urlToSend;
    }
    else if ([segue.identifier isEqualToString:@"CustomNavBarViewControllerSegue"])
    {
        self.customNavBarContainerViewController = segue.destinationViewController;
        if ([RKClient sharedClient]) {
            self.customNavBarContainerViewController.userIsLoggedIn = YES;
        }
        else
        {
            self.customNavBarContainerViewController.userIsLoggedIn = NO;
        }
    }
}

//- (IBAction)swapButtonPressed:(id)sender;

//
//- (IBAction)swapButtonPressed:(id)sender
//{
//    [self.containerViewController swapViewControllers];
//}


- (NSString*)textToHtml:(NSString*)string withCell:(CommentTableViewCell *)cell andComment:(Comment *)comment
{
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@""];

    return string;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return self.cellHeight;
//}

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

#pragma mark - Device Rotating 

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // TODO: Fix rotate issue with comments bar...
//    UIView *viewToRemove = [self.view viewWithTag:2];
//    [viewToRemove removeFromSuperview];
//    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    CGRect blurView;
//    NSLog(@"%f", self.navigationController.navigationBar.frame.size.height);
//    if (!self.navigationController.navigationBarHidden) {
//        blurView = CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20, self.view.frame.size.width, self.view.frame.size.height);
//    }
//    else {
//        blurView = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height);
//    }
//    [visualEffectView setFrame:blurView];
//    visualEffectView.tag = 2;
//    [self.view insertSubview:visualEffectView belowSubview:self.tableView];
}

@end
