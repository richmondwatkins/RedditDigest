//
//  Digest.m
//  
//
//  Created by Richmond on 11/17/14.
//
//

#import "Digest.h"
#import "DigestPost.h"


@implementation Digest

@dynamic isMorning;
@dynamic time;
@dynamic digestPost;

+(void)createDigestFromDigestPosts:(NSMutableArray *)digestPosts withManagedObject:(NSManagedObjectContext *)managedObject{
    Digest *savedDigest = [NSEntityDescription insertNewObjectForEntityForName:@"Digest" inManagedObjectContext:managedObject];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    savedDigest.time = [NSNumber numberWithDouble:time];

    for (DigestPost *post in digestPosts) {
        post.digest = savedDigest;
        [savedDigest addDigestPostObject:post];
        [managedObject save:nil];
    }
}

@end
