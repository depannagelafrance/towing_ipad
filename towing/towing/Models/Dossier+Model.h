//
//  Dossier+Model.h
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "Dossier.h"

@interface Dossier (Model)
- (Dossier *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;
- (NSMutableDictionary *) jsonObject;

- (void) jsonValue:(NSString *)value forKey:(NSString *) key;
- (void) jsonObject:(id) value forKey:(NSString *) key;

- (id) jsonObjectForKey:(NSString *) key;
- (void) performSaveToBackoffice;

+ (Dossier *) findDossierById: (NSString *)id withContext:(NSManagedObjectContext *) context;

+ (NSArray *) findAllDossiersWithContext:(NSManagedObjectContext *) context;
@end
