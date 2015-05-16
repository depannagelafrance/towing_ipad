//
//  LoginViewController.m
//  towing
//
//  Created by Kris Vandermast on 29/09/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "LoginViewController.h"
#import "RestService.h"
#import "SharedPreferences.h"
#import "AppDelegate.h"
#import "User+Model.h"
#import "Dossier+Model.h"
#import "SynchronisationHandler.h"
#import "Crouton.h"

#define LOGIN_API                       @"/login"

#define AUTHENTICATION_FAILED           @"Inloggen mislukt. Probeer opnieuw!"
#define UNABLE_TO_AUTHENTICATE          @ "Er is een fout opgetreden bij de authenticatie. Probeer later opnieuw!"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) UIStoryboard *mainStoryBoard;
@end

@implementation LoginViewController

#pragma mark - Lifecycle events

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userNameTextField.text = [SharedPreferences fetchUsername];
    self.passwordTextField.text = DEBUG ? @"T0w1nG" : @"";
}

#pragma mark - Getters

- (UIStoryboard *) mainStoryBoard {
    if(!_mainStoryBoard) {
        _mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    
    return _mainStoryBoard;
}

#pragma mark - IBActions

- (IBAction)performLoginAction:(id)sender
{
    NSString *login = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    NSDictionary *params = @{@"login": login,
                             @"password": password};
    
    [self showWaitMessage];
    
    [self.restService post:LOGIN_API withParameters:params
           onCompleteBlock:^(NSDictionary *json) {
               DLog(@"Authenticated!");
               
               NSManagedObjectContext *context =  self.delegate.managedObjectContext;
               
               User *user = [[User alloc] initFromDictionary:json withContext:context];
               
               if(user) {
                   [self.delegate saveContext];
                   
                   self.delegate.authenticatedUser = user;
                   
                   [SharedPreferences storeUsername:user.login];
                   
                   SynchronisationHandler *handler = [[SynchronisationHandler alloc] init];
                   [handler synchronizeDossiersAndVouchersFromBackofficeInContext:context];
                   
                   if([handler isMetaDataSynchRequiredWithContext:context]) {
                       [handler synchronizeMetadataWithContext:context token:self.delegate.authenticatedUser.token];
                   }
                   
                   [self hideWaitMessage];
                   
                   UINavigationController *viewController = (UINavigationController *) [self.mainStoryBoard instantiateViewControllerWithIdentifier:@"voucherOverviewNavigationControllerStoryboard"];
                   
                   [self presentViewController:viewController animated:YES completion:nil];
               } else {
                   [self triggerErrorMessage:UNABLE_TO_AUTHENTICATE];
               }
           } onFailBlock:^(NSError *error, int statusCode) {
               DLog(@"Failed to authenticated!");
               DLog(@" --> Status Code: %u", statusCode);
               DLog(@" --> %@", error);
               
               [self hideWaitMessage];
               
               
               [[Crouton alert:AUTHENTICATION_FAILED inView:self.view] show];
           } ];
}



@end
