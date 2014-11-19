//
//  WelcomeButtons.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/8/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];

    if (highlighted) {
        self.layer.borderColor = [UIColor colorWithRed:0.894 green:0.894 blue:0.894 alpha:1].CGColor;
        }
    else {
        self.layer.borderColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1].CGColor;
    }
}

@end
