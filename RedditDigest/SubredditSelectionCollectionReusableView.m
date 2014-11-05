//
//  SubredditSelectionCollectionReusableView.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/5/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SubredditSelectionCollectionReusableView.h"

@implementation SubredditSelectionCollectionReusableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.textField addTarget:self action:@selector(tellDelegateToAddSubreddit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    return self;
}

- (void)tellDelegateToAddSubreddit:(id)sender
{
    [self.delegate searchForSubreddit:self.textField sender:sender];
}

@end
