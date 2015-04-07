//
//  TowingMessage.h
//  towing
//
//  Created by Kris Vandermast on 24/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TowingVoucher;

@interface TowingMessage : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) TowingVoucher *towingVoucher;

@end
