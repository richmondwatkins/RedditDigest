//
//  UserInteractionSettingsExit.h
//  RedditDigest
//
//  Created by Richmond on 12/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInteractionSettingsExit : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign, getter=isInteractive)BOOL interactive;

- (void)addInteractionToViewController:(UIViewController *)viewController;

@end
