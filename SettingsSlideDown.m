//
//  SlideFromTop.m
//  RedditDigest
//
//  Created by Richmond on 12/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SettingsSlideDown.h"


@implementation SettingsSlideDown

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{

    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *snapShot = [toVC.view snapshotViewAfterScreenUpdates:YES];
    snapShot.center = toVC.view.center;
    snapShot.alpha = 0.0;
    snapShot.center = CGPointMake(toVC.view.center.x, (toVC.view.center.y - toVC.view.frame.size.height));
    UIView *container = [transitionContext containerView];

    [container addSubview:snapShot];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        snapShot.alpha = 1.0;
        snapShot.center = toVC.view.center;
    } completion:^(BOOL finished) {
        [snapShot removeFromSuperview];
        [container addSubview:toVC.view];

        [transitionContext completeTransition:YES];
    }];

}

@end
