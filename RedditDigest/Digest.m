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
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Digest" inManagedObjectContext:managedObject]];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];

    [fetch setSortDescriptors:@[sorter]];
    NSArray *digestArray = [managedObject executeFetchRequest:fetch error:nil];

    if (digestArray.count >= 14) {
        NSMutableArray *mutableDigests = [digestArray mutableCopy];
        Digest *digestToDelete = [mutableDigests objectAtIndex:0];
        [self clearOutContentsOfDigest:digestToDelete];
        [managedObject deleteObject:digestToDelete];
        [mutableDigests removeObjectAtIndex:0];
        [managedObject save:nil];
    }

    Digest *savedDigest = [NSEntityDescription insertNewObjectForEntityForName:@"Digest" inManagedObjectContext:managedObject];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    savedDigest.time = [NSNumber numberWithDouble:time];

    for (DigestPost *post in digestPosts) {
        post.digest = savedDigest;
        [savedDigest addDigestPostObject:post];
        [managedObject save:nil];
    }
}

+(void)clearOutContentsOfDigest:(Digest *)digest{
    NSArray *digestPosts = [digest.digestPost allObjects];

    for (DigestPost *post in digestPosts) {
        if ([post.image boolValue]) {
            [self documentsPathForFileName:post.postID withPrefix:@"image-copy"];

        }else if([post.thumbnailImagePath boolValue]){
            [self documentsPathForFileName:post.postID withPrefix:@"thumbnail-copy"];

        }else if([post.subredditImage boolValue]){
            [self documentsPathForFileName:post.postID withPrefix:@"subreddit-copy"];

        }
    }
}


+(void)documentsPathForFileName:(NSString *)postID withPrefix:(NSString *)prefix
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];

    NSString *pathCompenent = [NSString stringWithFormat:@"%@-%@",prefix, postID];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:pathCompenent];
    BOOL test = [fileManager removeItemAtPath:filePath error:nil];
    NSLog(@"DELETEEEEEEEE %@",test ? @"true" : @"false");
}

//NSFileManager *fileManager = [NSFileManager defaultManager];
//NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//
//NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image-%@", fileName]];
//
//NSError *error;
//[fileManager removeItemAtPath:filePath error:&error];

@end
