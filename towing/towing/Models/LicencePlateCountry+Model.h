//
//  LicencePlateCountry+Model.h
//  towing
//
//  Created by Kris Vandermast on 02/12/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "LicencePlateCountry.h"

@interface LicencePlateCountry (Model)
- (LicencePlateCountry *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;

+ (LicencePlateCountry *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context;
+ (NSArray *) findAll:(NSManagedObjectContext *) context;
@end
