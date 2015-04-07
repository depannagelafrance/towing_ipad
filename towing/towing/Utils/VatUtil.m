//
//  VatUtil.m
//  towing
//
//  Created by Kris Vandermast on 07/01/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "VatUtil.h"
#import "RestService.h"


#define VAT_API @"/util/vat"

@implementation VatUtil
+ (void) checkVatNumber:(NSString *) vatNumber onSuccess:(void (^)(NSDictionary*)) onSuccessHandler onFailure:(void (^)(NSError*)) onFailureHandler {
    const RestService *service = [[RestService alloc] init];
    
    [service post:VAT_API withParameters:@{@"vat": vatNumber} onCompleteBlock:^(NSDictionary *result) {
        onSuccessHandler(result);
    } onFailBlock:^(NSError *error, int statusCode) {
        if(statusCode == ERROR_DOMAIN_CONNECTION_CODE) {            
            onFailureHandler(nil);
        } else {
            onFailureHandler(error);
        }
    }];
}
@end
