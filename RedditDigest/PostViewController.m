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
#import "Comment.h"
#import "ChildComment.h"
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
    NSArray *allComments = [self commentSorter:[post.comments allObjects]];
    NSMutableArray *parentChildComments = [self matchChildCommentsToParent:allComments];

    PageWrapperViewController *viewController;
    if (post.isImageLink.intValue == 1) {
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageView"];
        viewController.imageData = post.image;
    }else if(post.isYouTube.intValue == 1){
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoView"];
        viewController.url = post.url;
    }else if(post.isGif.intValue == 1){
        viewController =[self.storyboard instantiateViewControllerWithIdentifier:@"GifView"];
        viewController.url = post.url;
    }else if(post.isSelfPost.integerValue == 1){
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfPostView"];
        viewController.selfPostText = post.selfText;
    }else{
        viewController =[self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
        viewController.url = post.url;
    }

    viewController.comments = parentChildComments;
    viewController.index = index;
    return viewController;
}

-(NSArray *)commentSorter:(NSArray *)comments{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

    return [comments sortedArrayUsingDescriptors:sortDescriptors];
}

-(NSMutableArray *)matchChildCommentsToParent:(NSArray *)parentComments{
    NSMutableArray *matchedComments = [NSMutableArray array];

    for(Comment *comment in parentComments){
        NSArray *childComments = [self commentSorter:[comment.childcomments allObjects]];
        NSDictionary *parentChildComment = [[NSDictionary alloc] initWithObjectsAndKeys:comment, @"parent", childComments, @"children", nil];
        [matchedComments addObject:parentChildComment];
    }

        return matchedComments;
}


@end
