//
//  SubredditCategory.m
//  RedditDigest
//
//  Created by Richmond on 11/11/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SelectableSubreddit.h"

@implementation SelectableSubreddit


+(SelectableSubreddit *)createInstanceFromRKSubreddit:(RKSubreddit *)subreddit{
    SelectableSubreddit *selectableSubreddit = [SelectableSubreddit new];
    selectableSubreddit.name = subreddit.name;
    selectableSubreddit.url = subreddit.URL;
    selectableSubreddit.currentlySubscribed = subreddit.isCurrentlySubscribed;
    selectableSubreddit.imageLink = [subreddit.headerImageURL absoluteString];

    return selectableSubreddit;
}

+(SelectableSubreddit *)createInstanceFromCategoryDictionary:(NSDictionary *)category{
    SelectableSubreddit *selectableSubreddit = [SelectableSubreddit new];
    selectableSubreddit.name = category[@"category"][@"name"];
    selectableSubreddit.currentlySubscribed = NO;
    selectableSubreddit.subreddits = category[@"subreddits"];

    return selectableSubreddit;
}

+(SelectableSubreddit *)createSubredditInstanceFromCategoryDictionary:(NSDictionary *)subreddit withCategoryName:(NSString *)categoryName{

    SelectableSubreddit *selectableSubreddit = [SelectableSubreddit new];
    selectableSubreddit.name = subreddit[@"name"];
    selectableSubreddit.categoryName = categoryName;
    selectableSubreddit.url = subreddit[@"url"];
    selectableSubreddit.currentlySubscribed = NO;
    return selectableSubreddit;
}

+(NSMutableArray *)createArrayFromRKLinks:(NSArray *)links{
    NSMutableArray *arrayToReturn = [NSMutableArray array];
    for (RKLink *link in links) {
        SelectableSubreddit *selectableSubreddit = [SelectableSubreddit new];
        selectableSubreddit.name = link.subreddit;
        selectableSubreddit.url = [NSString stringWithFormat:@"/r/%@/", link.subreddit];
        selectableSubreddit.currentlySubscribed = NO;
        if (![arrayToReturn containsObject:selectableSubreddit]) {
            [arrayToReturn addObject:selectableSubreddit];
        }
    }

    return arrayToReturn;
}

@end
