//
//  Comment.m
//  
//
//  Created by Richmond on 11/8/14.
//
//

#import "Comment.h"
#import "ChildComment.h"
#import "Post.h"
#import <RedditKit.h>


@implementation Comment

@dynamic author;
@dynamic body;
@dynamic score;
@dynamic post;
@dynamic childcomments;
@dynamic html;
+(void)addCommentsToPost:(Post *)post  commentsArray:(NSArray *)comments withMangedObject:(NSManagedObjectContext *)managedObjectContext{

    NSInteger totalCommentCount = comments.count;
    int commentCount = 0;
    for(RKComment *comment in comments){
        Comment *savedComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:managedObjectContext];
        savedComment.author = comment.author;
        savedComment.html = [NSString stringWithFormat:@"<html><style>p{font-size:10px;}</style>%@</html>",comment.bodyHTML];
        savedComment.body = comment.body;
        savedComment.score = [NSNumber numberWithInteger:comment.score];
        totalCommentCount += comment.replies.count;
        [post addCommentsObject:savedComment];

        if (comment.replies) {
            [ChildComment addChildrenToComment:savedComment childrenCommentsArray:comment.replies withMangedObject:managedObjectContext];
        }

        commentCount++;
        [managedObjectContext save:nil];
        if (commentCount == 11) {
            break;
        }
    }
    post.totalComments = [NSNumber numberWithInteger:totalCommentCount];
}



@end
