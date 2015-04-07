//
//  ContextHelper.m
//  towing
//
//  Created by Kris Vandermast on 27/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "ContextHelper.h"

@implementation ContextHelper
+ (id) findEntity:(NSString *) entityName byId:(NSString *) identifier inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", identifier];
    request.fetchLimit = 1;
    
    NSError *error;
    
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if(result == nil) {
        NSLog(@"%s - Caught an error while fetching %@: %@", __PRETTY_FUNCTION__, entityName, error);
        return nil;
    }
    
    return [result firstObject];
}

+ (NSArray *) findAllEntities:(NSString *) entityName inContext:(NSManagedObjectContext *) context
{
    return [ContextHelper findAllEntities:entityName usingPredicate:nil inContext:context];
}

+ (NSArray *) findAllEntities:(NSString *) entityName withSortingDescription:(NSSortDescriptor *) descriptor inContext:(NSManagedObjectContext *)context
{
    return [ContextHelper findAllEntities:entityName usingPredicate:nil usingSortDescriptor:descriptor inContext:context];
}

+ (NSArray *) findAllEntities:(NSString *) entityName usingPredicate:(NSPredicate *) predicate inContext:(NSManagedObjectContext *) context
{
    return [ContextHelper findAllEntities:entityName usingPredicate:predicate usingSortDescriptor:nil inContext:context];
}

+ (NSArray *) findAllEntities:(NSString *) entityName
               usingPredicate:(NSPredicate *) predicate
          usingSortDescriptor:(NSSortDescriptor *) descriptor
                    inContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    if(predicate)
    {
        request.predicate = predicate;
    }
    
    if(descriptor)
    {
        request.sortDescriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
    }
    
    NSError *error;
    
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if(result == nil) {
        NSLog(@"%s - Caught an error while fetching %@: %@", __PRETTY_FUNCTION__, entityName, error);
        return nil;
    }
    
    return result;
}


+ (id) findEntity:(NSString *) entityName usingPredicate:(NSPredicate *) predicate inContext:(NSManagedObjectContext *) context
{
    NSArray *result = [ContextHelper findAllEntities:entityName usingPredicate:predicate inContext:context];
    
    if(result)
    {
        return [result firstObject];
    }
    
    return nil;
}

@end
