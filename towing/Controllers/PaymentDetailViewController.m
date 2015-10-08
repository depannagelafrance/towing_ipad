//
//  PaymentDetailViewController.m
//  towing
//
//  Created by Kris Vandermast on 02/12/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "PaymentDetailViewController.h"
#import "AppDelegate.h"
#import "TowingVoucher.h"
#import "Dossier+Model.h"
#import "JsonUtil.h"

@interface PaymentDetailViewController ()
@property (readonly, strong, nonatomic) TowingVoucher *towingVoucher;
@end

@implementation PaymentDetailViewController
#pragma mark - getters

- (TowingVoucher *) towingVoucher
{
    return self.delegate.towingVoucher;
}

#pragma mark - view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //configuring navigation bar
    self.navigationItem.title = @"Betalingsmodaliteiten";
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(performSave)];
    self.navigationItem.rightBarButtonItem = done;
    
    NSArray *payments = [self.towingVoucher jsonObjectForKey:@"towing_payment_details"];
    
    for (NSDictionary *payment in payments)
    {
        if([payment[@"category"] isEqualToString:@"CUSTOMER"])
        {
            self.totalAmountTextField.text = [JsonUtil asString:[payment objectForKey:@"amount_incl_vat"]];
            self.totalAmountExclVatTextField.text = [JsonUtil asString:[payment objectForKey:@"amount_excl_vat"]];
            self.paidInCashTextField.text = [JsonUtil asString:[payment objectForKey:@"amount_paid_cash"]];
            self.paidByMaestroTextField.text = [JsonUtil asString:[payment objectForKey:@"amount_paid_maestro"]];
            self.paidByCreditCardTextField.text = [JsonUtil asString:[payment objectForKey:@"amount_paid_visa"]];
        }
    }
    
    self.paidInCashTextField.delegate = self;
    self.paidByMaestroTextField.delegate = self;
    self.paidByCreditCardTextField.delegate = self;
    
    [self recaculateUnpaid];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector (handle_TextFieldTextChanged:)
                               name:UITextFieldTextDidChangeNotification
                             object:nil];
}


- (void) handle_TextFieldTextChanged:(NSNotification *) notification
{
    [self recaculateUnpaid];
}

#pragma mark - DetailViewProtocol implementation
- (void) performSave
{
    NSLog(@"Triggering %s", __PRETTY_FUNCTION__);
    
    NSArray *payments = [self.towingVoucher jsonObjectForKey:@"towing_payment_details"];
    
    for (NSDictionary *payment in payments)
    {
        if([payment[@"category"] isEqualToString:@"CUSTOMER"])
        {
            [payment setValue:self.paidInCashTextField.text forKey:@"amount_paid_cash"];
            [payment setValue:self.paidByMaestroTextField.text forKey:@"amount_paid_maestro"];
            [payment setValue:self.paidByCreditCardTextField.text forKey:@"amount_paid_visa"];
        }
    }
    
    [self.towingVoucher jsonObject:payments forKey:@"towing_payment_details"];
    
    [((Dossier *) self.towingVoucher.dossier) performSaveToBackoffice];
}

#pragma mark - IBActions
- (IBAction)paymentButtonClicked:(id)sender
{
    UITextField *textField = nil;
    
    if([sender isEqual:self.completeCashButton]) {
        textField = self.paidInCashTextField;
    } else if([sender isEqual:self.completeCreditCardButton]) {
        textField = self.paidByCreditCardTextField;
    } else if([sender isEqual:self.completeMaestroButton]) {
        textField = self.paidByMaestroTextField;
    }
    
    textField.text = [self shouldUseFeeExclVat] ? self.totalAmountExclVatTextField.text : self.totalAmountTextField.text;
    
    [self recaculateUnpaid];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    bool result = [[string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]] isEqualToString:@""] || [string isEqualToString:@"."];
    
    return result;
}

- (BOOL) shouldUseFeeExclVat {
    NSDictionary *data = [self.towingVoucher jsonObjectForKey:@"customer"];
    
    if(data[@"company_vat"] && ![data[@"company_vat"] isKindOfClass:[NSNull class]] && ![data[@"company_vat"] isEqualToString:@""]) {
        return [[data[@"company_vat"] uppercaseString] hasPrefix:@"BE"];
    }
    
    return false;
}

- (void) recaculateUnpaid
{
    NSArray *payments = [self.towingVoucher jsonObjectForKey:@"towing_payment_details"];
    
    for (NSDictionary *payment in payments) {
        if([payment[@"category"] isEqualToString:@"CUSTOMER"]) {
            double cash = self.paidInCashTextField.text.doubleValue;
            double creditCard = self.paidByCreditCardTextField.text.doubleValue;
            double maestro = self.paidByMaestroTextField.text.doubleValue;
            
            double total = [JsonUtil asNumber:[payment objectForKey:@"amount_incl_vat"]].doubleValue;
            
            if([self shouldUseFeeExclVat]) {
                total = [JsonUtil asNumber:[payment objectForKey:@"amount_excl_vat"]].doubleValue;
            }
            
            double unpaid = total - cash - creditCard - maestro;
            
            self.unpaidTextField.text = [NSString stringWithFormat:@"%.2f", unpaid];
            
            if(unpaid < 0) {
                self.unpaidTextField.backgroundColor = [UIColor redColor];
                self.unpaidTextField.textColor = [UIColor whiteColor];
            } else if(unpaid > 0) {
                self.unpaidTextField.backgroundColor = [UIColor orangeColor];
                self.unpaidTextField.textColor = [UIColor whiteColor];
            } else {
                self.unpaidTextField.backgroundColor = [UIColor greenColor];
                self.unpaidTextField.textColor = [UIColor whiteColor];
            }
        }
    }
}


@end
