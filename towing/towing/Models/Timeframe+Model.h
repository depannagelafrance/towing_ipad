//
//  Timeframe+Model.h
//  towing
//
//  Created by Kris Vandermast on 27/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "Timeframe.h"

@interface Timeframe (Model)
- (Timeframe *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;

+ (Timeframe *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context;
@end
