//
//  GifPostViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

//#define REDDIT_DARK_BLUE [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];

#import "GifPostViewController.h"
#import "FLAnimatedImage.h"

@interface GifPostViewController ()//<UIGestureRecognizerDelegate, UIScrollViewDelegate>

//@property (weak, nonatomic) IBOutlet UIView *statusBarBackground;

@end
@implementation GifPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//
//    self.statusBarBackground.backgroundColor = REDDIT_DARK_BLUE;
//    if (!self.navigationController.navigationBarHidden) {
//        self.statusBarBackground.alpha = 0.0;
//    }
}

-(void)viewWillAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.url]]];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
            imageView.animatedImage = image;
            CGRect screenRect =[[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            CGFloat screenHeight = screenRect.size.height;
            imageView.frame = CGRectMake(0.0, self.view.center.y/2, screenWidth, screenHeight/2);
            [self.view addSubview:imageView];
        });
    });

//    if (self.navigationController.navigationBarHidden) {
//        self.statusBarBackground.alpha = 1.0;
//    }
//    else {
//        self.statusBarBackground.alpha = 0.0;
//    }
}

//- (IBAction)onPan:(UIPanGestureRecognizer *)panGesture
//{
//    typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
//        UIPanGestureRecognizerDirectionUndefined,
//        UIPanGestureRecognizerDirectionUp,
//        UIPanGestureRecognizerDirectionDown,
//        UIPanGestureRecognizerDirectionLeft,
//        UIPanGestureRecognizerDirectionRight
//    };
//
//    static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
//
//    switch (panGesture.state) {
//        case UIGestureRecognizerStateBegan:
//        {
//            if (direction == UIPanGestureRecognizerDirectionUndefined) {
//
//                CGPoint velocity = [panGesture velocityInView:self.view];
//
//                BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
//
//                if (isVerticalGesture) {
//                    if (velocity.y > 0) {
//                        direction = UIPanGestureRecognizerDirectionUp;
//                    } else {
//                        direction = UIPanGestureRecognizerDirectionDown;
//                    }
//                }
//
//                else {
//                    if (velocity.x > 0) {
//                        direction = UIPanGestureRecognizerDirectionRight;
//                    } else {
//                        direction = UIPanGestureRecognizerDirectionLeft;
//                    }
//                }
//            }
//            if (direction == UIPanGestureRecognizerDirectionDown && !self.navigationController.navigationBarHidden) {
//                [self hideNavigationAndTabBars];
//            }
//            break;
//        }
//        case UIGestureRecognizerStateEnded:
//        {
//            if (direction == UIPanGestureRecognizerDirectionUp) {
//                if (self.navigationController.navigationBarHidden) {
//                    [self showNavigationAndTabBars];
//                }
//            }
//            direction = UIPanGestureRecognizerDirectionUndefined;
//            break;
//        }
//        default:
//            break;
//    }
//}
//
//- (void)hideNavigationAndTabBars
//{
//    // If visiable hide nav and tab bar when scroll begins.
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//        self.tabBarController.tabBar.hidden = YES;
//    }];
//
//    [UIView animateWithDuration:0.0 delay:0.1 options:UIViewAnimationOptionTransitionNone animations:^{
//        self.statusBarBackground.alpha = 1.0;
//    } completion:^(BOOL finished) {
//        // Done
//    }];
//}
//
//- (void)showNavigationAndTabBars
//{
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//        self.tabBarController.tabBar.hidden = NO;
//    }];
//    // Animate after delay or there's a weird blip
//    [UIView animateWithDuration:0.0 delay:0.1 options:UIViewAnimationOptionTransitionNone animations:^{
//        self.statusBarBackground.alpha = 0.0;
//    } completion:^(BOOL finished) {
//        // Done
//    }];
//}
//
//-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
//{
//    [self showNavigationAndTabBars];
//}
//
//-(BOOL)prefersStatusBarHidden {
//    return YES;
//}
//
//// Allow simultaneous recognition
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}

@end
