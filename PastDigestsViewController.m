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
#import "ArchivedDigestTableViewCell.h"

@interface PastDigestsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *pastDigestTableView;
@property NSArray *digests;
@property NSArray *selectedDigestPosts;
@property NSCache *imageCache;
@property BOOL notificationsOn;
@end

@implementation PastDigestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self retrievePastDigestFromCoreData];

    UIApplication *application = [UIApplication sharedApplication];

    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        self.notificationsOn = [application isRegisteredForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType types = [application enabledRemoteNotificationTypes];
        self.notificationsOn = types & UIRemoteNotificationTypeAlert;
    }
}


-(void)retrievePastDigestFromCoreData{
    NSFetchRequest *fetchDigests = [[NSFetchRequest alloc] initWithEntityName:@"Digest"];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
    [fetchDigests setSortDescriptors:@[sorter]];

    NSArray *digests = [self.managedObject executeFetchRequest:fetchDigests error:nil];
    if (digests) {
        self.digests = digests;

        [self.pastDigestTableView reloadData];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (self.notificationsOn) {
        return self.digests.count;
    }else{
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    ArchivedDigestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DigestCell"];

    if (self.notificationsOn)
    {
        Digest *digest = [self.digests objectAtIndex:indexPath.row];

        NSArray *posts = [digest.digestPost allObjects];
        DigestPost *post = posts.firstObject;

        if ([post.image boolValue]) {
            cell.archiveImageView.image = [self returnImageForCellFromData:post.postID withSubredditNameForKey:post.subreddit andFilePathPrefix:@"image-copy"];
        }else if([post.thumbnailImagePath boolValue]){
            cell.archiveImageView.image = [self returnImageForCellFromData:post.postID withSubredditNameForKey:post.subreddit  andFilePathPrefix:@"thumbnail-copy"];
        }else if([post.subredditImage boolValue]){
            cell.archiveImageView.image = [self returnImageForCellFromData:post.subreddit withSubredditNameForKey:post.subreddit andFilePathPrefix:@"subreddit-copy"];
        }else{
            cell.archiveImageView.image = [UIImage imageNamed:@"snoo_camera_placeholder"];
        }
        cell.archiveImageView.clipsToBounds = YES;

        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[digest.time doubleValue]];

        NSDateFormatter *dateFormat =[[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"MMMM dd, yyyy - h:00"];
        NSString *dateText = [dateFormat stringFromDate:date];
        cell.archiveTitleLabel.text = dateText;
    }
    else {
        [cell setUserInteractionEnabled:NO];
        cell.archiveTitleLabel.text = @"Push notifications must be enabled to recieve archived digests";
    }
    cell.archiveTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;

    return cell;
}

-(UIImage *)returnImageForCellFromData:(NSString *)filePath withSubredditNameForKey:(NSString *)subreddit andFilePathPrefix:(NSString *)prefix{

    NSData *imageData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:filePath withPrefix:prefix]];
    UIImage *image = [UIImage imageWithData:imageData];

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

    NSDateFormatter *dateFormat =[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
    NSString *dateText = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:[selectedDigest.time doubleValue]]];

    digestController.oldDigestDate = dateText;
}

@end
