//
//  AllotmentDirectionTableViewController.h
//  towing
//
//  Created by Kris Vandermast on 02/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListPickerTableViewControllerDelegate.h"

@interface AllotmentDirectionTableViewController : UITableViewController
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) id<ListPickerTableViewControllerDelegate> delegate;
@property (strong, nonatomic) id sender;
@end
