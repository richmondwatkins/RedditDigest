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
@property NSMutableArray *subredditsForFirstDigest;
@property BOOL isComingFromSubredditSelectionView;
@property (strong, nonatomic) IBOutlet UITableView *digestTableView;

-(void)fetchNewData:(BOOL)isDigest withCompletion:(void (^)(UIBackgroundFetchResult))completionHandler;
-(void)requestNewLinks:(BOOL)isDigest;
-(void)performNewFetchedDataActions:(BOOL)isDigest;

@end

