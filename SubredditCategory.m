//
//  SubredditCategory.m
//  RedditDigest
//
//  Created by Richmond on 11/11/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SubredditCategory.h"
#import "SelectableSubreddit.h"
@implementation SubredditCategory

+(NSArray *)createCategoriesAndSubreddit:(NSArray *)categoriesFromHeroku{
    NSMutableArray *allCategories = [NSMutableArray array];
    for (NSDictionary *categoryDict in categoriesFromHeroku) {
        SubredditCategory *category = [SubredditCategory new];
        category.name = categoryDict[@"category"][@"name"];

        NSMutableArray *subredditObjs = [NSMutableArray array];
        for(NSDictionary *subredditDict in categoryDict[@"subreddits"]){
            [subredditObjs addObject:[SelectableSubreddit createSubredditInstanceFromCategoryDictionary:subredditDict withCategoryName:category.name]];
        }
        category.subreddits = [NSArray arrayWithArray:subredditObjs];
        [allCategories addObject:category];
    }

    return allCategories;
}
@end
