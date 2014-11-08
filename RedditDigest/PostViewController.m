//
//  PostViewController.m
//  Pods
//
//  Created by Richmond on 11/5/14.
//
//

#import "PostViewController.h"
#import "ImagePostViewController.h"
#import "WebPostViewController.h"
#import "GifPostViewController.h"
#import "SelfPostViewController.h"
#import "VideoPostViewController.h"
#import "PageWrapperViewController.h"
@interface PostViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    if (self.selectedPost) {
//        [self loadPageFromCoreData];
//    }

    [self setUpPageViewController];
}

-(void)setUpPageViewController{
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];

    PageWrapperViewController *initialViewController = [self viewControllerAtIndex:self.index];

    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];

    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    PageWrapperViewController *p = (PageWrapperViewController *)viewController;
    return [self viewControllerAtIndex:(p.index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    PageWrapperViewController *p = (PageWrapperViewController *)viewController;
    return [self viewControllerAtIndex:(p.index + 1)];
}




- (PageWrapperViewController *)viewControllerAtIndex:(NSInteger)index {

    if (index<0) {
        return nil;
    }
    if (index >= self.allPosts.count) {
        return nil;
    }

    Post *post = self.allPosts[index];
    NSLog(@"POST %@",post);
    if (post.isImageLink.intValue == 1) {
        ImagePostViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageView"];
        ivc.imageData = post.image;
        ivc.index = index;
        return ivc;
    }else if(post.isYouTube.intValue == 1){
        VideoPostViewController *vvc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoView"];
        vvc.url = post.url;
        vvc.index = index;
        return vvc;
    }else if(post.isGif.intValue == 1){
        GifPostViewController *gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"GifView"];
        gvc.url = post.url;
        gvc.index = index;
        return gvc;
    }else if(post.isSelfPost.integerValue ==1){
        SelfPostViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfPostView"];
        svc.selfPostText = post.selfText;
        svc.index = index;
        return svc;
    }else{
        WebPostViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
        wvc.urlString = post.url;
        wvc.index = index;
        return wvc;
    }
}


@end
