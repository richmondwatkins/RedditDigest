//
//  ViewController.h
//  RedditDigest
//
//  Created by Richmond on 11/1/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DigestViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end

