//
//  GifPostViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#define REDDIT_DARK_BLUE [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];

#import "GifPostViewController.h"
#import "FLAnimatedImage.h"
#import "InternetConnectionTest.h"
@interface GifPostViewController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *statusBarBackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
@implementation GifPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.statusBarBackground.backgroundColor = REDDIT_DARK_BLUE;
    if (!self.navigationController.navigationBarHidden) {
        self.statusBarBackground.alpha = 0.0;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [InternetConnectionTest testInternetConnectionWithViewController:self andCompletion:^(BOOL internet) {
        if (internet == YES) {
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];

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

                    [self.activityIndicator stopAnimating];
                    self.activityIndicator.hidden = YES;

                    if (self.isNSFW) {
                        UIVisualEffectView *blurEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
                        blurEffect.frame = imageView.bounds;
                        [imageView addSubview:blurEffect];
                    }
                });
            });

            if (!self.navController.navigationBarHidden) {
                self.statusBarBackground.alpha = 0.0;
            }
            else {
                self.statusBarBackground.alpha = 1.0;
            }
        }
    }];
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
//        if (self.verticalSpaceConstraint.constant < 0) {
//            self.verticalSpaceConstraint.constant = 0;
//        }
//        else {
//          self.verticalSpaceConstraint.constant += self.navController.navigationBar.frame.size.height;
//        }
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
        self.verticalSpaceConstraint.constant = 0; //self.verticalSpaceConstraint.constant -= self.navController.navigationBar.frame.size.height;
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

@end
