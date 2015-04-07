//
//  TrafficPost+Model.h
//  towing
//
//  Created by Kris Vandermast on 29/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "TrafficPost.h"

@interface TrafficPost (Model)
- (TrafficPost *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;

+ (TrafficPost *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context;

+ (NSArray *) findAllTrafficPosts:(NSManagedObjectContext *) context;

@end
