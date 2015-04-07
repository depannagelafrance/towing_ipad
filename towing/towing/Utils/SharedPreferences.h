//
//  SharedPreferences.h
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedPreferences : NSObject
+ (void) storeUsername:(NSString *) username;
+ (void) storeRegistrationId:(NSString *) registrationId;
+ (void) storeIsOfficeTab:(BOOL)isOfficeTab;
+ (void) storeSignatureLocation:(NSString *) location;

+ (NSString *) fetchUsername;
+ (NSString *) fetchRegistrationId;
+ (NSString *) fetchSignatureLocation;

+ (BOOL) isOfficeTab;
@end
