//
//  Post.h
//  
//
//  Created by Richmond on 11/11/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DigestViewController.h"
#import <RedditKit.h>
#import <RKLink.h>

@class Comment, Subreddit;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * downvoted;
@property (nonatomic, retain) NSString * html;
@property (nonatomic, retain) NSNumber * image;
@property (nonatomic, retain) NSNumber * isGif;
@property (nonatomic, retain) NSNumber * isImageLink;
@property (nonatomic, retain) NSNumber * isSelfPost;
@property (nonatomic, retain) NSNumber * isWebPage;
@property (nonatomic, retain) NSNumber * isYouTube;
@property (nonatomic, retain) NSNumber * nsfw;
@property (nonatomic, retain) NSString * postID;
@property (nonatomic, retain) NSString * selfText;
@property (nonatomic, retain) NSNumber * thumbnailImage;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * totalComments;
@property (nonatomic, retain) NSNumber * upvoted;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * viewed;
@property (nonatomic, retain) NSNumber * voteRatio;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) Subreddit *subreddit;
@property (nonatomic, retain) NSNumber *isLocalPost;
@property (nonatomic, retain) NSString *domain;


@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

+(void)savePosts:(NSMutableArray *)posts withManagedObject:(NSManagedObjectContext *)managedObjectContext andCompletion:(void (^)(BOOL completed))complete;

+(void)removeAllPostsFromCoreData:(NSManagedObjectContext *)managedObjectContext;

+(void)saveLocalSubreddit:(RKLink *)post withManagedObject:(NSManagedObjectContext *)managedObject withComments:(NSArray *)comments andCompletion:(void (^)(BOOL completed))complete;

@end
