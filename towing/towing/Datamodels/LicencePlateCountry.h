//
//  LicencePlateCountry.h
//  towing
//
//  Created by Kris Vandermast on 02/12/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LicencePlateCountry : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * id;

@end
