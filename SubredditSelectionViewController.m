//
//  SubredditSelectionViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#define REDDIT_DARK_BLUE [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];

#import "SubredditSelectionViewController.h"
#import "SubredditListCollectionViewCell.h"
#import <RedditKit.h>
#import <RKLink.h>
#import <RKSubreddit.h>
#import "KTCenterFlowLayout.h"
#import "HeaderCollectionReusableView.h"
#import "DigestViewController.h"
#import "UserRequests.h"
#import "RedditRequests.h"
#import "Subreddit.h"
#import "LoginViewController.h"

@interface SubredditSelectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *subredditCollectionView;
@property NSMutableArray *subreddits;
@property NSMutableArray *catagories;
@property NSMutableArray *selectedSubreddits;
@property NSMutableArray *posts; 
@property SubredditListCollectionViewCell *sizingCell;
@property (weak, nonatomic) IBOutlet UIButton *doneSelectingSubredditsButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property BOOL hasRedditAccount;
@property NSInteger direction;
@property NSInteger shakes;
@end

@implementation SubredditSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    KTCenterFlowLayout *layout = [KTCenterFlowLayout new];
    layout.minimumInteritemSpacing = 10.f;
    layout.minimumLineSpacing = 10.f;
    self.subredditCollectionView = [self.subredditCollectionView initWithFrame:self.view.frame collectionViewLayout:layout];
    self.subredditCollectionView.allowsMultipleSelection = YES;

    self.doneSelectingSubredditsButton.alpha = 0.0;
    self.doneSelectingSubredditsButton.layer.borderWidth = 0.5;
    self.doneSelectingSubredditsButton.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;


    self.posts = [NSMutableArray array];
    self.selectedSubreddits = [[NSMutableArray alloc] init];

    // Logged in with reddit account
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasRedditAccount"])
    {
        [self.activityIndicator startAnimating];
        self.hasRedditAccount = YES;
        [[RKClient sharedClient] subscribedSubredditsWithCompletion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
            self.subreddits = [[NSMutableArray alloc] initWithArray:collection];

            if (self.isFromSettings) {[self checkForExistingSubscription];}

             [self.subredditCollectionView reloadData];
             [self.activityIndicator stopAnimating];
             self.activityIndicator.hidden = YES;
         }];
        // If user has account set the nav title to the following
        self.navigationItem.title = @"Choose your subreddits";
    }
    else // Didn't login with reddit account
    {
        self.hasRedditAccount = NO;
        self.activityIndicator.hidden = YES;

        NSURL *categoryURL = [NSURL URLWithString:@"http://192.168.129.228:3000/get/categories"];
        NSURLRequest *request = [NSURLRequest requestWithURL:categoryURL];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            self.catagories = results[@"allCategories"];
            [self.subredditCollectionView reloadData];
        }];
        // If the user has not reddit accounts set the nav title to the following
        // If user has account set the nav title to the following
        self.navigationItem.title = @"Choose your catagories";
    }


    // Regester cell for sizing template
    UINib *cellNib = [UINib nibWithNibName:@"SubredditSelectionCell" bundle:nil];
    [self.subredditCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"Cell"];
    self.sizingCell = [[cellNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.hasRedditAccount) {
        return self.subreddits.count;
    }
    else {
        return self.catagories.count;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubredditListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    [self configureCell:cell forIndexPath:indexPath];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasRedditAccount)
    {
        RKSubreddit *subreddit = self.subreddits[indexPath.row];

        if (self.selectedSubreddits.count < 10)
        {
            NSMutableDictionary *subredditDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subreddit.name, @"subreddit",subreddit.URL, @"url", [NSNumber numberWithBool:subreddit.isCurrentlySubscribed], @"currentlySubscribed", nil];
            [self.selectedSubreddits addObject:subredditDict];

            if (self.selectedSubreddits.count > 0) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.doneSelectingSubredditsButton.alpha = 1.0;
                }];
            }
        }
        else
        {
            [self.subredditCollectionView deselectItemAtIndexPath:indexPath animated: YES];
        }
    }
    else {
        if (self.selectedSubreddits.count < 10)
        {

            NSDictionary *subreddit = self.catagories[indexPath.row];

            for (NSDictionary *subredditDictionary in subreddit[@"subreddits"]) {
                NSMutableDictionary *subredditDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subredditDictionary[@"name"], @"subreddit",subredditDictionary[@"url"], @"url", nil];

                [self.selectedSubreddits addObject:subredditDict];
            }

            if (self.selectedSubreddits.count > 0) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.doneSelectingSubredditsButton.alpha = 1.0;
                }];
            }
        }
        else {
            [self.subredditCollectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
    }

}

- (void)configureCell:(SubredditListCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasRedditAccount) {
        RKSubreddit *subreddit = self.subreddits[indexPath.row];
        if (subreddit.isCurrentlySubscribed) {
            [self.subreddits addObject:subreddit];
            cell.selected = YES;
            [self.subredditCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:NO];
        }
        cell.subredditTitleLabel.text = subreddit.name;
    }
    else {

        cell.subredditTitleLabel.text = self.catagories[indexPath.row][@"category"][@"name"];
    }
    // SubredditTitleLabel font and color
    cell.subredditTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    cell.subredditTitleLabel.textColor = REDDIT_DARK_BLUE;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:self.sizingCell forIndexPath:indexPath];
    return [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.hasRedditAccount) {
        RKSubreddit *subreddit = self.subreddits[indexPath.row];
        NSMutableDictionary *subredditDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subreddit.name, @"subreddit",subreddit.URL, @"url", [NSNumber numberWithBool:subreddit.isCurrentlySubscribed], @"currentlySubscribed",  nil];

        if ([self.selectedSubreddits containsObject:subredditDict]) {
            [self.selectedSubreddits removeObject:subredditDict];
            if (subreddit.isCurrentlySubscribed) {
                [Subreddit removeFromCoreData:subreddit.name withManagedObject:self.managedObject];
            }
        }
    }
    else {
        [self.selectedSubreddits removeObject:self.catagories[indexPath.row]];
    }

    if (self.selectedSubreddits.count == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.doneSelectingSubredditsButton.alpha = 0.0;
        }];
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            self.doneSelectingSubredditsButton.alpha = 1.0;
        }];
    }
}

// Used for users without reddit accounts
- (void)removeCatagoryFromSelectedCatagories:(NSIndexPath *)indexPath
{
    [self.selectedSubreddits removeObject:self.catagories[indexPath.row]];
}

// Used for users with reddit accounts
- (void)removeSubredditFromSelectedSubreddits:(RKSubreddit *)subreddit
{
    NSMutableDictionary *subredditDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subreddit.name, @"subreddit",subreddit.URL, @"url", nil];

    if ([self.selectedSubreddits containsObject:subredditDict]) {
        [self.selectedSubreddits removeObject:subredditDict];
    }
}

#pragma mark - Cell Spacing and Padding

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 15, 10, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
}

#pragma mark - Header

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;

    if (kind == UICollectionElementKindSectionHeader)
    {
        HeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

        // Add tap gesture recognizer to resignkeyboard when user taps outside of textField and is first responder
        UIGestureRecognizer *tapToResignFirstResponderGesture = [[UITapGestureRecognizer alloc] initWithTarget:headerView action:@selector(hideKeyboardOnTapInHeaderView:)];
        [headerView addGestureRecognizer:tapToResignFirstResponderGesture];

        // Style textField
        headerView.textField.layer.borderWidth = 0.5;
        headerView.textField.layer.cornerRadius = 5.0;
        headerView.textField.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;
        headerView.textField.textColor = REDDIT_DARK_BLUE;

        [headerView.textField addTarget:self action:@selector(searchForSubreddit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        reusableview = headerView;
    }

    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];

        reusableview = footerview;
    }


    return reusableview;
}

// Header Height and Width
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.hasRedditAccount) {
        return CGSizeMake(self.view.frame.size.width, 44.0);
    }
    else {
        return CGSizeMake(0, 0);
    }
}

// Footer Height and Width
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(self.view.frame.size.width, 44.0);
}

#pragma mark - Search

- (void)searchForSubreddit:(UITextField *)textField
{
    NSString *subredditName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [[RKClient sharedClient] subredditWithName:subredditName completion:^(RKSubreddit *subreddit, NSError *error) {
        if (subreddit != NULL) {
            [self.subreddits insertObject:subreddit atIndex:0];
            // Add the new subreddit in the collectionView at index 0.
            NSIndexPath *firstIndex = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.subredditCollectionView insertItemsAtIndexPaths:@[firstIndex]];
        }
        else
        {
            textField.placeholder = @"Subreddit doesn't exist...";
            self.direction = 1;
            self.shakes = 0;
            [self shake:textField];
        }
    }];

    textField.text = @"";
    [textField resignFirstResponder];
}

-(void)shake:(UIView*) view
{
    const int reset = 5;
    const int maxShakes = 6;

    //pass these as variables instead of statics or class variables if shaking two controls simultaneously
    static int shakes = 0;
    static int translate = reset;

    [UIView animateWithDuration:0.09-(shakes*.01) // reduce duration every shake from .09 to .04
                          delay:0.01f//edge wait delay
                        options:(enum UIViewAnimationOptions) UIViewAnimationCurveEaseInOut
                     animations:^{view.transform = CGAffineTransformMakeTranslation(translate, 0);}
                     completion:^(BOOL finished)
    {
         if(shakes < maxShakes)
         {
             shakes++;

             //throttle down movement
             if (translate>0)
                 translate--;

             //change direction
             translate*=-1;
             [self shake:view];
         } else {
             view.transform = CGAffineTransformIdentity;
             shakes = 0;//ready for next time
             translate = reset;//ready for next time
             return;
         }
     }];
}

- (IBAction)hideKeyboardOnTapInHeaderView:(id)sender
{
    // Nothing needs to happen here because the method gets called in the HeaderCollectionReusableView
    // But a warning gets thrown if this isn't here
}

#pragma mark - Backend
/*
    .         .
    |         |
    j    :    l
   /           \
  /             \
 Y       .       Y
 |       |       |
 l "----~Y~----" !
  \      |      /
   Y     |     Y
   |     I     |
 ***************************************
 */
- (IBAction)finishSelectingSubreddits:(id)sender
{
    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    NSString *deviceString = [NSString stringWithFormat:@"%@", deviceID];
    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.selectedSubreddits, @"subreddits", nil];

    [Subreddit addSubredditsToCoreData:self.selectedSubreddits withManagedObject:self.managedObject];

    [UserRequests postSelectedSubreddits:deviceString selections:dataDictionary withCompletion:^(BOOL completed) {
        if (completed) {
            //
        }
    }];

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DigestViewController *digestViewController = segue.destinationViewController;
    NSLog(@"%@",self.selectedSubreddits);
    digestViewController.subredditsForFirstDigest = self.selectedSubreddits;
    digestViewController.isComingFromSubredditSelectionView = YES;
}

-(void)checkForExistingSubscription
{
    NSFetchRequest *subredditFetch = [NSFetchRequest fetchRequestWithEntityName:@"Subreddit"];
    NSArray *subscribedSubreddits = [self.managedObject executeFetchRequest:subredditFetch error:nil];
    NSLog(@"CORE DATA SUBSSS %@",self.subreddits);
    for (Subreddit *subscribedSub in subscribedSubreddits) {
        for (RKSubreddit *subFromReddit in self.subreddits) {
            if ([subscribedSub.subreddit isEqualToString:subFromReddit.name]) {
                subFromReddit.isCurrentlySubscribed = YES;
                NSMutableDictionary *subredditDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subFromReddit.name, @"subreddit",subFromReddit.URL, @"url", [NSNumber numberWithBool:subFromReddit.isCurrentlySubscribed], @"currentlySubscribed", nil];
                [self.selectedSubreddits addObject:subredditDict];
            }
        }
    }

}

@end
