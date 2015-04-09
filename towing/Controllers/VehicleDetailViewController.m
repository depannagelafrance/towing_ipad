//
//  VehicleDetailViewController.m
//  towing
//
//  Created by Kris Vandermast on 07/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "VehicleDetailViewController.h"

#import "LicencePlateCountryTableViewController.h"
#import "ImpactViewController.h"

#import "Dossier+Model.h"
#import "TowingVoucher+Model.h"
#import "LicencePlateCountry+Model.h"

#import "JsonUtil.h"


@interface VehicleDetailViewController ()



@property (strong, nonatomic) TowingVoucher *towingVoucher;
@property (strong, nonatomic) NSArray *licencePlates;

@property (strong, nonatomic) UIPopoverController *impactPopover;
@end

@implementation VehicleDetailViewController
#pragma mark - property getters
- (TowingVoucher *) towingVoucher
{
    return self.delegate.towingVoucher;
}

- (NSArray *) licencePlates
{
    if(!_licencePlates) {
        _licencePlates = [LicencePlateCountry findAll:self.delegate.managedObjectContext];
    }
    
    return _licencePlates;
}



#pragma mark - lifecycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.vehicleTypeTextField.text  = [JsonUtil asString:[self.towingVoucher jsonObjectForKey:VEHICULE_TYPE]];
    self.vehicleColorTextField.text = [JsonUtil asString:[self.towingVoucher jsonObjectForKey:VEHICULE_COLOR]];
    self.vehicleTextField.text      = [JsonUtil asString:[self.towingVoucher jsonObjectForKey:VEHICULE]];
    self.licencePlateTextField.text = [JsonUtil asString:[self.towingVoucher jsonObjectForKey:VEHICULE_LICENCE_PLATE]];
    self.vehicleDamageRemarksTextView.text = [JsonUtil asString:[self.towingVoucher jsonObjectForKey:VEHICULE_IMPACT_REMARKS]];
    
    self.keysPresentSwitch.on = [[JsonUtil asNumber:[self.towingVoucher jsonObjectForKey:VEHICULE_KEYS_PRESENT]] isEqualToNumber:@1];
    
    
    NSString *licencePlateCountry = [JsonUtil asString:[self.towingVoucher jsonObjectForKey:LICENCE_PLATE_COUNTRY]];
    
    DLog(@"%s -- Licence plate country: %@", __PRETTY_FUNCTION__, licencePlateCountry);
    
    if(licencePlateCountry && ![licencePlateCountry isEqualToString:@""])
    {
        [self.countryButton setTitle:licencePlateCountry forState:UIControlStateNormal];
    }
    else
    {
        [self.countryButton setTitle:BUTTON_TITLE_UNKNOWN forState:UIControlStateNormal];
    }
    
    //set the image if applicable
    if(self.towingVoucher.impact_image_path) {
        self.impactImageView.image = [UIImage imageWithContentsOfFile:self.towingVoucher.impact_image_path];
    }
    
    
    //setting the scrollview for the delegate
    self.currentScrollView = self.scrollView;
    
    //configuring navigation bar
    self.navigationItem.title = VIEW_TITLE_VEHICLE_DETAIL;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(performSave)];
    self.navigationItem.rightBarButtonItem = done;
    
    [self resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)selectLicencePlateCountryAction:(id)sender
{
    LicencePlateCountryTableViewController *viewController = [[LicencePlateCountryTableViewController alloc] init];
    viewController.data = self.licencePlates;
    viewController.delegate = self;
    viewController.sender = sender;
    
    [self presentPopOverViewController:viewController fromSender:sender withDelegate:self];
}

- (IBAction)drawVehicleImpactDamageAction:(id)sender
{
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    ImpactViewController *viewController = [[ImpactViewController alloc] initWithNibName:@"ImpactView" bundle:nil];
    viewController.token = delegate.authenticatedUser.token;
    viewController.impactView = self.impactImageView;
    
    __block NSString *token = delegate.authenticatedUser.token;
    __block NSString *voucherId = delegate.towingVoucher.id;
    
    [viewController setSignatureBlock:^(NSString *path) {
        NSLog(@"Wrote image to directory: %@", path);
        
        NSData *signaturePNG = [NSData dataWithContentsOfFile:path];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        
        NSString *api = [NSString stringWithFormat:@"/dossier/voucher/attachment/vehicle_damage/%@/%@", voucherId, token];
        NSDictionary *params = @{@"content_type": @"image/png",
                                 @"file_size" : fileSizeNumber,
                                 @"file_name" : [NSString stringWithFormat:@"impact_voucher_%@.png", voucherId],
                                 @"content" : [signaturePNG base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]};
        
        
        [self.impactPopover dismissPopoverAnimated:YES];
        
        RestService *restService = [[RestService alloc] init];
        
        [restService post:api withParameters:params onCompleteBlock:^(NSDictionary *result) {
            NSLog(@"Added the attachment in the back-end: %@", result);
        } onFailBlock:^(NSError *error, int statusCode) {
            NSLog(@"Failed to send signature to back-end: %ul - %@", statusCode, error);
        }];
    }];
    
    
    self.impactPopover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.impactPopover.delegate = self;
    self.impactPopover.popoverContentSize = CGSizeMake(950, 430); //current image is 944 × 374 pixels
    self.impactPopover.passthroughViews = [NSArray arrayWithObject:self.view];

    [self.impactPopover presentPopoverFromRect:CGRectMake(0, 0, self.view.frame.size.width+320, self.view.frame.size.height)
                                  inView:self.view
                permittedArrowDirections:0
                                animated:YES];
}

#pragma mark - DetailViewProtocol
- (void) performSave
{
    NSLog(@"Triggering %s", __PRETTY_FUNCTION__);
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    [self.towingVoucher jsonValue:self.vehicleTextField.text            forKey:VEHICULE];
    [self.towingVoucher jsonValue:self.vehicleTypeTextField.text        forKey:VEHICULE_TYPE];
    [self.towingVoucher jsonValue:self.licencePlateTextField.text       forKey:VEHICULE_LICENCE_PLATE];
    [self.towingVoucher jsonValue:self.vehicleColorTextField.text       forKey:VEHICULE_COLOR];
    [self.towingVoucher jsonValue:self.vehicleDamageRemarksTextView.text forKey:VEHICULE_IMPACT_REMARKS];
    
    [self.towingVoucher jsonValue:(self.keysPresentSwitch.on ? @"1" : @"0") forKey:VEHICULE_KEYS_PRESENT];
    
    [delegate.managedObjectContext save:nil];
    
    [((Dossier *) self.towingVoucher.dossier) performSaveToBackoffice];
}

#pragma mark - ListPickerTableViewControllerDelegate
- (void) wasSelected:(id)selectedItem sender:(id)sender
{
    if(selectedItem)
    {
        //        Dossier *dossier = (Dossier *)voucher.dossier;
        
        if([selectedItem isKindOfClass:[LicencePlateCountry class]])
        {
            LicencePlateCountry *lp =  (LicencePlateCountry *) selectedItem;
            
            [self.towingVoucher jsonValue:lp.name forKey:LICENCE_PLATE_COUNTRY];
            
            [self.countryButton setTitle:lp.name forState:UIControlStateNormal];
        }
    }
    
    [self dismissPopOverViewController];
}

@end
