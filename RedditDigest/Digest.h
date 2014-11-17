//
//  Digest.h
//  
//
//  Created by Richmond on 11/17/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DigestPost;

@interface Digest : NSManagedObject

@property (nonatomic, retain) NSNumber * isMorning;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSSet *digestPost;
@end

@interface Digest (CoreDataGeneratedAccessors)

- (void)addDigestPostObject:(DigestPost *)value;
- (void)removeDigestPostObject:(DigestPost *)value;
- (void)addDigestPost:(NSSet *)values;
- (void)removeDigestPost:(NSSet *)values;

+(void)createDigestFromDigestPosts:(NSMutableArray *)digestPosts withManagedObject:(NSManagedObjectContext *)managedObject;
@end
