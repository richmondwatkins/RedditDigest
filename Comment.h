//
//  Comment.h
//  
//
//  Created by Richmond on 11/8/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) Post *post;

@end
