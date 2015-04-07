//
//  AppDelegate.m
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "MasterViewController.h"
#import "CollectorSignatureViewController.h"
#import "VourcherOverviewController.h"
#import "LoginViewController.h"
#import "AFNetworking.h"
#import "Crouton.h"

#import "TowingVoucher+Model.h"
#import "Vehicle+Model.h"

#import "SharedPreferences.h"


#define ALERT_BODY_REGISTRATION_NOTIFICATIONS_FAILED    @"Er is een fout opgetreden bij het registreren van dit toestel bij APNS. Probeer later opnieuw."
//NSLocalizedString(@"ERROR_COULD_NOT_REGISTER_FOR_REMOTE_NOTIFICATIONS", nil)

#define NOTIFICATION_ACTION_KEY                 @"ACTION"
#define ACTION_COLLECTOR_SIGNATURE              @"COLLECTOR_SIGNATURE"
#define ACTION_TOWING_UPDATED_FOR_VOUCHER       @"TOWING_UPDATED_FOR_VOUCHER"
#define COLLECTOR_SIGNATURE_STORYBOARD          @"collectorSignatureStoryBoard"
#define VOUCHER_OVERVIEW_STORYBOARD             @"towingVoucherOverviewStoryBoard"
#define LOGIN_STORYBOARD                        @"loginStoryBoard"


@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //to check if the notifications are enabled:
    //UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    
#ifdef __IPHONE_8_0
    //Right, that is the point
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                         |UIUserNotificationTypeSound
                                                                                         |UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#else
    //register to receive notifications
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
#endif
    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(notification)
    {
        [self processNotification:notification.userInfo];
    }
    
    
    return YES;
}

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    // Override point for customization after application launch.
////    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
////    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
////    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
////    splitViewController.delegate = self;
////
////    UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
////    MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
////    controller.managedObjectContext = self.managedObjectContext;
//    return YES;
//}

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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

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
    // The directory the application uses to store the Core Data store file. This code uses a directory named "be.towing.app.towing" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"towing" withExtension:@"momd"];
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
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"towing.sqlite"];
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




# pragma mark - Process Push Notifications
#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    //change received token to NSString, strip ' ', '<' and '>'
    NSString *token = [deviceToken description];
    //token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    //token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if([SharedPreferences fetchRegistrationId]) {
        NSLog(@"  --> Device token was already registerd in the preferences");
        //let see if it is equal
        
        if([[SharedPreferences fetchRegistrationId] isEqualToString:token]) {
            NSLog(@"  --> Device token hasn't changed!");
        } else {
            NSLog(@"  --> Device token has changed since last usage. Maybe reset?");
            [SharedPreferences storeRegistrationId:token];
        }
    } else {
        NSLog(@"  --> Device token was not yet set, saving it to the User Defaults");
        
        [SharedPreferences storeRegistrationId:token];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
    
    if([SharedPreferences fetchRegistrationId] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE_ERROR
                                                        message:ALERT_BODY_REGISTRATION_NOTIFICATIONS_FAILED
                                                       delegate:self
                                              cancelButtonTitle:ALERT_BUTTON_CANCEL
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self processNotification:userInfo];
}

- (void) processNotification:(NSDictionary *) userInfo
{
    if(DEBUG) {
        NSLog(@"Received notification: %@", userInfo);
    }
    
    if(self.authenticatedUser && self.authenticatedUser.token)
    {
        if([userInfo objectForKey:NOTIFICATION_ACTION_KEY])
        {
            NSString *action = [userInfo objectForKey:NOTIFICATION_ACTION_KEY];
            
            if([action isEqualToString:ACTION_NEW_TOWING_VOUCHER_ASSIGNED])
            {
                //force refetch of the vouchers
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_VOUCHER_OVERVIEW
                                                                    object:self];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nieuwe takelbon"
                                                                message:@"Er werd een nieuwe takelbon aan u toegekend. Deze kan u terugvinden in het overzicht."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_VOUCHER_OVERVIEW object:self];
            }
            else if([action isEqualToString:ACTION_TOWING_UPDATED_FOR_VOUCHER])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aangepaste takelaar voor takelbon"
                                                                message:@"Er werd een nieuwe takelaar toegekend aan een takelbon."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                NSString *voucherId = [userInfo objectForKey:VOUCHER_ID];
                
                TowingVoucher *voucher = [TowingVoucher findVoucherById:voucherId withContext:self.managedObjectContext];
                
                if(voucher)
                {
                    NSString *vehicleId = [userInfo objectForKey:TOWING_VEHICLE_ID];
                    NSString *towing_id = [userInfo objectForKey:TOWING_ID];
                    NSString *towing_called = [NSString stringWithFormat:@"%@",  [userInfo objectForKey:TOWING_CALLED]];
                    
                    Vehicle *vehicle = [Vehicle findById:vehicleId withContext:self.managedObjectContext];
                    
                    voucher.towing_vehicle = vehicle;
                    
                    //update the json context
                    [voucher jsonValue:vehicleId forKey:TOWING_VEHICLE_ID];
                    [voucher jsonValue:towing_id forKey:TOWING_ID];
                    [voucher jsonValue:towing_called forKey:TOWING_CALLED];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_TOWING object:nil];
                    
                    [self.managedObjectContext save:nil];
                } else {
                    NSString *message = [NSString stringWithFormat:@"De aanpassing  van de takelbon kan niet doorgevoerd worden. Er kon geen takelbon gevonden worden met het nummer '%@'. Ververs de lijst met takelbonnen om de laatste versies op te halen.", voucherId];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Takelbon niet gevonden"
                                                                    message:message
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
             }
            else if ([action isEqualToString:ACTION_COLLECTOR_SIGNATURE])
            {
                [self gotoCollectorSignatureStoryBoard:userInfo];
            }
        }
    }
}

- (UIStoryboard *) mainStoryBoard {
    if(!_mainStoryBoard) {        
        _mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    
    return _mainStoryBoard;
}

- (void) gotoCollectorSignatureStoryBoard:(NSDictionary *) bundleInformation
{
    CollectorSignatureViewController *viewController = nil;
    viewController = (CollectorSignatureViewController *) [self.mainStoryBoard instantiateViewControllerWithIdentifier:COLLECTOR_SIGNATURE_STORYBOARD];
    viewController.bundleInformation = bundleInformation;
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    
    [navController addChildViewController:viewController];
    
    [[self topMostController] presentViewController:navController animated:YES completion:nil];
}

- (void) logout
{
    UIViewController *topMost = [self topMostController];
    
    if([topMost isKindOfClass:[UINavigationController class]]) {
        LoginViewController *viewController = nil;
        viewController = (LoginViewController *) [self.mainStoryBoard instantiateViewControllerWithIdentifier:LOGIN_STORYBOARD];
        
        self.window.rootViewController = viewController;
    } else {
        [topMost dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIViewController*) topMostController
{
    UIViewController *topController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

- (void) gotoTowingVoucherOverview
{
    static NSString *navigationControllerStoryboard = @"voucherOverviewNavigationControllerStoryboard";
    
    UIViewController *controller = [self.mainStoryBoard instantiateViewControllerWithIdentifier:navigationControllerStoryboard];
    
    UIViewController *currentController = self.window.rootViewController;
    self.window.rootViewController = controller;
    self.window.rootViewController = currentController;
    
    [UIView transitionWithView:self.window
                      duration:0.75
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.window.rootViewController = controller;
                    }
                    completion:^(BOOL finished){
                        //notify update of vouchers
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_VOUCHER_OVERVIEW object:self];
                    }];
}

- (void) showErrorMessage:(NSString *)message
{
    UIViewController *viewController = [self topMostController];
    
    if(viewController)
    {
        [[Crouton alert:message inView:viewController.view] show];
    }
}

@end
