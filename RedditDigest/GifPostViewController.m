//
//  GifPostViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "GifPostViewController.h"
#import "FLAnimatedImage.h"

@interface GifPostViewController ()

@end

@implementation GifPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.url]]];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
            imageView.animatedImage = image;
            CGRect screenRect =[[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            CGFloat screenHeight = screenRect.size.height;
            imageView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight/2);
            [self.view addSubview:imageView];
        });
    });
    [self.gifCommentsTableView reloadData];
}

@end
