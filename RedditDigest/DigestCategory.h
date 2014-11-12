//
//  DigestCategory.h
//  RedditDigest
//
//  Created by Richmond on 11/11/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Subreddit;

@interface DigestCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *subreddits;
@end

@interface DigestCategory (CoreDataGeneratedAccessors)

- (void)addSubredditsObject:(Subreddit *)value;
- (void)removeSubredditsObject:(Subreddit *)value;
- (void)addSubreddits:(NSSet *)values;
- (void)removeSubreddits:(NSSet *)values;

+(void)addCategoryWithSubredditsToCoreData:(NSString *)categoryName withSubreddit:(Subreddit *)subreddit withManagedObject:(NSManagedObjectContext *)managedObject;
+(void)removeFromCoreData:(NSString *)categoryName withManagedObject:(NSManagedObjectContext *)managedObject;
@end
