//
//  TimeframeActivityFee+Model.m
//  towing
//
//  Created by Kris Vandermast on 03/11/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "TimeframeActivityFee+Model.h"
#import "ContextHelper.h"
#import "JsonUtil.h"

@implementation TimeframeActivityFee (Model)
- (TimeframeActivityFee *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    TimeframeActivityFee *fee = [TimeframeActivityFee findById:[data objectForKey:@"id"] withContext:context];
    
    if(!fee)
    {
        fee =[NSEntityDescription insertNewObjectForEntityForName:TIMEFRAME_ACTIVITY_FEE_ENTITY
                                           inManagedObjectContext:context];
    }
    
    fee.id = [data objectForKey:@"id"];
    fee.timeframe_activity_id = [data objectForKey:@"timeframe_activity_id"];
    fee.timeframe_id = [data objectForKey:@"timeframe_id"];
    fee.fee_excl_vat = [JsonUtil asNumber:[data objectForKey:@"fee_excl_vat"]];
    fee.fee_incl_vat = [JsonUtil asNumber:[data objectForKey:@"fee_incl_vat"]];
    
    return fee;
}

+ (TimeframeActivityFee *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context
{
    return [ContextHelper findEntity:TIMEFRAME_ACTIVITY_FEE_ENTITY byId:identifier inContext:context];
}

+ (TimeframeActivityFee *) findByTimeframe:(NSNumber *) timeframe andActivity:(NSNumber *) activity inContext:(NSManagedObjectContext *) context
{
    NSString *params = [NSString stringWithFormat:@"timeframe_id == %@ AND timeframe_activity_id == %@", timeframe, activity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:params];
    
    return [ContextHelper findEntity:TIMEFRAME_ACTIVITY_FEE_ENTITY usingPredicate:predicate inContext:context];
}

+ (NSArray *) findAllTimeframeActivitiesForTimeframe:(NSString *) id inContext:(NSManagedObjectContext *) context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"timeframe_id == %@",id]];
    
    return [ContextHelper findAllEntities:TIMEFRAME_ACTIVITY_FEE_ENTITY usingPredicate:predicate inContext:context];
}

@end
