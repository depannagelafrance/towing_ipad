//
//  CauserDetailViewController.m
//  towing
//
//  Created by Kris Vandermast on 13/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "CauserDetailViewController.h"
#import "AppDelegate.h"
#import "Dossier+Model.h"
#import "TowingVoucher+Model.h"
#import "TowingVoucherSignature.h"
#import "JsonUtil.h"
#import "SignatureViewController.h"
#import "RestService.h"
#import "VatUtil.h"

@interface CauserDetailViewController() {
    UITextField *assignedTextField;
}
@property (weak, nonatomic) IBOutlet UIImageView *signatureImageView;
@property (strong, nonatomic) TowingVoucher *towingVoucher;
@property (strong, nonatomic) UIPopoverController *popover;
@end

@implementation CauserDetailViewController
- (TowingVoucher *) towingVoucher
{
    if(!_towingVoucher) {
        AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
        _towingVoucher = delegate.towingVoucher;
    }
    
    return _towingVoucher;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self setFormValuesForKey:@"causer"];
    
    if(self.towingVoucher.signature_causer) {
        NSString *path = self.towingVoucher.signature_causer.path;
        [self.signatureImageView setImage:[UIImage imageWithContentsOfFile:path]];
    }
    
    self.navigationItem.title = @"Hinderverwekker";
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(performSave)];
    self.navigationItem.rightBarButtonItem = done;
    
    self.currentScrollView = self.scrollview;
}


#pragma mark - DetailViewProtocol implementation
- (void) performSave
{
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    TowingVoucher *voucher = delegate.towingVoucher;
    
    NSDictionary *data = [voucher jsonObjectForKey:@"causer"];
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
                                           @"email"          : self.emailTextField.text
                                           }];
    
    [voucher jsonObject:data forKey:@"causer"];
    
    [((Dossier *) voucher.dossier) performSaveToBackoffice];
}

- (IBAction)copyFromCustomerAction:(id)sender {
    [self setFormValuesForKey:@"customer"];
    
    [self performSave];
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

- (IBAction)showSignatureViewAction:(id)sender
{
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    SignatureViewController *viewController = [[SignatureViewController alloc] initWithNibName:@"SignatureView" bundle:nil];
    viewController.token = delegate.authenticatedUser.token;
    viewController.category = @"signature_causer";
    viewController.signatureImageView = self.signatureImageView;
    
    __block NSString *token = delegate.authenticatedUser.token;
    __block NSString *voucherId = delegate.towingVoucher.id;
    
    [viewController setSignatureBlock:^(NSString *path) {
        NSLog(@"Wrote image to directory: %@", path);
        
        NSData *signaturePNG = [NSData dataWithContentsOfFile:path];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        
        NSString *api = [NSString stringWithFormat:@"/dossier/voucher/attachment/signature_causer/%@/%@", voucherId, token];
        NSDictionary *params = @{@"content_type": @"image/png",
                                 @"file_size" : fileSizeNumber,
                                 @"content" : [signaturePNG base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]};
        
        
        [self.popover dismissPopoverAnimated:YES];
        
        RestService *restService = [[RestService alloc] init];
        
        [restService post:api withParameters:params onCompleteBlock:^(NSDictionary *result) {
            NSLog(@"Added the attachment in the back-end: %@", result);
        } onFailBlock:^(NSError *error, int statusCode) {
            NSLog(@"Failed to send signature to back-end: %ul - %@", statusCode, error);
        }];
    }];
    
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.delegate = self;
    self.popover.popoverContentSize = CGSizeMake(self.view.frame.size.width+320, self.view.frame.size.height);
    self.popover.passthroughViews = [NSArray arrayWithObject:self.view];
    
    [self.popover presentPopoverFromRect:CGRectMake(0, 0, self.view.frame.size.width+320, self.view.frame.size.height)
                                  inView:self.view
                permittedArrowDirections:0
                                animated:YES];
}

- (void) setFormValuesForKey:(NSString *)key
{
    NSDictionary *json = [self.towingVoucher jsonObjectForKey:key];
    
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
}
@end
