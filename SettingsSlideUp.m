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
    return 0.5;
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

        if ([transitionContext transitionWasCancelled]) {
            [container addSubview:fromVC.view];
            [transitionContext completeTransition:NO];
        } else{
            [container addSubview:toVC.view];
            [transitionContext completeTransition:YES];
        }
        [fromSnapShot removeFromSuperview];
    }];
}


@end
