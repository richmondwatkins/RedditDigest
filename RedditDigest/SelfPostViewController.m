//
//  SelfPostViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#define REDDIT_DARK_BLUE [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];

#import "SelfPostViewController.h"

@interface SelfPostViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *statusBarBackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceConstraint;

@end

@implementation SelfPostViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.textView.text = self.selfPostText;

    if (!self.navController.navigationBarHidden) {
        self.statusBarBackground.alpha = 0.0;
    }
    else {
        self.statusBarBackground.alpha = 1.0;
    }

    NSLog(@"%f", self.verticalSpaceConstraint.constant);
    //self.verticalSpaceConstraint.constant -= 20;
}

//- (void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    CGRect viewBounds = self.view.bounds;
//    CGFloat topBarOffset = self.topLayoutGuide.length;
//
//    // snaps the view under the status bar (iOS 6 style)
//    viewBounds.origin.y = topBarOffset * -1;
//
//    // shrink the bounds of your view to compensate for the offset
//    viewBounds.size.height = viewBounds.size.height + (topBarOffset * -1);
//    self.view.bounds = viewBounds;
//}

- (void)viewDidLoad {
    [super viewDidLoad];


    // This makes sure each self post is scrolled to the top when it loads
    [self.textView scrollRangeToVisible:NSMakeRange(0, 1)];

    self.statusBarBackground.backgroundColor = REDDIT_DARK_BLUE;
    if (!self.navigationController.navigationBarHidden) {
        self.statusBarBackground.alpha = 0.0;
    }
}

- (IBAction)onPan:(UIPanGestureRecognizer *)panGesture
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
                [self hideNavigationAndTabBars];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            if (direction == UIPanGestureRecognizerDirectionUp) {
                if (self.navigationController.navigationBarHidden) {
                    [self showNavigationAndTabBars];
                }
            }
            direction = UIPanGestureRecognizerDirectionUndefined;
            break;
        }
        default:
            break;
    }
}

- (void)hideNavigationAndTabBars
{
    // If visiable hide nav and tab bar when scroll begins.
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.tabBarController.tabBar.hidden = YES;
    }];

    [UIView animateWithDuration:0.0 delay:0.1 options:UIViewAnimationOptionTransitionNone animations:^{
        self.statusBarBackground.alpha = 1.0;
    } completion:^(BOOL finished) {
        // Done
    }];
}

- (void)showNavigationAndTabBars
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.tabBarController.tabBar.hidden = NO;
    }];
    // Animate after delay or there's a weird blip
    [UIView animateWithDuration:0.0 delay:0.1 options:UIViewAnimationOptionTransitionNone animations:^{
        self.statusBarBackground.alpha = 0.0;
    } completion:^(BOOL finished) {
        // Done
    }];
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self showNavigationAndTabBars];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

// Allow simultaneous recognition
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
