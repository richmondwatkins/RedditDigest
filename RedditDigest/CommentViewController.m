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
#import "TSMessage.h"

@interface CommentViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITabBarControllerDelegate, UITextViewDelegate>

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

    if (!self.isFromPastDigest) {
        [self setupVoteButtons];
    }
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
        cell.userNameLabel.text = comment.author;
        cell.voteScoreLabel.text = [self abbreviateNumber:comment.score.integerValue];

        if (indexPath.row % 2) {
            cell.commentTextView.backgroundColor = [UIColor whiteColor];
            cell.userDetailsBackgroundView.backgroundColor = [UIColor whiteColor];
        } else {
            cell.commentTextView.backgroundColor = [UIColor colorWithRed:0.937 green:0.969 blue:1 alpha:1];
            cell.userDetailsBackgroundView.backgroundColor = [UIColor colorWithRed:0.937 green:0.969 blue:1 alpha:1];

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0)
    {
        [self.delegate showOrHideCommentsViewController:abs(scrollView.contentOffset.y) isScrolling:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollingFinish];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollingFinish];
}

- (void)scrollingFinish
{
    [self.delegate showOrHideCommentsViewController:1.0 isScrolling:NO];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"TextViewWebSegue"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        TextViewWebViewController *commentWebCtrl = navigationController.viewControllers.firstObject;
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
    if ([self.post.downvoted boolValue]) {
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
        // Send downvote to reddit
        [self sendDownVoteToReddit:self.post.postID];
    }
    [self.managedObjectContext save:nil];

}

- (IBAction)onUpVoteButtonPressed:(UIButton *)upVoteButton
{
    if ([self.post.upvoted boolValue]) {
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
        // Send upvote to reddit
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
    NSLog(@"SELECTED POST %@",self.self.post.url);
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.post.title, self.post.url]
                                      applicationActivities:nil];
            [self.navigationController presentViewController:activityViewController
                                                   animated:YES
                                                 completion:^{
                                                    NSLog(@"Share Pressed");
                                                 }];

}

#pragma mark - Cell Helpers

-(NSString *)abbreviateNumber:(NSInteger)num
{
    NSString *abbreviatedNumunber;
    float number = (float)num;

    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbreviations = @[@"k", @"m", @"b"];

        for (NSInteger i = abbreviations.count - 1; i >= 0; i--)
        {
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);

            if (size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];

                // Add the letter for the abbreviation
                abbreviatedNumunber = [NSString stringWithFormat:@"%@%@", numberString, [abbreviations objectAtIndex:i]];
            }
        }
    } else {
        // Numbers like: 999 returns 999 instead of NULL
        abbreviatedNumunber = [NSString stringWithFormat:@"%d", (int)number];
    }
    return abbreviatedNumunber;
}

- (NSString *) floatToString:(float) val
{
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];

    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    return ret;
}


@end
