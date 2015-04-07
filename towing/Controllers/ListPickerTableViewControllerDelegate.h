//
//  ListPickerTableViewControllerDelegate.h
//  towing
//
//  Created by Kris Vandermast on 02/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ListPickerTableViewControllerDelegate <NSObject>
@required
- (void) wasSelected:(id) selectedItem sender:(id) sender;
@end
