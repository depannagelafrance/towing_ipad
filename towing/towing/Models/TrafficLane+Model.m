//
//  TrafficLane+Model.m
//  towing
//
//  Created by Kris Vandermast on 03/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "TrafficLane+Model.h"
#import "ContextHelper.h"

@implementation TrafficLane (Model)
- (TrafficLane *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    TrafficLane *trafficLane = [TrafficLane findById:[data valueForKey:ID] withContext:context];
    
    if(!trafficLane) {
        trafficLane =[NSEntityDescription insertNewObjectForEntityForName:TRAFFIC_LANE_ENTITY
                                                 inManagedObjectContext:context];
    }
    
    trafficLane.id = [NSString stringWithFormat:@"%@", [data valueForKey:ID]];
    trafficLane.name = [data valueForKey:NAME];
    
    return trafficLane;
}

+ (TrafficLane *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context
{
    return [ContextHelper findEntity:TRAFFIC_LANE_ENTITY byId:identifier inContext:context];
}

+ (NSArray *) findAll:(NSManagedObjectContext *) context
{
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:NAME ascending:YES];
    
    return [ContextHelper findAllEntities:TRAFFIC_LANE_ENTITY
                   withSortingDescription:sd
                                inContext:context];
}

@end
