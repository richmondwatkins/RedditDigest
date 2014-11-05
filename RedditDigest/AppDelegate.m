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

@interface AppDelegate ()
@property NSString *token;
@property (nonatomic, strong) NSString *temperature;
@property NSString *deviceString;
@property NSMutableArray *posts;

@end

@implementation AppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    NSLog(@"%@", BaseURL);

    [ZeroPush engageWithAPIKey:@"PM4ouAj1rzxmQysu5ej6" delegate:self];
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
         [[ZeroPush shared] registerForRemoteNotifications];

    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];

    [application registerForRemoteNotifications];
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)tokenData
{
    [[ZeroPush shared] registerDeviceToken:tokenData];
    self.token = [ZeroPush deviceTokenFromData:tokenData];
    [self registerDeviceForPushNotifications];
}

-(void)registerDevice{
    NSString* deviceURLString = @"http://192.168.1.4:3000/register/device";
    NSURL *url = [[NSURL alloc] initWithString:[deviceURLString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSError *error;
    NSDictionary *deviceIdDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.deviceString, @"deviceid", nil];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:deviceIdDictionary options:0 error:&error];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error from device registration %@",error);
        }
    }];
    [dataTask resume];
}


-(void)registerDeviceForPushNotifications{

    NSString* urlString = @"http://192.168.1.4:3000/register/push";
//    NSString* urlString = @"http://192.168.129.228:3000/register/push";

    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    NSError *error;
    NSDictionary *tokenDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.token, @"token", self.deviceString, @"deviceid", nil];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tokenDictionary options:0 error:&error];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];

    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Push Notification Error: %@",error);
        }
    }];
    [dataTask resume];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    DigestViewController *digestController = (DigestViewController *)navigationController.topViewController;
    digestController.managedObjectContext = self.managedObjectContext;


    [self showWelcomeViewOrDigestView];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    [self reloadFromCoreDataOrFetch:digestController];

// WE NEED THIS:   if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
    NSUUID *deviceID = [UIDevice currentDevice].identifierForVendor;
    self.deviceString = [NSString stringWithFormat:@"%@", deviceID];
    [self registerDevice];
//    }

    return YES;
}

-(void)reloadFromCoreDataOrFetch:(DigestViewController *)digestController{
    NSCalendar* myCalendar = [NSCalendar currentCalendar];
    NSDateComponents* morningComponents = [myCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                 fromDate:[NSDate date]];
    [morningComponents setHour: 2];
    [morningComponents setMinute: 0];
    [morningComponents setSecond: 0];
    NSDate *morningDigest = [myCalendar dateFromComponents:morningComponents];

    NSDateComponents *eveningComponents = [myCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                 fromDate:[NSDate date]];
    [eveningComponents setHour: 18];
    [eveningComponents setMinute: 0];
    [eveningComponents setSecond: 0];
    NSDate *eveningDigest = [myCalendar dateFromComponents:eveningComponents];

    NSDate *lastDigest = [[NSUserDefaults standardUserDefaults] valueForKey:@"LastDigest"];

    if([[NSDate date] compare: lastDigest] == NSOrderedDescending && [lastDigest compare: morningDigest] == NSOrderedDescending){
//        [digestController retrievePostsFromCoreData];
        [digestController requestNewLinks];

    }else if([[NSDate date] compare: eveningDigest] == NSOrderedDescending && [lastDigest compare: eveningDigest] == NSOrderedDescending){
//        [digestController retrievePostsFromCoreData];
        [digestController requestNewLinks];


    }else{
        [digestController requestNewLinks];

    }
}

- (void)showWelcomeViewOrDigestView
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
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

    handler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


-(void) application:(UIApplication *)application performFetchWithCompletionHandler: (void (^)(UIBackgroundFetchResult))completionHandler {
    DigestViewController *digestViewController = [(id)self.window.rootViewController viewControllers][0];
    [digestViewController fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
    }];

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
