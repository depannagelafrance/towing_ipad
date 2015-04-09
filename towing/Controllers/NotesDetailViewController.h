//
//  NotesDetailViewController.h
//  towing
//
//  Created by Kris Vandermast on 24/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "DetailViewProtocol.h"
#import "DetailItemViewController.h"

@interface NotesDetailViewController : DetailItemViewController<DetailViewProtocol, UITableViewDataSource, UITableViewDelegate>

@end
