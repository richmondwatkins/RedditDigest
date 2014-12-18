//
//  SettingsViewController.h
//  RedditDigest
//
//  Created by Taylor Wright-Sanson on 11/4/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DigestViewController.h"

@interface SettingsViewController : UITableViewController 
@property NSManagedObjectContext *managedObject;
@property BOOL isFromSettings;
@property DigestViewController *digestViewController;
@end
