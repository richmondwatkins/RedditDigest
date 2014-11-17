//
//  DigestPost.m
//  
//
//  Created by Richmond on 11/17/14.
//
//

#import "DigestPost.h"
#import "Digest.h"
#import "Post.h"

@implementation DigestPost

@dynamic totalComments;
@dynamic voteRaio;
@dynamic author;
@dynamic domain;
@dynamic html;
@dynamic postID;
@dynamic selfText;
@dynamic title;
@dynamic url;
@dynamic isGif;
@dynamic isImageLink;
@dynamic isSelfPost;
@dynamic isWebPage;
@dynamic isYouTube;
@dynamic nsfw;
@dynamic imagePath;
@dynamic thumbnailImagePath;
@dynamic digest;

+(void)createNewDigestPosts:(NSArray *)posts withManagedObject:(NSManagedObjectContext *)managedObject{
    NSMutableArray *savedDigestPosts = [NSMutableArray array];
    for (Post *post in posts) {
        DigestPost *savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"DigestPost" inManagedObjectContext:managedObject];
        savedPost.totalComments = post.totalComments;
        savedPost.voteRaio = post.voteRatio;
        savedPost.author = post.author;
        savedPost.domain = post.domain;
        savedPost.postID = post.postID;
        if (post.isSelfPost) {
            savedPost.selfText = post.selfText;
            savedPost.isSelfPost = post.isSelfPost;
        }
        savedPost.title = post.title;
        savedPost.url = post.url;

        if (post.isGif) {
            savedPost.isGif = post.isGif;
        }

        if (post.isImageLink) {
            savedPost.isImageLink = post.isImageLink;
        }

        if (post.isWebPage) {
            savedPost.isWebPage = post.isWebPage;
        }

        if (post.isYouTube) {
            savedPost.isYouTube = post.isYouTube;
        }
        savedPost.nsfw = post.nsfw;

        [savedDigestPosts addObject:savedPost];
    }
    [Digest createDigestFromDigestPosts:savedDigestPosts withManagedObject:managedObject];
}

@end
