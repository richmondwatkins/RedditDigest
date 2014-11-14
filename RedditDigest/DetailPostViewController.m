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

@interface DetailPostViewController () <UIGestureRecognizerDelegate>

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

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    panGestureRecognizer.delegate = self;
    [self.commentsViewController.view addGestureRecognizer:panGestureRecognizer];
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

- (void)onPanGesture:(UIPanGestureRecognizer *)panGesture
{
    typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
        UIPanGestureRecognizerDirectionUndefined,
        UIPanGestureRecognizerDirectionUp,
        UIPanGestureRecognizerDirectionDown,
        UIPanGestureRecognizerDirectionLeft,
        UIPanGestureRecognizerDirectionRight
    };

    static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;

    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (direction == UIPanGestureRecognizerDirectionUndefined) {

                CGPoint velocity = [panGesture velocityInView:self.view];

                BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);

                if (isVerticalGesture) {
                    if (velocity.y > 0) {
                        direction = UIPanGestureRecognizerDirectionUp;
                    } else {
                        direction = UIPanGestureRecognizerDirectionDown;
                    }
                }

                else {
                    if (velocity.x > 0) {
                        direction = UIPanGestureRecognizerDirectionRight;
                    } else {
                        direction = UIPanGestureRecognizerDirectionLeft;
                    }
                }
            }
            if (direction == UIPanGestureRecognizerDirectionDown && !self.navigationController.navigationBarHidden) {
                //[self hideNavigationAndTabBars];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGesture translationInView:panGesture.view];
            self.commentsViewController.constant -= translation.y;
            [panGesture setTranslation:CGPointMake(0, 0) inView:panGesture.view];
            //self.lastYTranslation = translation.y;
            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            if (direction == UIPanGestureRecognizerDirectionUp) {
                if (self.navigationController.navigationBarHidden) {
                    //[self showNavigationAndTabBars];
                }
                self.commentsHeightConstraint.constant = 44.0;
                [UIView animateWithDuration:0.2 animations:^{
                    [self.view layoutIfNeeded];
                    // self.blurView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    //[self.blurView removeFromSuperview];
                }];
            }

            else if (direction == UIPanGestureRecognizerDirectionDown) {
                self.commentsHeightConstraint.constant = self.view.frame.size.height;
                [UIView animateWithDuration:0.2 animations:^{
                    [self.view layoutIfNeeded];
                    //self.blurView.alpha = 1.0;
                }];


            }
            direction = UIPanGestureRecognizerDirectionUndefined;
            break;
        }

        case UIGestureRecognizerStateCancelled:
        {
            self.commentsHeightConstraint.constant = 44;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
                //                self.blurView.alpha = 0.0;
            } completion:^(BOOL finished) {
                //                [self.blurView removeFromSuperview];
            }];
            break;
        }
        default:
            break;
    }

    //    if (UIGestureRecognizerStateBegan == gesture.state)
    //    {
    ////        if (self.containerViewHeightConstraint.constant == INITIAL_CONTAINER_LOC) // Container is being moved up
    ////        {
    //            // Create blur view to animate
    ////            self.blurView = [[LFGlassView alloc] initWithFrame:self.view.frame];;
    ////            self.blurView.alpha = 0.0;
    ////            self.blurView.frame = self.view.frame;
    ////            [self.view insertSubview:self.blurView belowSubview:self.containerView];
    ////        }
    //    }
    //    else if (UIGestureRecognizerStateChanged == gesture.state)
    //    {
    //        CGPoint translation = [gesture translationInView:gesture.view];
    //        self.commentsViewController.constant -= translation.y;
    //        [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];
    //        self.lastYTranslation = translation.y;
    //
    //        // Set blurView alpha
    //        //CGPoint location = [gesture locationInView:self.view];
    //        //self.blurView.alpha = 1.06 - (location.y/self.view.frame.size.height);
    //    }
    //    else if (UIGestureRecognizerStateEnded == gesture.state)
    //    {
    //        if (self.lastYTranslation > 0) // User was panning down so finish closing
    //        {
    //            self.containerViewHeightConstraint.constant = INITIAL_CONTAINER_LOC;
    //            [UIView animateWithDuration:0.2 animations:^{
    //                [self.view layoutIfNeeded];
    //                self.blurView.alpha = 0.0;
    //            } completion:^(BOOL finished) {
    //                [self.blurView removeFromSuperview];
    //            }];
    //        }
    //        else // User was panning up so finish opening
    //        {
    //            self.containerViewHeightConstraint.constant = self.view.frame.size.height;
    //            [UIView animateWithDuration:0.2 animations:^{
    //                [self.view layoutIfNeeded];
    //                self.blurView.alpha = 1.0;
    //            }];
    //        }
    //    }
    //    else // Gesture was cancelled or failed so animate back to original location
    //    {
    //        self.containerViewHeightConstraint.constant = INITIAL_CONTAINER_LOC;
    //        [UIView animateWithDuration:0.2 animations:^{
    //            [self.view layoutIfNeeded];
    //            self.blurView.alpha = 0.0;
    //        } completion:^(BOOL finished) {
    //            [self.blurView removeFromSuperview];
    //        }];
    //    }
}


@end
