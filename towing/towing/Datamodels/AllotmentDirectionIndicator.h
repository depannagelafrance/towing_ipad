//
//  AllotmentDirectionIndicator.h
//  
//
//  Created by Kris Vandermast on 14/04/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AllotmentDirection;

@interface AllotmentDirectionIndicator : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) AllotmentDirection *direction;

@end
