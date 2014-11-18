//
//  CommentsNavBarContainerViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "CommentsNavBarContainerViewController.h"
#import "CommentsNavBarLoggedInViewController.h"
#import "CommentsNavBarLoggedOutViewController.h"
#import "DetailPostViewController.h"

#define SegueIdentifierLoggedIn @"LoggedInSegue"
#define SegueIdentifierLoggedOut @"LoggedOutSegue"

@interface CommentsNavBarContainerViewController ()

@property (strong, nonatomic) CommentsNavBarLoggedInViewController *loggedInViewController;
@property (strong, nonatomic) CommentsNavBarLoggedOutViewController *loggedOutViewController;
@property (assign, nonatomic) BOOL transitionInProgress;
@property (strong, nonatomic) NSString *currentSegueIdentifier;

@end

@implementation CommentsNavBarContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentSegueIdentifier = SegueIdentifierLoggedIn;
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];

    if (!self.userIsLoggedIn) {
        [self swapViewControllers];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SegueIdentifierLoggedIn])
    {
        CommentsNavBarLoggedInViewController *commentsNavBarLoggedInViewController = segue.destinationViewController;
        if (self.childViewControllers.count > 0) {
            [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:commentsNavBarLoggedInViewController];
        }
        else {
            [self addChildViewController:commentsNavBarLoggedInViewController];
            commentsNavBarLoggedInViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

            [self.view addSubview:((UIViewController *)segue.destinationViewController).view];
            [commentsNavBarLoggedInViewController didMoveToParentViewController:self];
        }
    }
    else if ([segue.identifier isEqualToString:SegueIdentifierLoggedOut])
    {
        CommentsNavBarLoggedOutViewController *commentsNavBarLoggedOutViewController = segue.destinationViewController;
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:commentsNavBarLoggedOutViewController];
    }
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
    }];
}

- (void)swapViewControllers
{
    self.currentSegueIdentifier = ([self.currentSegueIdentifier  isEqual:SegueIdentifierLoggedIn]) ? SegueIdentifierLoggedOut : SegueIdentifierLoggedIn;
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
}

@end
