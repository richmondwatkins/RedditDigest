//
//  CommentViewController.h
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/11/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "DetailPostViewController.h"


@interface CommentViewController : UIViewController <DetailPostViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSInteger index;
@property NSMutableArray *comments;

@end
