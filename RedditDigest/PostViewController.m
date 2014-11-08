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

    UIViewController *initialViewController = [self viewControllerAtIndex];

    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];

    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    --self.index;

    if (self.index == 0) {
        return nil;
    }

    return [self viewControllerAtIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    ++self.index;


    if (self.index == self.allPosts.count) {
        return nil;
    }

    return [self viewControllerAtIndex];
}


- (UIViewController *)viewControllerAtIndex {
    NSLog(@"%i",self.index);
    Post *post = self.allPosts[self.index];
//    NSLog(@"POST %@",post);
    if (post.isImageLink.intValue == 1) {
        ImagePostViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageView"];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            UIImage *image = [UIImage imageWithData:post.image];
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        ivc.imageView.image = image;
                    });
                });
        return ivc;
    }else if(post.isYouTube.intValue == 1){
        VideoPostViewController *vvc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoView"];
        vvc.url = post.url;
        return vvc;
    }else if(post.isGif.intValue == 1){
        GifPostViewController *gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"GifView"];
        gvc.url = post.url;
        return gvc;
    }else if(post.isSelfPost.integerValue == 1){
          SelfPostViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfPostView"];
        svc.selfPostText = post.selfText;
        return svc;
    }else{
        WebPostViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
        wvc.urlString = post.url;
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



@end
