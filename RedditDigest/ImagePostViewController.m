//
//  IndividualPostViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "ImagePostViewController.h"

@interface ImagePostViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *statusBarBackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ImagePostViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        UIImage *image = [UIImage imageWithData:[self documentsPathForFileName:self.postID]];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.imageView.image = image;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
        });
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.navController.navigationBarHidden) {
        self.statusBarBackground.alpha = 0.0;
    }
    else {
        self.statusBarBackground.alpha = 1.0;
    }

    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.contentSize = CGSizeMake(1280, 960);
    self.scrollView.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSData *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *pathCompenent;
    if (self.isOldDigest) {
        pathCompenent = [NSString stringWithFormat:@"image-copy-%@", name];
    }else{
        pathCompenent = [NSString stringWithFormat:@"image-%@", name];
    }

    NSString *filePath = [documentsPath stringByAppendingPathComponent:pathCompenent];
    NSLog(@"FILE PATH %@",filePath);
    return [NSData dataWithContentsOfFile:filePath];
}

#pragma mark - Scroll View Delegate 

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
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
        if (self.verticalSpaceConstraint.constant < 0) {
            self.verticalSpaceConstraint.constant = 0;
        }
        else {
            self.verticalSpaceConstraint.constant += self.navController.navigationBar.frame.size.height;
        }
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
        self.verticalSpaceConstraint.constant -= self.navController.navigationBar.frame.size.height;
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
