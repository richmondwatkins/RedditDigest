//
//  CommentTableViewCell.h
//  Pods
//
//  Created by Richmond on 11/10/14.
//
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface CommentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIWebView *commentWebView;
@property (strong, nonatomic) IBOutlet UIButton *showMoreButton;
@property Comment *comment;

@property (strong, nonatomic) IBOutlet UITextView *textView;
@end

