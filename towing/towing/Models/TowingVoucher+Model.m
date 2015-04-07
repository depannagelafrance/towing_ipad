//
//  TowingVoucher+Model.m
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "TowingVoucher+Model.h"
#import "TowingVoucherSignature.h"
#import "JsonUtil.h"
#import "AppDelegate.h"
#import "Dossier+Model.h"
#import "TowingMessage.h"
#import "Vehicle+Model.h"

@implementation TowingVoucher (Model)
- (TowingVoucher *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    TowingVoucher *voucher = [TowingVoucher findVoucherById:[data objectForKey:@"id"] withContext:context];
    
    if(!voucher) {
        voucher = [NSEntityDescription insertNewObjectForEntityForName:TOWING_VOUCHER_ENTITY
                                                inManagedObjectContext:context];
        
    }
    
    voucher.id  = [JsonUtil asString:[data objectForKey:@"id"]];
    
    voucher.signa_arrival = [JsonUtil asDateFromUnixTimestamp:[data objectForKey:@"signa_arrival"]];
    voucher.signa_by = [JsonUtil asString:[data objectForKey:@"signa_by"]];
    voucher.signa_by_vehicule = [JsonUtil asString:[data objectForKey:@"signa_by_vehicule"]];
    
    voucher.towed_by = [JsonUtil asString:[data objectForKey:@"towed_by"]];
    voucher.towed_by_vehicule = [JsonUtil asString:[data objectForKey:@"towed_by_vehicule"]];
    voucher.towing_arrival = [JsonUtil asDateFromUnixTimestamp:[data objectForKey:@"towing_arrival"]];
    voucher.towing_called = [JsonUtil asDateFromUnixTimestamp:[data objectForKey:@"towing_called"]];
    voucher.towing_start = [JsonUtil asDateFromUnixTimestamp:[data objectForKey:@"towing_start"]];
    voucher.towing_completed = [JsonUtil asDateFromUnixTimestamp:[data objectForKey:@"towing_completed"]];
    voucher.towing_depot = [JsonUtil asString:[data objectForKey:@"towing_depot"]];
    
    voucher.vehicule_country = [JsonUtil asString:[data objectForKey:@"vehicule_country"]];
    voucher.vehicule_licenceplate = [JsonUtil asString:[data objectForKey:@"vehicule_licenceplate"]];
    voucher.vehicule_type = [JsonUtil asString:[data objectForKey:@"vehicule_type"]];
    
    voucher.voucher_number = [JsonUtil asString:[data objectForKey:@"voucher_number"]];
    
    
    NSString *vehicleId = [JsonUtil asString:[data  objectForKey:TOWING_VEHICLE_ID]];
    
    voucher.towing_vehicle = [Vehicle findById:vehicleId withContext:context];
        
    return voucher;
}

+ (TowingVoucher *) findVoucherById: (NSString *) identifier withContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:TOWING_VOUCHER_ENTITY];
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", identifier]];
    request.fetchLimit = 1;
    
    NSError *error;
    
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if(result == nil) {
        NSLog(@"%s - Caught an error while fetching dossier: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    return [result firstObject];
}

+ (NSArray *) findAllVouchersWithContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:TOWING_VOUCHER_ENTITY];
    
    NSError *error;
    
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if(result == nil) {
        NSLog(@"%s - Caught an error while fetching voucher: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    return result;
}

- (void) jsonValue:(NSString *)value forKey:(NSString *) key
{
    NSMutableDictionary *jsonDossier = [((Dossier *) self.dossier) jsonObject];
    
    for(NSMutableDictionary *jsonVoucher in [jsonDossier objectForKey:@"towing_vouchers"])
    {
        if([[[jsonVoucher objectForKey:@"id"] stringValue] isEqualToString:self.id])
        {
            [jsonVoucher setValue:value forKey:key];
        }
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDossier options:NSJSONWritingPrettyPrinted error:nil];
    ((Dossier *) self.dossier).json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void) jsonObject:(id) value forKey:(NSString *) key
{
    NSMutableDictionary *jsonDossier = [((Dossier *) self.dossier) jsonObject];
    
    for(NSMutableDictionary *jsonVoucher in [jsonDossier objectForKey:@"towing_vouchers"])
    {
        if([[[jsonVoucher objectForKey:@"id"] stringValue] isEqualToString:self.id])
        {
            [jsonVoucher setObject:value forKey:key];
        }
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDossier options:NSJSONWritingPrettyPrinted error:nil];
    ((Dossier *) self.dossier).json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (id) jsonObjectForKey:(NSString *)key
{
    NSDictionary *jsonDossier = [((Dossier *) self.dossier) jsonObject];
    
    for(NSDictionary *jsonVoucher in [jsonDossier objectForKey:@"towing_vouchers"])
    {
        if([[[jsonVoucher objectForKey:@"id"] stringValue] isEqualToString:self.id])
        {
            return [jsonVoucher objectForKey:key];
        }
    }
    
    return nil;
}

- (void) addTowingSignatureWithCategory:(NSString *) category inLocation:(NSString *) path
{
    TowingVoucherSignature *signature = (TowingVoucherSignature *) [NSEntityDescription insertNewObjectForEntityForName:TOWING_VOUCHER_SIGNATURE
                                                                                                 inManagedObjectContext:self.managedObjectContext];
    
    signature.path = path;
    
    if([category isEqualToString:@"signature_causer"]) {
        self.signature_causer = signature;
    } else if([category isEqualToString:@"signature_police"]) {
        self.signature_traffic_post = signature;
    }
    
    
    [self.managedObjectContext save:nil];
}

- (void) addTowingMessage:(NSString *) message
{
    TowingMessage *towingMessage = (TowingMessage *) [NSEntityDescription insertNewObjectForEntityForName:TOWING_MESSAGE
                                                                                   inManagedObjectContext:self.managedObjectContext];
    
    towingMessage.message = message;
    [self.managedObjectContext save:nil];
    
    //add it to the array
    NSMutableArray *messages = [NSMutableArray arrayWithArray:[self.towing_messages allObjects]];
    [messages addObject:towingMessage];
    
    self.towing_messages = [NSSet setWithArray:messages];
    [self.managedObjectContext save:nil];
}


@end
