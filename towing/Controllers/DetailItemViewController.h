//
//  DetailViewController.h
//  towing
//
//  Created by Kris Vandermast on 26/01/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "BaseViewController.h"

@interface DetailItemViewController : BaseViewController
@property (weak, nonatomic) UIScrollView *currentScrollView;

- (void) presentPopOverViewController:(id)viewController fromSender:(id) sender withDelegate:(id) delegate;
- (void) dismissPopOverViewController;
- (void) recalculateVoucherTotal;
@end
