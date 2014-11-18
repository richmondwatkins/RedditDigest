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
#import "Subreddit.h"
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
@dynamic subreddit;
@dynamic subredditImage;

+(void)createNewDigestPosts:(NSArray *)posts withManagedObject:(NSManagedObjectContext *)managedObject{
    NSMutableArray *savedDigestPosts = [NSMutableArray array];
    for (Post *post in posts) {
        DigestPost *savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"DigestPost" inManagedObjectContext:managedObject];
        savedPost.totalComments = post.totalComments;
        savedPost.voteRaio = post.voteRatio;
        savedPost.author = post.author;
        savedPost.domain = post.domain;
        savedPost.postID = post.postID;
        savedPost.subreddit = post.subreddit.subreddit;

        if (post.subreddit) {
            NSData *imageData = [self documentsPathForFileName:post.subreddit.subreddit andPrefix:@"subreddit"];
            [self saveDataToDocumentsDirectory:imageData withFileNamePrefix:@"subreddit-copy" andPostfix:post.subreddit.subreddit];
            if (imageData) {
                savedPost.subredditImage = [NSNumber numberWithBool:YES];
            }
        }

        if (post.isSelfPost) {
            savedPost.selfText = post.selfText;
            savedPost.isSelfPost = post.isSelfPost;
        }
        savedPost.title = post.title;
        savedPost.url = post.url;

        if (post.thumbnailImage) {
            savedPost.thumbnailImagePath = [NSNumber numberWithBool:YES];
            NSData *imageData = [self documentsPathForFileName:post.postID andPrefix:@"thumbnail"];
            [self saveDataToDocumentsDirectory:imageData withFileNamePrefix:@"thumbnail-copy" andPostfix:post.postID];
        }

        if (post.isGif) {
            savedPost.isGif = post.isGif;
        }

        if (post.isImageLink) {
            savedPost.isImageLink = post.isImageLink;

            NSData *imageData = [self documentsPathForFileName:post.postID andPrefix:@"image"];
            [self saveDataToDocumentsDirectory:imageData withFileNamePrefix:@"image-copy" andPostfix:post.postID];

            if (imageData) {
                savedPost.imagePath = [NSNumber numberWithBool:YES];
            }
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

+(NSData *)documentsPathForFileName:(NSString *)name andPrefix:(NSString *)prefix
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];

    NSString *pathCompenent = [NSString stringWithFormat:@"%@-%@",prefix, name];

    NSString *filePath = [documentsPath stringByAppendingPathComponent:pathCompenent];

    return [NSData dataWithContentsOfFile:filePath];
}

+(void)saveDataToDocumentsDirectory:(NSData *)data withFileNamePrefix:(NSString *)prefix andPostfix:(NSString *)postfix{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@",prefix, postfix]];
    [data writeToFile:filePath atomically:YES];
}
@end
