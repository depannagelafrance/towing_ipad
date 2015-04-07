//
//  RestService.h
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestService : NSObject
- (void) get: (NSString *) url  withParameters:(NSDictionary *) requestParams onCompleteBlock:(void (^)(NSDictionary*)) onCompleteHandler onFailBlock:(void (^)(NSError*)) onFailureHandler;
- (void) post:(NSString *) url  withParameters:(NSDictionary *) requestParams onCompleteBlock:(void (^)(NSDictionary*)) onCompleteHandler onFailBlock:(void (^)(NSError*, int statusCode)) onFailureHandler;
- (void) put:(NSString *) url  withParameters:(NSDictionary *) requestParams onCompleteBlock:(void (^)(NSDictionary*)) onCompleteHandler onFailBlock:(void (^)(NSError*, int statusCode)) onFailureHandler;
- (void) del:(NSString *) url  withParameters:(NSDictionary *) requestParams onCompleteBlock:(void (^)(NSDictionary*)) onCompleteHandler onFailBlock:(void (^)(NSError*, int statusCode)) onFailureHandler;
@end
