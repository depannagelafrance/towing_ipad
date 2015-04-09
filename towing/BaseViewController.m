//
//  BaseViewController.m
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "BaseViewController.h"
#import "RestService.h"
#import "Crouton.h"

#define CROUTON_PLEASE_WAIT @"Even geduld aub."

@interface BaseViewController (){
    Crouton *waitMessage;
}

@end

@implementation BaseViewController
#pragma mark - getters and setters
- (RestService *) restService
{
    if(!_restService) {
        _restService = [[RestService alloc] init];
    }
    
    return _restService;
}

- (AppDelegate *) delegate
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return delegate;
}


#pragma mark - view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Crouton actions
- (void) showWaitMessage
{
    waitMessage = [Crouton pleaseWait:CROUTON_PLEASE_WAIT inView:self.view];
}

- (void) triggerErrorMessage:(NSString *) message
{
    if(waitMessage)
    {
        [self hideWaitMessage];
    }
    
    [[Crouton alert:message inView:self.parentViewController.view] show];
}

- (void) triggerInfoMessage:(NSString *) info
{
    [[Crouton info:info inView:self.parentViewController.view] show];
}

- (void) hideWaitMessage
{
    [waitMessage dismiss];
    waitMessage = nil;
}


- (NSUInteger) supportedInterfaceOrientations
{
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskLandscape;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationLandscapeLeft;
}

@end
