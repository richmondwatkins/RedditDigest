//
//  DetailPostTabBarViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/12/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "DetailPostViewController.h"

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

@interface DetailPostViewController ()

@property (strong, nonatomic) UIPageViewController *postPageController;
@property CommentViewController *commentsViewController;
//@property (strong, nonatomic) UIPageViewController *commentsPageController;
@property NSMutableArray *comments;
//@property BOOL commentsViewLoaded;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentsHeightConstraint;

@end

@implementation DetailPostViewController

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

    // Add postPageController just below the commentsViewController
    [self.view insertSubview:self.postPageController.view atIndex:0];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CommentsSegue"])
    {
        self.commentsViewController = segue.destinationViewController;
        self.delegate = self.commentsViewController;
        [self loadCommentsFromSelectedPost:self.index];
    }
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
        [self loadCommentsFromSelectedPost:index];
    }
}

- (void)loadCommentsFromSelectedPost:(NSUInteger)indexOfPostToGetCommentsFor
{
    Post *post = self.allPosts[indexOfPostToGetCommentsFor];
    [self.commentsViewController reloadTableWithCommentsFromCurrentPost:post];
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

@end
