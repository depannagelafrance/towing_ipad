//
//  LicencePlateCountryTableViewController.h
//  towing
//
//  Created by Kris Vandermast on 02/12/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListPickerTableViewControllerDelegate.h"

@interface LicencePlateCountryTableViewController : UITableViewController<UISearchBarDelegate, UISearchDisplayDelegate>
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) id<ListPickerTableViewControllerDelegate> delegate;
@property (strong, nonatomic) id sender;
@end

