//
//  RecommendedSubredditsViewController.m
//  Pods
//
//  Created by Richmond on 11/15/14.
//
//
#define REDDIT_DARK_BLUE [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1];

#import "RecommendedSubredditsViewController.h"
#import <RedditKit.h>
#import "Subreddit.h"
#import "UserRequests.h"
#import "KTCenterFlowLayout.h"
#import "HeaderCollectionReusableView.h"
#import "SubredditListCollectionViewCell.h"
#import "DigestViewController.h"
#import "RecHeaderCollectionReusableView.h"
@interface RecommendedSubredditsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property NSMutableArray *recommendedFromSubscriptions;
@property NSMutableArray *recommendedFromUsers;
@property NSMutableArray *selectedSubreddits;
@property NSMutableArray *recomendations;
@property (strong, nonatomic) IBOutlet UICollectionView *subredditCollectionView;
@property (strong, nonatomic) IBOutlet UIButton *doneSelectingSubredditsButton;
@property SubredditListCollectionViewCell *sizingCell;
@property (strong, nonatomic) IBOutlet UILabel *recHeader;

@end

@implementation RecommendedSubredditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    KTCenterFlowLayout *layout = [KTCenterFlowLayout new];
    layout.minimumInteritemSpacing = 10.f;
    layout.minimumLineSpacing = 10.f;
    self.subredditCollectionView = [self.subredditCollectionView initWithFrame:self.view.frame collectionViewLayout:layout];
    self.subredditCollectionView.allowsMultipleSelection = YES;

    self.doneSelectingSubredditsButton.alpha = 0.0;
    self.doneSelectingSubredditsButton.layer.borderWidth = 0.5;
    self.doneSelectingSubredditsButton.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;

    self.selectedSubreddits = [[NSMutableArray alloc] init];
    self.recomendations = [NSMutableArray array];
//    [self.activityIndicator startAnimating];


    self.recommendedFromSubscriptions = [NSMutableArray array];
    self.recommendedFromUsers = [NSMutableArray array];

    [self lookUpRelatedSubreddit:[Subreddit retrieveAllSubreddits:self.managedObject]];
    [UserRequests retrieveRecommendedSubredditsWithCompletion:^(NSArray *results) {
        if (results) {
            NSLog(@"RESULTS IN REC CONTRLLER %@",results);
            __block int i = 0;
            for (NSString *subreddit in results) {
                [[RKClient sharedClient] subredditWithName:subreddit completion:^(RKSubreddit *object, NSError *error) {
                    i++;
//                    if (object.totalSubscribers >= 20000) {
                        if (![self.recommendedFromSubscriptions containsObject:object] && ![self.recommendedFromUsers containsObject:object]) {
                            [self.recommendedFromUsers addObject:object];
                        }
//                    }

                    if (i == results.count) {
                        [self checkForExistingSubscription:self.recommendedFromUsers];
                        [self.recomendations addObject:self.recommendedFromUsers];
                        [self.subredditCollectionView reloadData];
                    }
                }];
            }
        }
    }];

    [self setUpView];
}


-(void)lookUpRelatedSubreddit:(NSArray *)subsFromCoreData{
    NSMutableArray *recSubredditNames = [NSMutableArray array];
    __block int i = 0;
    for (Subreddit *subreddit in subsFromCoreData) {
        [[RKClient sharedClient] recommendedSubredditsForSubreddits:@[subreddit.subreddit] completion:^(NSArray *collection, NSError *error) {
            i++;
            [recSubredditNames addObject:collection];
            if (i == subsFromCoreData.count) {
                [self retrieveSubredditInfoFromReddit:recSubredditNames];
            }
        }];
    }
}


-(void)retrieveSubredditInfoFromReddit:(NSMutableArray *)recommendedSubNames{
    NSArray *flattenedSubNames = [recommendedSubNames valueForKeyPath: @"@unionOfArrays.self"];
    __block int i = 0;
    for (NSString *subName in flattenedSubNames) {
        [[RKClient sharedClient] subredditWithName:subName completion:^(RKSubreddit *object, NSError *error) {
            i++;
            if (object.totalSubscribers >= 10000) {
                if (![self.recommendedFromSubscriptions containsObject:object]) {
                    [self.recommendedFromSubscriptions addObject:object];
                }
            }

            if (i == flattenedSubNames.count) {
                [self checkForExistingSubscription:self.recommendedFromSubscriptions];
                [self.recomendations addObject:self.recommendedFromSubscriptions];
                [self.subredditCollectionView reloadData];
            }
        }];

    }
}

-(void)checkForExistingSubscription:(NSMutableArray *)subredditsArray
{  // NSLog(@"RK OBJS %@",subredditsArray);
    NSMutableArray *subredditsArrayCopy = [NSMutableArray arrayWithArray:subredditsArray];
    NSFetchRequest *subredditFetch = [NSFetchRequest fetchRequestWithEntityName:@"Subreddit"];
    NSArray *subscribedSubreddits = [self.managedObject executeFetchRequest:subredditFetch error:nil];
    if (subscribedSubreddits.count) {
        for (Subreddit *subscribedSub in subscribedSubreddits) {
            for (RKSubreddit *rkSubreddit in subredditsArrayCopy) {
                if ([subscribedSub.subreddit isEqualToString:rkSubreddit.name]) {
                    if (!subscribedSub.isLocalSubreddit) {
                        [subredditsArray removeObject:rkSubreddit];
                    }
                }
            }
        }
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RKSubreddit *subreddit = [[self.recomendations objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if (self.selectedSubreddits.count < 10)
    {
        [self.selectedSubreddits addObject:subreddit];
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

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

    RKSubreddit *subreddit =[[self.recomendations objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if ([self.selectedSubreddits containsObject:subreddit]) {
        [self.selectedSubreddits removeObject:subreddit];
        if (subreddit.isCurrentlySubscribed) {
            [Subreddit removeFromCoreData:subreddit.name withManagedObject:self.managedObject];
        }
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

- (IBAction)finishSelectingSubreddits:(id)sender
{

    [Subreddit addSubredditsToCoreData:self.selectedSubreddits withManagedObject:self.managedObject];

    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.selectedSubreddits, @"subreddits", nil];
    [UserRequests postSelectedSubreddits:dataDictionary withCompletion:^(BOOL completed) {
        if (completed) {
            //
        }
    }];
}

#pragma mark - Collection View Delegate Methods

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubredditListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    [self configureCell:cell forIndexPath:indexPath];

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.recomendations objectAtIndex:section] count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.recomendations.count;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DigestViewController *digestViewController = segue.destinationViewController;
    digestViewController.isComingFromSubredditSelectionView = YES;
}


#pragma mark - Collection View Layout Methods

-(void)setUpView{
    self.subredditCollectionView.contentOffset = CGPointMake(0, 44);
    self.navigationItem.title = @"Recommended Subreddits";
    //for resizing template
    UINib *cellNib = [UINib nibWithNibName:@"SubredditSelectionCell" bundle:nil];
    [self.subredditCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"Cell"];
    self.sizingCell = [[cellNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:self.sizingCell forIndexPath:indexPath];
    return [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}

- (void)configureCell:(SubredditListCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{

    RKSubreddit *subreddit = [self.recomendations[indexPath.section] objectAtIndex:indexPath.row];

    if (subreddit.isCurrentlySubscribed) {
        cell.selected = YES;
        [self.subredditCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:NO];
    }
    cell.subredditTitleLabel.text = subreddit.name;

    // SubredditTitleLabel font and color
    cell.subredditTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    cell.subredditTitleLabel.textColor = REDDIT_DARK_BLUE;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 15, 10, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;

    if (kind == UICollectionElementKindSectionHeader && indexPath.section == 0){
        RecHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headerView.recHeaderView.text = @"Based on Users Like You";
        reusableview = headerView;
    }else{
        RecHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headerView.recHeaderView.text = @"Based on Current Subscriptions";
        reusableview = headerView;
    }

    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];

        reusableview = footerview;
    }
    
    return reusableview;
}



@end
