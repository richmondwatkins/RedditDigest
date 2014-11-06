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

    if (self.selectedPost) {
        [self loadPageFromCoreData];
    }else{
        [self loadPageFromRKLink];
    }

}

-(void)loadPageFromCoreData{
    if (self.selectedPost.isImageLink.intValue == 1) {
        self.imageView.hidden = NO;
        self.imageView.image = [UIImage imageWithData:self.selectedPost.image];
        NSLog(@"IMAGE %@",self.imageView.image);
    }else if(self.selectedPost.isSelfPost != nil){
        self.textView.hidden = NO;
        self.textView.text = self.selectedPost.selfText;
    }else{
        self.webView.hidden = NO;
        NSData *data = [NSData dataWithContentsOfFile:[self cacheFile] options:0 error:nil];
        NSLog(@"Data %@",data);
        [self.webView loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:self.selectedPost.url]];
        NSString *currentURL = [self.webView stringByEvaluatingJavaScriptFromString:@"window.location"];
        NSLog(@"URL %@",currentURL);
    }

}

-(NSString*)cacheFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *string = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.selectedPost.title]];
    return string;
}

-(void)loadPageFromRKLink{
//    if (self.selectedLink.isImageLink) {
//        self.imageView.hidden = NO;
//        self.imageView.image = [UIImage imageWithData:self.selectedPost.image];
//        NSLog(@"IMAGE %@",self.imageView.image);
//    }else if(self.selectedPost.isSelfPost != nil){
//        self.textView.hidden = NO;
//        self.textView.text = self.selectedPost.selfText;
//    }else{
//        self.webView.hidden = NO;
//        [self.webView loadHTMLString:[self.selectedPost.html stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"] baseURL:nil];
//    }
}


@end
