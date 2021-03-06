//
//  PostViewController.h
//  Pods
//
//  Created by Richmond on 11/5/14.
//
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import <RedditKit.h>
#import <RKLink.h>
@interface PostViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *postsPageController;
@property NSMutableArray *allPosts;
@property NSInteger index;

@end
