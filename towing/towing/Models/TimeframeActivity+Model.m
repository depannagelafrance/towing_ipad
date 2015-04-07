//
//  TimeframeActivity+Model.m
//  towing
//
//  Created by Kris Vandermast on 27/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "TimeframeActivity+Model.h"
#import "ContextHelper.h"



@implementation TimeframeActivity (Model)
- (TimeframeActivity *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    TimeframeActivity *activity = [TimeframeActivity findById:[data valueForKey:@"id"] withContext:context];
    
    if(!activity)  {
        activity = [NSEntityDescription insertNewObjectForEntityForName:TIMEFRAME_ACTIVITY_ENTITY
                                                 inManagedObjectContext:context];
    }
    
    activity.id = [data valueForKey:@"id"];
    activity.code = [data valueForKey:@"code"];
    activity.name = [data valueForKey:@"name"];
    
    return activity;
}

+ (TimeframeActivity *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context
{
    return [ContextHelper findEntity:TIMEFRAME_ACTIVITY_ENTITY byId:identifier inContext:context];
}

+ (NSArray *) findAllTimeframeActivities:(NSManagedObjectContext *) context
{
    return [ContextHelper findAllEntities:TIMEFRAME_ACTIVITY_ENTITY
                   withSortingDescription:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                inContext:context];
}
@end
