//
//  SynchronisationHandler.m
//  towing
//
//  Created by Kris Vandermast on 10/11/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "SynchronisationHandler.h"
#import "RestService.h"
#import "Dossier+Model.h"
#import "SettingsViewController.h"
#import "SignatureViewController.h"
#import "SharedPreferences.h"
#import "Timeframe+Model.h"
#import "TimeframeActivity+Model.h"
#import "TimeframeActivityFee+Model.h"
#import "TrafficPost+Model.h"
#import "LicencePlateCountry+Model.h"
#import "AllotmentDirection+Model.h"
#import "AllotmentDirectionIndicator+Model.h"
#import "TrafficLane+Model.h"
#import "Vehicle+Model.h"
#import "SynchronisationHandler.h"
#import "AppDelegate.h"

#define VOCAB_TIMEFRAMES                @"/vocab/timeframe/%@"
#define VOCAB_TIMEFRAME_ACTIVITIES      @"/vocab/timeframe/activities/%@"
#define VOCAB_TIMEFRAME_ACTIVITY_FEES   @"/vocab/timeframe/activity/%@/fees/%@"
#define VOCAB_TRAFFIC_LANES             @"/vocab/traffic_lanes/%@"
#define VOCAB_VEHICLES                  @"/vocab/vehicles/%@"

@interface SynchronisationHandler()
@property (strong, nonatomic) RestService *restService;
@property (strong, nonatomic) AppDelegate *delegate;
@property (strong, nonatomic) NSMutableArray *dossierToDelete;
@end

@implementation SynchronisationHandler
#pragma mark - Getters
- (RestService *) restService
{
    if(!_restService)
    {
        _restService = [[RestService alloc] init];
    }
    
    return  _restService;
}

- (AppDelegate *) delegate
{
    if(!_delegate) {
        _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return _delegate;
}

- (NSMutableArray *) dossierToDelete
{
    if(!_dossierToDelete) {
        _dossierToDelete = [NSMutableArray new];
    }
    
    return _dossierToDelete;
}

#pragma mark - init en dealloc
- (id) init
{
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(purgeDossiers:)
                                                 name:NOTIFICATION_PURGE_DOSSIERS
                                               object:nil];
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - synchronisation features
- (void) synchronizeDossiersAndVouchersFromBackofficeInContext:(NSManagedObjectContext *)context
{
    // ----------------------------------------------------------------------
    // Dossiers
    
    NSArray *currentDossiers = [Dossier findAllDossiersWithContext:context];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_WAIT
                                                        object:self];
    
    //only delete dossiers that have been marked as synchronized.
    for (Dossier *dossier in currentDossiers) {
        if([dossier.hasBeenSynchd isEqualToValue:@0]) {
            //dossier has not been synchronized yet, attempt to do so
            [dossier performSaveToBackoffice];
        } else {
            [self.dossierToDelete addObject:dossier];
        }
    }
    
    
    [self.restService get:[NSString stringWithFormat:NEW_VOUCHERS_API, self.delegate.authenticatedUser.token]
           withParameters:nil
          onCompleteBlock:^(NSDictionary *json) {
              NSLog(@"Results: %@", json);
              
              __block int i = 0;
              
              if(json && json.count == 0) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PURGE_DOSSIERS
                                                                      object:self];
              }
              
              for (NSDictionary *item in json) {
                  [self.restService get:[NSString stringWithFormat:DOSSIER_BY_ID, [item objectForKey:@"dossier_id"], self.delegate.authenticatedUser.token]
                         withParameters:nil
                        onCompleteBlock:^(NSDictionary *data) {
                            i++;
                            NSDictionary *dossierData = [data objectForKey:@"dossier"];
                            
                            Dossier *dossier = [[Dossier alloc] initFromDictionary:dossierData withContext:context];
                            
                            [self.dossierToDelete removeObjectIdenticalTo:dossier];
                            
                            NSLog(@"Synchronized dossier: %@", dossier.id);
                            
                            [self.delegate saveContext];
                            
                            if(i >= json.count)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PURGE_DOSSIERS
                                                                                    object:self];
                            }
                            
                        } onFailBlock:^(NSError *error) {
                            NSLog(@"Error while processing vouchers: %@", error);
                        }];
              }
              
              
              [context save:nil];
              
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDE_WAIT
                                                                  object:self];
          } onFailBlock:^(NSError *error) {
              NSLog(@"Failed to fetch new vouchers: %@", error);
              
              [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDE_WAIT
                                                                  object:self];
          }];
}

- (void) purgeDossiers:(NSNotification *) notification
{
    NSManagedObjectContext *context = self.delegate.managedObjectContext;
    
    if([notification.name isEqualToString:NOTIFICATION_PURGE_DOSSIERS]) {
        for (Dossier *dossier in self.dossierToDelete) {
            NSLog(@"Dossier up for delete: %@", dossier.id);
            
            [context deleteObject:dossier];
        }
        
        self.dossierToDelete = nil;
        
        [context save:nil];
    }
}


- (void) createTowingVoucherForDossier:(Dossier *)dossier
{    
    NSString *api = [NSString stringWithFormat:NEW_VOUCHER_FOR_DOSSIER_API, dossier.id, self.delegate.authenticatedUser.token];
    
    [self.restService post:api
            withParameters:nil
           onCompleteBlock:^(NSDictionary *json) {
               NSLog(@"Results: %@", json);
               
               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nieuwe takelbon"
                                                               message:@"Nieuwe takelbon beschikbaar. Ga naar het overzichtscherm!"
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
               [alert show];
               
               [self synchronizeDossiersAndVouchersFromBackofficeInContext:dossier.managedObjectContext];
           } onFailBlock:^(NSError *error, int statusCode) {
               NSLog(@"Failed to fetch new vouchers: %d, %@", statusCode, error);
               
               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fout"
                                                               message:[NSString stringWithFormat:@"Er is een fout opgetreden bij het aanmaken van een nieuwe takelbon: %d - %@", statusCode, error.description ]
                                                              delegate:self
                                                     cancelButtonTitle:@"Annuleren"
                                                     otherButtonTitles:nil];
               [alert show];
           }];
}

- (BOOL) isMetaDataSynchRequiredWithContext:(NSManagedObjectContext *) context
{
    NSArray *data = [TrafficLane findAll:context];
    
    return !(data && data.count > 0);
}

- (void) synchronizeMetadataWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    [self refreshVehiclesWithContext:context token:token];
    
    [self refreshTrafficPostsWithContext:context token:token];
    
    [self refreshTimeframeDataWithContext:context token:token];
    
    [self refreshCountryLicencePlatesWithContext:context token:token];
    
    [self refreshAllotmentDirectionsWithContext:context token:token];
    
    [self refreshTrafficLanesWithContext:context token:token];
}

- (void) refreshVehiclesWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    NSString *api = [NSString stringWithFormat:VOCAB_VEHICLES, token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            Vehicle *post = [[Vehicle alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized vehicle: %@", post.name);
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshTrafficLanesWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    NSString *api = [NSString stringWithFormat:VOCAB_TRAFFIC_LANES, token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            TrafficLane *post = [[TrafficLane alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized trafficlane: %@", post.name);
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshAllotmentDirectionsWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    NSString *api = [NSString stringWithFormat:@"/vocab/directions/%@", token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            AllotmentDirection *post = [[AllotmentDirection alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized direction: %@", post.name);
                
                [self refreshIndicatorsForDirection:post inContext:context token:token];
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshIndicatorsForDirection:(AllotmentDirection *) direction inContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    NSString *api = [NSString stringWithFormat:@"/vocab/indicators/%@/%@", direction.id, token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            AllotmentDirectionIndicator *post = [[AllotmentDirectionIndicator alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized %@ for %@", post.name, direction.name);
                
                
                [direction addIndicatorsObject:post];
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshCountryLicencePlatesWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    
    NSString *api = [NSString stringWithFormat:@"/vocab/country_licence_plates/%@", token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            LicencePlateCountry *post = [[LicencePlateCountry alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized licence plate: %@", post.name);
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshTrafficPostsWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    // ----------------------------------------------------------------------
    // police traffic post
    NSString *company_id = [self.delegate.authenticatedUser.jsonObject valueForKeyPath:@"company.id"];
    
    NSString *api = [NSString stringWithFormat:@"/vocab/trafficpost/allotment/%@/%@", company_id, token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            TrafficPost *post = [[TrafficPost alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized trafficpost: %@", post.name);
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshTimeframeDataWithContext:(NSManagedObjectContext *) context token:(NSString *)token
{
    // ----------------------------------------------------------------------
    // timeframes en stuff
    [self.restService get:[NSString stringWithFormat:VOCAB_TIMEFRAMES, token] withParameters:nil onCompleteBlock:^(NSDictionary *json) {
        
        //save the timeframes
        for(NSDictionary *item in json)
        {
            Timeframe *timeframe = [[Timeframe alloc] initFromDictionary:item withContext:context];
            
            NSLog(@"Synchronized timeframe: %@", timeframe.name);
            
            [self refreshTimeframeActivityFeesForTimeframe:timeframe.id inContext:context token:token];
        }
        
        [self.delegate saveContext];
        
        [self refreshTimeframeActivitiesWithContext:context token:token];
        
    } onFailBlock:^(NSError * error) {
        //woeps
        NSLog(@"%@", error);
    }];
}

- (void) refreshTimeframeActivitiesWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    //save the activities
    [self.restService get:[NSString stringWithFormat:VOCAB_TIMEFRAME_ACTIVITIES, token] withParameters:nil onCompleteBlock:^(NSDictionary *activitiesData) {
        NSLog(@"%@", activitiesData);
        
        for(NSDictionary *item in activitiesData) {
            TimeframeActivity *activity = [[TimeframeActivity alloc] initFromDictionary:item withContext:context];
            
            NSLog(@"Synchronized timeframe activity: %@", activity.name);
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //woeps
        NSLog(@"%@", error);
    }];
}

- (void) refreshTimeframeActivityFeesForTimeframe:(NSNumber *)timeframe inContext:(NSManagedObjectContext *)context token:(NSString *)token
{
    //save the activity fees
    [self.restService get:[NSString stringWithFormat:VOCAB_TIMEFRAME_ACTIVITY_FEES, timeframe , token] withParameters:nil onCompleteBlock:^(NSDictionary *activitiesData) {
        DLog(@"%@", activitiesData);
        
        for(NSDictionary *item in activitiesData) {
            TimeframeActivityFee *fee = [[TimeframeActivityFee alloc] initFromDictionary:item withContext:context];
            DLog(@"---- TimeframeActivityFee -------" );
            DLog(@"%@", item);
            DLog(@"Synchronized timeframe activity fee: %@/%@/%@", fee.id, fee.fee_excl_vat, fee.fee_incl_vat);
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //woeps
        NSLog(@"%@", error);
    }];
}

@end
