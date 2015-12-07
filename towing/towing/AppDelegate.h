//
//  AppDelegate.h
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "User+Model.h"
#import "TowingVoucher+Model.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic, retain) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;



@property (strong, nonatomic) UIStoryboard *mainStoryBoard;

@property (strong, nonatomic) User* authenticatedUser;
@property (strong, nonatomic) TowingVoucher *towingVoucher;

- (void) saveContext;
- (void) logout;
- (void) showErrorMessage:(NSString *)message;
- (NSURL *) applicationDocumentsDirectory;

- (void) gotoTowingVoucherOverview;

@end

