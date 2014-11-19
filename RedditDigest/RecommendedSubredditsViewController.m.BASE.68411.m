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

@end

@implementation RecommendedSubredditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(void)lookUpRelatedSubreddits:(NSString *)subredditName{
    [[RKClient sharedClient] recommendedSubredditsForSubreddits:@[subredditName] completion:^(NSArray *collection, NSError *error) {
        for (RKSubreddit *sub in collection) {
            NSLog(@"RECOMENNDED SUBSSSS %@",sub);
        }
    }];
}


@end
