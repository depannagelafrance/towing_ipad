//
//  Dossier.h
//  towing
//
//  Created by Kris Vandermast on 05/01/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TowingVoucher;

@interface Dossier : NSManagedObject

@property (nonatomic, retain) NSString * allotment_direction_indicator_name;
@property (nonatomic, retain) NSString * allotment_direction_name;
@property (nonatomic, retain) NSString * allotment_name;
@property (nonatomic, retain) NSDate * call_date;
@property (nonatomic, retain) NSString * call_number;
@property (nonatomic, retain) NSString * dossier_number;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * incident_type_name;
@property (nonatomic, retain) NSString * json;
@property (nonatomic, retain) NSString * traffic_lane_name;
@property (nonatomic, retain) NSNumber * hasBeenSynchd;
@property (nonatomic, retain) NSSet *towing_vouchers;
@end

@interface Dossier (CoreDataGeneratedAccessors)

- (void)addTowing_vouchersObject:(TowingVoucher *)value;
- (void)removeTowing_vouchersObject:(TowingVoucher *)value;
- (void)addTowing_vouchers:(NSSet *)values;
- (void)removeTowing_vouchers:(NSSet *)values;

@end
