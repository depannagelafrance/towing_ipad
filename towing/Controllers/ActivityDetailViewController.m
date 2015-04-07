//
//  ActivityDetailViewController.m
//  towing
//
//  Created by Kris Vandermast on 27/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "AvailableActivitiesTableViewController.h"
#import "ActivityDetailTableViewCell.h"
#import "TowingVoucher+Model.h"
#import "TimeframeActivity+Model.h"
#import "TimeframeActivityFee+Model.h"
#import "Dossier+Model.h"
#import "JsonUtil.h"


@interface ActivityDetailViewController () {
    long selectedIndex;
}
@property (strong, nonatomic) NSMutableArray *activities;
@property (strong, nonatomic) NSMutableArray *availableActivities;
@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UILabel *totalExclVatLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalInclVatLabel;
@end

@implementation ActivityDetailViewController

#pragma mark - getters
- (NSMutableArray *) activities
{
    if(!_activities) {
        NSArray *items = [self.delegate.towingVoucher jsonObjectForKey:TOWING_ACTIVITIES];
        _activities = [[NSMutableArray alloc] initWithArray:[items sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            return [[a objectForKey:NAME] compare:[b objectForKey:NAME]
                                          options:NSCaseInsensitiveSearch];
        }]];
    }
    
    return _activities;
}

- (NSMutableArray *) availableActivities
{
    NSManagedObjectContext *context = self.delegate.managedObjectContext;
    
    _availableActivities = [[NSMutableArray alloc] initWithArray:[TimeframeActivity findAllTimeframeActivities:context]];
    
    for(NSDictionary *activity in self.activities)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", [activity objectForKey:TIMEFRAME_ACTIVITY_ID]];
        
        NSArray *filteredResults = [_availableActivities filteredArrayUsingPredicate:predicate];
        
        if(filteredResults && filteredResults.count > 0)
        {
            [_availableActivities removeObjectIdenticalTo:[filteredResults firstObject]];
        }
    }
    
    if(DEBUG){
        for(id act in self.activities) {
            DLog(@"%@", act);
        }
        
        DLog(@" ------------------------------------------------ " );
        
        for(TimeframeActivity *act in _availableActivities) {
            DLog(@"[%@] %@ - %@ -", act.id, act.code, act.name);
        }
    }
    
    
    return _availableActivities;
}

#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ActivityDetailCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"activityDetailCell"];
    
    [self calculateTotalCost];
    
    self.navigationItem.title = @"Activiteiten";
    
    [self resetNavigationButtons];
    
}

- (void) resetNavigationButtons {
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(performSave)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addActivityAction)];
    self.navigationItem.rightBarButtonItem = done;
    self.navigationItem.leftBarButtonItem = add;
}

#pragma mark - IBActions
- (void)addActivityAction
{
    AvailableActivitiesTableViewController *viewController = [[AvailableActivitiesTableViewController alloc] init];
    viewController.availableActivities = self.availableActivities;
    viewController.delegate = self;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.delegate = self;
    self.popover.popoverContentSize = CGSizeMake(650, 450); //your custom size.
    //    self.popover.passthroughViews = [NSArray arrayWithObject:self.view];
    
    [self.popover presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    //    [self.popover presentPopoverFromRect:self.navigationItem.leftBarButtonItem.
    //                                  inView:self.view
    //                permittedArrowDirections: UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionUp
    //                                animated:YES];
}

#pragma mark - Implementation ActivityListPickerDelegate
- (void) wasSelected:(id)selectedItem
{
    [self.popover dismissPopoverAnimated:YES];
    
    TimeframeActivity *activity = (TimeframeActivity *) selectedItem;
    
    NSNumber *timeframe_id = [self.delegate.towingVoucher.dossier.jsonObject objectForKey:@"timeframe_id"];
    
    TimeframeActivityFee *fee = [TimeframeActivityFee findByTimeframe:timeframe_id andActivity:activity.id inContext:self.delegate.managedObjectContext];
    
    NSDictionary *params = @{ACTIVITY_ID: fee.id,
                             CODE: activity.code,
                             NAME: activity.name,
                             TOWING_VOUCHER_ID: self.delegate.towingVoucher.id,
                             AMOUNT: @1,
                             CAL_FEE_INCL_VAT: fee.fee_incl_vat,
                             CAL_FEE_EXCL_VAT: fee.fee_excl_vat,
                             FEE_INCL_VAT: fee.fee_incl_vat,
                             FEE_EXCL_VAT: fee.fee_excl_vat};
    
    if(DEBUG) {
        DLog(@"Setting parameters for activity: %@", params);
    }
    
    NSMutableArray *items = [self.delegate.towingVoucher jsonObjectForKey:TOWING_ACTIVITIES];
    [items addObject:params];
    
    [self.delegate.towingVoucher jsonObject:[items copy] forKey:TOWING_ACTIVITIES];
    
    [self reloadData];
}

- (void) reloadData
{
    self.activities = nil;
    self.availableActivities = nil;
    
    [self.tableView reloadData];
    [self calculateTotalCost];
}

- (void) calculateTotalCost
{
    double cal_fee_incl_vat = 0.0;
    double cal_fee_excl_vat = 0.0;
    
    for(NSDictionary *item in self.activities)
    {
        cal_fee_incl_vat += [JsonUtil asNumber:[item objectForKey:CAL_FEE_INCL_VAT]].doubleValue;
        cal_fee_excl_vat += [JsonUtil asNumber:[item objectForKey:CAL_FEE_EXCL_VAT]].doubleValue;
    }
    
    self.totalExclVatLabel.text = [NSString stringWithFormat:FORMAT_CURRENCY, cal_fee_excl_vat];
    self.totalInclVatLabel.text = [NSString stringWithFormat:FORMAT_CURRENCY, cal_fee_incl_vat];
    
}

#pragma mark - DetailViewProtocol
- (void) performSave
{
    [((Dossier *) self.delegate.towingVoucher.dossier) performSaveToBackoffice];
}

- (void) performDelete
{
    if(selectedIndex >= 0) {
        NSMutableArray *copyList = [NSMutableArray new];
        
        for(int i = 0; i < self.activities.count; i++) {
            if(i != selectedIndex)
            {
                [copyList addObject:[self.activities objectAtIndex:i]];
            } else {
                NSString *activityId = [JsonUtil asString:[(NSDictionary *)[self.activities objectAtIndex:i] objectForKey:ACTIVITY_ID]];
                NSString *api = [NSString stringWithFormat:REMOVE_ACTIVITY_FROM_VOUCHER_API, self.delegate.towingVoucher.id, activityId, self.delegate.authenticatedUser.token];
                
                [self.restService del:api withParameters:nil onCompleteBlock:^(NSDictionary *data) {
                    //ignore
                } onFailBlock:^(NSError *error, int statusCode) {
                    if(statusCode == ERROR_DOMAIN_CONNECTION_CODE) {
                        [self triggerErrorMessage:@"Om een activiteit te verwijderen dient u een internet connectie te hebben."];
                    } else {
                        [self triggerErrorMessage:@"Er was een probleem bij het verwijderen van deze activiteit. Contacteer de centrale."];
                    }
                }];
            }
        }
        
        selectedIndex = -1;
        self.activities = nil;
        
        [self.delegate.towingVoucher jsonObject:copyList forKey:TOWING_ACTIVITIES];
        [self performSave];
        
        [self.tableView reloadData];
        [self resetNavigationButtons];
    }
}

#pragma mark - UITableView delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableIdentifier = @"activityDetailCell";
    
    ActivityDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
    
    if(!cell) {
        cell = [[ActivityDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:reusableIdentifier];
    }
    
    
    NSDictionary *item = [self.activities objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [item objectForKey:NAME];
    
    cell.amountTextField.text       = [JsonUtil asString:[item objectForKey:AMOUNT]];
    cell.amountTextField.delegate   = self;
    cell.amountTextField.tag        = 900 + indexPath.row;
    
    cell.feeExclVatLabel.text       = [NSString stringWithFormat:FORMAT_CURRENCY, [JsonUtil asString:[item objectForKey:FEE_EXCL_VAT]].doubleValue];
    cell.feeInclVatLabel.text       = [NSString stringWithFormat:FORMAT_CURRENCY, [JsonUtil asString:[item objectForKey:FEE_INCL_VAT]].doubleValue];
    cell.calFeeExclVatLabel.text    = [NSString stringWithFormat:FORMAT_CURRENCY, [JsonUtil asNumber:[item objectForKey:CAL_FEE_EXCL_VAT]].doubleValue];
    cell.calFeeInclVatLabel.text    = [NSString stringWithFormat:FORMAT_CURRENCY, [JsonUtil asNumber:[item objectForKey:CAL_FEE_INCL_VAT]].doubleValue];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIBarButtonItem *deleteRow = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(performDelete)];
    
    self.navigationItem.rightBarButtonItem = deleteRow;
    
    selectedIndex = indexPath.row;
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self resetNavigationButtons];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.activities.count;
}

#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    int selectedRow = (int) textField.tag - 900;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
    
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [self recalculateFeeForTextField:textField];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self recalculateFeeForTextField:textField];
    
    return YES;
}

- (void) recalculateFeeForTextField:(UITextField *) textField
{
    int selectedRow =  (int) textField.tag - 900;
    
    NSDictionary *item = [self.activities objectAtIndex:selectedRow];
    
    double fee_incl_vat = ((NSString *)[item objectForKey:FEE_INCL_VAT]).doubleValue * textField.text.doubleValue;
    double fee_excl_vat = ((NSString *)[item objectForKey:FEE_EXCL_VAT]).doubleValue * textField.text.doubleValue;
    
    [item setValue:textField.text forKey:AMOUNT];
    [item setValue:[NSString stringWithFormat:@"%f", fee_incl_vat] forKey:CAL_FEE_INCL_VAT];
    [item setValue:[NSString stringWithFormat:@"%f", fee_excl_vat] forKey:CAL_FEE_EXCL_VAT];
    
    [self.activities setObject:item atIndexedSubscript:selectedRow];
    
    ActivityDetailTableViewCell *cell = (ActivityDetailTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]];
    cell.calFeeExclVatLabel.text = [NSString stringWithFormat:FORMAT_CURRENCY, fee_excl_vat];
    cell.calFeeInclVatLabel.text = [NSString stringWithFormat:FORMAT_CURRENCY, fee_incl_vat];
    
    [self.delegate.towingVoucher jsonObject:self.activities forKey:TOWING_ACTIVITIES];
    
    [self calculateTotalCost];
}

@end
