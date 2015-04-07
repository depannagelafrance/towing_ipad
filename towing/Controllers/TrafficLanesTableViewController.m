//
//  TrafficLanesTableViewController.m
//  towing
//
//  Created by Kris Vandermast on 03/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "TrafficLanesTableViewController.h"
#import "TrafficLane+Model.h"

@implementation TrafficLanesTableViewController

#pragma mark - getters
- (NSArray *) selectedItems {
    if(!_selectedItems) {
        _selectedItems = [NSArray new];
    }
    
    return _selectedItems;
}

#pragma mark - view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelection = YES;
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
    TrafficLane *tl = ((TrafficLane *)[self.data objectAtIndex:indexPath.row]);
    cell.textLabel.text = tl.name;
    
    if([self.selectedItems containsObject:tl]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self processTableSelection:tableView atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self processTableSelection:tableView atIndexPath:indexPath];
}

- (void) processTableSelection:(UITableView *) tableView atIndexPath:(NSIndexPath *)indexPath {
    if(self.delegate)
    {
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if(cell)
        {
            TrafficLane *item = (TrafficLane *) [self.data objectAtIndex:indexPath.row];
            
            NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.selectedItems];
            
            if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
            {
                //was selected, now deselect
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                [items removeObject:item];
            }
            else
            {
                //not selected, so select it
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                [items addObject:item];
            }
            
            self.selectedItems = [items copy];
            
            [self.delegate wasSelected:self.selectedItems sender:self.sender];
        }
    }
}

@end
