//
//  SubredditSelectionViewController.h
//  RedditDigest
//
//  Created by Richmond on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const MAX_SELECTABLE_SUBREDDITS_FOR_DIGEST;

@interface SubredditSelectionViewController : UIViewController

@property NSManagedObjectContext *managedObject;
@property BOOL isFromSettings;
@property NSMutableArray *selectedSubreddits;

@end
