//
//  SynchronisationHandler.h
//  towing
//
//  Created by Kris Vandermast on 10/11/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Dossier.h"

@interface SynchronisationHandler : NSObject
- (void) synchronizeDossiersAndVouchersFromBackofficeInContext:(NSManagedObjectContext *)context;
- (void) createTowingVoucherForDossier:(Dossier *) dossier;
- (void) purgeDossiers:(NSNotification *) notification;
@end
