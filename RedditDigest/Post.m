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

+(void)savePost:(RKLink *)post withManagedObject:(NSManagedObjectContext *)managedObjectContext withComments:(NSArray *)comments andCompletion:(void (^)(BOOL))complete{

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

        [self createSubredditRelationship:post withPostObject:savedPost withManagedObj:managedObjectContext];

        NSURLRequest *thumbnailRequest = [NSURLRequest requestWithURL:post.thumbnailURL];
        [NSURLConnection sendAsynchronousRequest:thumbnailRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                savedPost.thumbnailImage = [NSNumber numberWithBool:YES];
            }

            [self saveDataToDocumentsDirectory:data withFileNamePrefix:@"thumbnail" andPostfix:savedPost.postID];

            if (post.isImageLink) {
                savedPost.isImageLink = [NSNumber numberWithBool:YES];
                NSURLRequest *mainImageRequest = [NSURLRequest requestWithURL:post.URL];
                [NSURLConnection sendAsynchronousRequest:mainImageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                    NSString *contentType = [httpResponse allHeaderFields][@"Content-Type"];

                    if ([contentType isEqualToString:@"image/gif"]) {
                        savedPost.isImageLink = [NSNumber numberWithBool:NO];
                        savedPost.isGif = [NSNumber numberWithBool:YES];
                    }else{
                        [self saveDataToDocumentsDirectory:data withFileNamePrefix:@"image" andPostfix:savedPost.postID];
                        savedPost.image = post.fullName;
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



//SAVE IF WE WANT TO INCORPORATE IMGUR REGEX
//    if ([[post.URL absoluteString] containsString:@"imgur"] && ![[post.URL absoluteString] containsString:@"/a/"] && ![[post.URL absoluteString] containsString:@"gallery"]) {
//        post.customURL = [self performRegexOnImgur:post.URL];
//        post.customIsImage = YES;
//        if (post.customURL == nil) {
//            post.customIsImage = NO;
//        }
//    }



@end
