//
//  AppDelegate.m
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"
#import "ItemDetailsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"oqM758m32dGwvjzOwwm5SP4yWTBFeteAPfX7U0Sq"
                  clientKey:@"nuCQvRTW9s4TK9pscWpq0ZVShQKHtUjmwYDJEIcE"];

    [PFFacebookUtils initializeWithApplicationId:@"100901256728525"];

    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert ];
    
    // Obtain the installation object for the current device
    PFInstallation *myInstallation = [PFInstallation currentInstallation];
    [myInstallation saveInBackground];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    UINavigationController *navigationController  = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    [navigationController setNavigationBarHidden:YES];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    
    
    //handling startup when launched from remote notification
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [self processRemoteNotification:userInfo];
    }
    
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    [PFPush storeDeviceToken:newDeviceToken]; // Send parse the device token
    // Subscribe this user to the broadcast channel, ""
    [[PFInstallation currentInstallation] addUniqueObject:@"" forKey:@"channels"];
    [[PFInstallation currentInstallation] saveEventually];
}

#pragma mark Push Notification methods

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //    [PFPush handlePush:userInfo];- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if ( application.applicationState == UIApplicationStateActive ) {
        // app was already in the foreground
        
    }
    else {
        // app was just brought from background to foreground
        [self processRemoteNotification:userInfo];
    }
}

- (void)processRemoteNotification:(NSDictionary*)userInfo {
    
    NSLog(@"Processing remote notification with userInfo: %@", userInfo);
    
    //if item_id comes in, show that item's page
    NSString *itemId = [userInfo objectForKey:@"item_id"];
    NSLog(@"itemId: %@", itemId);

    
    if( itemId != NULL)
    {
        //item notification (new comment, or something else in the future)
        
        PFQuery *queryItem = [PFQuery queryWithClassName:DB_TABLE_ITEMS];
        PFObject *item = [queryItem getObjectWithId:itemId];
        
        ItemDetailsViewController *itemDetailsViewController = [[ItemDetailsViewController alloc] initWithNibName:@"ItemDetailsViewController" bundle:nil];
        [itemDetailsViewController setItemObject:item];
        
        UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
        [navigationController pushViewController:itemDetailsViewController animated:YES];
    }
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [PFFacebookUtils handleOpenURL:url];
}

#pragma mark Unused signatured methods

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
