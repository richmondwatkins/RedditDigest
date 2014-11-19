//
//  SubredditSelectionCollectionReusableView.m
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/5/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "HeaderCollectionReusableView.h"

@implementation HeaderCollectionReusableView

- (IBAction)hideKeyboardOnTapInHeaderView:(id)sender
{
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
}

@end
