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
#import "AppDelegate.h"


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
          } onFailBlock:^(NSError *error) {
              NSLog(@"Failed to fetch new vouchers: %@", error);
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
@end
