//
//  LicencePlateCountry+Model.m
//  towing
//
//  Created by Kris Vandermast on 02/12/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "LicencePlateCountry+Model.h"
#import "ContextHelper.h"

@implementation LicencePlateCountry (Model)
- (LicencePlateCountry *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    LicencePlateCountry *post = [LicencePlateCountry findById:[data valueForKey:@"id"] withContext:context];
    
    if(!post) {
        post =[NSEntityDescription insertNewObjectForEntityForName:LICENCE_PLATE_COUNTRY_ENTITY
                                            inManagedObjectContext:context];
    }
    
    post.id = [NSString stringWithFormat:@"%@", [data valueForKey:@"id"]];
    post.name = [data valueForKey:@"name"];
    
    return post;
}

+ (LicencePlateCountry *) findById: (NSString *) identifier withContext:(NSManagedObjectContext *) context
{
    return [ContextHelper findEntity:LICENCE_PLATE_COUNTRY_ENTITY byId:identifier inContext:context];
}

+ (NSArray *) findAll:(NSManagedObjectContext *) context
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    return [ContextHelper findAllEntities:LICENCE_PLATE_COUNTRY_ENTITY withSortingDescription:sort inContext:context];
}
@end
