//
//  AllotmentDirection.h
//  towing
//
//  Created by Kris Vandermast on 02/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AllotmentDirectionIndicator;

@interface AllotmentDirection : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *indicators;
@end

@interface AllotmentDirection (CoreDataGeneratedAccessors)

- (void)addIndicatorsObject:(AllotmentDirectionIndicator *)value;
- (void)removeIndicatorsObject:(AllotmentDirectionIndicator *)value;
- (void)addIndicators:(NSSet *)values;
- (void)removeIndicators:(NSSet *)values;

@end
