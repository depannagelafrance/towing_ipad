//
//  VatUtil.h
//  towing
//
//  Created by Kris Vandermast on 07/01/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VatUtil : NSObject
+ (void) checkVatNumber:(NSString *) vatNumber onSuccess:(void (^)(NSDictionary*)) onSuccessHandler onFailure:(void (^)(NSError*)) onFailureHandler;
@end
