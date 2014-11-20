//
//  NoInternetAlertControl.h
//  RedditDigest
//
//  Created by Richmond on 11/19/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworkReachabilityManager.h>
#import <UIKit/UIKit.h>
@interface NoInternetAlertControl : NSObject

+(void)checkForInternetReachability:(UIViewController *)viewController;
@end
