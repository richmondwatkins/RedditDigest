//
//  WebPostViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

//#define REDDIT_DARK_BLUE [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];

#import "WebPostViewController.h"
#import "InternetConnectionTest.h"
#import "WebViewOverlayTouchIntercept.h"
@interface WebPostViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate, UIWebViewDelegate, WebViewTouchIntercepts, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *statusBarBackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
@implementation WebPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [InternetConnectionTest testInternetConnectionWithViewController:self andCompletion:^(BOOL internet) {
        if (internet == YES) {
            NSURLRequest *request;
            if (![self.url containsString:@"imgur"]) {
                request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
            }else{
                request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
            }

            [self.webView loadRequest:request];
            if (self.navController.navigationBarHidden) {
                self.statusBarBackground.alpha = 1.0;
                self.verticalSpaceConstraint.constant = 20;
            }
            else {
                self.statusBarBackground.alpha = 0.0;
                self.verticalSpaceConstraint.constant = 0;
            }
        }
    }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.webView.scrollView.delegate = self;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];

    if (self.isNSFW && [[NSUserDefaults standardUserDefaults] boolForKey:@"HideNSFW"]) {
        UIVisualEffectView *blurEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        blurEffect.frame = webView.bounds;
        [webView addSubview:blurEffect];
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView stringByEvaluatingJavaScriptFromString:@"window.alert=null;"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;

    [webView stringByEvaluatingJavaScriptFromString:@"(function removeElementsByClass(){"
     "var elements = document.getElementsByClassName('gallery-carousel');"
     "var i = elements.length;"
     "while(i > 0){"
        "elements[0].className += ' noSwipe';"
        "i--;}})();"
     ];
}

#pragma mark - Pan
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
            if (direction == UIPanGestureRecognizerDirectionDown && !self.navController.navigationBarHidden) {
                [self hideNavigationAndTabBars];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            if (direction == UIPanGestureRecognizerDirectionUp) {

                if (self.navController.navigationBarHidden) {
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
    [UIView animateWithDuration:0.2 animations:^{
        self.statusBarBackground.alpha = 1.0;
    }];
    NSLog(@"%f", self.verticalSpaceConstraint.constant);
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        [self.navController setNavigationBarHidden:YES animated:YES];
        self.verticalSpaceConstraint.constant = self.navController.navigationBar.frame.size.height -24;
        [self.view layoutIfNeeded];
    }];
}

- (void)showNavigationAndTabBars
{
    [UIView animateWithDuration:0.2 animations:^{
        self.statusBarBackground.alpha = 0.0;
    }];
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        [self.navController setNavigationBarHidden:NO animated:YES];
        self.verticalSpaceConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

// Allow simultaneous recognition
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self showNavigationAndTabBars];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"Scroll");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    CGPoint translation = [scrollView.panGestureRecognizer velocityInView:self.view];
    NSLog(@"TRANSLATION %@",NSStringFromCGPoint(translation));
    if (translation.x > 0) {
        NSLog(@"RIGHT");
    }else if(translation.x < 0){
        NSLog(@"LEFT");
    }
}

-(void)sendTouchToWebView:(NSSet *)touches withEven:(UIEvent *)event{

    [self.webView touchesMoved:touches withEvent:event];
}

-(void)aTouchBegan:(NSSet *)touches withEven:(UIEvent *)event{
    NSLog(@"Touchessssss %@",touches);
    NSLog(@"Event %@",event);
    [self.webView touchesBegan:touches withEvent:event];
}

-(void)aTouchCancled:(NSSet *)touches withEven:(UIEvent *)event{
    [self.webView touchesCancelled:touches withEvent:event];
}

-(void)aTouchEnded:(NSSet *)touches withEven:(UIEvent *)event{
    [self.webView touchesEnded:touches withEvent:event];
}

@end
