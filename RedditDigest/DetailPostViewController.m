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
@property NSMutableArray *comments;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentsHeightConstraint;

@end

@implementation DetailPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUpPageViewController];

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
            CGPoint translation = [panGesture locationInView:panGesture.view];
            // Make sure user can't pull down when comments view is already all the way at the bottom
            if (translation.y > 44) {
                self.commentsHeightConstraint.constant -= translation.y;
                [panGesture setTranslation:CGPointMake(0, 0) inView:panGesture.view];
            }
            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            if (direction == UIPanGestureRecognizerDirectionUp) {
                // Pulling down
                if (self.navigationController.navigationBarHidden) {
                    //[self showNavigationAndTabBars];
                }
                self.commentsHeightConstraint.constant = 44.0;

                // Snap shut
                [UIView animateWithDuration:0.3
                                      delay:0
                     usingSpringWithDamping:0.8
                      initialSpringVelocity:1.0
                                    options:0
                                 animations:^{
                                     [self.view layoutIfNeeded];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }

            else if (direction == UIPanGestureRecognizerDirectionDown) {
                // Pulling Up
                self.commentsHeightConstraint.constant = self.view.frame.size.height;
                // Snap shut
                [UIView animateWithDuration:0.3
                                      delay:0
                     usingSpringWithDamping:0.8
                      initialSpringVelocity:1.0
                                    options:0
                                 animations:^{
                                     [self.view layoutIfNeeded];
                                 }
                                 completion:^(BOOL finished) {
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
            } completion:^(BOOL finished) {
            }];
            break;
        }
        default:
            break;
    }
}


@end
