//
//  Post.h
//  
//
//  Created by Richmond on 11/7/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DigestViewController.h"
#import <RedditKit.h>
#import <RKLink.h>

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * html;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * isGif;
@property (nonatomic, retain) NSNumber * isImageLink;
@property (nonatomic, retain) NSNumber * isSelfPost;
@property (nonatomic, retain) NSNumber * isWebPage;
@property (nonatomic, retain) NSNumber * isYouTube;
@property (nonatomic, retain) NSNumber * nsfw;
@property (nonatomic, retain) NSString * selfText;
@property (nonatomic, retain) NSString * subreddit;
@property (nonatomic, retain) NSData * thumbnailImage;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * totalComments;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * voteRatio;


+(void)savePost:(RKLink *)post withManagedObject:(NSManagedObjectContext *)managedObjectContext withCompletion:(void (^)(BOOL completed))complete;
+(void)removeAllPostsFromCoreData:(NSManagedObjectContext *)managedObjectContext;
@end
