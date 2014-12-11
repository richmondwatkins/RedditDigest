//
//  WebViewOverlayTouchIntercept.m
//  RedditDigest
//
//  Created by Richmond on 12/10/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "WebViewOverlayTouchIntercept.h"
@interface WebViewOverlayTouchIntercept ()
@property CGFloat scrollPosition;
@end

@implementation WebViewOverlayTouchIntercept

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"TOUCH");
    [self.delegate aTouchBegan:touches withEven:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGPoint prevLocation = [touch previousLocationInView:self];

    if (location.y - prevLocation.y > 0 ) {
        self.scrollPosition -= location.y;
        [self.delegate sendTouchToWebView:touches withEven:event];
    }else if (location.y - prevLocation.y < 0){
        self.scrollPosition += location.y;
        [self.delegate sendTouchToWebView:touches withEven:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate aTouchEnded:touches withEven:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate aTouchCancled:touches withEven:event];
}

@end
