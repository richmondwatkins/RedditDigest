//
//  DetailPostTabBarViewController.h
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/12/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailPostTabBarViewController : UITabBarController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property NSMutableArray *allPosts;
@property NSInteger index;

@end
