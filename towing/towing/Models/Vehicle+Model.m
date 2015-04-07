//
//  Vehicle+Model.m
//  towing
//
//  Created by Kris Vandermast on 25/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "Vehicle+Model.h"
#import "ContextHelper.h"

@implementation Vehicle (Model)
- (Vehicle *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    Vehicle *vehicle = [Vehicle findById:[data valueForKey:ID] withContext:context];
    
    if(!vehicle) {
        vehicle =[NSEntityDescription insertNewObjectForEntityForName:VEHICLE_ENTITY
                                                   inManagedObjectContext:context];
    }
    
    vehicle.id = [NSString stringWithFormat:@"%@", [data valueForKey:ID]];
    vehicle.name = [data valueForKey:NAME];
    vehicle.licence_plate = [data valueForKey:LICENCE_PLATE];
    
    return vehicle;
}

+ (Vehicle *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context
{
    return [ContextHelper findEntity:VEHICLE_ENTITY byId:identifier inContext:context];
}

+ (NSArray *) findAll:(NSManagedObjectContext *) context
{
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:NAME ascending:YES];
    
    return [ContextHelper findAllEntities:VEHICLE_ENTITY
                   withSortingDescription:sd
                                inContext:context];
}
@end
