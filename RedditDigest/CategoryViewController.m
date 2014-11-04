//
//  CategoryViewController.m
//  RedditDigest
//
//  Created by Christopher on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "CategoryViewController.h"
#import "CategoryCustomCollectionViewCell.h"

@interface CategoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property NSArray *categories;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property UICollectionViewFlowLayout *flowLayout;


@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.categories = [NSArray arrayWithObjects:@"fashion", @"beauty",@"health",@"US news",@"global news",@"politics",@"technology",@"film",@"science",@"humor",@"world explorer",@"books",@"business & finance",@"music",@"art & design",@"history",@"the future",@"surprise me!",@"offbeat",@"cooking",@"sports",@"geek",@"green",@"adventure", nil];

    // Configure layout
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [self.flowLayout setItemSize:CGSizeMake(90, 100)];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.flowLayout.minimumInteritemSpacing = 0.0f;
    self.flowLayout.minimumLineSpacing = 0.0f;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    self.collectionView.bounces = YES;
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    [self.collectionView setShowsVerticalScrollIndicator:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Delegate Protocols

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.categories.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:(@"CVCell") forIndexPath:indexPath];
    [cell.categoryLabel sizeToFit];
    cell.categoryLabel.text = self.categories[indexPath.row];
    return cell;
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
