//
//  RestService.m
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "RestService.h"
#import "AFNetworking.h"


@interface RestService()
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSURL *baseUrl;
@end

@implementation RestService


#pragma mark - init
- (id) init
{
    self = [super init];
    
    return self;
}

#pragma mark - property setters and getters
- (AFHTTPRequestOperationManager *) manager {
    if(!_manager) {
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.baseUrl];
        [_manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",
                                                                                   @"text/plain",
                                                                                   @"application/json"]];
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [securityPolicy setAllowInvalidCertificates:YES];
        
        [_manager setSecurityPolicy:securityPolicy];
    }
    
    return _manager;
}

- (NSURL *) baseUrl
{
    if(!_baseUrl) {
        _baseUrl = [NSURL URLWithString:BASE_URL];
    }
    
    return _baseUrl;
}

#pragma mark - service implementations
- (void) get: (NSString *) url  withParameters:(NSDictionary *) requestParams onCompleteBlock:(void (^)(NSDictionary*)) onCompleteHandler onFailBlock:(void (^)(NSError*)) onFailureHandler {
    
    if(![self connected])
    {
        NSError *error = [NSError errorWithDomain:ERROR_DOMAIN_CONNECTION code:ERROR_DOMAIN_CONNECTION_CODE userInfo:requestParams];
        onFailureHandler(error);
    }
    else
    {
        AFHTTPRequestOperation *operation = nil;
        
        DLog(@"%s -- GET -- %@", __PRETTY_FUNCTION__, url);
        
        operation = [self.manager GET:url
                           parameters:requestParams
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  //execute onsuccess
                                  NSLog(@"%s - SUCCESS - %@", __PRETTY_FUNCTION__, url);
                                  
                                  if(onCompleteHandler) {
                                      NSLog(@"%s   ->> Execute onCompleteHandler", __PRETTY_FUNCTION__);
                                      NSString *response = [operation responseString];
                                      
                                      NSError *error;
                                      NSData* myResponseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                                      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:myResponseData
                                                                                           options:kNilOptions
                                                                                             error:&error];
                                      
                                      if(error) {
                                          NSLog(@"%s    --> Error while decoding to NSDictionary: \n%@", __PRETTY_FUNCTION__, error);
                                          onCompleteHandler(nil);
                                      } else {
                                          onCompleteHandler(json);
                                      }
                                  }
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  //execute onfailure
                                  NSLog(@"%s Executing failureBlock", __PRETTY_FUNCTION__);
                                  NSLog(@"%s    --> URL: %@", __PRETTY_FUNCTION__, url);
                                  NSLog(@"%s    --> Error: \n%@", __PRETTY_FUNCTION__, error);
                                  NSLog(@"%s    --> Operation response: %@", __PRETTY_FUNCTION__, [operation.response description]);
                                  NSLog(@"%s    --> Parameters sent: %@", __PRETTY_FUNCTION__, requestParams);
                                  
                                  if(onFailureHandler) {
                                      onFailureHandler(error);
                                  } else {
                                      NSLog(@"%s    --> onFailureHandler block was nil", __PRETTY_FUNCTION__);
                                  }
                              }];
        
        [operation start];
    }
}

- (void) post:(NSString *) url  withParameters:(NSDictionary *) requestParams onCompleteBlock:(void (^)(NSDictionary*)) onCompleteHandler onFailBlock:(void (^)(NSError*,int)) onFailureHandler
{
    if(![self connected])
    {
        NSError *error = [NSError errorWithDomain:ERROR_DOMAIN_CONNECTION code:ERROR_DOMAIN_CONNECTION_CODE userInfo:requestParams];
        onFailureHandler(error, ERROR_DOMAIN_CONNECTION_CODE);
    }
    else
    {
        AFHTTPRequestOperation *operation = nil;
        
        NSError *error;
        NSDictionary *jsonData = requestParams;
        
        if (! jsonData && requestParams) { //only fail if we had request params, but didn't get a converted jsonData object
            NSLog(@"Got an error: %@", error);
            onFailureHandler(error, -1);
        } else {
            // NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            operation = [self.manager POST:url parameters:jsonData //previously jsonString
                                   success:^(AFHTTPRequestOperation *operation, id responseObject)
                         {
                             //execute onsuccess
                             if(onCompleteHandler) {
                                 NSLog(@"%s   ->> Execute onCompleteHandler", __PRETTY_FUNCTION__);
                                 NSString *response = [operation responseString];
                                 
                                 NSError *error;
                                 NSData* myResponseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                                 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:myResponseData
                                                                                      options:kNilOptions
                                                                                        error:&error];
                                 
                                 if(error) {
                                     NSLog(@"%s    --> Error while decoding to NSDictionary: \n%@", __PRETTY_FUNCTION__, error);
                                     onCompleteHandler(nil);
                                 } else {
                                     onCompleteHandler(json);
                                 }
                             }
                         }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error)
                         {
                             // operation.response.statusCode
                             
                             //execute onfailure
                             NSLog(@"%s Executing failureBlock", __PRETTY_FUNCTION__);
                             NSLog(@"%s    --> URL: %@", __PRETTY_FUNCTION__, url);
                             NSLog(@"%s    --> Error: \n%@", __PRETTY_FUNCTION__, error);
                             NSLog(@"%s    --> Operation response: %@", __PRETTY_FUNCTION__, [operation.response description]);
                             NSLog(@"%s    --> Parameters sent: %@", __PRETTY_FUNCTION__, requestParams);
                             
                             if(onFailureHandler) {
                                 onFailureHandler(error, (int) operation.response.statusCode);
                             } else {
                                 NSLog(@"%s    --> onFailureHandler block was nil", __PRETTY_FUNCTION__);
                             }
                         }];
            
            [operation start];
        }
    }
}

- (void) put:(NSString *) url  withParameters:(NSDictionary *) requestParams onCompleteBlock:(void (^)(NSDictionary*)) onCompleteHandler onFailBlock:(void (^)(NSError*, int statusCode)) onFailureHandler
{
    if(![self connected])
    {
        NSError *error = [NSError errorWithDomain:ERROR_DOMAIN_CONNECTION code:ERROR_DOMAIN_CONNECTION_CODE userInfo:requestParams];
        onFailureHandler(error, ERROR_DOMAIN_CONNECTION_CODE);
    }
    else
    {
        AFHTTPRequestOperation *operation = nil;
        
        NSError *error;
        
        NSDictionary *jsonData = requestParams;
        
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
            onFailureHandler(error, -1);
        } else {
            operation = [self.manager PUT:url parameters:jsonData //previously jsonString
                                  success:^(AFHTTPRequestOperation *operation, id responseObject)
                         {
                             //execute onsuccess
                             if(onCompleteHandler) {
                                 NSString *response = [operation responseString];
                                 
                                 NSLog(@"==> Response:, ");
                                 NSLog(@"%@", response);
                                 NSLog(@"<== Response");
                                 
                                 NSError *error;
                                 NSData* myResponseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                                 NSDictionary *json = myResponseData ? [NSJSONSerialization JSONObjectWithData:myResponseData
                                                                                                       options:kNilOptions
                                                                                                         error:&error] : @{};
                                 
                                 if(error) {
                                     onCompleteHandler(nil);
                                 } else {
                                     onCompleteHandler(json);
                                 }
                             }
                         }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
                         {
                             // operation.response.statusCode
                             
                             //execute onfailure
                             NSLog(@"%s Executing failureBlock", __PRETTY_FUNCTION__);
                             NSLog(@"   --> URL: %@",  url);
                             NSLog(@"   --> Error: \n%@",  error);
                             NSLog(@"   --> Operation response: %@", [operation responseString]);
                             NSLog(@"    --> Parameters sent: %@",  requestParams);
                             
                             if(onFailureHandler) {
                                 onFailureHandler(error, (int) operation.response.statusCode);
                             } else {
                                 NSLog(@"%s    --> onFailureHandler block was nil", __PRETTY_FUNCTION__);
                             }
                         }];
            
            [operation start];
        }
    }
}

- (void) del:(NSString *) url  withParameters:(NSDictionary *) requestParams onCompleteBlock:(void (^)(NSDictionary*)) onCompleteHandler onFailBlock:(void (^)(NSError*, int statusCode)) onFailureHandler
{
    if(![self connected])
    {
        NSError *error = [NSError errorWithDomain:ERROR_DOMAIN_CONNECTION code:ERROR_DOMAIN_CONNECTION_CODE userInfo:requestParams];
        onFailureHandler(error, ERROR_DOMAIN_CONNECTION_CODE);
    }
    else
    {
        AFHTTPRequestOperation *operation = nil;
        
//        NSError *error;
        
        NSDictionary *jsonData = requestParams;
        
        
        operation = [self.manager DELETE:url parameters:jsonData //previously jsonString
                                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                     {
                         //execute onsuccess
                         if(onCompleteHandler) {
                             NSString *response = [operation responseString];
                             
                             NSLog(@"==> Response:, ");
                             NSLog(@"%@", response);
                             NSLog(@"<== Response");
                             
                             NSError *error;
                             NSData* myResponseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                             NSDictionary *json = myResponseData ? [NSJSONSerialization JSONObjectWithData:myResponseData
                                                                                                   options:kNilOptions
                                                                                                     error:&error] : @{};
                             
                             if(error) {
                                 onCompleteHandler(nil);
                             } else {
                                 onCompleteHandler(json);
                             }
                         }
                     }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
                     {
                         // operation.response.statusCode
                         
                         //execute onfailure
                         NSLog(@"%s Executing failureBlock", __PRETTY_FUNCTION__);
                         NSLog(@"   --> URL: %@",  url);
                         NSLog(@"   --> Error: \n%@",  error);
                         NSLog(@"   --> Operation response: %@", [operation responseString]);
                         NSLog(@"    --> Parameters sent: %@",  requestParams);
                         
                         if(onFailureHandler) {
                             onFailureHandler(error, (int) operation.response.statusCode);
                         } else {
                             NSLog(@"%s    --> onFailureHandler block was nil", __PRETTY_FUNCTION__);
                         }
                     }];
        
        [operation start];
        
    }
}

- (BOOL)connected
{
    if([BASE_URL isEqualToString:@"http://localhost:8443"])
    {
        return true;
    }
    
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

@end

