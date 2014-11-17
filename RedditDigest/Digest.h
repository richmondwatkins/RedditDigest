//
//  Digest.h
//  RedditDigest
//
//  Created by Richmond on 11/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Digest : NSManagedObject

@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * isMorning;
@property (nonatomic, retain) NSSet *posts;
@end

@interface Digest (CoreDataGeneratedAccessors)

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

+(void)createAndSaveDigestWithPost:(NSArray *)post andManagedObject:(NSManagedObjectContext *)managedObject;

@end
