//
//  TrafficLane+Model.h
//  towing
//
//  Created by Kris Vandermast on 03/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "TrafficLane.h"

@interface TrafficLane (Model)
- (TrafficLane *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;
+ (TrafficLane *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context;
+ (NSArray *) findAll:(NSManagedObjectContext *) context;
@end
