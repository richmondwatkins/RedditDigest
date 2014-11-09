//
//  PageWrapperViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "PageWrapperViewController.h"

@interface PageWrapperViewController ()

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
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.comments.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    NSDictionary *commentDictionary = self.comments[indexPath.row];
    NSLog(@"COMMENT DICT %@",commentDictionary);
    Comment *comment = commentDictionary[@"parent"];
    cell.textLabel.text = comment.body;
    cell.detailTextLabel.text = comment.author;
    return cell;
}


@end
