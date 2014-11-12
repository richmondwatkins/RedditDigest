//
//  IndividualPostViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "ImagePostViewController.h"

@implementation ImagePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        UIImage *image = [UIImage imageWithData:self.imageData];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.imageView.image = image;
        });
    });
}

@end
