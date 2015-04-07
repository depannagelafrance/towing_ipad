//
//  VehicleDetailViewController.h
//  towing
//
//  Created by Kris Vandermast on 07/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "DetailItemViewController.h"
#import "ListPickerTableViewControllerDelegate.h"
#import "DetailViewProtocol.h"

@interface VehicleDetailViewController : DetailItemViewController<DetailViewProtocol, ListPickerTableViewControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *vehicleTextField;
@property (weak, nonatomic) IBOutlet UITextField *vehicleTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *licencePlateTextField;
@property (weak, nonatomic) IBOutlet UITextField *vehicleColorTextField;
@property (weak, nonatomic) IBOutlet UISwitch *keysPresentSwitch;
@property (weak, nonatomic) IBOutlet UITextView *vehicleDamageRemarksTextView;

@property (weak, nonatomic) IBOutlet UIImageView *impactImageView;

@property (weak, nonatomic) IBOutlet UIButton *countryButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
