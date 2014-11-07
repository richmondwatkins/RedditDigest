//
//  PostViewController.m
//  Pods
//
//  Created by Richmond on 11/5/14.
//
//

#import "PostViewController.h"
#import "FLAnimatedImage.h"

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
    }
}

-(void)loadPageFromCoreData{
    if (self.selectedPost.isImageLink.intValue == 1) {
        self.imageView.hidden = NO;
        self.imageView.image = [UIImage imageWithData:self.selectedPost.image];
        NSLog(@"IMAGE %@",self.imageView.image);
        [self prepareAndDisplayGif];
    }else if(self.selectedPost.isSelfPost != nil){
        self.textView.hidden = NO;
        self.textView.text = self.selectedPost.selfText;
    }
    else if(self.selectedPost.isGif.intValue == 1){
        [self prepareAndDisplayGif];
    }else{
        self.webView.hidden = NO;
        [self.webView setAllowsInlineMediaPlayback:YES];
        [self.webView setMediaPlaybackRequiresUserAction:YES];

        if (self.selectedPost.isYouTube) {
            [self embedYouTubePlayer];
        }else{
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.selectedPost.url]];
            [self.webView loadRequest:request];
        }

    }

}


-(void)embedYouTubePlayer{
    NSString* embedHTML = [NSString stringWithFormat:@"\
                           <html>\
                           <body style='margin:0px;padding:0px;'>\
                           <script type='text/javascript' src='http://www.youtube.com/iframe_api'></script>\
                           <iframe id='playerId' type='text/html' width='%d' height='%d' src='http://%@?enablejsapi=1&rel=0&playsinline=1&autoplay=1' frameborder='0'>\
                           </body>\
                           </html>", 300, 200, self.selectedPost.url];
    [self.webView loadHTMLString:embedHTML baseURL:[[NSBundle mainBundle] resourceURL]];
}

-(void)prepareAndDisplayGif{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectedPost.url]]];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
            imageView.animatedImage = image;
            CGRect screenRect =[[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            CGFloat screenHeight = screenRect.size.height;
            imageView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight/2);
            [self.view addSubview:imageView];
        });
    });
}

@end
