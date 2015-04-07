//
//  TowingVoucher.m
//  towing
//
//  Created by Kris Vandermast on 25/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "TowingVoucher.h"
#import "Dossier.h"
#import "TowingActivity.h"
#import "TowingMessage.h"
#import "TowingVoucherSignature.h"
#import "Vehicle.h"


@implementation TowingVoucher

@dynamic id;
@dynamic impact_image_path;
@dynamic signa_arrival;
@dynamic signa_by;
@dynamic signa_by_vehicule;
@dynamic towed_by;
@dynamic towed_by_vehicule;
@dynamic towing_arrival;
@dynamic towing_called;
@dynamic towing_completed;
@dynamic towing_depot;
@dynamic towing_start;
@dynamic vehicule_country;
@dynamic vehicule_licenceplate;
@dynamic vehicule_type;
@dynamic voucher_number;
@dynamic dossier;
@dynamic signature_causer;
@dynamic signature_traffic_post;
@dynamic towing_activities;
@dynamic towing_messages;
@dynamic towing_vehicle;

@end
