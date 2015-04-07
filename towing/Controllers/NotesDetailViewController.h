//
//  NotesDetailViewController.h
//  towing
//
//  Created by Kris Vandermast on 24/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "BaseViewController.h"
#import "DetailViewProtocol.h"

@interface NotesDetailViewController : BaseViewController<DetailViewProtocol, UITableViewDataSource, UITableViewDelegate>

@end
