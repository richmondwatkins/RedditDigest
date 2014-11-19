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
#import "DigestPost.h"
@interface PastDigestsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *pastDigestTableView;
@property NSArray *digests;
@property NSArray *selectedDigestPosts;
@property NSCache *imageCache;

@end

@implementation PastDigestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self retrievePastDigestFromCoreData];
    self.imageCache = [[NSCache alloc] init];
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

    NSArray *posts = [digest.digestPost allObjects];
    DigestPost *post = posts.firstObject;

    if ([post.image boolValue]) {
        cell.imageView.image = [self returnImageForCellFromData:post.postID withSubredditNameForKey:post.subreddit andFilePathPrefix:@"image-copy"];
    }else if([post.thumbnailImagePath boolValue]){
         cell.imageView.image = [self returnImageForCellFromData:post.postID withSubredditNameForKey:post.subreddit  andFilePathPrefix:@"thumbnail-copy"];
    }else if([post.subredditImage boolValue]){
         cell.imageView.image = [self returnImageForCellFromData:post.subreddit withSubredditNameForKey:post.subreddit andFilePathPrefix:@"subreddit-copy"];
    }else{
         cell.imageView.image = [UIImage imageNamed:@"snoo_camera_placeholder"];
    }

    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[digest.time doubleValue]];

    NSDateFormatter *dateFormat =[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];

    cell.textLabel.text = [dateFormat stringFromDate:date];
    return cell;
}

-(UIImage *)returnImageForCellFromData:(NSString *)filePath withSubredditNameForKey:(NSString *)subreddit andFilePathPrefix:(NSString *)prefix{
    UIImage *image = [self.imageCache objectForKey:subreddit];
    if (image == nil) {
        NSData *imageData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:filePath withPrefix:prefix]];
        image = [UIImage imageWithData:imageData];
        [self.imageCache setObject:image forKey:subreddit];
    }
    return image;
}

- (NSString *)documentsPathForFileName:(NSString *)name withPrefix:(NSString *)prefix
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];

    NSString *pathCompenent = [NSString stringWithFormat:@"%@-%@",prefix, name];
    return [documentsPath stringByAppendingPathComponent:pathCompenent];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    DigestViewController *digestController = segue.destinationViewController;
    NSIndexPath *indexPath = [self.pastDigestTableView indexPathForSelectedRow];
    Digest *selectedDigest = [self.digests objectAtIndex:indexPath.row];

    digestController.oldDigest = [selectedDigest.digestPost allObjects];
    digestController.isFromPastDigest = YES;
}

@end
