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

@property Comment *comment;
@property (strong, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *hiddenLabelForCellSize;

@end

