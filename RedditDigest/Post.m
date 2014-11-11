//
//  Post.m
//  
//
//  Created by Richmond on 11/8/14.
//
//

#import "Post.h"
#import "Comment.h"


@implementation Post

@dynamic author;
@dynamic html;
@dynamic image;
@dynamic isGif;
@dynamic isImageLink;
@dynamic isSelfPost;
@dynamic isWebPage;
@dynamic isYouTube;
@dynamic nsfw;
@dynamic selfText;
@dynamic subreddit;
@dynamic thumbnailImage;
@dynamic title;
@dynamic totalComments;
@dynamic url;
@dynamic voteRatio;
@dynamic comments;
@dynamic postID;
@dynamic viewed;
@dynamic upvoted;
@dynamic downvoted;
+(void)savePost:(RKLink *)post withManagedObject:(NSManagedObjectContext *)managedObjectContext withComments:(NSArray *)comments andCompletion:(void (^)(BOOL))complete{

    Post *savedPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:managedObjectContext];
    savedPost.title = post.title;
    savedPost.subreddit = post.subreddit;
    savedPost.url = [post.URL absoluteString];
    savedPost.nsfw = [NSNumber numberWithBool:post.NSFW];
    savedPost.author = post.author;
    savedPost.voteRatio = [NSNumber numberWithFloat:post.score];
    savedPost.postID = post.fullName;

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

//    if ([[post.URL absoluteString] containsString:@"imgur"] && ![[post.URL absoluteString] containsString:@"/a/"] && ![[post.URL absoluteString] containsString:@"gallery"]) {
//        post.customURL = [self performRegexOnImgur:post.URL];
//        post.customIsImage = YES;
//        if (post.customURL == nil) {
//            post.customIsImage = NO;
//        }
//    }

    NSURLRequest *thumbnailRequest = [NSURLRequest requestWithURL:post.thumbnailURL];
    [NSURLConnection sendAsynchronousRequest:thumbnailRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        savedPost.thumbnailImage = data;

        if (post.isImageLink) {
            savedPost.isImageLink = [NSNumber numberWithBool:YES];
            NSURLRequest *mainImageRequest = [NSURLRequest requestWithURL:post.URL];
            [NSURLConnection sendAsynchronousRequest:mainImageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                NSString *contentType = [httpResponse allHeaderFields][@"Content-Type"];

                if ([contentType isEqualToString:@"image/gif"]) {
                    savedPost.isImageLink = [NSNumber numberWithBool:NO];
                    savedPost.isGif = [NSNumber numberWithBool:YES];
                }
                savedPost.image = data;

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

+(void)removeAllPostsFromCoreData:(NSManagedObjectContext *)managedObjectContext{
    NSFetchRequest * allPosts = [[NSFetchRequest alloc] init];
    [allPosts setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:managedObjectContext]];
    [allPosts setIncludesPropertyValues:NO];

    NSError * error = nil;
    NSArray * posts = [managedObjectContext executeFetchRequest:allPosts error:&error];

    for (NSManagedObject * post in posts) {
        [managedObjectContext deleteObject:post];
    }
    [managedObjectContext save:nil];
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



@end
