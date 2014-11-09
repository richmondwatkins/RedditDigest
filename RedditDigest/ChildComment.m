//
//  ChildComment.m
//  
//
//  Created by Richmond on 11/8/14.
//
//

#import "ChildComment.h"
#import "Comment.h"
#import <RedditKit.h>


@implementation ChildComment

@dynamic score;
@dynamic author;
@dynamic body;
@dynamic comment;


+(void)addChildrenToComment:(Comment *)comment  childrenCommentsArray:(NSArray *)comments withMangedObject:(NSManagedObjectContext *)managedObjectContext{
    for(RKComment *childComment in comments){
        ChildComment *newChildComment = [NSEntityDescription insertNewObjectForEntityForName:@"ChildComment" inManagedObjectContext:managedObjectContext];
        newChildComment.author = childComment.author;
        newChildComment.body = childComment.body;
        newChildComment.score = [NSNumber numberWithInteger:childComment.score];
        [comment addChildcommentsObject:newChildComment];
        [managedObjectContext save:nil];
    }
}


@end
