//
//  AvailableActivitiesTableViewController.h
//  towing
//
//  Created by Kris Vandermast on 28/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "BaseViewController.h"

@protocol AvailableActivitiesListPickerDelegate <NSObject>
@required
- (void) wasSelected:(id) selectedItem;
@end

@interface AvailableActivitiesTableViewController : UITableViewController
@property (strong, nonatomic) NSArray *availableActivities;
@property (weak, nonatomic) id<AvailableActivitiesListPickerDelegate> delegate;
@end
