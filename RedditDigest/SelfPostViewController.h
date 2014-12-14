//
//  SelfPostViewController.h
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageWrapperViewController.h"
#import "SelfPostTextView.h"
@interface SelfPostViewController : PageWrapperViewController

@property (strong, nonatomic) IBOutlet SelfPostTextView *textView;

@end
