//
//  JsonUtil.m
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "JsonUtil.h"
#import "DateUtil.h"

@implementation JsonUtil
+ (NSDate *) asDate:(NSString *) value
{
    return [DateUtil dateFromString:value];
}

+ (NSDate *) asDateFromUnixTimestamp:(NSString *) value
{
    if(value && ![value isEqual:[NSNull null]])
    {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:value.doubleValue];
        
        return date;
    }
    
    return nil;
}

+ (NSDate *) asDateFromMySQLDateTime:(NSString *) value {
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    formatter.locale = enUSPOSIXLocale;
    formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'";
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    
    return [formatter dateFromString:value];
}


+ (NSString *) asString:(id) value
{
    if(value && value != (id)[NSNull null])
    {
        return [NSString stringWithFormat:@"%@", value];
    }
    
    return nil;
}

+ (NSString *) asString:(id) value defaultValue:(NSString *) defaultValue
{
    NSString *_value = [self asString:value];
    
    if(!_value) {
        return defaultValue;
    }
    
    return value;
}

+ (NSNumber *) asNumber:(id) value
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    [f setLocale:locale];
    
    NSNumber *formattedValue = nil;
    
    if([value isKindOfClass:[NSString class]]) {
        formattedValue = [f numberFromString:value];
    } else {
        formattedValue = value;
    }
    
    if(formattedValue == (id) [NSNull null] || [formattedValue isKindOfClass:[NSNull class]])
        return nil;
    
    
    if(!formattedValue)
    {
        [f setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"nl_BE"]];
        
        return [f numberFromString:value];
    }
    else
    {
        NSLog(@"Formatting %@ to value %@", value, formattedValue);
        return formattedValue;
    }
}

@end
