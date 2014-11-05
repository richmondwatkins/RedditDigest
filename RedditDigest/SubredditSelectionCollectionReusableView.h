//
//  SubredditSelectionCollectionReusableView.h
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/5/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SubredditSelectionCollectionViewHeaderDelegate <NSObject>

- (void)searchForSubreddit:(UITextField *)textField sender:(id)sender;

@end

@interface SubredditSelectionCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property id<SubredditSelectionCollectionViewHeaderDelegate>delegate;

@end
