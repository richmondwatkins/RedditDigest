//
//  IndividualPostViewController.m
//  RedditDigest
//
//  Created by Richmond, Taylor & Chris on 11/7/14.
//  Copyright (c) 2014 Richmond, Taylor & Chris. All rights reserved.
//

#import "ImagePostViewController.h"

@interface ImagePostViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *statusBarBackground;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ImagePostViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.navController.navigationBarHidden) {
        self.statusBarBackground.alpha = 0.0;
    }
    else {
        self.statusBarBackground.alpha = 1.0;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        UIImage *image = [UIImage imageWithData:[self documentsPathForFileName:self.postID]];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            // Only add view if it's not already there
            if (![self.scrollView viewWithTag:1])
            {
                self.imageView = [[UIImageView alloc] initWithImage:image];
                self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
                self.imageView.tag = 1;
                [self.scrollView addSubview:self.imageView];
                self.scrollView.contentSize = image.size;

                // Set up the minimum & maximum zoom scales
                CGRect scrollViewFrame = self.scrollView.frame;
                CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width / 2;
                CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height / 2;
                // Make min scale fill the screen width
                CGFloat minScale = MIN(scaleWidth, scaleHeight) * 2;

                self.scrollView.minimumZoomScale = minScale;
                self.scrollView.maximumZoomScale = 1.0f;
                self.scrollView.zoomScale = minScale;

                [self centerScrollViewContents];
            }

            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;

            if (self.isNSFW && [[NSUserDefaults standardUserDefaults] boolForKey:@"HideNSFW"]) {
                UIVisualEffectView *blurEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
                blurEffect.frame = self.imageView.bounds;
                [self.imageView addSubview:blurEffect];
            }

        });
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Add a double tap gesture to zoom
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Scroll View Delegate

- (void)centerScrollViewContents
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;

    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }

    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }

    self.imageView.frame = contentsFrame;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

#pragma mark - Tap and Double Tap Gestures 

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer
{
    CGPoint pointInView = [recognizer locationInView:self.imageView];

    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);

    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.scrollView.bounds.size;

    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);

    CGRect rectToZoomTo = CGRectMake(x, y, w, h);

    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

// Allow simultaneous gesture recognition
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Documents Directory - Getting Images 

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

-(BOOL)prefersStatusBarHidden {
    return YES;
}


@end
