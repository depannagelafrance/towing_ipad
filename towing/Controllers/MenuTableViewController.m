//
//  MenuTableViewController.m
//  towing
//
//  Created by Kris Vandermast on 13/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "MenuTableViewController.h"

#import "DetailViewProtocol.h"

#import "IncidentDetailViewController.h"
#import "CustomerDetailViewController.h"
#import "CauserDetailViewController.h"
#import "DepotDetailViewController.h"
#import "ActivityDetailViewController.h"
#import "PaymentDetailViewController.h"
#import "NotesDetailViewController.h"
#import "VoucherMenuInfoTableViewCell.h"
#import "TrafficPostDetailViewController.h"
#import "AttachmentDetailViewController.h"
#import "VehicleDetailViewController.h"

#import "AppDelegate.h"
#import "JsonUtil.h"
#import "SynchronisationHandler.h"
#import "Crouton.h"
#import "DateUtil.h"

#import "Dossier+Model.h"

@interface MenuTableViewController() {
    UILabel *labelIncidentTypeVal;
    UILabel *labelDirectionVal;
    UILabel *labelIndicatorVal ;
    UILabel *labelTrafficLaneVal;
    UILabel *labelCallNumberVal;
    UILabel *labelCallTimeVal;
}
@property (strong, nonatomic) AppDelegate *delegate;
@end

@implementation MenuTableViewController

#pragma mark - Getters
- (AppDelegate *) delegate
{
    if(!_delegate) {
        _delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    
    return _delegate;
}

#pragma mark - Life cycle
- (void) viewDidLoad
{
    UIViewController *masterViewController = [self.splitViewController.viewControllers objectAtIndex:0];
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController addChildViewController:  [[IncidentDetailViewController alloc] initWithNibName:@"IncidentDetail" bundle:nil]];
    
    NSArray *viewControllers = @[masterViewController, navController];
    
    [self.splitViewController setViewControllers:viewControllers];
    
    self.navigationItem.title = self.delegate.towingVoucher.voucher_number;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMenuDescription)
                                                 name:NOTIFICATION_DIRECTIONS_UPDATED object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateMenuDescription
{
    TowingVoucher *voucher = self.delegate.towingVoucher;
    Dossier *dossier = (Dossier *)voucher.dossier;
    
    [labelIncidentTypeVal setText:[JsonUtil asString:[dossier jsonObjectForKey:@"incident_type_name"]]];
    [labelDirectionVal setText:[JsonUtil asString:[dossier jsonObjectForKey:@"direction_name"]]];
    [labelIndicatorVal setText:[JsonUtil asString:[dossier jsonObjectForKey:@"indicator_name"]]];
    [labelTrafficLaneVal setText:[JsonUtil asString:[dossier jsonObjectForKey:@"traffic_lane_name"]]];
    [labelCallNumberVal setText:dossier.call_number];
    [labelCallTimeVal setText:[DateUtil formatAsDateTime:dossier.call_date]];
}

#pragma mark - UITableViewDelegate implementation
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 100)];
    
    UILabel *labelDirection     = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, tableView.frame.size.width, 18)];
    UILabel *labelIndicator     = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, tableView.frame.size.width, 18)];
    UILabel *labelTrafficLane   = [[UILabel alloc] initWithFrame:CGRectMake(10, 65, tableView.frame.size.width, 18)];
    UILabel *labelCallNumber    = [[UILabel alloc] initWithFrame:CGRectMake(10, 85, tableView.frame.size.width, 18)];
    UILabel *labelCallTime      = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, tableView.frame.size.width, 18)];
    
    labelIncidentTypeVal   = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width-70, 18)];
    labelDirectionVal      = [[UILabel alloc] initWithFrame:CGRectMake(70, 25, tableView.frame.size.width-70, 18)];
    labelIndicatorVal      = [[UILabel alloc] initWithFrame:CGRectMake(70, 45, tableView.frame.size.width-70, 18)];
    labelTrafficLaneVal    = [[UILabel alloc] initWithFrame:CGRectMake(70, 65, tableView.frame.size.width-70, 18)];
    labelCallNumberVal     = [[UILabel alloc] initWithFrame:CGRectMake(70, 85, tableView.frame.size.width-70, 18)];
    labelCallTimeVal       = [[UILabel alloc] initWithFrame:CGRectMake(70, 105, tableView.frame.size.width-70, 18)];
    
    
    [labelDirection setFont:[UIFont boldSystemFontOfSize:12]];
    [labelIndicator setFont:[UIFont boldSystemFontOfSize:12]];
    [labelTrafficLane setFont:[UIFont boldSystemFontOfSize:12]];
    [labelCallNumber setFont:[UIFont boldSystemFontOfSize:12]];
    [labelCallTime setFont:[UIFont boldSystemFontOfSize:12]];
    
    
    [labelIncidentTypeVal setFont:[UIFont boldSystemFontOfSize:12]];
    [labelDirectionVal setFont:[UIFont systemFontOfSize:12]];
    [labelIndicatorVal setFont:[UIFont systemFontOfSize:12]];
    [labelTrafficLaneVal setFont:[UIFont systemFontOfSize:12]];
    [labelCallNumberVal setFont:[UIFont systemFontOfSize:12]];
    [labelCallTimeVal setFont:[UIFont systemFontOfSize:12]];
    
    [labelIndicatorVal setAdjustsFontSizeToFitWidth:YES];
    [labelIncidentTypeVal setAdjustsFontSizeToFitWidth:YES];
    

    [labelDirection setText:@"Richting: "];
    [labelIndicator setText:@"KM Paal: "];
    [labelTrafficLane setText:@"Rijvak: "];
    [labelCallNumber setText:@"Oproepnr.: "];
    [labelCallTime setText:@"Oproep: "];
    
    [self updateMenuDescription];
    
    [view addSubview:labelDirection];
    [view addSubview:labelIndicator];
    [view addSubview:labelTrafficLane];
    [view addSubview:labelCallNumber];
    [view addSubview:labelCallTime];
    
    [view addSubview:labelIncidentTypeVal];
    [view addSubview:labelDirectionVal];
    [view addSubview:labelIndicatorVal];
    [view addSubview:labelTrafficLaneVal];
    [view addSubview:labelCallNumberVal];
    [view addSubview:labelCallTimeVal];
    
    [view setBackgroundColor:[UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0]];
    
    return view;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 130.0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"Identifier: %@", cell.reuseIdentifier);
    
    UIViewController *masterViewController = [self.splitViewController.viewControllers objectAtIndex:0];
    UINavigationController *navigationController = (self.splitViewController.viewControllers.count > 1 ? [self.splitViewController.viewControllers objectAtIndex:1] : nil);
    UIViewController<DetailViewProtocol> *detailViewController = [[navigationController viewControllers] firstObject];
    
    if([detailViewController canPerformAction:@selector(performSave) withSender:nil]) {
        [detailViewController performSave];
    }
    
    if([cell.reuseIdentifier isEqualToString:@"Overview"])
    {
        [self.delegate gotoTowingVoucherOverview];
    }
    else
    {
        id viewController = nil;
        
        if([cell.reuseIdentifier isEqualToString:@"IncidentDetail"])
        {
            viewController = [[IncidentDetailViewController alloc] initWithNibName:@"IncidentDetail" bundle:nil];
        }
        else if([cell.reuseIdentifier isEqualToString:@"CustomerDetail"])
        {
            viewController = [[CustomerDetailViewController alloc] initWithNibName:@"CustomerDetail" bundle:nil];
        }
        else if([cell.reuseIdentifier isEqualToString:@"CauserDetail"])
        {
            viewController = [[CauserDetailViewController alloc] initWithNibName:@"CauserDetail" bundle:nil];
        }
        else if([cell.reuseIdentifier isEqualToString:@"DepotDetail"])
        {
            viewController = [[DepotDetailViewController alloc] initWithNibName:@"DepotDetail" bundle:nil];
        }
        else if([cell.reuseIdentifier isEqualToString:@"ActivityDetail"])
        {
            viewController = [[ActivityDetailViewController alloc] initWithNibName:@"ActivityDetail" bundle:nil];
        }
        else if([cell.reuseIdentifier isEqualToString:@"PaymentDetail"])
        {
            viewController = [[PaymentDetailViewController alloc] initWithNibName:@"PaymentDetail" bundle:nil];
        }
        else if([cell.reuseIdentifier isEqualToString:@"NotesDetail"])
        {
            viewController = [[NotesDetailViewController alloc] initWithNibName:@"NotesDetail" bundle:nil];
        }
        else if ([cell.reuseIdentifier isEqualToString:@"TrafficPostDetail"])
        {
            viewController = [[TrafficPostDetailViewController alloc] initWithNibName:@"TrafficPostDetail" bundle:nil];
        }
        else if ([cell.reuseIdentifier isEqualToString:@"AttachmentDetail"])
        {
            viewController = [[AttachmentDetailViewController alloc] initWithNibName:@"AttachmentDetail" bundle:nil];
        }
        else if ([cell.reuseIdentifier isEqualToString:@"VehicleDetail"]) {
            viewController = [[VehicleDetailViewController alloc] initWithNibName:@"VehicleDetail" bundle:nil];
        }
            
        
        UINavigationController *navController = [[UINavigationController alloc] init];
        [navController addChildViewController:viewController];
        
        [self.splitViewController setViewControllers:@[masterViewController, navController]];
    }
}


#pragma mark - IBActions
- (IBAction)addTowingVoucherAction:(id)sender
{
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT_TITLE_REQUEST_NEW_VOUCHER
                                                                   message:ALERT_MESSAGE_REQUEST_NEW_VOUCHER
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ALERT_BUTTON_CANCEL
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             DLog(@"%s -- CANCEL", __PRETTY_FUNCTION__);
                                                         }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:ALERT_BUTTON_OK
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              DLog(@"%s -- OK", __PRETTY_FUNCTION__);
                                                              
                                                              [[Crouton info:@"Aanvraag voor nieuwe takelbon wordt verzonden!" inView:self.parentViewController.parentViewController.view] show];
                                                              
                                                              SynchronisationHandler *handler = [[SynchronisationHandler alloc] init];
                                                              
                                                              [handler createTowingVoucherForDossier:self.delegate.towingVoucher.dossier];
                                                          }];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
