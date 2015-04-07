//
//  TrafficPost+Model.m
//  towing
//
//  Created by Kris Vandermast on 29/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "TrafficPost+Model.h"
#import "ContextHelper.h"


@implementation TrafficPost (Model)
- (TrafficPost *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    TrafficPost *post = [TrafficPost findById:[data valueForKey:@"id"] withContext:context];
    
    if(!post) {
        post =[NSEntityDescription insertNewObjectForEntityForName:TRAFFICPOST_ENTITY
                                            inManagedObjectContext:context];
    }
    
    post.id = [NSString stringWithFormat:@"%@", [data valueForKey:@"id"]];
    post.name = [data valueForKey:@"name"];
    
    return post;
}

+ (TrafficPost *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context
{
    return [ContextHelper findEntity:TRAFFICPOST_ENTITY byId:identifier inContext:context];
}

+ (NSArray *) findAllTrafficPosts:(NSManagedObjectContext *) context
{
    return [ContextHelper findAllEntities:TRAFFICPOST_ENTITY inContext:context];
}

@end
