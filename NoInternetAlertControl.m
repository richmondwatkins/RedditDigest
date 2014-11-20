//
//  NoInternetAlertControl.m
//  RedditDigest
//
//  Created by Richmond on 11/19/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "NoInternetAlertControl.h"
#import "TSMessage.h"

@implementation NoInternetAlertControl



+(void)checkForInternetReachability:(UIViewController *)viewController{
    BOOL isReachable = [AFNetworkReachabilityManager sharedManager].reachable;
    NSLog(@"REACHABLEEEEE %@",(isReachable) ? @"true" : @"false");
    if (isReachable == NO) {
        NSString *message = @"You are not connected to the internet.";

        [TSMessage showNotificationInViewController:viewController
                                              title:message
                                           subtitle:nil
                                               type:TSMessageNotificationTypeError
                                           duration:1.3];
    }
}


@end
