    //
//  SearchSubredditsViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/4/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SearchSubredditsViewController.h"

@interface SearchSubredditsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>

@property NSArray *subreddits;
@property NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchSubredditsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.subreddits = @[@"Noodles", @"Hippos", @"Turtles", @"Boobs", @"Chocolate", @"Hungarian Horntail"];
    self.searchResults = [NSArray array];
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResults.count;
    }
    else {
        return self.subreddits.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell.textLabel.text = self.searchResults[indexPath.row];
    }
    else
    {
        cell.textLabel.text = self.subreddits[indexPath.row];
    }

    return cell;
}

#pragma mark - Search Methods

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    // Find all words beginning with the letter of the search
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginsWith[c] %@", searchText];
    self.searchResults = [self.subreddits filteredArrayUsingPredicate:predicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];

    return YES;
}

- (IBAction)onDoneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
