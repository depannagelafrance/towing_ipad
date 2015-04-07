//
//  TimeframeActivity+Model.h
//  towing
//
//  Created by Kris Vandermast on 27/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "TimeframeActivity.h"

@interface TimeframeActivity (Model)
- (TimeframeActivity *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;

+ (TimeframeActivity *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context;

+ (NSArray *) findAllTimeframeActivities:(NSManagedObjectContext *) context;
@end
