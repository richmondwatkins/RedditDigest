//
//  PageWrapperViewController.h
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
@interface PageWrapperViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property NSInteger index;
@property NSMutableArray *comments;
@property NSString *url;
@property NSString *selfPostText;
@property NSData *imageData;
@property (strong, nonatomic) IBOutlet UITableView *imageCommentsTableView;
@property (strong, nonatomic) IBOutlet UITableView *selfPostCommentsTableView;
@property (strong, nonatomic) IBOutlet UITableView *gifCommentsTableView;
@property (strong, nonatomic) IBOutlet UITableView *videoCommentsTableView;

@end
