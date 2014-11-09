//
//  SettingsViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/4/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SettingsViewController.h"
#import "RKUser.h"
#import <SSKeychain/SSKeychain.h>
#import "LoginViewController.h"


@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *settingsArray;
@property NSArray *titlesArray;
@property NSString *currentUserName;
@property (strong, nonatomic) IBOutlet UILabel *loginLogoutLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingsArray = [NSArray arrayWithObjects: @"Edit Subreddits", @"Play Ping Pong", @"Dance", @"Fuggedaboutit", nil];
    self.titlesArray = [NSArray arrayWithObjects:@"One", @"Two", @"Three", @"Four", nil];
    [self findUserName];
    self.title = self.currentUserName;

    if (self.currentUserName == nil)
        
    {
        self.loginLogoutLabel.text = @"Login";

    } else {

        self.loginLogoutLabel.text = @"Logout";
    }

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Login Credentials and Login or Logout

-(void)findUserName
{
    NSArray *array = [SSKeychain accountsForService:@"friendsOfSnoo"];
    NSDictionary *accountInfoDictionary = array.firstObject;
    NSString *username = accountInfoDictionary[@"acct"];
    self.currentUserName = username;
}



//if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasRedditAccount"])
//{
//    NSArray *array = [SSKeychain accountsForService:@"friendsOfSnoo"];
//    NSDictionary *accountInfoDictionary = array.firstObject;
//    NSString *username = accountInfoDictionary[@"acct"];
//    NSString *password = [SSKeychain passwordForService:@"friendsOfSnoo" account:username];
//
//    [[RKClient sharedClient] signInWithUsername:accountInfoDictionary[@"acct"] password:password completion:^(NSError *error) {
//        if (!error)
//        {
//            NSLog(@"Successfully signed in!");

#pragma mark - TableView Delegate Methods


//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 4;
//}

//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//
//    return 8;
//    NSLog(@"Section now is %ld", (long)section);
//    if (section == 0) {
//        return 1; }
//    else if (section == 1) {
//        return 2;
//    }
//    else {
//        return 4;
//    }
//}

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
////    cell.textLabel.text = self.settingsArray[indexPath.row];
//    return cell;
//}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 36)];
//    /* Create custom view to display section header... */
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
//    [label setFont:[UIFont boldSystemFontOfSize:12]];
//    NSString *string =[self.titlesArray objectAtIndex:section];
//    /* Section header is in 0th index... */
//    [label setText:string];
//    [view addSubview:label];
//    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
//    return view;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Unwind from Edit Subreddits
- (IBAction)unwindToSettingsViewController:(UIStoryboardSegue *)segue {
    //nothing goes here
    NSLog(@"NOW ACTIVATE UNWIND!!!!!");

}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    LoginViewController *viewController = segue.destinationViewController;
//    viewController.isFromSettings = YES;   // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
