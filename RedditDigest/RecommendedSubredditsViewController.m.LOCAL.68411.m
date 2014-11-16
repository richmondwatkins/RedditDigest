//
//  RecommendedSubredditsViewController.m
//  Pods
//
//  Created by Richmond on 11/15/14.
//
//

#import "RecommendedSubredditsViewController.h"
#import <RedditKit.h>
#import "Subreddit.h"
@interface RecommendedSubredditsViewController ()
@property NSMutableArray *recommendedFromSubscriptions;
@end

@implementation RecommendedSubredditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recommendedFromSubscriptions = [NSMutableArray array];
    [self lookUpRelatedSubreddit:[Subreddit retrieveAllSubreddits:self.mangedObject]];

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
            if (object.totalSubscribers >= 20000) {
                if (![self.recommendedFromSubscriptions containsObject:object]) {
                    [self.recommendedFromSubscriptions addObject:object];
                }
            }

            if (i == flattenedSubNames.count) {
                NSLog(@"ALL RECS %@",self.recommendedFromSubscriptions);
            }
        }];

    }

}




@end
