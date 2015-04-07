//
//  SharedPreferences.m
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "SharedPreferences.h"

#define USERNAME            @"PREF_USERNAME"
#define REGISTRATION_ID     @"PREF_REGISTRATION_ID"
#define IS_OFFICE_TAB       @"PREF_IS_OFFICE_TAB"
#define SIGNATURE_LOCATION  @"PREF_SIGNATURE_LOCATION"


@implementation SharedPreferences
+ (void) storeUsername:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:USERNAME];
}

+ (void) storeRegistrationId:(NSString *) registrationId
{
    [[NSUserDefaults standardUserDefaults] setObject:registrationId forKey:REGISTRATION_ID];
}

+ (void) storeIsOfficeTab:(BOOL)isOfficeTab
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%i", isOfficeTab] forKey:IS_OFFICE_TAB];
}

+ (void) storeSignatureLocation:(NSString *)location
{
    [[NSUserDefaults standardUserDefaults] setObject:location forKey:SIGNATURE_LOCATION];
}

+ (NSString *) fetchUsername
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
}


+ (NSString *) fetchRegistrationId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:REGISTRATION_ID];
}

+ (NSString *) fetchSignatureLocation
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SIGNATURE_LOCATION];
}

+ (BOOL) isOfficeTab {
    id isOfficeTab = [[NSUserDefaults standardUserDefaults] objectForKey:IS_OFFICE_TAB];
    
    if(!isOfficeTab)
        return false;
    
    
    if([isOfficeTab isKindOfClass:[NSString class]])
        return [isOfficeTab isEqualToString:@"1"];
    
    return [isOfficeTab isEqualToNumber:@1];
}
@end
