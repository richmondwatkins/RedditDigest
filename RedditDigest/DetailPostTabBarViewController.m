//
//  DetailPostTabBarViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/12/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "DetailPostTabBarViewController.h"

#import "PostViewController.h"
#import "ImagePostViewController.h"
#import "WebPostViewController.h"
#import "GifPostViewController.h"
#import "SelfPostViewController.h"
#import "VideoPostViewController.h"

#import "PageWrapperViewController.h"
#import "CommentViewController.h"
#import "Comment.h"
#import "ChildComment.h"

@interface DetailPostTabBarViewController ()

@property (strong, nonatomic) UIPageViewController *postPageController;
@property (strong, nonatomic) UIPageViewController *commentsPageController;
@property NSMutableArray *comments;
@property BOOL commentsViewLoaded;

@end

@implementation DetailPostTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUpPageViewController];
    //self.navigationController.hidesBarsOnSwipe = YES;
    //self.navigationController.hidesBarsOnTap = YES;
    //self.hidesBottomBarWhenPushed = YES;
    
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
-(void)setUpPageViewController
{
    self.postPageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    self.postPageController.dataSource = self;
    self.postPageController.view.frame = self.view.bounds;
    self.postPageController.delegate = self;

    PageWrapperViewController *detailPostViewController = [self viewControllerAtIndex:self.index];
    NSArray *postViewControllers = [NSArray arrayWithObject:detailPostViewController];
    [self.postPageController setViewControllers:postViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    CommentViewController *commentsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentsViewController.view.frame = self.view.bounds;
    commentsViewController.comments = [self getcommentsFromSelectedPost:self.index];
    self.commentsViewLoaded = YES;

    self.postPageController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:1];
    commentsViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:2];

    self.viewControllers = @[self.postPageController, commentsViewController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    PageWrapperViewController *pageWrapperViewController = (PageWrapperViewController *)viewController;
    return [self viewControllerAtIndex:(pageWrapperViewController.index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    PageWrapperViewController *pageWrapperViewController = (PageWrapperViewController *)viewController;
    return [self viewControllerAtIndex:(pageWrapperViewController.index + 1)];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    if([pendingViewControllers count] > 0)
    {
        NSUInteger index =[(PageWrapperViewController*)[pendingViewControllers objectAtIndex:0] index];
        CommentViewController *commentsViewController = self.viewControllers[1];
        commentsViewController.comments = [self getcommentsFromSelectedPost:index];
        [commentsViewController.tableView reloadData];
    }
}

- (NSMutableArray *)getcommentsFromSelectedPost:(NSInteger)selectedPostIndex
{
    Post *post = self.allPosts[selectedPostIndex];
    NSArray *allComments = [self commentSorter:[post.comments allObjects]];
    NSMutableArray *comments = [self matchChildCommentsToParent:allComments];
    return comments;
}

- (PageWrapperViewController *)viewControllerAtIndex:(NSInteger)index
{
    if (index<0) {
        return nil;
    }
    if (index >= self.allPosts.count) {
        return nil;
    }

    Post *post = self.allPosts[index];
    NSArray *allComments = [self commentSorter:[post.comments allObjects]];
    self.comments = [self matchChildCommentsToParent:allComments];

    PageWrapperViewController *viewController;
    if (post.isImageLink.intValue == 1) {
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageView"];
        viewController.sourceViewIdentifier = 1;
        viewController.imageData = post.image;
    }else if(post.isYouTube.intValue == 1){
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoView"];
        viewController.sourceViewIdentifier = 2;
        viewController.url = post.url;
    }else if(post.isGif.intValue == 1){
        viewController =[self.storyboard instantiateViewControllerWithIdentifier:@"GifView"];
        viewController.sourceViewIdentifier = 3;
        viewController.url = post.url;
    }else if(post.isSelfPost.integerValue == 1){
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfPostView"];
        viewController.sourceViewIdentifier = 4;
        viewController.selfPostText = post.selfText;
    }else{
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
        viewController.sourceViewIdentifier = 5;
        viewController.url = post.url;
    }

    viewController.post = post;
    viewController.index = index;

    return viewController;
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



@end
