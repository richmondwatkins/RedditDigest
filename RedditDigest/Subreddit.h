//
//  Subreddit.h
//  RedditDigest
//
//  Created by Richmond on 11/9/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Subreddit : NSManagedObject

@property (nonatomic, retain) NSString * subreddit;
@property (nonatomic, retain) NSString * url;

+(void)addSubredditsToCoreData:(NSMutableArray *)selectedSubreddits withManagedObject:(NSManagedObjectContext *)managedObject;
+(void)removeFromCoreData:(NSString *)subreddit withManagedObject:(NSManagedObjectContext *)managedObject;
@end
