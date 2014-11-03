//
//  LoginViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "LoginViewController.h"
#import <RedditKit.h>

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.usernameTextField becomeFirstResponder];

    [self.usernameTextField addTarget:self.passwordTextField action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self action:@selector(login:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (IBAction)login:(id)sender
{
    [[RKClient sharedClient] signInWithUsername:self.usernameTextField.text password:self.passwordTextField.text completion:^(NSError *error) {
        if (!error) {
            NSLog(@"Successfully signed in!");
        }
        else {
            NSLog(@"Error logging in: %@", error.localizedDescription);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
