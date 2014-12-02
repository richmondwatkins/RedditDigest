//
//  Post.m
//  
//
//  Created by Richmond on 11/11/14.
//
//

#import "Post.h"
#import "Comment.h"
#import "Subreddit.h"
#import "Digest.h"

@implementation Post

@dynamic author;
@dynamic downvoted;
@dynamic html;
@dynamic image;
@dynamic isGif;
@dynamic isImageLink;
@dynamic isSelfPost;
@dynamic isWebPage;
@dynamic isYouTube;
@dynamic nsfw;
@dynamic postID;
@dynamic selfText;
@dynamic thumbnailImage;
@dynamic title;
@dynamic totalComments;
@dynamic upvoted;
@dynamic url;
@dynamic viewed;
@dynamic voteRatio;
@dynamic comments;
@dynamic subreddit;
@dynamic isLocalPost;
@dynamic domain;
@dynamic isHidden;

+(void)savePosts:(NSMutableArray *)posts withManagedObject:(NSManagedObjectContext *)managedObjectContext andCompletion:(void (^)(BOOL))complete{
    NSMutableArray *notInCoreDataArray = [self returnPostNotInCoreData:posts withManagedObject:managedObjectContext];
    if (notInCoreDataArray.count == 0) {
        complete(YES);
    }
    [self removePostsNotInLatestRefresh:posts withManagedObject:managedObjectContext];
    __block int i = 0;
    for (RKLink *post in notInCoreDataArray) {
        Post *savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:managedObjectContext];
        savedPost.title = post.title;
        savedPost.url = [post.URL absoluteString];
        savedPost.nsfw = [NSNumber numberWithBool:post.NSFW];
        savedPost.author = post.author;
        savedPost.voteRatio = [NSNumber numberWithFloat:post.score];
        savedPost.postID = post.fullName;
        savedPost.isLocalPost = [NSNumber numberWithBool:post.isLocalPost];
        savedPost.domain = post.domain;
        savedPost.isHidden = [NSNumber numberWithBool:NO];
        [[RKClient sharedClient] commentsForLink:post completion:^(NSArray *comments, RKPagination *pagination, NSError *error) {
            if (comments) {
                [Comment addCommentsToPost:savedPost commentsArray:comments withMangedObject:managedObjectContext];
            }

            if ([[post.URL absoluteString] containsString:@"youtube.com"] || [[post.URL absoluteString] containsString:@"youtu.be"]) {
                savedPost.url = [self performRegexOnYoutube:post.URL];
                savedPost.isYouTube = [NSNumber numberWithBool:YES];
            }

            if (post.isImageLink) {
                post.customIsImage = YES;
                post.customURL = post.URL;
            }

            if ([[post.URL absoluteString] containsString:@"imgur"] && [post.URL absoluteString].length == 24 && ![[post.URL absoluteString] containsString:@"/a/"] && ![[post.URL absoluteString] containsString:@"gallery"]) {
                NSString *stringURL = [NSString stringWithFormat:@"%@.jpg", [post.URL absoluteString]];
                post.customIsImage = YES;
                post.customURL = [NSURL URLWithString:stringURL];
            }

            [self createSubredditRelationship:post withPostObject:savedPost withManagedObj:managedObjectContext];

            NSURLRequest *thumbnailRequest = [NSURLRequest requestWithURL:post.thumbnailURL];
            [NSURLConnection sendAsynchronousRequest:thumbnailRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (data) {
                    savedPost.thumbnailImage = [NSNumber numberWithBool:YES];
                }

                [self saveDataToDocumentsDirectory:data withFileNamePrefix:@"thumbnail" andPostfix:savedPost.postID];

                if (post.customIsImage) {
                    savedPost.isImageLink = [NSNumber numberWithBool:YES];
                    NSURLRequest *mainImageRequest = [NSURLRequest requestWithURL:post.customURL];
                    [NSURLConnection sendAsynchronousRequest:mainImageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                        NSString *contentType = [httpResponse allHeaderFields][@"Content-Type"];

                        if ([contentType isEqualToString:@"image/gif"]) {
                            savedPost.isImageLink = [NSNumber numberWithBool:NO];
                            savedPost.isGif = [NSNumber numberWithBool:YES];
                        }else{
                            [self saveDataToDocumentsDirectory:data withFileNamePrefix:@"image" andPostfix:savedPost.postID];
                            savedPost.image = [NSNumber numberWithBool:YES];
                        }

                        [managedObjectContext save:nil];
                        i += 1;
                        if (i == notInCoreDataArray.count) {
                            complete(YES);
                        }
                    }];
                }else{
                    i += 1;

                    savedPost.isImageLink = [NSNumber numberWithBool:NO];

                    if (post.isSelfPost) {
                        savedPost.isSelfPost = [NSNumber numberWithBool:YES];

                        if ([post.selfText isEqualToString:@""]) {
                            savedPost.selfText = post.title;
                        }else{
                            savedPost.selfText = post.selfText;
                        }
                        [managedObjectContext save:nil];
                        if (i == notInCoreDataArray.count) {
                            complete(YES);
                        }
                    }else{
                        savedPost.isWebPage = [NSNumber numberWithBool:YES];
                        [managedObjectContext save:nil];
                        if (i == notInCoreDataArray.count) {
                            complete(YES);
                        }
                    }
                }
            }];
        }];
    }
}

+(void)saveDataToDocumentsDirectory:(NSData *)data withFileNamePrefix:(NSString *)prefix andPostfix:(NSString *)postfix{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@",prefix, postfix]];
    [data writeToFile:filePath atomically:YES];
}

+(void)removeAllPostsFromCoreData:(NSManagedObjectContext *)managedObjectContext{
    NSFetchRequest * allPosts = [[NSFetchRequest alloc] init];
    [allPosts setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:managedObjectContext]];
    [allPosts setIncludesPropertyValues:NO];

    NSError * error = nil;
    NSArray * posts = [managedObjectContext executeFetchRequest:allPosts error:&error];

    for (Post * post in posts) {
        [self removePhotoFromDocumentDirectory:post.postID];
        [managedObjectContext deleteObject:post];
    }
    [managedObjectContext save:nil];
}

+(NSMutableArray *)returnPostNotInCoreData:(NSMutableArray *)newPosts  withManagedObject:(NSManagedObjectContext *)managedObjectContext{
    NSMutableArray *notInCoreData = [NSMutableArray array];
    for (RKLink *post in newPosts) {
        NSFetchRequest * allPostsFetch = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
        allPostsFetch.predicate = [NSPredicate predicateWithFormat:@"postID == %@", post.fullName];
        NSArray *results = [managedObjectContext executeFetchRequest:allPostsFetch error:nil];

        if (results.count == 0) {
            [notInCoreData addObject:post];
        }
    }

    return notInCoreData;
}

+(void)removePostsNotInLatestRefresh:(NSMutableArray *)posts withManagedObject:(NSManagedObjectContext *)managedObject{
    NSFetchRequest * allPostsFetch = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
    NSArray *results = [managedObject executeFetchRequest:allPostsFetch error:nil];

    for (Post *post in results) {
        BOOL isInCoreData = NO;
        for (RKLink *rkLink in posts) {
            if ([post.postID isEqualToString:rkLink.fullName]) {
                isInCoreData = YES;
            }
        }
        if (isInCoreData == NO) {
            [managedObject deleteObject:post];
            [managedObject save:nil];
        }
    }
}

+(void)removePhotoFromDocumentDirectory:(NSString *)fileName{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image-%@", fileName]];

    NSError *error;
    [fileManager removeItemAtPath:filePath error:&error];

}


+(NSString *)performRegexOnYoutube:(NSURL *)url{
    NSString *regexString = @"(?:youtube.com.+v[=/]|youtu.be/)([-a-zA-Z0-9_]+)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *urlString = [url absoluteString];
    NSTextCheckingResult *match = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    NSRange videoIDRange = [match rangeAtIndex:1];
    NSString *youTubeID = [urlString substringWithRange:videoIDRange];

    return [NSString stringWithFormat:@"www.youtube.com/embed/%@", youTubeID];
}

+(void)createSubredditRelationship:(RKLink *)rkLink withPostObject:(Post*)postObject withManagedObj:(NSManagedObjectContext *)managedObject{
    NSFetchRequest * subredditFetch = [[NSFetchRequest alloc] init];
    [subredditFetch setEntity:[NSEntityDescription entityForName:@"Subreddit" inManagedObjectContext:managedObject]];
    subredditFetch.predicate = [NSPredicate predicateWithFormat:@"subreddit == %@", rkLink.subreddit];

    NSArray *results = [managedObject executeFetchRequest:subredditFetch error:nil];
    if (results) {
        Subreddit *subreddit = results.firstObject;
        postObject.subreddit = subreddit;
    }
}

+(NSURL *)performRegexOnImgur:(NSURL *)url{
    NSString *regexString = @"(?:imgur.com.+[/])([-a-zA-Z0-9_]+)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *urlString = [url absoluteString];
    NSTextCheckingResult *match = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];

    if (!match) {
        return nil;
    }
    NSRange iDRange = [match rangeAtIndex:1];
    NSString *imgurID = [urlString substringWithRange:iDRange];
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://imgur.com/%@.png", imgurID]];
}


+(void)saveLocalSubreddit:(RKLink *)post withManagedObject:(NSManagedObjectContext *)managedObjectContext withComments:(NSArray *)comments andCompletion:(void (^)(BOOL completed))complete{
    NSFetchRequest * postFetch = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
    postFetch.predicate = [NSPredicate predicateWithFormat:@"postID == %@", post.fullName];
    NSArray * posts = [managedObjectContext executeFetchRequest:postFetch error:nil];

    if (posts.count) {
        complete(YES);
    }else{
        Post *savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:managedObjectContext];
        savedPost.title = post.title;
        savedPost.url = [post.URL absoluteString];
        savedPost.nsfw = [NSNumber numberWithBool:post.NSFW];
        savedPost.author = post.author;
        savedPost.voteRatio = [NSNumber numberWithFloat:post.score];
        savedPost.postID = post.fullName;
        savedPost.isLocalPost = [NSNumber numberWithBool:post.isLocalPost];
        savedPost.domain = post.domain;

        if (comments) {
            [Comment addCommentsToPost:savedPost commentsArray:comments withMangedObject:managedObjectContext];
        }

        if ([[post.URL absoluteString] containsString:@"youtube.com"] || [[post.URL absoluteString] containsString:@"youtu.be"]) {
            savedPost.url = [self performRegexOnYoutube:post.URL];
            savedPost.isYouTube = [NSNumber numberWithBool:YES];
        }

        if (post.isImageLink) {
            post.customIsImage = YES;
            post.customURL = post.URL;
        }

//        if ([[post.URL absoluteString] containsString:@"imgur"] && [post.URL absoluteString].length == 24 && ![[post.URL absoluteString] containsString:@"/a/"] && ![[post.URL absoluteString] containsString:@"gallery"]) {
//            NSString *stringURL = [NSString stringWithFormat:@"%@.jpg", [post.URL absoluteString]];
//            post.customIsImage = YES;
//            post.customURL = [NSURL URLWithString:stringURL];
//        }

        [self createSubredditRelationship:post withPostObject:savedPost withManagedObj:managedObjectContext];

        NSURLRequest *thumbnailRequest = [NSURLRequest requestWithURL:post.thumbnailURL];
        [NSURLConnection sendAsynchronousRequest:thumbnailRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                savedPost.thumbnailImage = [NSNumber numberWithBool:YES];
            }

            [self saveDataToDocumentsDirectory:data withFileNamePrefix:@"thumbnail" andPostfix:savedPost.postID];

            if (post.customIsImage) {
                savedPost.isImageLink = [NSNumber numberWithBool:YES];
                NSURLRequest *mainImageRequest = [NSURLRequest requestWithURL:post.customURL];
                [NSURLConnection sendAsynchronousRequest:mainImageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                    NSString *contentType = [httpResponse allHeaderFields][@"Content-Type"];

                    if ([contentType isEqualToString:@"image/gif"]) {
                        savedPost.isImageLink = [NSNumber numberWithBool:NO];
                        savedPost.isGif = [NSNumber numberWithBool:YES];
                    }else{
                        [self saveDataToDocumentsDirectory:data withFileNamePrefix:@"image" andPostfix:savedPost.postID];
                        savedPost.image = [NSNumber numberWithBool:YES];
                    }

                    [managedObjectContext save:nil];
                    complete(YES);
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
                    [managedObjectContext save:nil];
                    complete(YES);
                }else{
                    savedPost.isWebPage = [NSNumber numberWithBool:YES];
                    [managedObjectContext save:nil];
                    complete(YES);
                }
            }
        }];
    }
}

-(void)markPostAsHidden{
    self.isHidden = [NSNumber numberWithBool:YES];
    NSLog(@"SELFFFF %@",self);
    [self.managedObjectContext save:nil];
}

//SAVE IF WE WANT TO INCORPORATE IMGUR REGEX
//    if ([[post.URL absoluteString] containsString:@"imgur"] && ![[post.URL absoluteString] containsString:@"/a/"] && ![[post.URL absoluteString] containsString:@"gallery"]) {
//        post.customURL = [self performRegexOnImgur:post.URL];
//        post.customIsImage = YES;
//        if (post.customURL == nil) {
//            post.customIsImage = NO;
//        }
//    }


@end
