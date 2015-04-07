//
//  TimeframeActivityFee+Model.h
//  towing
//
//  Created by Kris Vandermast on 03/11/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "TimeframeActivityFee.h"

@interface TimeframeActivityFee (Model)
- (TimeframeActivityFee *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;

+ (TimeframeActivityFee *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context;
+ (TimeframeActivityFee *) findByTimeframe:(NSNumber *) timeframe andActivity:(NSNumber *) activity inContext:(NSManagedObjectContext *) context;

+ (NSArray *) findAllTimeframeActivitiesForTimeframe:(NSNumber *) id inContext:(NSManagedObjectContext *) context;
@end
