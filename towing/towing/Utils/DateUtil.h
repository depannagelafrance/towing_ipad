//
//  DateUtil.h
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject
+ (NSDate *) dateFromString:(NSString *) date;
+ (NSString *) formatAsDateTime:(NSDate *) date;
+ (NSString *) formatAsJsonDateTime:(NSDate *) date;
@end
