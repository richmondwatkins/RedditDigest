//
//  CommentsNavBarLoggedInViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "CommentsNavBarLoggedInViewController.h"

@interface CommentsNavBarLoggedInViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentsHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *commentsUpDownButton;

@end

@implementation CommentsNavBarLoggedInViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCommentsButtonTapped:)];
    tapGestureRecognizer.delegate = self;
    [self.commentsUpDownButton addGestureRecognizer:tapGestureRecognizer];
}

// Tap gesture to show/hide comments
- (void)onCommentsButtonTapped:(UITapGestureRecognizer *)tapGesture
{
    switch (tapGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        {
            if (self.commentsHeightConstraint.constant < 45) {
                if (self.navigationController.navigationBarHidden) {
                    self.commentsHeightConstraint.constant = self.view.frame.size.height - 20;
                }
                else {
                    self.commentsHeightConstraint.constant = self.view.frame.size.height;
                }
                [self animateViewIntoPlace];
                [self.commentsUpDownButton setImage:[UIImage imageNamed:@"comment_down"] forState:UIControlStateNormal];
            }
            else
            {
                self.commentsHeightConstraint.constant = self.navigationController.navigationBar.frame.size.height;
                [self animateViewIntoPlace];
                [self.commentsUpDownButton setImage:[UIImage imageNamed:@"comment_up"] forState:UIControlStateNormal];
            }
            break;
        }
        default:
            break;
    }
}

- (void)animateViewIntoPlace
{
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:1.0
                        options:0
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
