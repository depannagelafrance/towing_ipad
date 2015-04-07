//
//  User+Model.h
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "User.h"

@interface User (Model)
- (User *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;
- (NSDictionary *) jsonObject;

+ (User *) findUserById: (NSString *)id withContext:(NSManagedObjectContext *) context;

@end
