//
//  AllotmentDirectionTableViewController.m
//  towing
//
//  Created by Kris Vandermast on 02/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "AllotmentDirectionTableViewController.h"
#import "AllotmentDirection+Model.h"

@implementation AllotmentDirectionTableViewController
#pragma mark - view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    cell.textLabel.text = ((AllotmentDirection *)[self.data objectAtIndex:indexPath.row]).name;
    
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
