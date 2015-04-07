//
//  BaseViewController.h
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestService.h"
#import "AppDelegate.h"

@interface BaseViewController : UIViewController
@property (strong, nonatomic) RestService *restService;
@property (readonly, nonatomic) AppDelegate *delegate;

- (void) showWaitMessage;
- (void) triggerErrorMessage:(NSString *) message;
- (void) triggerInfoMessage:(NSString *) info;
- (void) hideWaitMessage;
@end
