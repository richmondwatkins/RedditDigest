//
//  PageWrapperViewController.h
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageWrapperViewController : UIViewController
@property NSInteger index;
@property NSMutableArray *comments;
@property NSString *url;
@property NSString *selfPostText;
@property NSData *imageData;

@end
