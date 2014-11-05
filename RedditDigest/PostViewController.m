//
//  PostViewController.m
//  Pods
//
//  Created by Richmond on 11/5/14.
//
//

#import "PostViewController.h"

@interface PostViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"IN DETAIL VIEW %@",self.selectedPost);

    if (self.selectedPost.isImageLink.intValue == 1) {
        self.imageView.hidden = NO;
        self.imageView.image = [UIImage imageWithData:self.selectedPost.image];
        NSLog(@"IMAGE %@",self.imageView.image);
    }else if(self.selectedPost.isSelfPost != nil){
        self.textView.hidden = NO;
        self.textView.text = self.selectedPost.selfText;
    }else{
        self.webView.hidden = NO;
        [self.webView loadHTMLString:[self.selectedPost.html stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"] baseURL:nil];
    }


}


@end
