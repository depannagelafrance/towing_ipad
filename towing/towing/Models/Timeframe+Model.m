//
//  Timeframe+Model.m
//  towing
//
//  Created by Kris Vandermast on 27/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "Timeframe+Model.h"
#import "ContextHelper.h"


@implementation Timeframe (Model)
- (Timeframe *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    Timeframe *timeframe = [Timeframe findById:[data valueForKey:@"id"] withContext:context];
    
    if(!timeframe) {
        timeframe =[NSEntityDescription insertNewObjectForEntityForName:TIMEFRAME_ENTITY
                                                 inManagedObjectContext:context];
    }
    
    timeframe.id = [data valueForKey:@"id"];
    timeframe.name = [data valueForKey:@"name"];
    
    return timeframe;
}

+ (Timeframe *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context
{
    return [ContextHelper findEntity:TIMEFRAME_ENTITY byId:identifier inContext:context];
}
@end
