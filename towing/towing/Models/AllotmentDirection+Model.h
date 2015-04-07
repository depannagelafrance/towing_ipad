//
//  AllotmentDirection+Model.h
//  towing
//
//  Created by Kris Vandermast on 02/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "AllotmentDirection.h"

@interface AllotmentDirection (Model)
- (AllotmentDirection *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;
+ (AllotmentDirection *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context;
+ (NSArray *) findAll:(NSManagedObjectContext *) context;
@end
