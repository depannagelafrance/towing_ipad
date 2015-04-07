//
//  TowingVoucher+Model.h
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "TowingVoucher.h"

@interface TowingVoucher (Model)
- (TowingVoucher *) initFromDictionary:(NSDictionary *) data withContext:(NSManagedObjectContext *) context;

+ (TowingVoucher *) findVoucherById: (NSString *) identifier withContext:(NSManagedObjectContext *) context;

+ (NSArray *) findAllVouchersWithContext:(NSManagedObjectContext *) context;

- (void) jsonValue:(NSString *)value forKey:(NSString *) key;
- (void) jsonObject:(id) value forKey:(NSString *) key;

- (id) jsonObjectForKey:(NSString *) key;

- (void) addTowingSignatureWithCategory:(NSString *) category inLocation:(NSString *) path;
- (void) addTowingMessage:(NSString *) message;

@end
