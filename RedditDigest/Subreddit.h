//
//  Subreddit.h
//  
//
//  Created by Richmond on 11/11/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Subreddit : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * subreddit;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Post *post;

+(void)addSubredditsToCoreData:(NSMutableArray *)selectedSubreddits withManagedObject:(NSManagedObjectContext *)managedObject;
+(void)removeFromCoreData:(NSString *)subreddit withManagedObject:(NSManagedObjectContext *)managedObject;


@end
