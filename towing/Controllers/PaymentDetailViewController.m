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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //configuring navigation bar
    self.navigationItem.title = @"Betalingsmodaliteiten";
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(performSave)];
    self.navigationItem.rightBarButtonItem = done;
    
    NSDictionary *payments = [self.towingVoucher jsonObjectForKey:@"towing_payments"];
    
    self.totalAmountTextField.text = [JsonUtil asString:[payments objectForKey:@"total_incl_vat"]];
    self.totalAmountExclVatTextField.text = [JsonUtil asString:[payments objectForKey:@"total_excl_vat"]];
    self.paidInCashTextField.text = [JsonUtil asString:[payments objectForKey:@"paid_in_cash"]];
    self.paidByMaestroTextField.text = [JsonUtil asString:[payments objectForKey:@"paid_by_debit_card"]];
    self.paidByCreditCardTextField.text = [JsonUtil asString:[payments objectForKey:@"paid_by_credit_card"]];
    
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
    
    NSDictionary *payments = [self.towingVoucher jsonObjectForKey:@"towing_payments"];
    
    [payments setValue:self.paidInCashTextField.text forKey:@"paid_in_cash"];
    [payments setValue:self.paidByMaestroTextField.text forKey:@"paid_by_debit_card"];
    [payments setValue:self.paidByCreditCardTextField.text forKey:@"paid_by_credit_card"];
    
    [self.towingVoucher jsonObject:payments forKey:@"towing_payments"];
    
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
        return [data[@"company_vat"] hasPrefix:@"BE"];
    }
    
    return false;
}

- (void) recaculateUnpaid
{
    NSDictionary *payments = [self.towingVoucher jsonObjectForKey:@"towing_payments"];
    
    double cash = self.paidInCashTextField.text.doubleValue;
    double creditCard = self.paidByCreditCardTextField.text.doubleValue;
    double maestro = self.paidByMaestroTextField.text.doubleValue;
    
    double total = [JsonUtil asNumber:[payments objectForKey:@"total_incl_vat"]].doubleValue;
    
    if([self shouldUseFeeExclVat]) {
        total = [JsonUtil asNumber:[payments objectForKey:@"total_excl_vat"]].doubleValue;
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


@end
