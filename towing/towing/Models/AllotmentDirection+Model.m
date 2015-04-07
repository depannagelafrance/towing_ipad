//
//  AllotmentDirection+Model.m
//  towing
//
//  Created by Kris Vandermast on 02/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "AllotmentDirection+Model.h"
#import "ContextHelper.h"

#define ALLOTMENT_DIRECTION_ENTITY @"AllotmentDirection"

@implementation AllotmentDirection (Model)
- (AllotmentDirection *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    AllotmentDirection *direction = [AllotmentDirection findById:[data valueForKey:ID] withContext:context];
    
    if(!direction) {
        direction =[NSEntityDescription insertNewObjectForEntityForName:ALLOTMENT_DIRECTION_ENTITY
                                                 inManagedObjectContext:context];
    }
    
    direction.id = [NSString stringWithFormat:@"%@", [data valueForKey:ID]];
    direction.name = [data valueForKey:NAME];
    
    return direction;
}

+ (AllotmentDirection *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context
{
    return [ContextHelper findEntity:ALLOTMENT_DIRECTION_ENTITY byId:identifier inContext:context];
}

+ (NSArray *) findAll:(NSManagedObjectContext *) context
{
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:NAME ascending:YES];
    
    return [ContextHelper findAllEntities:ALLOTMENT_DIRECTION_ENTITY
                   withSortingDescription:sd
                                inContext:context];
}
@end
