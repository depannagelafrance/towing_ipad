//
//  CustomerDetailViewController.m
//  towing
//
//  Created by Kris Vandermast on 13/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "CustomerDetailViewController.h"
#import "AppDelegate.h"
#import "Dossier+Model.h"
#import "TowingVoucher+Model.h"
#import "JsonUtil.h"
#import "VatUtil.h"

#define CUSTOMER_TYPE_DEFAULT   @"DEFAULT"
#define CUSTOMER_TYPE_AGENCY    @"AGENCY"

@interface CustomerDetailViewController() {
    BOOL isAgency;
}
@end


@implementation CustomerDetailViewController
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self setFormValuesForKey:@"customer"];
    
    self.navigationItem.title = @"Klant/Facturatiegegevens";
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(performSave)];
    self.navigationItem.rightBarButtonItem = done;
    
    self.currentScrollView = self.scrollview;
}

#pragma mark - DetailViewProtocol implementation
- (void) performSave
{
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    TowingVoucher *voucher = delegate.towingVoucher;
    
    NSDictionary *data = [voucher jsonObjectForKey:@"customer"];
    [data setValuesForKeysWithDictionary:@{@"last_name"      : self.nameTextField.text,
                                           @"first_name"     : self.firstNameTextField.text,
                                           @"company_name"   : self.companyTextField.text,
                                           @"company_vat"    : self.vatTextField.text,
                                           @"street"         : self.streetTextField.text,
                                           @"street_number"  : self.numberTextField.text,
                                           @"street_pobox"   : self.poboxTextField.text,
                                           @"zip"            : self.zipTextField.text,
                                           @"city"           : self.cityTextField.text,
                                           @"country"        : self.countryTextField.text,
                                           @"phone"          : self.phoneTextField.text,
                                           @"email"          : self.emailTextField.text,
                                           @"type"           : isAgency ? CUSTOMER_TYPE_AGENCY : CUSTOMER_TYPE_DEFAULT
                                           }];
    
    [voucher jsonObject:data forKey:@"customer"];
    
    
    [((Dossier *) voucher.dossier) performSaveToBackoffice];
}

#pragma mark - IBActions

- (IBAction)copyFromCauserAction:(id)sender
{
    [self setFormValuesForKey:@"causer"];
    
    isAgency = NO;
    
    [self performSave];
}

- (IBAction)copyFromAgencyAction:(id)sender
{
    Dossier *dossier = self.delegate.towingVoucher.dossier;
    
    NSDictionary *json = [dossier jsonObjectForKey:@"allotment_agency"];
    
    self.companyTextField.text      = [JsonUtil asString:[json valueForKey:@"company_name"]];
    self.vatTextField.text          = [JsonUtil asString:[json valueForKey:@"company_vat"]];
    self.streetTextField.text       = [JsonUtil asString:[json valueForKey:@"street"]];
    self.numberTextField.text       = [JsonUtil asString:[json valueForKey:@"street_number"]];
    self.poboxTextField.text        = [JsonUtil asString:[json valueForKey:@"street_pobox"]];
    self.zipTextField.text          = [JsonUtil asString:[json valueForKey:@"zip"]];
    self.cityTextField.text         = [JsonUtil asString:[json valueForKey:@"city"]];
    self.countryTextField.text      = [JsonUtil asString:[json valueForKey:@"country"]];
    self.phoneTextField.text        = [JsonUtil asString:[json valueForKey:@"phone"]];
    self.emailTextField.text        = [JsonUtil asString:[json valueForKey:@"email"]];
    
    isAgency = YES;
}

- (IBAction)checkVat:(id)sender
{
    if(self.vatTextField.text) {
        [VatUtil checkVatNumber:self.vatTextField.text onSuccess:^(NSDictionary *data) {
            if([self.companyTextField.text isEqualToString:@""]) {
                self.companyTextField.text  = [JsonUtil asString:[data objectForKey:@"name"]];
            }
            
            if([self.streetTextField.text isEqualToString:@""]) {
                if([data objectForKey:@"address_data"]) {
                    NSDictionary *address_data = [data objectForKey:@"address_data"];
                    self.streetTextField.text   = [JsonUtil asString:[address_data objectForKey:@"street"]];
                    self.numberTextField.text   = [JsonUtil asString:[address_data objectForKey:@"street_number"]];
                    self.zipTextField.text      = [JsonUtil asString:[address_data objectForKey:@"zip"]];
                    self.cityTextField.text     = [JsonUtil asString:[address_data objectForKey:@"city"]];
                } else {
                    self.streetTextField.text = [JsonUtil asString:[data objectForKey:@"address"]];
                }
            }
        } onFailure:^(NSError *error) {
            if(error) {
                DLog(@"Seems there is an error: %@", error);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE_ERROR
                                                                message:@"Dit is mogelijk een foutief BTW nummer. Controleer de ingave en probeer opnieuw"
                                                               delegate:self
                                                      cancelButtonTitle:ALERT_BUTTON_CANCEL
                                                      otherButtonTitles:nil];
                [alert show];
            } else {
                DLog(@"%s -- Error seems to be nil > No connection", __PRETTY_FUNCTION__);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE_ERROR
                                                                message:@"Controleer de toegang tot het internet en probeer opnieuw!"
                                                               delegate:self
                                                      cancelButtonTitle:ALERT_BUTTON_CANCEL
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

- (void) setFormValuesForKey:(NSString *)key
{
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    TowingVoucher *voucher = delegate.towingVoucher;
    
    NSDictionary *json = [voucher jsonObjectForKey:key];
    
    self.nameTextField.text         = [JsonUtil asString:[json valueForKey:@"last_name"]];
    self.firstNameTextField.text    = [JsonUtil asString:[json valueForKey:@"first_name"]];
    self.companyTextField.text      = [JsonUtil asString:[json valueForKey:@"company_name"]];
    self.vatTextField.text          = [JsonUtil asString:[json valueForKey:@"company_vat"]];
    self.streetTextField.text       = [JsonUtil asString:[json valueForKey:@"street"]];
    self.numberTextField.text       = [JsonUtil asString:[json valueForKey:@"street_number"]];
    self.poboxTextField.text        = [JsonUtil asString:[json valueForKey:@"street_pobox"]];
    self.zipTextField.text          = [JsonUtil asString:[json valueForKey:@"zip"]];
    self.cityTextField.text         = [JsonUtil asString:[json valueForKey:@"city"]];
    self.countryTextField.text      = [JsonUtil asString:[json valueForKey:@"country"]];
    self.phoneTextField.text        = [JsonUtil asString:[json valueForKey:@"phone"]];
    self.emailTextField.text        = [JsonUtil asString:[json valueForKey:@"email"]];
    
    isAgency  = [[JsonUtil asString:[json valueForKey:@"type"]] isEqualToString:CUSTOMER_TYPE_AGENCY];
}


@end
