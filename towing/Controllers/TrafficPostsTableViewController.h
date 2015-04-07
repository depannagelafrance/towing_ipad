//
//  TrafficPostsTableViewController.h
//  towing
//
//  Created by Kris Vandermast on 29/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "BaseViewController.h"

@protocol TrafficPostListPickerDelegate <NSObject>
@required
- (void) wasSelected:(id) selectedItem;
@end

@interface TrafficPostsTableViewController : UITableViewController
@property (strong, nonatomic) NSArray *availableTrafficPosts;
@property (weak, nonatomic) id<TrafficPostListPickerDelegate> delegate;
@end
