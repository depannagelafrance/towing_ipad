//
//  DateUtil.m
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "DateUtil.h"

#define DATE_TIME_TS_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
#define DATE_TIME_FORMAT    @"dd/MM/yyyy HH:mm"

@implementation DateUtil
+ (NSDate *) dateFromString:(NSString *) date
{
    if(date && date != (id)[NSNull null] && date.length > 0 )
    {
        NSLog(@"Attempting to format: %@", date);
    
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormat setDateFormat:DATE_TIME_TS_FORMAT];
        
        // Convert string to date object
        NSDate *convertedDate = [dateFormat dateFromString:date];
        
        NSLog(@"--> Converted date: %@", convertedDate);
        
        if(convertedDate) {
            return convertedDate;
        }
        
        return nil;
    }
    
    return nil;
}


+ (NSString *) formatAsDateTime:(NSDate *) date
{
    if(date)
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+1"]];
        [dateFormat setDateFormat:DATE_TIME_FORMAT];
        return [dateFormat stringFromDate:date];
    }
    
    return nil;
}

+ (NSString *) formatAsJsonDateTime:(NSDate *) date
{
    if(date)
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormat setDateFormat:DATE_TIME_TS_FORMAT];
        return [dateFormat stringFromDate:date];
    }
    
    return nil;
}
@end
