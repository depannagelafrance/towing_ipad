//
//  TowingVoucher.h
//  towing
//
//  Created by Kris Vandermast on 25/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Dossier, TowingActivity, TowingMessage, TowingVoucherSignature, Vehicle;

@interface TowingVoucher : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * impact_image_path;
@property (nonatomic, retain) NSDate * signa_arrival;
@property (nonatomic, retain) NSString * signa_by;
@property (nonatomic, retain) NSString * signa_by_vehicule;
@property (nonatomic, retain) NSString * towed_by;
@property (nonatomic, retain) NSString * towed_by_vehicule;
@property (nonatomic, retain) NSDate * towing_arrival;
@property (nonatomic, retain) NSDate * towing_called;
@property (nonatomic, retain) NSDate * towing_completed;
@property (nonatomic, retain) NSString * towing_depot;
@property (nonatomic, retain) NSDate * towing_start;
@property (nonatomic, retain) NSString * vehicule_country;
@property (nonatomic, retain) NSString * vehicule_licenceplate;
@property (nonatomic, retain) NSString * vehicule_type;
@property (nonatomic, retain) NSString * voucher_number;
@property (nonatomic, retain) Dossier *dossier;
@property (nonatomic, retain) TowingVoucherSignature *signature_causer;
@property (nonatomic, retain) TowingVoucherSignature *signature_traffic_post;
@property (nonatomic, retain) NSSet *towing_activities;
@property (nonatomic, retain) NSSet *towing_messages;
@property (nonatomic, retain) Vehicle *towing_vehicle;
@end

@interface TowingVoucher (CoreDataGeneratedAccessors)

- (void)addTowing_activitiesObject:(TowingActivity *)value;
- (void)removeTowing_activitiesObject:(TowingActivity *)value;
- (void)addTowing_activities:(NSSet *)values;
- (void)removeTowing_activities:(NSSet *)values;

- (void)addTowing_messagesObject:(TowingMessage *)value;
- (void)removeTowing_messagesObject:(TowingMessage *)value;
- (void)addTowing_messages:(NSSet *)values;
- (void)removeTowing_messages:(NSSet *)values;

@end
