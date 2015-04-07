//
//  TowingActivity.h
//  towing
//
//  Created by Kris Vandermast on 21/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TowingVoucher;

@interface TowingActivity : NSManagedObject

@property (nonatomic, retain) TowingVoucher *towing_voucher;

@end
