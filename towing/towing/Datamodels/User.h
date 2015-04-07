//
//  User.h
//  towing
//
//  Created by Kris Vandermast on 24/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * json;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * signature_path;

@end
