//
//  ExpandedCommentViewController.m
//  Pods
//
//  Created by Richmond on 11/10/14.
//
//

#import "ExpandedCommentViewController.h"

@interface ExpandedCommentViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ExpandedCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadHTMLString:[self textToHtml:self.comment.body] baseURL:nil];
}

- (NSString*)textToHtml:(NSString*)string{

    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];

    return string;
}


@end
