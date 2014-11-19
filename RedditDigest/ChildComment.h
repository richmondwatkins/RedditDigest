//
//  ChildComment.h
//  
//
//  Created by Richmond on 11/8/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment;

@interface ChildComment : NSManagedObject

@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) Comment *comment;

+(void)addChildrenToComment:(Comment *)post  childrenCommentsArray:(NSArray *)comments withMangedObject:(NSManagedObjectContext *)managedObjectContext;

@end
