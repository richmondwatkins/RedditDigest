//
//  WebViewOverlayTouchIntercept.h
//  RedditDigest
//
//  Created by Richmond on 12/10/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebViewTouchIntercepts <NSObject>

-(void)sendTouchToWebView:(NSSet *)touches withEven:(UIEvent *)event;
-(void)aTouchBegan:(NSSet *)touches withEven:(UIEvent *)event;
-(void)aTouchEnded:(NSSet *)touches withEven:(UIEvent *)event;
-(void)aTouchCancled:(NSSet *)touches withEven:(UIEvent *)event;


@end

@interface WebViewOverlayTouchIntercept : UIView

@property id <WebViewTouchIntercepts> delegate;

@end
