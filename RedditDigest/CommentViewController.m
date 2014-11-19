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
#import "PocketAPI.h"
#import "TSMessage.h"
#import <SafariServices/SafariServices.h>

@interface CommentViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITabBarControllerDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property Comment *selectedComment;
@property CGFloat cellHeight;
@property NSMutableArray *tableCells;
@property NSURL *urlToSend;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraintForCommentsButton;
@property (weak, nonatomic) IBOutlet UIButton *upVoteButton;
@property (weak, nonatomic) IBOutlet UIButton *downVoteButton;

@end

@implementation CommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UserIsLoggedIn"])
    {
        self.upVoteButton.hidden = NO;
        self.downVoteButton.hidden = NO;
        // Size of constraint set in storyboard
        self.leadingConstraintForCommentsButton.constant = 134.0;
        [self setupVoteButtons];
    }
    else {
        self.upVoteButton.hidden = YES;
        self.downVoteButton.hidden = YES;
        CGFloat size = self.leadingConstraintForCommentsButton.constant;
        self.leadingConstraintForCommentsButton.constant -= size / 2;
    }

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

    if (self.isFromPastDigest) {
        cell.commentTextView.text = @"Comments are not available for archived digests.";
        cell.hiddenLabelForCellSize.text = @"Comments are not available for archived digests.";
    }else{
        NSDictionary *commentDictionary = self.comments[indexPath.row];
        Comment *comment = commentDictionary[@"parent"];

        NSString *partialComment = [self textToHtml:comment.body withCell:cell andComment:comment];
        cell.commentTextView.text = comment.html;
        // [cell.commentTextView sizeToFit];
        //self.cellHeight = cell.commentTextView.frame.size.height;

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
    }

    cell.commentTextView.scrollEnabled = NO;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isFromPastDigest) {
        return 1;
    }else{
        return self.comments.count;
    }
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

#pragma mark - Voting

- (void)setupVoteButtons
{
    if ([self.post.upvoted boolValue]) {
        [self.upVoteButton setImage:[UIImage imageNamed:@"up_arrow_selected"] forState:UIControlStateNormal];
    }
    else {
        [self.upVoteButton setImage:[UIImage imageNamed:@"up_arrow"] forState:UIControlStateNormal];
    }
    if ([self.post.downvoted isEqual:[NSNumber numberWithInt:1]]) {
        [self.downVoteButton setImage:[UIImage imageNamed:@"down_arrow_selected"] forState:UIControlStateNormal];
    }
    else {
        [self.downVoteButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
    }
}

- (IBAction)onDownVoteButtonPressed:(UIButton *)downVoteButton
{
    if ([self.post.downvoted boolValue]) {
        // Remove downvote
        [downVoteButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
        [self.upVoteButton setImage:[UIImage imageNamed:@"up_arrow"] forState:UIControlStateNormal];
        self.post.downvoted = [NSNumber numberWithBool:NO];
        self.post.upvoted = [NSNumber numberWithBool:NO];
        // Remove vote from reddit
        [self removeVoteFromReddit:self.post.postID];
    }
    else {
        // Downvote
        [downVoteButton setImage:[UIImage imageNamed:@"down_arrow_selected"] forState:UIControlStateNormal];
        [self.upVoteButton setImage:[UIImage imageNamed:@"up_arrow"] forState:UIControlStateNormal];
        self.post.downvoted = [NSNumber numberWithBool:YES];
        self.post.upvoted = [NSNumber numberWithBool:NO];
        // Remove vote from reddit
        [self sendDownVoteToReddit:self.post.postID];
    }
    [self.managedObjectContext save:nil];

}

- (IBAction)onUpVoteButtonPressed:(UIButton *)upVoteButton
{
    if (self.post.upvoted) {
        // Remove upvote
        [upVoteButton setImage:[UIImage imageNamed:@"up_arrow"] forState:UIControlStateNormal];
        [self.downVoteButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
        self.post.upvoted = [NSNumber numberWithBool:NO];
        self.post.downvoted = [NSNumber numberWithBool:NO];
        // Remove vote from reddit
        [self removeVoteFromReddit:self.post.postID];
    }
    else {
        // Upvote
        [upVoteButton setImage:[UIImage imageNamed:@"up_arrow_selected"] forState:UIControlStateNormal];
        [self.downVoteButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
        self.post.upvoted = [NSNumber numberWithBool:YES];
        self.post.downvoted = [NSNumber numberWithBool:NO];
        // Remove vote from reddit
        [self sendUpVoteToReddit:self.post.postID];
    }

    [self.managedObjectContext save:nil];
}

-(void)sendUpVoteToReddit:(NSString *)postID
{
    [[RKClient sharedClient] linkWithFullName:postID completion:^(id object, NSError *error) {
        [[RKClient sharedClient] upvote:object completion:^(NSError *error) {
            NSLog(@"Upvote");
        }];
    }];
}

-(void)sendDownVoteToReddit:(NSString *)postID
{
    [[RKClient sharedClient] linkWithFullName:postID completion:^(id object, NSError *error) {
        [[RKClient sharedClient] downvote:object completion:^(NSError *error) {
            NSLog(@"Downvote");
        }];
    }];

}

- (void)removeVoteFromReddit:(NSString *)postID
{
    [[RKClient sharedClient] linkWithFullName:postID completion:^(id object, NSError *error) {
        [[RKClient sharedClient] revokeVote:object completion:^(NSError *error) {
            NSLog(@"Removed Vote");
        }];
    }];
}

#pragma mark - Share
- (IBAction)onShareButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Save Post to Pocket", @"Save to Reading List", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate Methods 

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        // Save post url to Pocket
        NSURL *url = [NSURL URLWithString:self.post.url];
        [[PocketAPI sharedAPI] saveURL:url handler:^(PocketAPI *api, NSURL *url, NSError *error) {
            if (error) {
                NSLog(@"Error saving to Pocket %@", error.localizedDescription);
                [TSMessage showNotificationInViewController:self.parentViewController
                                                      title:@"Error Saving to Pocket!"
                                                   subtitle:@"Try again later"
                                                       type:TSMessageNotificationTypeError
                                                   duration:2.5];
            }
            else {
                [TSMessage showNotificationInViewController:self.parentViewController
                                                      title:@"Saved to Pocket!"
                                                   subtitle:nil
                                                       type:TSMessageNotificationTypeSuccess
                                                   duration:1.5];
            }
        }];
    }
    else if (buttonIndex == 1) {
        SSReadingList * readList = [SSReadingList defaultReadingList];
        NSError * error = [NSError new];

        BOOL status =[readList addReadingListItemWithURL:[NSURL URLWithString:self.post.url] title:self.post.title previewText:self.post.description error:&error];

        if(status) {
            NSLog(@"Added URL");
        }
        else {
            NSLog(@"Error %@", error.localizedDescription);
        }
    }
}


@end
