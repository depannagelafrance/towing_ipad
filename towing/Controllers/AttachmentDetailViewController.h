//
//  AttachmentDetailViewController.h
//  towing
//
//  Created by Kris Vandermast on 04/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailItemViewController.h"
#import "DetailViewProtocol.h"

@interface AttachmentDetailViewController : DetailItemViewController<DetailViewProtocol, UIDocumentInteractionControllerDelegate, UITextFieldDelegate>

@end
