//
//  TrafficPostDetailViewController.h
//  towing
//
//  Created by Kris Vandermast on 28/01/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "DetailItemViewController.h"
#import "DetailViewProtocol.h"
#import "TrafficPostsTableViewController.h"

@interface TrafficPostDetailViewController : DetailItemViewController<DetailViewProtocol, TrafficPostListPickerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate>


@end
