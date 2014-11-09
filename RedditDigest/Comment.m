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


+(void)addCommentsToPost:(Post *)post  commentsArray:(NSArray *)comments withMangedObject:(NSManagedObjectContext *)managedObjectContext{

    NSInteger totalCommentCount = comments.count;
    for(RKComment *comment in comments){
        Comment *savedComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:managedObjectContext];
        savedComment.author = comment.author;
        savedComment.body = comment.body;
        savedComment.score = [NSNumber numberWithInteger:comment.score];
        totalCommentCount += comment.replies.count;
        [post addCommentsObject:savedComment];
        
        [ChildComment addChildrenToComment:savedComment childrenCommentsArray:comment.replies withMangedObject:managedObjectContext];

        [managedObjectContext save:nil];
    }
    post.totalComments = [NSNumber numberWithInteger:totalCommentCount];
}



@end
