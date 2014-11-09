//
//  LoginViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "LoginViewController.h"
#import <RedditKit.h>
#import <SSKeychain/SSKeychain.h>


@interface LoginViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Username textField style
    self.usernameTextField.layer.borderWidth = 0.5;
    self.usernameTextField.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;
    self.usernameTextField.textColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];
    self.usernameTextField.layer.cornerRadius = 5.0;
    // password textField style
    self.passwordTextField.layer.borderWidth = 0.5;
    self.passwordTextField.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;
    self.passwordTextField.textColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];
    self.passwordTextField.layer.cornerRadius = 5.0;
    
    [self.usernameTextField becomeFirstResponder];

    [self.usernameTextField addTarget:self.passwordTextField action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self action:@selector(login:) forControlEvents:UIControlEventEditingDidEndOnExit];

    if (self.isFromSettings == YES) {

        NSLog(@"IS from Settings");

        } else {
            
            NSLog(@"IS NOT from Settings");
        }
}

- (IBAction)login:(id)sender
{
    [[RKClient sharedClient] signInWithUsername:self.usernameTextField.text password:self.passwordTextField.text completion:^(NSError *error) {
        if (!error)
        {
            NSLog(@"Successfully signed in!");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasRedditAccount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // Store credentials in Keychain
            BOOL result = [SSKeychain setPassword:self.passwordTextField.text forService:@"friendsOfSnoo" account:self.usernameTextField.text];

            if (result) {
                [self performSegueWithIdentifier:@"SubredditSelectionFromLoginSegue" sender:self];
            }
            /* // Richmond, uncomment this to get what you need after the user logs in correctly
            [[RKClient sharedClient] subscribedSubredditsWithCompletion:^(NSArray *collection, RKPagination *pagination, NSError *error) {

                RKSubreddit *subreddit = collection.firstObject;

                [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
                    //                    NSLog(@"Links: %@", links);
                    [[RKClient sharedClient] upvote:links.firstObject completion:^(NSError *error) {
                        NSLog(@"Upvoted the link!");
                    }];
                }];
                
            }];
             */
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Login" message:@"Incorrect username or password, give it another go" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alertView.delegate = self;
            [alertView show];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If user fails a login clear textFields and let them try again
    if (buttonIndex == 0)
    {
        self.usernameTextField.text = @"";
        self.passwordTextField.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
