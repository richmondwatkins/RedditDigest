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
    return selectableSubreddit;
}

@end
