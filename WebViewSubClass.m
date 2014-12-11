//
//  WebViewSubClass.m
//  RedditDigest
//
//  Created by Richmond on 12/11/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "WebViewSubClass.h"

@implementation WebViewSubClass

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"TOUCH");
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGPoint prevLocation = [touch previousLocationInView:self];

    if (location.y - prevLocation.y > 0 ) {
       NSLog(@"LEFTTTT");
    }else if (location.y - prevLocation.y < 0){
        NSLog(@"RIGHTTTT");

    }
}



@end
