//
//  SelfPostTextView.h
//  RedditDigest
//
//  Created by Richmond on 12/14/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelfPostTextView : UITextView

- (void)htmlToTextAndSetViewsText:(NSString *)htmlString;

@end
