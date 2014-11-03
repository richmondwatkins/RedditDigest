//
//  CategoryViewController.m
//  RedditDigest
//
//  Created by Christopher on 11/3/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "CategoryViewController.h"

@interface CategoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property NSArray *categories;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.categories = [NSArray arrayWithObjects:@"fashion", @"beauty",@"health",@"US news",@"global news",@"politics",@"technology",@"film",@"science",@"humor",@"world explorer",@"books",@"business & finance",@"music",@"art & design",@"history",@"the future",@"surprise me!",@"offbeat",@"cooking",@"sports",@"geek",@"green",@"adventure", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Delegate Protocols

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:(@"CVCell") forIndexPath:indexPath];
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
