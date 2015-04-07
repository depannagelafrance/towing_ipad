//
//  LicencePlateCountryTableViewController.m
//  towing
//
//  Created by Kris Vandermast on 02/12/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "LicencePlateCountryTableViewController.h"
#import "LicencePlateCountry.h"

@interface LicencePlateCountryTableViewController () {
    UISearchBar *tableSearchBar;
    UISearchController *searchDisplayController;
    BOOL senderIsTextField;
    NSArray *originalData;
    NSArray *filteredList;
}

- (void) filterContentForSearchText:(NSString *)searchText;

@end

@implementation LicencePlateCountryTableViewController
#pragma mark - view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    tableSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    /*the search bar widht must be > 1, the height must be at least 44
     (the real size of the search bar)*/
    
    tableSearchBar.delegate = self;
    
    self.tableView.tableHeaderView = tableSearchBar;
    
    originalData = [self.data copy];
    filteredList = [self.data copy];
}

- (void) viewDidAppear:(BOOL)animated {
    if(tableSearchBar.text.length>0)
    {
        [self filterContentForSearchText:tableSearchBar.text];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) filterContentForSearchText:(NSString *)searchText  {
    if(searchText == nil || [searchText isEqualToString:@""]) {
        //just create a copy
        filteredList = [NSMutableArray arrayWithArray:originalData];
    } else {
        //filter away
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@", searchText];
        
        filteredList = nil;
        filteredList = [NSMutableArray arrayWithArray:[originalData filteredArrayUsingPredicate:predicate]];
    }
    
    self.data = [filteredList copy];
    
    [self.tableView reloadData];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    filteredList = [[NSMutableArray alloc] initWithArray:originalData];
    [self.tableView reloadData];
    
    [searchBar resignFirstResponder];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterContentForSearchText:searchText];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self filterContentForSearchText:searchBar.text];
    [searchBar resignFirstResponder];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = ((LicencePlateCountry *)[self.data objectAtIndex:indexPath.row]).name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Notify the delegate if it exists.
    if (_delegate != nil)
    {
        [self.delegate wasSelected:[self.data objectAtIndex:indexPath.row] sender:self.sender];
    }
}

@end
