//
//  SubredditCategory.h
//  RedditDigest
//
//  Created by Richmond on 11/11/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RedditKit.h>
@interface SelectableSubreddit : NSObject
@property NSString *name;
@property BOOL currentlySubscribed;
@property NSArray *subreddits;
@property NSString *url;
@property NSString *imageLink;
@property NSString *categoryName;

+(SelectableSubreddit *)createInstanceFromRKSubreddit:(RKSubreddit *)subreddit;
+(SelectableSubreddit *)createInstanceFromCategoryDictionary:(NSDictionary *)category;
+(SelectableSubreddit *)createSubredditInstanceFromCategoryDictionary:(NSDictionary *)category withCategoryName:(NSString *)categoryName;
+(NSMutableArray *)createArrayFromRKLinks:(NSArray *)links;
@end
