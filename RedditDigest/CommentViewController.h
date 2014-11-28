//
//  CommentViewController.h
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/11/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "Post.h"
#import "DetailPostViewController.h"

@protocol CommentViewControllerDelegate <NSObject>

- (void)showOrHideCommentsViewController:(float)contentOffSet isScrolling:(BOOL)isScrolling;

@end

@interface CommentViewController : UIViewController <DetailPostViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSInteger index;
@property NSMutableArray *comments;
@property Post *post;
@property NSInteger constant;
@property (weak, nonatomic) IBOutlet UIButton *showHideCommentsViewButton;
@property BOOL isFromPastDigest;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property id<CommentViewControllerDelegate>delegate;

- (void)setupVoteButtons;

@end
