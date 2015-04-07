//
//  Vehicle+Model.h
//  towing
//
//  Created by Kris Vandermast on 25/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "Vehicle.h"

@interface Vehicle (Model)
- (Vehicle *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;
+ (Vehicle *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context;
+ (NSArray *) findAll:(NSManagedObjectContext *) context;
@end
