//
//  LoadingViewController.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/10/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "LoadingViewController.h"

@implementation LoadingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *imageNames = @[@"loading_snoo0000.png", @"loading_snoo0001.png", @"loading_snoo0002.png", @"loading_snoo0003.png",
                            @"loading_snoo0004.png", @"loading_snoo0005.png", @"loading_snoo0006.png", @"loading_snoo0007.png",
                            @"loading_snoo0008.png", @"loading_snoo0009.png", @"loading_snoo0010.png", @"loading_snoo0011.png"];

    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames.count; i++) {
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    }

    self.loadingImageView.animationImages = images;
    self.loadingImageView.animationDuration = 0.7;

    [self.loadingImageView startAnimating];

}

@end
