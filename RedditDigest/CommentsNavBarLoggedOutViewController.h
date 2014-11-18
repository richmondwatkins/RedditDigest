//
//  CommentsLoggedOutViewController.h
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentsNavBarLoggedOutViewController <NSObject>

- (void)onCommentsButtonTapped:(UITapGestureRecognizer *)tapGesture;

@end

@interface CommentsNavBarLoggedOutViewController : UIViewController

@property id<CommentsNavBarLoggedOutViewController>delegate;

@end
