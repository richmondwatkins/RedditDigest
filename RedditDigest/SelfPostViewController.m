//
//  SelfPostViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SelfPostViewController.h"

@interface SelfPostViewController ()

@end

@implementation SelfPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // This makes sure each self post is scrolled to the top when it loads
    [self.textView scrollRangeToVisible:NSMakeRange(0, 1)];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.textView.text = self.selfPostText;
    NSLog(@"TV %@",self.textView.text);
}

@end
