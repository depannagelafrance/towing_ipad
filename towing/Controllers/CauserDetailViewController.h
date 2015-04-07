//
//  CauserDetailViewController.h
//  towing
//
//  Created by Kris Vandermast on 13/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewProtocol.h"
#import "DetailItemViewController.h"

@interface CauserDetailViewController : DetailItemViewController<DetailViewProtocol, UIPopoverControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyTextField;
@property (weak, nonatomic) IBOutlet UITextField *vatTextField;
@property (weak, nonatomic) IBOutlet UITextField *streetTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UITextField *poboxTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@end
