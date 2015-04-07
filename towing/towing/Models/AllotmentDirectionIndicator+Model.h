//
//  AllotmentDirectionIndicator+Model.h
//  towing
//
//  Created by Kris Vandermast on 02/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "AllotmentDirectionIndicator.h"

@interface AllotmentDirectionIndicator (Model)
- (AllotmentDirectionIndicator *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;
+ (AllotmentDirectionIndicator *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context;
+ (NSArray *) findAll:(NSManagedObjectContext *) context;
@end
