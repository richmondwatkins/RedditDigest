//
//  DetailPostTabBarViewController.h
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/12/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@protocol DetailPostViewControllerDelegate <NSObject>

- (void)reloadTableWithCommentsFromCurrentPost:(Post *)selectedPost;

@end

@interface DetailPostViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property id<DetailPostViewControllerDelegate> delegate;

@property NSMutableArray *allPosts;
@property NSInteger index;

@end
