//
//  AppDelegate.m
//  RedditDigest
//
//  Created by Richmond on 11/1/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "AppDelegate.h"
#import <ZeroPush.h>

//
//  AppDelegate.m
//  RedditDigest
//
//  Created by Richmond on 11/1/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "AppDelegate.h"
#import <ZeroPush.h>
#import "DigestViewController.h"
#import <SSKeychain/SSKeychain.h>
#import <RedditKit/RedditKit.h>
#import "UserRequests.h"
#import "Digest.h"
@interface AppDelegate ()
@property (nonatomic, strong) NSString *temperature;
@property NSString *deviceString;
@property NSMutableArray *posts;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    DigestViewController *digestController = (DigestViewController *)navigationController.topViewController;
    digestController.managedObjectContext = self.managedObjectContext;

    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceID"]) {
        [self performFirstTimeUserMethods];
    }else{
        [self reloadFromCoreDataOrFetch:digestController];
    }


    [self setUpUI];

    [self showWelcomeViewOrDigestView];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)setUpUI
{
    // #336699 - reddit dark blue
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.2 green:0.4 blue:0.6 alpha:1]];
    // Nav bar buttons white
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    // White nav bar text color - font Helvetica Neue Regular
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      NSFontAttributeName : [UIFont fontWithName:@"Avenir-Medium" size:18.0]}];
    [[UINavigationBar appearance] setTranslucent:NO];

    // White status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)tokenData
{
    [[ZeroPush shared] registerDeviceToken:tokenData];
    NSString *token = [ZeroPush deviceTokenFromData:tokenData];
    [UserRequests registerDeviceForPushNotifications:token];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{

    NSCalendar *morningCalendar = [NSCalendar currentCalendar];
    NSDateComponents *morningComponents = [[NSDateComponents alloc] init];
    [morningComponents setHour: 8];
    [morningComponents setMinute: 0];
    [morningComponents setSecond: 0];
    [morningComponents setTimeZone: [NSTimeZone defaultTimeZone]];
    NSDate *morningDigest= [morningCalendar dateFromComponents:morningComponents];

    UILocalNotification* morningNotification = [[UILocalNotification alloc] init];
    morningNotification.fireDate = morningDigest;
    morningNotification.timeZone = [NSTimeZone defaultTimeZone];
    morningNotification.repeatInterval = NSCalendarUnitDay;
    morningNotification.alertBody = @"Your reddit digest is ready for viewing";
    morningNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:morningNotification];

    NSCalendar *afternoonCalendar = [NSCalendar currentCalendar];
    NSDateComponents *afternoonComponents = [[NSDateComponents alloc] init];
    [afternoonComponents setHour: 18];
    [afternoonComponents setMinute: 0];
    [afternoonComponents setSecond: 0];
    [afternoonComponents setTimeZone: [NSTimeZone defaultTimeZone]];
    NSDate *afternoonDigest = [afternoonCalendar dateFromComponents:afternoonComponents];

    UILocalNotification* afternoonNotification = [[UILocalNotification alloc] init];
    afternoonNotification.fireDate = afternoonDigest;
    afternoonNotification.timeZone = [NSTimeZone defaultTimeZone];
    afternoonNotification.repeatInterval = NSCalendarUnitDay;
    afternoonNotification.alertBody = @"Your reddit digest is ready for viewing";
    afternoonNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:afternoonNotification];

}


-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}


-(void)reloadFromCoreDataOrFetch:(DigestViewController *)digestController{

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Digest"];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    [fetchRequest setSortDescriptors:@[sorter]];

    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

    if (results.count) {
        Digest *lastDigest = results.firstObject;

        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];

        if (currentTime - 3600000 > lastDigest.time.doubleValue) {
            [digestController requestNewLinks:YES];
        }else{
            [digestController performNewFetchedDataActions:YES];
        }
    }
}

-(void)performFirstTimeUserMethods{
    CFUUIDRef uuidObject = CFUUIDCreate(NULL);

    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuidObject);
    CFRelease(uuidObject);

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:uuidStr forKey:@"DeviceID"];

    [userDefaults synchronize];
    [UserRequests registerDevice:uuidStr];
}


- (void)showWelcomeViewOrDigestView
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceID"])
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasRedditAccount"])
        {
            NSArray *array = [SSKeychain accountsForService:@"friendsOfSnoo"];
            NSDictionary *accountInfoDictionary = array.firstObject;
            NSString *username = accountInfoDictionary[@"acct"];
            NSString *password = [SSKeychain passwordForService:@"friendsOfSnoo" account:username];

            [[RKClient sharedClient] signInWithUsername:accountInfoDictionary[@"acct"] password:password completion:^(NSError *error) {
                if (!error)
                {
                    NSLog(@"Successfully signed in!");

                    /* // Richmond, uncomment this to get what you need after the user logs in correctly
                     [[RKClient sharedClient] subscribedSubredditsWithCompletion:^(NSArray *collection, RKPagination *pagination, NSError *error) {

                     RKSubreddit *subreddit = collection.firstObject;

                     [[RKClient sharedClient] linksInSubreddit:subreddit pagination:nil completion:^(NSArray *links, RKPagination *pagination, NSError *error) {
                     //                    NSLog(@"Links: %@", links);
                     [[RKClient sharedClient] upvote:links.firstObject completion:^(NSError *error) {
                     NSLog(@"Upvoted the link!");
                     }];
                     }];

                     }];
                     */
                }
                else
                {
                   
                }
            }];
        }
        else
        {
            // Get information about user who has no account. Unique ID? Generate content.
            NSLog(@"User Has no reddit account, but that's cool we'll just give them the content they requested the first time they setup the app. Bam!");
        }
    }
    else
    {
        
        // This is the first launch ever -- ooooo
    }
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler{
    DigestViewController *digestViewController = [(id)self.window.rootViewController viewControllers][0];
    [digestViewController fetchNewData:YES withCompletion:^(UIBackgroundFetchResult result) {
        handler(result);
    }];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DigestViewController *digestViewController = [(id)self.window.rootViewController viewControllers][0];
    [self reloadFromCoreDataOrFetch:digestViewController];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


-(void) application:(UIApplication *)application performFetchWithCompletionHandler: (void (^)(UIBackgroundFetchResult))completionHandler {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"BackgroundFetch"]) {
        completionHandler(UIBackgroundFetchResultNoData);
    }else{
        DigestViewController *digestViewController = [(id)self.window.rootViewController viewControllers][0];
        digestViewController.managedObjectContext = self.managedObjectContext;
        [digestViewController fetchNewData:NO withCompletion:^(UIBackgroundFetchResult result) {
            completionHandler(YES);
        }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com-greekconnect.RedditDigest" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RedditDigest" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RedditDigest.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
