//
//  VideoPostViewController.h
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPostViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *videoView;
@property NSString *url;
@end
