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
#import "DigestCategory.h"
#import <AudioToolbox/AudioToolbox.h>
#import "InternetConnectionTest.h"
NSInteger const MAX_SELECTABLE_SUBREDDITS_FOR_DIGEST = 20;

@interface SubredditSelectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *subredditCollectionView;
@property NSMutableArray *subreddits;
@property SubredditListCollectionViewCell *sizingCell;
@property (weak, nonatomic) IBOutlet UIButton *doneSelectingSubredditsButton;
@property BOOL hasRedditAccount;
@property NSInteger direction;
@property NSInteger shakes;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SubredditSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [InternetConnectionTest testInternetConnectionWithViewController:self andCompletion:^(BOOL status) {
        if (status == NO) {
            self.doneSelectingSubredditsButton.enabled = NO;
        }
    }];

    KTCenterFlowLayout *layout = [KTCenterFlowLayout new];
    layout.minimumInteritemSpacing = 10.f;
    layout.minimumLineSpacing = 10.f;
    self.subredditCollectionView = [self.subredditCollectionView initWithFrame:self.view.frame collectionViewLayout:layout];
    self.subredditCollectionView.allowsMultipleSelection = YES;

    self.doneSelectingSubredditsButton.alpha = 0.0;
    self.doneSelectingSubredditsButton.layer.borderWidth = 0.5;
    self.doneSelectingSubredditsButton.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;

    self.selectedSubreddits = [[NSMutableArray alloc] init];
    self.subreddits = [NSMutableArray array];
    [self.activityIndicator startAnimating];

    if (self.isFromSettings) {
        //[self.navigationItem setHidesBackButton:YES]; <-- This didn't work so create a view to put over the button
        UIView *backButtonCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        backButtonCoverView.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];
        self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonCoverView];
        [UIView animateWithDuration:0.3 animations:^{
            self.doneSelectingSubredditsButton.alpha = 1.0;
        }];
    }
    // Logged in with reddit account
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasRedditAccount"])
    {
        self.hasRedditAccount = YES;
        [[RKClient sharedClient] subscribedSubredditsWithCompletion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
            self.subreddits = [NSMutableArray arrayWithArray:collection];

            [self doneLoadingActivities];
         }];
    }
    else // Didn't login with reddit account
    {
        self.hasRedditAccount = NO;

            [[RKClient sharedClient] frontPageLinksWithCategory:RKSubredditCategoryHot pagination:0 completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
                for (RKLink *link in collection) {
                    [[RKClient sharedClient] subredditWithName:link.subreddit completion:^(id object, NSError *error) {
                        [self.subreddits addObject:object];
                        if (self.subreddits.count == collection.count) {
                            [[RKClient sharedClient] popularSubredditsWithPagination:nil completion:^(NSArray *collection, RKPagination *pagination, NSError *error) {
                                for (RKSubreddit *sub in collection) {
                                    if (![self.subreddits containsObject:sub]) {
                                        [self.subreddits addObject:sub];
                                    }
                                }
                                [self doneLoadingActivities];
                            }];
                        }
                    }];
                }
            }];

    }
    
    [self setUpView];
}

-(void)setUpView{
    self.subredditCollectionView.contentOffset = CGPointMake(0, 44);
    self.navigationItem.title = @"Choose Your subreddits";
    //for resizing template
    UINib *cellNib = [UINib nibWithNibName:@"SubredditSelectionCell" bundle:nil];
    [self.subredditCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"Cell"];
    self.sizingCell = [[cellNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
}


-(void)doneLoadingActivities{
    if (self.isFromSettings) {
        [self addItemsFromCoreData];
        [self checkForExistingSubscription];
    }

    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    [self sortSubredditsAlphabetically];
    [self.subredditCollectionView reloadData];

    [self updateSelectedSubredditCounter];
}

- (void)updateSelectedSubredditCounter
{
    // Set number of subredds select and number left to select
    NSString *selectedSubredditsCount = [NSString stringWithFormat:@"%lu/%zd", (unsigned long)self.selectedSubreddits.count, MAX_SELECTABLE_SUBREDDITS_FOR_DIGEST];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:selectedSubredditsCount style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - Collection View
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.subreddits.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubredditListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    [self configureCell:cell forIndexPath:indexPath];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RKSubreddit *subreddit = self.subreddits[indexPath.row];

    if (self.selectedSubreddits.count < MAX_SELECTABLE_SUBREDDITS_FOR_DIGEST)
    {
         [self.selectedSubreddits addObject:subreddit];
        if (self.selectedSubreddits.count > 0) {
            [self updateSelectedSubredditCounter];
            [UIView animateWithDuration:0.3 animations:^{
                self.doneSelectingSubredditsButton.alpha = 1.0;
                /*
                NSString *path  = [[NSBundle mainBundle] pathForResource:@"SelectSubreddit" ofType:@"mp3"];
                NSURL *pathURL = [NSURL fileURLWithPath : path];

                SystemSoundID audioEffect;
                AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
                AudioServicesPlaySystemSound(audioEffect);
                 */
            }];
        }
    }
    else
    {
        [self.subredditCollectionView deselectItemAtIndexPath:indexPath animated: YES];
        /*
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"DeselectSubreddit" ofType:@"mp3"];
        NSURL *pathURL = [NSURL fileURLWithPath : path];

        SystemSoundID audioEffect;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
        */
    }
}


- (void)configureCell:(SubredditListCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{

    RKSubreddit *subreddit = self.subreddits[indexPath.row];
    if (subreddit.isCurrentlySubscribed) {
        cell.selected = YES;
        [self.subredditCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:NO];
    }
    cell.subredditTitleLabel.text = subreddit.name;

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
    RKSubreddit *subreddit = self.subreddits[indexPath.row];
    if ([self.selectedSubreddits containsObject:subreddit]) {
        [self.selectedSubreddits removeObject:subreddit];
        if (subreddit.isCurrentlySubscribed) {
            [Subreddit removeFromCoreData:subreddit.name withManagedObject:self.managedObject];
        }
        subreddit.isCurrentlySubscribed = NO;
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
    [self updateSelectedSubredditCounter];
}

#pragma mark - Cell Spacing and Padding

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 15, 10, 15);
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
    return CGSizeMake(self.view.frame.size.width, 44.0);
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

- (IBAction)finishSelectingSubreddits:(id)sender
{
    /*
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"LoadDigest" ofType:@"mp3"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];

    SystemSoundID audioEffect;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
    AudioServicesPlaySystemSound(audioEffect);
    */

    [Subreddit addSubredditsToCoreData:self.selectedSubreddits withManagedObject:self.managedObject];

    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.selectedSubreddits, @"subreddits", nil];
    [UserRequests postSelectedSubreddits:dataDictionary withCompletion:^(BOOL completed) {
        if (completed) {
            //
        }
    }];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DigestViewController *digestViewController = segue.destinationViewController;
    digestViewController.isComingFromSubredditSelectionView = YES;
    digestViewController.isFromPastDigest = NO;
}


-(void)addItemsFromCoreData{
    NSFetchRequest *subredditFetch = [NSFetchRequest fetchRequestWithEntityName:@"Subreddit"];
    NSArray *subscribedSubreddits = [self.managedObject executeFetchRequest:subredditFetch error:nil];

    if (subscribedSubreddits) {
        for (Subreddit *subFromCore in subscribedSubreddits) {
            NSDictionary *rkSubDict = @{@"name": subFromCore.subreddit, @"URL": subFromCore.url};
            RKSubreddit *rkSubreddit =  [[RKSubreddit alloc] initWithDictionary:rkSubDict error:nil];
            if ([self canAddToSelected:rkSubreddit]) {
                [self.subreddits addObject:rkSubreddit];
            }
        }
    }
}

-(BOOL)canAddToSelected:(RKSubreddit *)subreddit{
    NSArray *subs = [self.subreddits valueForKey:@"name"];
    if ([subs containsObject:subreddit.name]) {
        return NO;
    }else{
        return YES;
    }
}

//TODO Move to Subbreddit Core Data Class
-(void)checkForExistingSubscription
{
    NSFetchRequest *subredditFetch = [NSFetchRequest fetchRequestWithEntityName:@"Subreddit"];
    NSArray *subscribedSubreddits = [self.managedObject executeFetchRequest:subredditFetch error:nil];
    if (subscribedSubreddits.count) {
        for (Subreddit *subscribedSub in subscribedSubreddits) {
            for (RKSubreddit *rkSubreddit in self.subreddits) {
                if ([subscribedSub.subreddit isEqualToString:rkSubreddit.name]) {
                    if (!subscribedSub.isLocalSubreddit) {
                        rkSubreddit.isCurrentlySubscribed = YES;
                        [self.selectedSubreddits addObject:rkSubreddit];
                    }
                }
            }
        }
    }
}

-(void)sortSubredditsAlphabetically
{
    NSSortDescriptor *sortedSubreddits = [[NSSortDescriptor alloc]initWithKey: @"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [self.subreddits sortUsingDescriptors:[NSArray arrayWithObject:sortedSubreddits]];
}



@end
