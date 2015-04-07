//
//  VourcherOverviewController.m
//  towing
//
//  Created by Kris Vandermast on 11/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "VourcherOverviewController.h"
#import "TowingVoucher+Model.h"
#import "AppDelegate.h"
#import "Dossier+Model.h"
#import "DossierTableViewCell.h"
#import "DateUtil.h"
#import "JsonUtil.h"
#import "SynchronisationHandler.h"

@interface VourcherOverviewController ()
@property (strong, nonatomic) NSArray *vouchers;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation VourcherOverviewController
- (NSManagedObjectContext *) managedObjectContext {
    if(!_managedObjectContext) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = delegate.managedObjectContext;
    }
    
    return _managedObjectContext;
}

- (NSArray *) vouchers {
    if(!_vouchers) {
        _vouchers = [TowingVoucher findAllVouchersWithContext:self.managedObjectContext];
    }
    
    return _vouchers;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processNotification:)
                                                 name:ACTION_NEW_TOWING_VOUCHER_ASSIGNED
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processNotification:)
                                                 name:NOTIFICATION_UPDATE_VOUCHER_OVERVIEW
                                               object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - IBActions
- (IBAction)refreshTableAction:(id)sender
{
    [self.refreshControl beginRefreshing];
    
    [self refreshTable];
}

- (void) processNotification:(NSNotification *) aNotification
{
    DLog(@"Processing notification: %@", aNotification);
    
    [self refreshTable];
}

- (void) refreshTable
{
    SynchronisationHandler *handler = [[SynchronisationHandler alloc] init];
    [handler synchronizeDossiersAndVouchersFromBackofficeInContext:self.managedObjectContext];
    
    [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        delegate.towingVoucher =  (TowingVoucher *) object;
    }
}

- (IBAction)logoutAction:(id)sender {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    [delegate logout];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; //[[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return sectionInfo ? [sectionInfo numberOfObjects] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self configureCellAtIndexPath:indexPath];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [self performSegueWithIdentifier:@"segueToDetail" sender:self];
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    TowingVoucher *voucher = (TowingVoucher *) object;
    NSString *towingEnd = [JsonUtil asString:[voucher jsonObjectForKey:TOWING_END]];
    
    BOOL result = !towingEnd && ![towingEnd isEqualToString:@""];
    
    if(!result)
    {
        UIAlertView *alert = [[UIAlertView alloc ] initWithTitle:ALERT_ERROR_TITLE
                                                         message:@"Deze takelbon is reeds afgewerkt en kan niet meer gewijzigd worden!"
                                                        delegate:nil
                                               cancelButtonTitle:ALERT_BUTTON_OK otherButtonTitles: nil];
        
        [alert show];
    }
    else
    {
        delegate.towingVoucher =  voucher;
        
        static NSString *splitViewControllerIdentifier = @"splitViewControllerStoryboard";
        
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:splitViewControllerIdentifier];
        
        UIViewController *currentController = delegate.window.rootViewController;
        delegate.window.rootViewController = controller;
        delegate.window.rootViewController = currentController;
        
        [UIView transitionWithView:self.navigationController.view.window
                          duration:0.75
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            delegate.window.rootViewController = controller;
                        }
                        completion:nil];
    }
}

- (UITableViewCell *) configureCellAtIndexPath:(NSIndexPath *)indexPath {
    TowingVoucher *voucher = (TowingVoucher *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    DossierTableViewCell *cell = (DossierTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:@"DossierCell" forIndexPath:indexPath];
    cell.numberLabel.text = voucher.voucher_number;
    cell.callDateLabel.text = [DateUtil formatAsDateTime:((Dossier *)voucher.dossier).call_date];
    cell.callNumberLabel.text = voucher.dossier.call_number;
    
    if([voucher.dossier.hasBeenSynchd isEqualToValue:@1]) {
        cell.statusView.backgroundColor = [UIColor greenColor];
    } else {
        cell.statusView.backgroundColor = [UIColor orangeColor];
    }
    
    NSLog(@"Json: %@", ((Dossier *)voucher.dossier).json);
    
    if(((Dossier *)voucher.dossier).json)
    {
        
        NSDictionary *json = [((Dossier *)voucher.dossier).jsonObject copy];
        
        cell.direction.text = [JsonUtil asString:[json valueForKey:@"direction_name"]];
        cell.indicator.text = [JsonUtil asString:[json valueForKey:@"indicator_name"]];
        cell.vehiculeType.text = [JsonUtil asString:[voucher jsonObjectForKey:@"vehicule_type"]];
    }
    
    return cell;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TowingVoucher" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCellAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

@end
