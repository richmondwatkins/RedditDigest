//
//  UserInteractionSettingsExit.m
//  RedditDigest
//
//  Created by Richmond on 12/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "UserInteractionSettingsExit.h"

@interface UserInteractionSettingsExit ()

@property UIView *currentView;
@property UINavigationController *navController;
@property CGPoint firstPoint;
@property CGFloat lastPercent;
@property CGPoint currentPanVelocity;
@end

@implementation UserInteractionSettingsExit

- (void)addInteractionToViewController:(UIViewController *)viewController
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];

    self.currentView = viewController.view;
    self.navController = viewController.navigationController;

    [viewController.view addGestureRecognizer:panGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    self.currentPanVelocity = [pan velocityInView:self.currentView];


    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.interactive = YES;
            self.firstPoint = [pan locationInView:self.currentView];
            if (self.currentPanVelocity.y < 0) {
                [self.navController popViewControllerAnimated:YES];
            }
            break;

        case UIGestureRecognizerStateChanged:
        {
            CGFloat panSpan = (self.firstPoint.y - [pan locationInView:self.currentView].y) / self.currentView.frame.size.height;
            self.lastPercent = panSpan;
            [self updateInteractiveTransition:panSpan];
        }
            break;

        case UIGestureRecognizerStateCancelled:
            self.interactive = NO;
            [self cancelInteractiveTransition];
            break;

        case UIGestureRecognizerStateEnded:
            self.interactive = NO;
            if (self.lastPercent > 0.25 && self.currentPanVelocity.y < 0) {
                [self finishInteractiveTransition];
            }else{
                [self cancelInteractiveTransition];
            }
            break;
            
        default:
            break;
    }

}


@end
