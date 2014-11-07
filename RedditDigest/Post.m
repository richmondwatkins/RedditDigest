//
//  Post.m
//  RedditDigest
//
//  Created by Richmond on 11/5/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "Post.h"


@implementation Post

@dynamic author;
@dynamic image;
@dynamic isImageLink;
@dynamic isSelfPost;
@dynamic nsfw;
@dynamic selfText;
@dynamic subreddit;
@dynamic thumbnailImage;
@dynamic title;
@dynamic totalComments;
@dynamic url;
@dynamic voteRatio;
@dynamic isWebPage;
@dynamic html;


+(void)savePost:(RKLink *)post withManagedObject:(NSManagedObjectContext *)managedObjectContext{
    Post *savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:managedObjectContext];
    savedPost.title = post.title;
    savedPost.subreddit = post.subreddit;
    savedPost.url = [post.URL absoluteString];
    savedPost.nsfw = [NSNumber numberWithBool:post.NSFW];
    savedPost.author = post.author;
    savedPost.voteRatio = [NSNumber numberWithFloat:post.score];

    NSURLRequest *thumbnailRequest = [NSURLRequest requestWithURL:post.thumbnailURL];
    [NSURLConnection sendAsynchronousRequest:thumbnailRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        savedPost.thumbnailImage = data;

        if (post.isImageLink) {
            savedPost.isImageLink = [NSNumber numberWithBool:YES];
            NSURLRequest *mainImageRequest = [NSURLRequest requestWithURL:post.URL];
            [NSURLConnection sendAsynchronousRequest:mainImageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                savedPost.image = data;
            }];
        }else{
            savedPost.isImageLink = [NSNumber numberWithBool:NO];

            if (post.isSelfPost) {
                savedPost.isSelfPost = [NSNumber numberWithBool:YES];

                if ([post.selfText isEqualToString:@""]) {
                    savedPost.selfText = post.title;
                }else{
                    savedPost.selfText = post.selfText;
                }
            }else{
                savedPost.isWebPage = [NSNumber numberWithBool:YES];
            }
        }
        [managedObjectContext save:nil];
    }];
}

+(void)removeAllPostsFromCoreData:(NSManagedObjectContext *)managedObjectContext{
    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:managedObjectContext]];
    [allCars setIncludesPropertyValues:NO];

    NSError * error = nil;
    NSArray * posts = [managedObjectContext executeFetchRequest:allCars error:&error];
    //error handling goes here
    for (NSManagedObject * post in posts) {
        [managedObjectContext deleteObject:post];
    }
    [managedObjectContext save:nil];
}


@end
