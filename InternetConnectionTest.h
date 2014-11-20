//
//  InternetConnectionTest.h
//  RedditDigest
//
//  Created by Richmond on 11/20/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface InternetConnectionTest : NSObject

+(void)testInternetConnectionWithViewController:(UIViewController *)viewController andCompletion:(void (^)(BOOL completed))complete;

@end
