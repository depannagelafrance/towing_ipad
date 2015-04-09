//
//  ActivityDetailViewController.h
//  towing
//
//  Created by Kris Vandermast on 27/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "DetailItemViewController.h"
#import "DetailViewProtocol.h"
#import "AvailableActivitiesTableViewController.h"

@interface ActivityDetailViewController : DetailItemViewController<DetailViewProtocol, AvailableActivitiesListPickerDelegate,
                                                             UIPopoverControllerDelegate, UITextFieldDelegate,
                                                             UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
