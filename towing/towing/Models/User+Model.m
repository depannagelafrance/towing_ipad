//
//  User+Model.m
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "User+Model.h"


@implementation User (Model)
- (User *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    User *user = [User findUserById:[data objectForKey:@"id"] withContext:context];
    
    if(!user) {
        user = [NSEntityDescription insertNewObjectForEntityForName:USER_ENTITY inManagedObjectContext:context];
    }
    
    user.id = [data objectForKey:@"id"];
    user.login = [data objectForKey:@"login"];
    user.first_name = [data objectForKey:@"first_name"];
    user.last_name = [data objectForKey:@"last_name"];
    user.token = [data objectForKey:@"token"];
    
    NSData *userData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    user.json = [[NSString alloc] initWithData:userData encoding:NSUTF8StringEncoding];
    
    return user;
}

- (NSDictionary *) jsonObject
{
    NSData *userData = [self.json dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSJSONSerialization JSONObjectWithData:userData
                                           options:NSJSONReadingMutableContainers
                                             error:nil];
}

+ (User *) findUserById:(NSString *)identifier withContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:USER_ENTITY];
    request.predicate = [NSPredicate predicateWithFormat:@"id == '%@'", identifier];
    request.fetchLimit = 1;
    
    NSError *error;
    
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if(result == nil) {
        NSLog(@"%s - Caught an error while fetching user: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    return [result firstObject];
}

@end
