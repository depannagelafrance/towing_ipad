//
//  IncidentDetailViewController.h
//  towing
//
//  Created by Kris Vandermast on 13/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewProtocol.h"
#import "TrafficPostsTableViewController.h"
#import "LicencePlateCountryTableViewController.h"
#import "GeneralActionButton.h"
#import "DisruptiveActionButton.h"
#import "DetailItemViewController.h"
#import "ListPickerTableViewControllerDelegate.h"


@interface IncidentDetailViewController : DetailItemViewController<DetailViewProtocol, ListPickerTableViewControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextView *additionalInformationTextView;

@property (weak, nonatomic) IBOutlet UILabel *signaArrivalLabel;
@property (weak, nonatomic) IBOutlet UILabel *towingArrivalLabel;
@property (weak, nonatomic) IBOutlet UILabel *towingStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *towingStopLabel;
@property (weak, nonatomic) IBOutlet UILabel *towingLicencePlateLabel;
@property (weak, nonatomic) IBOutlet UILabel *towingNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *towingCalledLabel;

@property (weak, nonatomic) IBOutlet UIButton *allotmentDirectionButton;
@property (weak, nonatomic) IBOutlet UIButton *allotmentDirectionIndicatorButton;
@property (weak, nonatomic) IBOutlet UIButton *trafficLanesButton;
@property (weak, nonatomic) IBOutlet GeneralActionButton *signArrivalButton;
@property (weak, nonatomic) IBOutlet GeneralActionButton *towingArrivalButton;
@property (weak, nonatomic) IBOutlet DisruptiveActionButton *towingStartButton;
@property (weak, nonatomic) IBOutlet GeneralActionButton *towingStopButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@end
