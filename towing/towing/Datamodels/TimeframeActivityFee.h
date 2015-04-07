//
//  TimeframeActivityFee.h
//  towing
//
//  Created by Kris Vandermast on 03/11/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimeframeActivityFee : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * timeframe_id;
@property (nonatomic, retain) NSNumber * fee_incl_vat;
@property (nonatomic, retain) NSNumber * fee_excl_vat;
@property (nonatomic, retain) NSNumber * timeframe_activity_id;

@end
