//
//  Vehicle.h
//  towing
//
//  Created by Kris Vandermast on 25/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TowingVoucher;

@interface Vehicle : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * licence_plate;
@property (nonatomic, retain) TowingVoucher *vehicleAsTowing;

@end
