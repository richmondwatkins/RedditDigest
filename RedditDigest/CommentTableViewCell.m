//
//  CommentTableViewCell.m
//  Pods
//
//  Created by Richmond on 11/10/14.
//
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

@synthesize textView = _textView;

//-(instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    if (self = [super initWithCoder:aDecoder]) {
//        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//    }
//    return self;
//}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


//-(void)setTextView:(UITextView *)textView{
//    _textView = textView;
//}
//
//-(UITextView*)textView{
//    return _textView;
//}

@end
