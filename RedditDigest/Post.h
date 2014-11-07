//
//  Post.h
//  RedditDigest
//
//  Created by Richmond on 11/5/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RedditKit.h>
#import <RKLink.h>
@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * isImageLink;
@property (nonatomic, retain) NSNumber * isSelfPost;
@property (nonatomic, retain) NSNumber * nsfw;
@property (nonatomic, retain) NSString * selfText;
@property (nonatomic, retain) NSString * subreddit;
@property (nonatomic, retain) NSData * thumbnailImage;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * totalComments;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * voteRatio;
@property (nonatomic, retain) NSNumber * isWebPage;
@property (nonatomic, retain) NSString * html;


+(void)savePost:(RKLink *)link withManagedObject:(NSManagedObjectContext *)managedObject;
+(void)removeAllPostsFromCoreData:(NSManagedObjectContext *)managedObject;

@end
