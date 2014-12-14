//
//  SelfPostTextView.m
//  RedditDigest
//
//  Created by Richmond on 12/14/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "SelfPostTextView.h"

@implementation SelfPostTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)htmlToTextAndSetViewsText:(NSString *)htmlString{

    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&quot;" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&apos;" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&amp;" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&lt;" withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&gt;" withString:@""];

    self.text = htmlString;
}
@end
