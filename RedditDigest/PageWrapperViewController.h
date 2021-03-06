//
//  PageWrapperViewController.h
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import "Post.h"
#import <RKLink.h>
@interface PageWrapperViewController : UIViewController

@property NSInteger index;
@property NSString *url;
@property NSString *selfPostText;
@property NSData *imageData;
@property Post *post;
@property NSString *postID;
@property int sourceViewIdentifier;
@property NSMutableArray *comments;
@property BOOL isOldDigest;
@property UINavigationController *navController;
@property BOOL isNSFW;
@property BOOL navBarIsHidden;
@end
