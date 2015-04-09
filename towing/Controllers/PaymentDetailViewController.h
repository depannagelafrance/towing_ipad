//
//  PaymentDetailViewController.h
//  towing
//
//  Created by Kris Vandermast on 02/12/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewProtocol.h"
#import "DetailItemViewController.h"

@interface PaymentDetailViewController : DetailItemViewController<DetailViewProtocol, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *totalAmountTextField;
@property (weak, nonatomic) IBOutlet UITextField *paidInCashTextField;
@property (weak, nonatomic) IBOutlet UITextField *paidByCreditCardTextField;
@property (weak, nonatomic) IBOutlet UITextField *paidByMaestroTextField;
@property (weak, nonatomic) IBOutlet UITextField *totalAmountExclVatTextField;
@property (weak, nonatomic) IBOutlet UIButton *completeCashButton;
@property (weak, nonatomic) IBOutlet UIButton *completeCreditCardButton;
@property (weak, nonatomic) IBOutlet UIButton *completeMaestroButton;
@property (weak, nonatomic) IBOutlet UITextField *unpaidTextField;

@end
