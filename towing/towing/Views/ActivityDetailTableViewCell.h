//
//  ActivityDetailTableViewCell.h
//  towing
//
//  Created by Kris Vandermast on 27/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityDetailTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *feeExclVatLabel;
@property (strong, nonatomic) IBOutlet UILabel *feeInclVatLabel;
@property (strong, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UILabel *calFeeExclVatLabel;
@property (weak, nonatomic) IBOutlet UILabel *calFeeInclVatLabel;

@end
