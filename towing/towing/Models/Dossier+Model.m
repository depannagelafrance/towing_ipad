//
//  Dossier+Model.m
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "Dossier+Model.h"
#import "TowingVoucher+Model.h"
#import "JsonUtil.h"
#import "RestService.h"
#import "AppDelegate.h"


@implementation Dossier (Model)

- (Dossier *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context
{
    Dossier *dossier = [Dossier findDossierById:[data objectForKey:@"id"] withContext:context];
    
    if(!dossier) {
        dossier = [NSEntityDescription insertNewObjectForEntityForName:DOSSIER_ENTITY
                                                inManagedObjectContext:context];
    }
    
    dossier.call_date       = [JsonUtil asDate:[data objectForKey:@"call_date"]];
    dossier.call_number     = [JsonUtil asString:[data objectForKey:@"call_number"]];
    dossier.dossier_number  = [JsonUtil asString:[data objectForKey:@"dossier_number"]];
    dossier.id              = [JsonUtil asString:[data objectForKey:@"id"]];
    dossier.hasBeenSynchd   = @1;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if(json)
        dossier.json = json;
    
    NSMutableArray *vouchers = (dossier.towing_vouchers ? [NSMutableArray arrayWithArray:[dossier.towing_vouchers allObjects]] : [NSMutableArray new]);
    
    for(NSDictionary *voucher in [data objectForKey:@"towing_vouchers"])
    {
        TowingVoucher *towingVoucher = [[TowingVoucher alloc] initFromDictionary:voucher withContext:dossier.managedObjectContext];
        
        [vouchers addObject:towingVoucher];
    }
    
    dossier.towing_vouchers = [[NSSet alloc] initWithArray:vouchers];
    
    return dossier;
}

+ (Dossier *) findDossierById: (NSString *)identifier withContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DOSSIER_ENTITY];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", identifier];
    request.fetchLimit = 1;
    
    NSError *error;
    
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if(result == nil) {
        NSLog(@"%s - Caught an error while fetching dossier: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    return [result firstObject];
}

+ (NSArray *) findAllDossiersWithContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DOSSIER_ENTITY];
    NSError *error;
    
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if(result == nil) {
        NSLog(@"%s - Caught an error while fetching dossier: %@", __PRETTY_FUNCTION__, error);
        return nil;
    }
    
    return result;
}

- (NSMutableDictionary *) jsonObject
{
    if(self.json) {
        NSData *data = [self.json dataUsingEncoding:NSUTF8StringEncoding];
        
        return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    
    return nil;
}


- (void) jsonValue:(NSString *)value forKey:(NSString *) key
{
    NSMutableDictionary *jsonDossier = self.jsonObject;
    
    [jsonDossier setValue:value forKey:key];
    
    [self storeJsonDictionary:jsonDossier];
}

- (void) jsonObject:(id) value forKey:(NSString *) key
{
    NSMutableDictionary *jsonDossier = self.jsonObject;
    
    [jsonDossier setObject:value forKey:key];
    
    [self storeJsonDictionary:jsonDossier];
}

- (id) jsonObjectForKey:(NSString *)key
{
    NSDictionary *jsonDossier = self.jsonObject;
    
    return [jsonDossier objectForKey:key] == [NSNull null] ? nil : [jsonDossier objectForKey:key];
}

- (void) performSaveToBackoffice
{
    RestService *service = [RestService new];
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    NSString *token = delegate.authenticatedUser.token;
    NSString *api = [NSString stringWithFormat:@"/dossier/%@/%@", self.id, token];
    
    [service put:api withParameters:@{@"dossier" : self.jsonObject} onCompleteBlock:^(NSDictionary *json) {
//        NSDictionary *jsonData = [json objectForKey:@"dossier"];
        
//        [self storeJsonDictionary:jsonData];
    
        self.hasBeenSynchd = @1;
        [self.managedObjectContext save:nil];
        
        NSLog(@"Information stored successfully in back-end");
    } onFailBlock:^(NSError *error, int statusCode) {
        NSLog(@"failed to save information to back-end");
        
        self.hasBeenSynchd = @0;
        [self.managedObjectContext save:nil];
        
        [delegate showErrorMessage:[NSString stringWithFormat:@"Fout bij het doorsturen van de gegevens: %d - %@", statusCode, error]];
    }];
    
}

- (void) storeJsonDictionary:(NSDictionary *) jsonData
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:nil];
    self.json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.managedObjectContext save:nil];
}


@end
