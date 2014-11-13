//
//  CommentTableViewCell.h
//  Pods
//
//  Created by Richmond on 11/10/14.
//
//

#import <UIKit/UIKit.h>
#import "Comment.h"

//static UITextView *_textView;

@interface CommentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIWebView *commentWebView;
@property Comment *comment;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

