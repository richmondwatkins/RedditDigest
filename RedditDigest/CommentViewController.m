//
//  CommentViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/11/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentTableViewCell.h"

@interface CommentViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITabBarControllerDelegate>

@property Comment *selectedComment;
@property CGFloat cellHeight;
@property NSMutableArray *tableCells;
@end

@implementation CommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

    cell.commentTextView.text = partialComment;
    cell.backgroundColor = [UIColor whiteColor];
    cell.comment = comment;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
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



@end
