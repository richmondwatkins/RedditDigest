//
//  VideoPostViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "VideoPostViewController.h"

@interface VideoPostViewController ()

@end

@implementation VideoPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    CGRect screenRect =[[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSString* embedHTML = [NSString stringWithFormat:@"\
                           <html>\
                           <body style='margin:0px;padding:0px;'>\
                           <script type='text/javascript' src='http://www.youtube.com/iframe_api'></script>\
                           <iframe id='playerId' type='text/html' width='%f' height='%f' src='http://%@?enablejsapi=1&rel=0&playsinline=1&autoplay=1' frameborder='0'>\
                           </body>\
                           </html>", screenWidth, screenHeight/2, self.url];
    [self.videoView loadHTMLString:embedHTML baseURL:[[NSBundle mainBundle] resourceURL]];
    [self.videoCommentsTableView reloadData];
}

@end
