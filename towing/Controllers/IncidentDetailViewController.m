//
//  IncidentDetailViewController.m
//  towing
//
//  Created by Kris Vandermast on 13/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "IncidentDetailViewController.h"
#import "TrafficPostsTableViewController.h"
#import "LicencePlateCountryTableViewController.h"
#import "SignatureViewController.h"
#import "AllotmentDirectionTableViewController.h"
#import "AllotmentDirectionIndicatorTableViewController.h"
#import "TrafficLanesTableViewController.h"

#import "TowingVoucher+Model.h"
#import "Dossier+Model.h"
#import "TrafficPost+Model.h"
#import "AllotmentDirection+Model.h"
#import "AllotmentDirectionIndicator+Model.h"
#import "TrafficLane+Model.h"
#import "Vehicle+Model.h"

#import "TowingVoucherSignature.h"

#import "AppDelegate.h"

#import "JsonUtil.h"
#import "SharedPreferences.h"
#import "DateUtil.h"


@interface IncidentDetailViewController() {
    UITextField *assignedTextField;
    AllotmentDirection *allotmentDirection;
}

@property (strong, readonly, nonatomic) TowingVoucher *towingVoucher;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) NSArray *trafficPosts;
@property (strong, nonatomic) NSArray *allotmentDirections;
@property (strong, nonatomic) NSArray *allotmentDirectionIndicators;
@property (strong, nonatomic) NSArray *trafficLanes;
@property (strong, nonatomic) NSArray *selectedTrafficLanes;
@end


@implementation IncidentDetailViewController
#pragma mark - getters


- (TowingVoucher *) towingVoucher
{
    return self.delegate.towingVoucher;
}

- (NSArray *) trafficPosts
{
    if(!_trafficPosts) {
        _trafficPosts = [TrafficPost findAllTrafficPosts:self.delegate.managedObjectContext];
    }
    
    return _trafficPosts;
}



- (NSArray *) allotmentDirections
{
    if(!_allotmentDirections) {
        _allotmentDirections = [AllotmentDirection findAll:self.delegate.managedObjectContext];
    }
    
    return _allotmentDirections;
}

- (NSArray *) allotmentDirectionIndicators {
    
    if(allotmentDirection) {
        return [[allotmentDirection.indicators allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            AllotmentDirectionIndicator *ad1 = (AllotmentDirectionIndicator *) obj1;
            AllotmentDirectionIndicator *ad2 = (AllotmentDirectionIndicator *) obj2;
            
            return [ad1.name compare:ad2.name];
        }];
    }
    
    return nil;
}

- (NSArray *) trafficLanes
{
    if(!_trafficLanes) {
        _trafficLanes = [TrafficLane findAll:self.delegate.managedObjectContext];
    }
    
    return _trafficLanes;
}

- (NSArray *) selectedTrafficLanes
{
    NSMutableArray *items = [NSMutableArray new];
    
    NSDictionary *lanes = [self.towingVoucher.dossier jsonObjectForKey:TRAFFIC_LANES];
    
    for (NSDictionary *lane in lanes) {
        if([[JsonUtil asString:[lane objectForKey:@"selected"]] isEqualToString:@"1"]) {
            [items addObject:[TrafficLane findById:[JsonUtil asString:[lane objectForKey:ID]]
                                       withContext:self.delegate.managedObjectContext]];
        }
    }
    
    
    return [items copy];
}

#pragma mark - View cycle

- (void) viewDidLoad
{
    [self setupGui];
    
    //configuring navigation bar
    self.navigationItem.title = [NSString stringWithFormat:VIEW_TITLE_INCIDENT_DETAIL,  [self.towingVoucher.dossier jsonObjectForKey:@"incident_type_name"]];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(performSave)];
    self.navigationItem.rightBarButtonItem = done;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processUpdateTowingNotification:)
                                                 name:NOTIFICATION_UPDATE_TOWING
                                               object:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) styleTrafficLanesButtonWithText:(NSString *)trafficLanesName
{
    if(!trafficLanesName || [trafficLanesName isEqualToString:@""]) {
        [self.trafficLanesButton setTitle:BUTTON_TRAFFIC_LANES_NONE forState:UIControlStateNormal];
        [self.trafficLanesButton setBackgroundColor:[UIColor redColor]];
        [self.trafficLanesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [self.trafficLanesButton setTitle:trafficLanesName forState:UIControlStateNormal];
        [self.trafficLanesButton setBackgroundColor:[UIColor clearColor]];
        [self.trafficLanesButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
}


- (void) processUpdateTowingNotification:(NSNotification *) notification
{
    [self setupGui];
}

- (void) setupGui
{
    TowingVoucher *voucher = self.delegate.towingVoucher;
    
    self.towingNameLabel.text               = voucher.towing_vehicle.name; // [JsonUtil asString:[voucher jsonObjectForKey:TOWED_BY]];
    self.towingLicencePlateLabel.text       = voucher.towing_vehicle.licence_plate; //[JsonUtil asString:[voucher jsonObjectForKey:TOWED_BY_VEHICLE]];
    
    self.additionalInformationTextView.text = [JsonUtil asString:[voucher jsonObjectForKey:ADDITIONAL_INFO]];
    
    // -- SET THE ALLOTMENT DIRECTION --
    allotmentDirection = [AllotmentDirection findById:[voucher.dossier jsonObjectForKey:@"allotment_direction_id"] withContext:self.delegate.managedObjectContext];
    
    if(allotmentDirection) {
        [self.allotmentDirectionButton setTitle:allotmentDirection.name forState:UIControlStateNormal];
    } else {
        [self.allotmentDirectionButton setTitle:BUTTON_LABEL_SELECT_DIRECTION forState:UIControlStateNormal];
    }
    
    // -- SET THE ALLOTMENT DIRECTION INDICATOR --
    AllotmentDirectionIndicator *indicator = [AllotmentDirectionIndicator findById:[voucher.dossier jsonObjectForKey:@"allotment_direction_indicator_id"] withContext:self.delegate.managedObjectContext];
    
    if(indicator) {
        [self.allotmentDirectionIndicatorButton setTitle:indicator.name forState:UIControlStateNormal];
    } else {
        [self.allotmentDirectionIndicatorButton setTitle:BUTTON_LABEL_SELECT_DIRECTION_INDICATOR forState:UIControlStateNormal];
    }
    
    
    //-- SET THE TRAFFIC LANES --
    NSString *trafficLanesName = [JsonUtil asString:[voucher.dossier jsonObjectForKey:TRAFFIC_LANES_NAME]];
    
    [self styleTrafficLanesButtonWithText:trafficLanesName];
    
    
    [self displayTimings];
}

- (void) displayTimings
{
    [self setTimingLabel:self.signaArrivalLabel
               andButton:self.signArrivalButton
              withString:[JsonUtil asString:[self.towingVoucher jsonObjectForKey:SIGNA_ARRIVAL]]];
    [self setTimingLabel:self.towingArrivalLabel
               andButton:self.towingArrivalButton
              withString:[JsonUtil asString:[self.towingVoucher jsonObjectForKey:TOWING_ARRIVAL]]];
    [self setTimingLabel:self.towingStartLabel
               andButton:self.towingStartButton
              withString:[JsonUtil asString:[self.towingVoucher jsonObjectForKey:TOWING_START]]];
    [self setTimingLabel:self.towingStopLabel
               andButton:self.towingStopButton
              withString:[JsonUtil asString:[self.towingVoucher jsonObjectForKey:TOWING_END]]];
    [self setTimingLabel:self.towingCalledLabel
               andButton:nil
              withString:[JsonUtil asString:[self.towingVoucher jsonObjectForKey:TOWING_CALLED]]];
}



#pragma mark - DetailViewProtocol implementation
- (void) performSave
{
    NSLog(@"Triggering %s", __PRETTY_FUNCTION__);
    
    [self saveVoucherToBackoffice];
}

- (void) saveVoucherToBackoffice {
    [self.delegate.managedObjectContext save:nil];
    
    [((Dossier *) self.towingVoucher.dossier) performSaveToBackoffice];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DIRECTIONS_UPDATED object:nil];
}

#pragma mark - IBActions

- (IBAction)selectAllotmentDirectionAction:(id)sender
{
    AllotmentDirectionTableViewController *viewController = [[AllotmentDirectionTableViewController alloc] init];
    viewController.data = self.allotmentDirections;
    viewController.delegate = self;
    viewController.sender = sender;
    
    [self presentPopOverViewController:viewController fromSender:sender withDelegate:self];
}

- (IBAction)selectAllotmentDirectionIndicatorAction:(id)sender
{
    AllotmentDirectionIndicatorTableViewController *viewController = [[AllotmentDirectionIndicatorTableViewController alloc] init];
    viewController.data = self.allotmentDirectionIndicators;
    viewController.delegate = self;
    viewController.sender = sender;
    
    [self presentPopOverViewController:viewController fromSender:sender withDelegate:self];
}

- (IBAction)selectTrafficLanesAction:(id)sender
{
    TrafficLanesTableViewController *viewController = [[TrafficLanesTableViewController alloc] init];
    viewController.data = self.trafficLanes;
    viewController.delegate = self;
    viewController.selectedItems = self.selectedTrafficLanes;
    viewController.sender = sender;
    
    [self presentPopOverViewController:viewController fromSender:sender withDelegate:self];
}

- (IBAction)singaArrivalAction:(id)sender
{
    [self registerVoucherDateTimeForCategory:SIGNA_ARRIVAL button:sender];
}

- (IBAction)towingArrivalAction:(id)sender
{
    [self registerVoucherDateTimeForCategory:TOWING_ARRIVAL button:sender] ;
}
- (IBAction)towingStartAction:(id)sender
{
    [self registerVoucherDateTimeForCategory:TOWING_START button:sender];
}
- (IBAction)towingEndAction:(id)sender
{
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT_TITLE_TOWING_END
                                                                   message:ALERT_MESSAGE_TOWING_END
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
                                                              [self showWaitMessage];
                                                              
                                                              [self registerVoucherDateTimeForCategory:TOWING_END button:sender];
                                                              
                                                              
                                                              [self hideWaitMessage];
                                                              
                                                              //navigate back to overview
                                                              [self.delegate gotoTowingVoucherOverview];
                                                          }];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)idleAction:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT_TITLE_IDLE_RIDE
                                                                   message:ALERT_MESSAGE_IDLE_RIDE
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
                                                              [self showWaitMessage];
                                                              
                                                              NSString *voucher_id = self.towingVoucher.id;
                                                              NSString *token = self.delegate.authenticatedUser.token;
                                                              
                                                              NSString *api = [NSString stringWithFormat:API_IDLE_RIDE, voucher_id, token];
                                                              
                                                              [self.restService post:api withParameters:nil onCompleteBlock:^(NSDictionary *json) {
                                                                  [self hideWaitMessage];
                                                                  
                                                                  //notify update of vouchers
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_VOUCHER_OVERVIEW object:self];
                                                                  
                                                                  //navigate back to overview
                                                                  [self.delegate gotoTowingVoucherOverview];
                                                              } onFailBlock:^(NSError *error, int statusCode) {
                                                                  [self hideWaitMessage];
                                                              }];
                                                          }];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) registerVoucherDateTimeForCategory:(NSString *) category button:(id)sender
{
    //NSString *date = [DateUtil formatAsJsonDateTime:[NSDate date]];
    NSDate *date = [NSDate date];
    
    [self.towingVoucher jsonObject:[NSString stringWithFormat:@"%f", [date timeIntervalSince1970]]
                                     forKey:category];
    
    [self performSave];
    
    ((UIButton *) sender).enabled = NO;
    
    [self displayTimings];
}



- (void) setTimingLabel:(UILabel *)label andButton:(UIButton *) button withString:(NSString *)dateString
{
    if(dateString)
    {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateString.doubleValue];
        
        label.text = [DateUtil formatAsDateTime:date];
        if(button)
            button.enabled = NO;
    }
    else
    {
        if(button)
            button.enabled = YES;
        
        label.text = @"";
    }
}

#pragma mark - List Picker Delegate
- (void) wasSelected:(id)selectedItem sender:(id) sender;
{
    if(selectedItem)
    {
        TowingVoucher *voucher = self.towingVoucher;
        Dossier *dossier = (Dossier *)voucher.dossier;
        
        if([selectedItem isKindOfClass:[AllotmentDirection class]])
        {
            allotmentDirection = (AllotmentDirection *) selectedItem;
            
            [dossier jsonValue:allotmentDirection.id forKey:ALLOTMENT_DIRECTION_ID];
            [dossier jsonValue:allotmentDirection.name forKey:@"direction_name"];
            
            [self.allotmentDirectionButton setTitle:allotmentDirection.name forState:UIControlStateNormal];
            
            self.allotmentDirectionIndicators = nil;
            
            [self.allotmentDirectionIndicatorButton setTitle:BUTTON_LABEL_SELECT_DIRECTION_INDICATOR forState:UIControlStateNormal];
        }
        else if([selectedItem isKindOfClass:[AllotmentDirectionIndicator class]])
        {
            AllotmentDirectionIndicator *adi = (AllotmentDirectionIndicator *) selectedItem;
            
            [dossier jsonValue:adi.id forKey:ALLOTMENT_DIRECTION_INDICATOR_ID];
            [dossier jsonValue:adi.name forKey:@"indicator_name"];
            
            [self.allotmentDirectionIndicatorButton setTitle:adi.name forState:UIControlStateNormal];
        } else {
            if([sender isEqual:self.trafficLanesButton]) {
                NSDictionary *lanes = [self.towingVoucher.dossier jsonObjectForKey:TRAFFIC_LANES];
                
                NSArray *selectedItemsFromResult = (NSArray *) selectedItem;
                
                NSString *trafficLanesName = @"";
                
                for (NSMutableDictionary *lane in lanes) {
                    TrafficLane *tl = [TrafficLane findById:[JsonUtil asString:[lane objectForKey:ID]]
                                                withContext:self.delegate.managedObjectContext];
                    
                    if([selectedItemsFromResult containsObject:tl]) {
                        [lane setObject:@1 forKey:@"selected"];
                        
                        if(![trafficLanesName isEqualToString:@""])
                            trafficLanesName = [NSString stringWithFormat:@"%@,", trafficLanesName];
                        
                        trafficLanesName = [NSString stringWithFormat:@"%@ %@", trafficLanesName, tl.name];
                    } else {
                        [lane setObject:@0 forKey:@"selected"];
                    }
                }
                
                [self styleTrafficLanesButtonWithText:trafficLanesName];
                
                [self.towingVoucher.dossier jsonObject:lanes forKey:TRAFFIC_LANES];
                [self.towingVoucher.dossier jsonObject:trafficLanesName forKey:TRAFFIC_LANES_NAME];
            }
        }
        
        [dossier.managedObjectContext save:nil];
    }
    
    if(![sender isEqual:self.trafficLanesButton]) {
        [self.popover dismissPopoverAnimated:YES];
    }
}

@end
