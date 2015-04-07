//
//  JsonUtil.h
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonUtil : NSObject
+ (NSDate *) asDate:(NSString *) value;
+ (NSDate *) asDateFromUnixTimestamp:(NSString *) value;
+ (NSDate *) asDateFromMySQLDateTime:(NSString *) value;
+ (NSString *) asString:(id) value;
+ (NSString *) asString:(id) value defaultValue:(NSString *) defaultValue;
+ (NSNumber *) asNumber:(id) value;
@end
