//
//  IndividualPostViewController.h
//  RedditDigest
//
//  Created by Richmond on 11/7/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageWrapperViewController.h"
@interface ImagePostViewController : PageWrapperViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property NSData *imageData;
@end