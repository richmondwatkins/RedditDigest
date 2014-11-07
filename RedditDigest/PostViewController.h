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


@property (strong, nonatomic) UIPageViewController *pageController;
@property NSMutableArray *allPosts;
@property Post *selectedPost; //if from core data
@property RKLink *selectedLink; //if from web
@end
