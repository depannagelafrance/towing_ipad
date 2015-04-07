//
//  AllotmentDirectionIndicatorTableViewController.h
//  towing
//
//  Created by Kris Vandermast on 02/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListPickerTableViewControllerDelegate.h"

@interface AllotmentDirectionIndicatorTableViewController : UITableViewController
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) id<ListPickerTableViewControllerDelegate> delegate;
@property (weak, nonatomic) id sender;
@end
