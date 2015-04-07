//
//  ContextHelper.h
//  towing
//
//  Created by Kris Vandermast on 27/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ContextHelper : NSObject
+ (id) findEntity:(NSString *) entityName byId:(NSString *) identifier inContext:(NSManagedObjectContext *)context;
+ (id) findEntity:(NSString *) entityName usingPredicate:(NSPredicate *) predicate inContext:(NSManagedObjectContext *) context;

+ (NSArray *) findAllEntities:(NSString *) entityName inContext:(NSManagedObjectContext *) context;
+ (NSArray *) findAllEntities:(NSString *) entityName usingPredicate:(NSPredicate *) predicate inContext:(NSManagedObjectContext *) context;
+ (NSArray *) findAllEntities:(NSString *) entityName withSortingDescription:(NSSortDescriptor *) descriptor inContext:(NSManagedObjectContext *)context;
@end
