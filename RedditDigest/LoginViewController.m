//
//  LoginViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#define REDDIT_DARK_BLUE [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];

#import "LoginViewController.h"
#import <RedditKit.h>
#import <SSKeychain/SSKeychain.h>
#import "SubredditSelectionViewController.h"

@interface LoginViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *takeMeBackButton;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Username textField style
    self.usernameTextField.layer.borderWidth = 0.5;
    self.usernameTextField.layer.cornerRadius = 5.0;
    self.usernameTextField.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;
    self.usernameTextField.textColor = REDDIT_DARK_BLUE;

    // password textField style
    self.passwordTextField.layer.borderWidth = 0.5;
    self.passwordTextField.layer.cornerRadius = 5.0;
    self.passwordTextField.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;
    self.passwordTextField.textColor = REDDIT_DARK_BLUE;

    // Add action to password text field to show login button if user begins typing.
    [self.passwordTextField addTarget:self
                               action:@selector(textFieldDidChange:)
                     forControlEvents:UIControlEventEditingChanged];

    // Hide login button until user has typed in password field as well as username field
    self.loginButton.alpha = 0.0;
    self.loginActivityIndicatorView.alpha = 0.0;

    [self.usernameTextField becomeFirstResponder];

    [self.usernameTextField addTarget:self.passwordTextField action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self action:@selector(login:) forControlEvents:UIControlEventEditingDidEndOnExit];

    if (self.isFromSettings == YES) {
        self.takeMeBackButton.hidden = YES;
        NSLog(@"IS from Settings");

        }
    else {
        self.takeMeBackButton.hidden = NO;
        NSLog(@"IS NOT from Settings");
    }
}

- (IBAction)onTapHideKeyboard:(id)sender
{
    if ([self.usernameTextField isFirstResponder]) {
        [self.usernameTextField resignFirstResponder];
    }
    else if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
}

#pragma mark - Login

- (IBAction)login:(id)sender
{
    [self.loginActivityIndicatorView startAnimating];
    // Hide login button to prevent double login error
    // Show activity indicator to indicate logging in.
    [UIView animateWithDuration:0.3 animations:^
    {
        self.loginButton.alpha = 0.0;
        self.loginActivityIndicatorView.alpha = 1.0;
    }];

    [[RKClient sharedClient] signInWithUsername:self.usernameTextField.text password:self.passwordTextField.text completion:^(NSError *error) {
        if (!error)
        {
            NSLog(@"Successfully signed in!");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasRedditAccount"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UserIsLoggedIn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // Store credentials in Keychain
            BOOL result = [SSKeychain setPassword:self.passwordTextField.text forService:@"friendsOfSnoo" account:self.usernameTextField.text];

            if (result) {
                [self.loginActivityIndicatorView stopAnimating];
                [self performSegueWithIdentifier:@"SubredditSelectionFromLoginSegue" sender:self];
            }
        }
        else
        {
            NSLog(@"Error logging in: %@", error.localizedDescription);

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Login" message:@"Incorrect username or password, give it another go" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alertView.delegate = self;
            [alertView show];

            [self.loginActivityIndicatorView stopAnimating];

            [UIView animateWithDuration:0.3 animations:^
             {
                 self.loginButton.alpha = 0.0;
                 self.loginActivityIndicatorView.alpha = 0.0;
                 [self.usernameTextField becomeFirstResponder];
             }];
        }
    }];
}

#pragma mark - TextField

- (void)textFieldDidChange:(UITextField *)textField
{
    if ([textField isEqual:self.passwordTextField]) {
        // Only do this once, not each time the user types a letter and only do it if the username textField is
        // not empty and the password textField is not empty
        if (![textField.text isEqualToString:@""] && ![self.usernameTextField.text isEqualToString:@""] && self.loginButton.alpha != 1.0) {
            [UIView animateWithDuration:0.3 animations:^
            {
                self.loginButton.alpha = 1.0;
            }];
        }
        else if ([textField.text isEqualToString:@""])
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.loginButton.alpha = 0.0;
            }];
        }
    }
}

#pragma mark -  Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If user fails a login clear textFields and let them try again
    if (buttonIndex == 0)
    {
        self.usernameTextField.text = @"";
        self.passwordTextField.text = @"";
    }
}

#pragma mark - Navigation methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SubredditSelectionFromLoginSegue"]) {
        // SubredditSelectionViewController is embeded in a Navigation Controller so the color of the status bar
        // could be set correctly. Thus the following extra step is needed.
        UINavigationController *selectionControllerNavigationParentVC = segue.destinationViewController;
        SubredditSelectionViewController *selectionController = selectionControllerNavigationParentVC.childViewControllers.firstObject;
        selectionController.managedObject = self.managedObject;
        if (self.isFromSettings) {
            selectionController.isFromSettings = YES;
        
        }
    }
}

- (IBAction)onTakeMeBackButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
