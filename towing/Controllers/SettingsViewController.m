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

#define VOCAB_TIMEFRAMES                @"/vocab/timeframe/%@"
#define VOCAB_TIMEFRAME_ACTIVITIES      @"/vocab/timeframe/activities/%@"
#define VOCAB_TIMEFRAME_ACTIVITY_FEES   @"/vocab/timeframe/activity/%@/fees/%@"
#define VOCAB_TRAFFIC_LANES             @"/vocab/traffic_lanes/%@"
#define VOCAB_VEHICLES                  @"/vocab/vehicles/%@"

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

- (void)didReceiveMemoryWarning {
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
    
    
    [self refreshVehiclesWithContext:context token:token];
    
    [self refreshTrafficPostsWithContext:context token:token];
    
    [self refreshTimeframeDataWithContext:context token:token];
    
    [self refreshCountryLicencePlatesWithContext:context token:token];
    
    [self refreshAllotmentDirectionsWithContext:context token:token];
    
    [self refreshTrafficLanesWithContext:context token:token];
}

- (void) refreshVehiclesWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    NSString *api = [NSString stringWithFormat:VOCAB_VEHICLES, token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            Vehicle *post = [[Vehicle alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized vehicle: %@", post.name);
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshTrafficLanesWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    NSString *api = [NSString stringWithFormat:VOCAB_TRAFFIC_LANES, token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            TrafficLane *post = [[TrafficLane alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized trafficlane: %@", post.name);
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshAllotmentDirectionsWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    NSString *api = [NSString stringWithFormat:@"/vocab/directions/%@", token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            AllotmentDirection *post = [[AllotmentDirection alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized direction: %@", post.name);
                
                [self refreshIndicatorsForDirection:post inContext:context token:token];
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshIndicatorsForDirection:(AllotmentDirection *) direction inContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    NSString *api = [NSString stringWithFormat:@"/vocab/indicators/%@/%@", direction.id, token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            AllotmentDirectionIndicator *post = [[AllotmentDirectionIndicator alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized %@ for %@", post.name, direction.name);
                
                
                [direction addIndicatorsObject:post];
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshCountryLicencePlatesWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    
    NSString *api = [NSString stringWithFormat:@"/vocab/country_licence_plates/%@", token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            LicencePlateCountry *post = [[LicencePlateCountry alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized licence plate: %@", post.name);
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshTrafficPostsWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    // ----------------------------------------------------------------------
    // police traffic post
    NSString *company_id = [self.delegate.authenticatedUser.jsonObject valueForKeyPath:@"company.id"];
    
    NSString *api = [NSString stringWithFormat:@"/vocab/trafficpost/allotment/%@/%@", company_id, token];
    
    [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
        for (NSDictionary *item in data)
        {
            TrafficPost *post = [[TrafficPost alloc] initFromDictionary:item withContext:context];
            
            if(post)
            {
                NSLog(@"Synchronized trafficpost: %@", post.name);
            }
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //process error
        NSLog(@"Error while accessing: %@, %@", api, error);
    }];
}

- (void) refreshTimeframeDataWithContext:(NSManagedObjectContext *) context token:(NSString *)token
{
    // ----------------------------------------------------------------------
    // timeframes en stuff
    [self.restService get:[NSString stringWithFormat:VOCAB_TIMEFRAMES, token] withParameters:nil onCompleteBlock:^(NSDictionary *json) {
        
        //save the timeframes
        for(NSDictionary *item in json)
        {
            Timeframe *timeframe = [[Timeframe alloc] initFromDictionary:item withContext:context];
            
            NSLog(@"Synchronized timeframe: %@", timeframe.name);
            
            [self refreshTimeframeActivityFeesForTimeframe:timeframe.id inContext:context token:token];
        }
        
        [self.delegate saveContext];
        
        [self refreshTimeframeActivitiesWithContext:context token:token];
        
    } onFailBlock:^(NSError * error) {
        //woeps
        NSLog(@"%@", error);
    }];
}

- (void) refreshTimeframeActivitiesWithContext:(NSManagedObjectContext *) context token:(NSString *) token
{
    //save the activities
    [self.restService get:[NSString stringWithFormat:VOCAB_TIMEFRAME_ACTIVITIES, token] withParameters:nil onCompleteBlock:^(NSDictionary *activitiesData) {
        NSLog(@"%@", activitiesData);
        
        for(NSDictionary *item in activitiesData) {
            TimeframeActivity *activity = [[TimeframeActivity alloc] initFromDictionary:item withContext:context];
            
            NSLog(@"Synchronized timeframe activity: %@", activity.name);
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //woeps
        NSLog(@"%@", error);
    }];
}

- (void) refreshTimeframeActivityFeesForTimeframe:(NSNumber *)timeframe inContext:(NSManagedObjectContext *)context token:(NSString *)token
{
    //save the activity fees
    [self.restService get:[NSString stringWithFormat:VOCAB_TIMEFRAME_ACTIVITY_FEES, timeframe , token] withParameters:nil onCompleteBlock:^(NSDictionary *activitiesData) {
        DLog(@"%@", activitiesData);
        
        for(NSDictionary *item in activitiesData) {
            TimeframeActivityFee *fee = [[TimeframeActivityFee alloc] initFromDictionary:item withContext:context];
            DLog(@"---- TimeframeActivityFee -------" );
            DLog(@"%@", item);
            DLog(@"Synchronized timeframe activity fee: %@/%@/%@", fee.id, fee.fee_excl_vat, fee.fee_incl_vat);
        }
        
        [self.delegate saveContext];
    } onFailBlock:^(NSError *error) {
        //woeps
        NSLog(@"%@", error);
    }];
}


@end
