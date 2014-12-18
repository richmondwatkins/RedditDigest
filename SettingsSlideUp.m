//
//  SettingsSlideUp.m
//  RedditDigest
//
//  Created by Richmond on 12/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SettingsSlideUp.h"

@implementation SettingsSlideUp

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *toViewSnapShot = [toVC.view snapshotViewAfterScreenUpdates:YES];
    UIView *fromSnapShot = [fromVC.view snapshotViewAfterScreenUpdates:YES];

    toViewSnapShot.center = toVC.view.center;

    UIView *container = [transitionContext containerView];

    [toViewSnapShot addSubview:fromSnapShot];
    [container addSubview:toViewSnapShot];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromSnapShot.center = CGPointMake(fromVC.view.center.x, (fromVC.view.center.y - fromVC.view.frame.size.height) - 80);
    } completion:^(BOOL finished) {
        [fromSnapShot removeFromSuperview];
        [container addSubview:toVC.view];

        [transitionContext completeTransition:YES];
    }];
}


@end
