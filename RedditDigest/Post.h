//
//  Post.h
//  
//
//  Created by Richmond on 11/5/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * author;
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
@property (nonatomic, retain) NSData * image;

@end
