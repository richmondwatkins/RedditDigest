//
//  VideoPostViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

//#define REDDIT_DARK_BLUE [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];

#import "VideoPostViewController.h"

@interface VideoPostViewController () <UIWebViewDelegate>  //<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *statusBarBackground;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation VideoPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGRect screenRect =[[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSString* embedHTML = [NSString stringWithFormat:@"\
                           <html>\
                           <body style='margin:0px;padding:0px;'>\
                           <script type='text/javascript' src='http://www.youtube.com/iframe_api'></script>\
                           <iframe id='playerId' type='text/html' width='%f' height='%f' src='http://%@?enablejsapi=1&rel=0&playsinline=1&autoplay=1' frameborder='0'>\
                           </body>\
                           </html>", screenWidth, screenHeight/2, self.url];
    [self.videoView loadHTMLString:embedHTML baseURL:[[NSBundle mainBundle] resourceURL]];

    if (!self.navController.navigationBarHidden) {
        self.statusBarBackground.alpha = 0.0;
    }
    else {
        self.statusBarBackground.alpha = 1.0;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
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
