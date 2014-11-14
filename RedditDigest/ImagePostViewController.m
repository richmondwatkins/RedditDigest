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

@end

@implementation ImagePostViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        UIImage *image = [UIImage imageWithData:self.imageData];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.imageView.image = image;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
