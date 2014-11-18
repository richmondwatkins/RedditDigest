//
//  PastDigestsViewController.m
//  RedditDigest
//
//  Created by Richmond on 11/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "PastDigestsViewController.h"
#import "Digest.h"
#import "DigestViewController.h"
@interface PastDigestsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *pastDigestTableView;
@property NSArray *digests;
@property NSArray *selectedDigestPosts;
@end

@implementation PastDigestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self retrievePastDigestFromCoreData];
}


-(void)retrievePastDigestFromCoreData{
    NSFetchRequest *fetchDigests = [[NSFetchRequest alloc] initWithEntityName:@"Digest"];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    [fetchDigests setSortDescriptors:@[sorter]];

    NSArray *digests = [self.managedObject executeFetchRequest:fetchDigests error:nil];
    if (digests) {
        self.digests = digests;
        [self.pastDigestTableView reloadData];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.digests.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DigestCell"];
    Digest *digest = [self.digests objectAtIndex:indexPath.row];

    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[digest.time doubleValue]];

    NSDateFormatter *dateFormat =[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];

    cell.textLabel.text = [dateFormat stringFromDate:date];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    DigestViewController *digestController = segue.destinationViewController;
    NSIndexPath *indexPath = [self.pastDigestTableView indexPathForSelectedRow];
    Digest *selectedDigest = [self.digests objectAtIndex:indexPath.row];

    digestController.oldDigest = [selectedDigest.digestPost allObjects];
    digestController.isFromPastDigest = YES;
}

@end
