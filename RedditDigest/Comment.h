//
//  Comment.h
//  
//
//  Created by Richmond on 11/8/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChildComment, Post;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) NSSet *childcomments;
@property (nonatomic, retain) NSString *html;

@end

@interface Comment (CoreDataGeneratedAccessors)

- (void)addChildcommentsObject:(ChildComment *)value;
- (void)removeChildcommentsObject:(ChildComment *)value;
- (void)addChildcomments:(NSSet *)values;
- (void)removeChildcomments:(NSSet *)values;

+(void)addCommentsToPost:(Post *)post  commentsArray:(NSArray *)comments withMangedObject:(NSManagedObjectContext *)managedObjectContext;


@end
