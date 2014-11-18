//
//  DigestPost.h
//  
//
//  Created by Richmond on 11/17/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Digest;

@interface DigestPost : NSManagedObject

@property (nonatomic, retain) NSNumber * totalComments;
@property (nonatomic, retain) NSNumber * voteRaio;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * html;
@property (nonatomic, retain) NSString * postID;
@property (nonatomic, retain) NSString * selfText;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * isGif;
@property (nonatomic, retain) NSNumber * isImageLink;
@property (nonatomic, retain) NSNumber * isSelfPost;
@property (nonatomic, retain) NSNumber * isWebPage;
@property (nonatomic, retain) NSNumber * isYouTube;
@property (nonatomic, retain) NSNumber * nsfw;
@property (nonatomic, retain) NSNumber * imagePath;
@property (nonatomic, retain) NSNumber * thumbnailImagePath;
@property (nonatomic, retain) Digest *digest;
@property (nonatomic, retain) NSString * subreddit;
@property (nonatomic, retain) NSNumber * subredditImage;

+(void)createNewDigestPosts:(NSArray *)posts withManagedObject:(NSManagedObjectContext *)managedObject;

@end
