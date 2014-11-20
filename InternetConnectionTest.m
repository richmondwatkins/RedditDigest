//
//  InternetConnectionTest.m
//  RedditDigest
//
//  Created by Richmond on 11/20/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "InternetConnectionTest.h"
#import "Reachability.h"
#import "TSMessage.h"

@implementation InternetConnectionTest


+(void)testInternetConnectionWithViewController:(UIViewController *)viewController andCompletion:(void (^)(BOOL))complete
{
    Reachability *internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];

    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Internet is Working");
            complete(YES);
        });
    };

    // Internet is not reachable
     internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = @"The internet is currenlty unreachable.";
            [TSMessage showNotificationInViewController:viewController
                                                  title:message
                                               subtitle:nil
                                                   type:TSMessageNotificationTypeWarning
                                               duration:3.0];
            complete(NO);
        });
    };

    [internetReachableFoo startNotifier];
}

@end
