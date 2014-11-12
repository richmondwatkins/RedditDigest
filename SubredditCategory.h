//
//  SubredditCategory.h
//  RedditDigest
//
//  Created by Richmond on 11/11/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubredditCategory : NSObject
@property NSString *name;
@property NSArray *subreddits;
@property BOOL currentlySubscribed;
+(NSMutableArray *)createCategoriesAndSubreddit:(NSArray *)categoriesFromHeroku;
@end
