//
//  PostViewController.m
//  Pods
//
//  Created by Richmond on 11/5/14.
//
//

#import "PostViewController.h"
#import "FLAnimatedImage.h"
#import "ImagePostViewController.h"
#import "WebPostViewController.h"
#import "GifPostViewController.h"
#import "SelfPostViewController.h"
#import "VideoPostViewController.h"
@interface PostViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"IN DETAIL VIEW %@",self.selectedPost);

//    if (self.selectedPost) {
//        [self loadPageFromCoreData];
//    }

    [self setUpPageViewController];
}

-(void)setUpPageViewController{
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];

    UIViewController *initialViewController = [self viewControllerAtIndex];

    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];

    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    self.index--;

    if (self.index == 0) {
        return nil;
    }

    return [self viewControllerAtIndex];

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    self.index++;

    if (self.index == self.allPosts.count) {
        return nil;
    }

    return [self viewControllerAtIndex];

}

- (UIViewController *)viewControllerAtIndex {
    
    Post *post = self.allPosts[self.index];
    NSLog(@"POST %@",post);
    if (post.isImageLink.intValue == 1) {
        ImagePostViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageView"];
        return ivc;
    }else if(post.isYouTube.intValue == 1){
        VideoPostViewController *vvc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoView"];
        return vvc;
    }else if(post.isGif.intValue == 1){
        GifPostViewController *gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"GifView"];
        return gvc;
    }else if(post.isSelfPost.integerValue ==1){
          SelfPostViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfPostView"];
        return svc;
    }else{
        WebPostViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
        return wvc;
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return self.allPosts.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}


//
//-(void)loadPageFromCoreData{
//    if (self.selectedPost.isImageLink.intValue == 1) {
//        self.imageView.hidden = NO;
//        self.imageView.image = [UIImage imageWithData:self.selectedPost.image];
//        NSLog(@"IMAGE %@",self.imageView.image);
//        [self prepareAndDisplayGif];
//    }else if(self.selectedPost.isSelfPost != nil){
//        self.textView.hidden = NO;
//        self.textView.text = self.selectedPost.selfText;
//    }
//    else if(self.selectedPost.isGif.intValue == 1){
//        [self prepareAndDisplayGif];
//    }else{
//        self.webView.hidden = NO;
//        [self.webView setAllowsInlineMediaPlayback:YES];
//        [self.webView setMediaPlaybackRequiresUserAction:YES];
//
//        if (self.selectedPost.isYouTube) {
//            [self embedYouTubePlayer];
//        }else{
//            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.selectedPost.url]];
//            [self.webView loadRequest:request];
//        }
//
//    }
//
//}
//
//
//-(void)embedYouTubePlayer{
//    NSString* embedHTML = [NSString stringWithFormat:@"\
//                           <html>\
//                           <body style='margin:0px;padding:0px;'>\
//                           <script type='text/javascript' src='http://www.youtube.com/iframe_api'></script>\
//                           <iframe id='playerId' type='text/html' width='%d' height='%d' src='http://%@?enablejsapi=1&rel=0&playsinline=1&autoplay=1' frameborder='0'>\
//                           </body>\
//                           </html>", 300, 200, self.selectedPost.url];
//    [self.webView loadHTMLString:embedHTML baseURL:[[NSBundle mainBundle] resourceURL]];
//}
//
//-(void)prepareAndDisplayGif{
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectedPost.url]]];
//        dispatch_async(dispatch_get_main_queue(), ^(void){
//            FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
//            imageView.animatedImage = image;
//            CGRect screenRect =[[UIScreen mainScreen] bounds];
//            CGFloat screenWidth = screenRect.size.width;
//            CGFloat screenHeight = screenRect.size.height;
//            imageView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight/2);
//            [self.view addSubview:imageView];
//        });
//    });
//}

@end
