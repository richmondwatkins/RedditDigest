//
//  Digest.m
//  RedditDigest
//
//  Created by Richmond on 11/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "Digest.h"
#import "Post.h"


@implementation Digest

@dynamic time;
@dynamic isMorning;
@dynamic posts;



+(void)createAndSaveDigestWithPost:(NSArray *)postsArray andManagedObject:(NSManagedObjectContext *)managedObject{
    NSSet *posts = [NSSet setWithArray:postsArray];
    Digest *saveDigest = [NSEntityDescription insertNewObjectForEntityForName:@"Digest" inManagedObjectContext:managedObject];
    [saveDigest addPosts:posts];

    NSTimeInterval digestTime = [[NSDate date] timeIntervalSince1970];
    saveDigest.time = [NSNumber numberWithDouble:digestTime];
    [managedObject save:nil];
}


@end
