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
#import "DigestPost.h"
@interface DetailPostViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPageViewController *postPageController;
@property CommentViewController *commentsViewController;
@property NSMutableArray *comments;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentsHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *currentPostIndexLabel;

@end

@implementation DetailPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpPageViewController];

    [self showCounterLabelAtIndex:self.index];
    Post *post = self.allPosts[self.index];
    post.viewed = [NSNumber numberWithBool:YES];
    self.navigationItem.title = post.title;
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

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCommentsButtonTapped:)];
    tapGestureRecognizer.delegate = self;
    [self.commentsViewController.showHideCommentsViewButton addGestureRecognizer:tapGestureRecognizer];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CommentsSegue"])
    {
        self.commentsViewController = segue.destinationViewController;
        self.delegate = self.commentsViewController;
        self.commentsViewController.post = [self.allPosts objectAtIndex:self.index];
        self.commentsViewController.managedObjectContext = self.managedObjectContext;
        [self loadCommentsFromSelectedPost:self.index];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    PageWrapperViewController *pageWrapperViewController = (PageWrapperViewController *)viewController;
    if ((pageWrapperViewController.index == 0) || (pageWrapperViewController.index == NSNotFound)) {
        pageWrapperViewController.index = self.allPosts.count ;
    }

    return [self viewControllerAtIndex:(pageWrapperViewController.index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    PageWrapperViewController *pageWrapperViewController = (PageWrapperViewController *)viewController;
    if ((pageWrapperViewController.index == self.allPosts.count) || (pageWrapperViewController.index == NSNotFound)) {
        pageWrapperViewController.index = 0;
    }

    return [self viewControllerAtIndex:(pageWrapperViewController.index + 1)];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{

    NSUInteger index = [[pageViewController.viewControllers lastObject] index];
    if ((index <= 0) || (index == NSNotFound)) {
        index = self.allPosts.count;
    }

    if (index >= self.allPosts.count) {
        index = 0;
    }

    [self loadCommentsFromSelectedPost:index];
//    [self showCounterLabelAtIndex:index];
    // Set title of nav bar on change to new post
    Post *currentPost = [self.allPosts objectAtIndex:index];
    self.navigationItem.title = currentPost.title;


    [self showCounterLabelAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
//    NSUInteger index;
//
//    if([pendingViewControllers count] > 0)
//    {
//        index =[(PageWrapperViewController*)[pendingViewControllers objectAtIndex:0] index];
//
//        if ((index <= 0) || (index == NSNotFound)) {
//            index = self.allPosts.count;
//        }
//
//        if (index >= self.allPosts.count) {
//            index = 0;
//        }
//
//        [self loadCommentsFromSelectedPost:index];
//    }
//    [self showCounterLabelAtIndex:index];
//    // Set title of nav bar on change to new post 
//    Post *currentPost = [self.allPosts objectAtIndex:index];
//    self.navigationItem.title = currentPost.title;
//
//    if (index <= 0 || (index == NSNotFound)) {
//        index = self.allPosts.count;
//    }
//
//    if (index >= self.allPosts.count) {
//        index = 0;
//    }
//
//    [self showCounterLabelAtIndex:index];
}

- (void)loadCommentsFromSelectedPost:(NSUInteger)index
{
    if (!self.isFromPastDigest) {
        if ((index <= 0) || (index == NSNotFound)) {
            index = self.allPosts.count;
        }

        if (index >= self.allPosts.count) {
            index = 0;
        }
        Post *post = self.allPosts[index];
        [self.commentsViewController reloadTableWithCommentsFromCurrentPost:post];
        self.commentsViewController.post = post;
        [self.commentsViewController setupVoteButtons];
    }else{
        self.commentsViewController.isFromPastDigest = YES;
    }
}

- (PageWrapperViewController *)viewControllerAtIndex:(NSInteger)index
{
    if ((index <= 0) || (index == NSNotFound)) {
       index = self.allPosts.count;
    }

    PageWrapperViewController *viewController;

    if (index >= self.allPosts.count) {
       index = 0;
    }

    if (!self.isFromPastDigest) {
        Post *post = self.allPosts[index];

        if (post.isImageLink.intValue == 1) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageView"];
            viewController.sourceViewIdentifier = 1;
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
        viewController.postID = post.postID;
    }else{
        DigestPost *post = self.allPosts[index];

        if (post.isImageLink.intValue == 1) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageView"];
            viewController.sourceViewIdentifier = 1;
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
        viewController.isOldDigest = YES;
        viewController.postID = post.postID;
    }


//    viewController.post = post;
    viewController.index = index;
    viewController.navController = self.navigationController;

    return viewController;
}

// Pan gesture to show comments
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
            if (direction != UIPanGestureRecognizerDirectionLeft && direction != UIPanGestureRecognizerDirectionRight)
            {
                // View begins as size of iphone screen

                //if (self.commentsViewController.view.frame.size.height > 479 || self.commentsViewController.view.frame.size.height > 43) {
                self.commentsHeightConstraint.constant -= translation.y;
                [panGesture setTranslation:CGPointMake(0, 0) inView:panGesture.view];
                //}
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
                self.commentsHeightConstraint.constant = self.navigationController.navigationBar.frame.size.height;

                if (direction != UIPanGestureRecognizerDirectionLeft || direction != UIPanGestureRecognizerDirectionRight)
                {   // Snap shut
                    [self animateViewIntoPlace];
                    [self.commentsViewController.showHideCommentsViewButton setImage:[UIImage imageNamed:@"comment_up"] forState:UIControlStateNormal];
                }
            }

            else if (direction == UIPanGestureRecognizerDirectionDown) {
                // Pulling Up
                if (self.navigationController.navigationBarHidden) {
                    self.commentsHeightConstraint.constant = self.view.frame.size.height - 20;
                }
                else {
                    self.commentsHeightConstraint.constant = self.view.frame.size.height;

                }
                if (direction != UIPanGestureRecognizerDirectionLeft || direction != UIPanGestureRecognizerDirectionRight)
                {   // Snap open
                    [self animateViewIntoPlace];
                    [self.commentsViewController.showHideCommentsViewButton setImage:[UIImage imageNamed:@"comment_down"] forState:UIControlStateNormal];
                }
            }
            direction = UIPanGestureRecognizerDirectionUndefined;
            break;
        }

        case UIGestureRecognizerStateCancelled:
        {
            self.commentsHeightConstraint.constant = self.navigationController.navigationBar.frame.size.height;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                NSLog(@"Gesture cancelled");
            }];
            break;
        }
        default:
            break;
    }
}

// Tap gesture to show/hide comments
- (void)onCommentsButtonTapped:(UITapGestureRecognizer *)tapGesture
{
    switch (tapGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        {
            if (self.commentsHeightConstraint.constant < 45) {
                if (self.navigationController.navigationBarHidden) {
                    self.commentsHeightConstraint.constant = self.view.frame.size.height - 20;
                }
                else {
                    self.commentsHeightConstraint.constant = self.view.frame.size.height;
                }
                [self animateViewIntoPlace];
                [self.commentsViewController.showHideCommentsViewButton setImage:[UIImage imageNamed:@"comment_down"] forState:UIControlStateNormal];
            }
            else
            {
                self.commentsHeightConstraint.constant = self.navigationController.navigationBar.frame.size.height;
                [self animateViewIntoPlace];
                [self.commentsViewController.showHideCommentsViewButton setImage:[UIImage imageNamed:@"comment_up"] forState:UIControlStateNormal];
            }
            break;
        }
        default:
            break;
    }
}

- (void)animateViewIntoPlace
{
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

#pragma mark - Counter Label

- (void)showCounterLabelAtIndex:(NSInteger)startingIndex
{
    self.currentPostIndexLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)startingIndex + 1, (unsigned long)self.allPosts.count];
    self.currentPostIndexLabel.alpha = 0.8;
    self.currentPostIndexLabel.layer.cornerRadius = 10;
    self.currentPostIndexLabel.clipsToBounds = YES;
    
    [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.currentPostIndexLabel.alpha = 0.0;
    } completion:nil];
}


@end
