//
//  AllotmentDirectionIndicator+Model.m
//  towing
//
//  Created by Kris Vandermast on 02/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "AllotmentDirectionIndicator+Model.h"
#import "ContextHelper.h"
#import "JsonUtil.h"

#define ALLOTMENT_DIRECTION_INDICATOR_ENTITY @"AllotmentDirectionIndicator"

#define ID          @"id"
#define NAME        @"name"
#define SEQUENCE    @"sequence"

@implementation AllotmentDirectionIndicator (Model)
- (AllotmentDirectionIndicator *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    AllotmentDirectionIndicator *direction = [AllotmentDirectionIndicator findById:[data valueForKey:ID] withContext:context];
    
    if(!direction) {
        direction =[NSEntityDescription insertNewObjectForEntityForName:ALLOTMENT_DIRECTION_INDICATOR_ENTITY
                                                 inManagedObjectContext:context];
    }
    
    direction.id = [NSString stringWithFormat:@"%@", [data valueForKey:ID]];
    direction.name = [data valueForKey:NAME];
    direction.sequence = [JsonUtil asNumber:[data objectForKey:SEQUENCE]];
    
    return direction;
}

+ (AllotmentDirectionIndicator *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context
{
    return [ContextHelper findEntity:ALLOTMENT_DIRECTION_INDICATOR_ENTITY byId:identifier inContext:context];
}

+ (NSArray *) findAll:(NSManagedObjectContext *) context
{
//    return [ContextHelper findAllEntities:ALLOTMENT_DIRECTION_INDICATOR_ENTITY inContext:context];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:SEQUENCE ascending:YES];
    
    return [ContextHelper findAllEntities:ALLOTMENT_DIRECTION_INDICATOR_ENTITY withSortingDescription:descriptor inContext:context];
}

@end
