//
//  SettingsViewController.m
//  towing
//
//  Created by Kris Vandermast on 24/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "SettingsViewController.h"
#import "SignatureViewController.h"
#import "SharedPreferences.h"
#import "Timeframe+Model.h"
#import "TimeframeActivity+Model.h"
#import "TimeframeActivityFee+Model.h"
#import "TrafficPost+Model.h"
#import "LicencePlateCountry+Model.h"
#import "AllotmentDirection+Model.h"
#import "AllotmentDirectionIndicator+Model.h"
#import "TrafficLane+Model.h"
#import "Vehicle+Model.h"
#import "SynchronisationHandler.h"

#define UPDATE_PROFILE                  @"/me/%@"
#define UPDATE_COMPANY_MOBILE_REG_ID    @"/admin/company/mobile/%@"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *apnsLabelTextField;

@property (weak, nonatomic) IBOutlet UISwitch *officeSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *signatureImageView;

@property (strong, nonatomic) UIPopoverController *popover;
@end

@implementation SettingsViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentUserNameLabel.text = [NSString stringWithFormat:@"Hallo, %@", self.delegate.authenticatedUser.first_name];
    self.apnsLabelTextField.text = [SharedPreferences fetchRegistrationId];
    
    self.officeSwitch.on = [SharedPreferences isOfficeTab];
    
    [self.signatureImageView setImage:[UIImage imageWithContentsOfFile:[SharedPreferences fetchSignatureLocation]]];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)signatureAction:(id)sender
{
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    SignatureViewController *viewController = [[SignatureViewController alloc] initWithNibName:@"SignatureView" bundle:nil];
    viewController.token = delegate.authenticatedUser.token;
    viewController.category = @"signature_signa";
    viewController.signatureImageView = self.signatureImageView;
    
    __block User* user = self.delegate.authenticatedUser;
    
    viewController.signatureBlock = ^(NSString *path) {
        NSLog(@"Wrote image to directory: %@", path);
        
        NSData *signaturePNG = [NSData dataWithContentsOfFile:path];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        
        NSString *api = [NSString stringWithFormat:@"/me/signature/%@", user.token];
        NSDictionary *params = @{@"content_type": @"image/png",
                                 @"file_size" : fileSizeNumber,
                                 @"content" : [signaturePNG base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]};
        
        RestService *restService = [[RestService alloc] init];
        
        [restService post:api withParameters:params onCompleteBlock:^(NSDictionary *result) {
            NSLog(@"Added the attachment in the back-end: %@", result);
            [SharedPreferences storeSignatureLocation:path];
            [self.signatureImageView setImage:[UIImage imageWithContentsOfFile:path]];
            [self.popover dismissPopoverAnimated:YES];
        } onFailBlock:^(NSError *error, int statusCode) {
            NSLog(@"Failed to send signature to back-end: %ul - %@", statusCode, error);
        }];
    };
    
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.delegate = self;
    self.popover.popoverContentSize = CGSizeMake(self.view.frame.size.width+320, self.view.frame.size.height);
    self.popover.passthroughViews = [NSArray arrayWithObject:self.view];
    
    [self.popover presentPopoverFromRect:CGRectMake(0, 0, self.view.frame.size.width+320, self.view.frame.size.height)
                                  inView:self.view
                permittedArrowDirections:0
                                animated:YES];
}

- (IBAction)saveProfileAction:(id)sender
{
    if(![SharedPreferences fetchRegistrationId]) {
        [self triggerErrorMessage:@"Er is geen APNS registratie nummer gevonden. Probleer later opnieuw"];
    } else {
        NSString *api = [NSString stringWithFormat:UPDATE_PROFILE, self.delegate.authenticatedUser.token];
        NSDictionary *params = @{@"registration_id": [SharedPreferences fetchRegistrationId]};
        
        [SharedPreferences storeIsOfficeTab:self.officeSwitch.on];
        
        [self showWaitMessage];
        
        [self.restService put:api withParameters:params onCompleteBlock:^(NSDictionary *result) {
            [self hideWaitMessage];
            [self triggerInfoMessage:@"Profiel werd aangepast"];
        } onFailBlock:^(NSError *error, int statusCode) {
            NSLog(@"Failed to send signature to back-end: %ul - %@", statusCode, error);
            [self triggerErrorMessage:[NSString stringWithFormat:@"Fout: %ul - %@", statusCode, error]];
        }];
        
        if([SharedPreferences isOfficeTab])
        {
            NSString *updateApi = [NSString stringWithFormat:UPDATE_COMPANY_MOBILE_REG_ID, self.delegate.authenticatedUser.token];
            
            [self.restService put:updateApi withParameters:@{@"registration_id" : [SharedPreferences fetchRegistrationId]} onCompleteBlock:^(NSDictionary *json) {
                //ignore
            } onFailBlock:^(NSError *error, int statusCode) {
                //ignore
            }];
        }
    }
}

- (void) backAction:(id) sender
{
    NSLog(@"on back pressed");
}

- (IBAction)refreshSettingsAction:(id)sender
{
    NSString *token = self.delegate.authenticatedUser.token;
    NSManagedObjectContext *context =  self.delegate.managedObjectContext;
    
    SynchronisationHandler *handler = [[SynchronisationHandler alloc] init];
    
    [handler synchronizeMetadataWithContext:context token:token];
}

@end
