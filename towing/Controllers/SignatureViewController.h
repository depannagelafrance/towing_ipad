//
//  SignatureViewController.h
//  towing
//
//  Created by Kris Vandermast on 21/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef void(^ProcessSignatureBlock)(NSString *);

@interface SignatureViewController : BaseViewController
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) UIImageView *signatureImageView;
@property (copy, nonatomic) ProcessSignatureBlock signatureBlock;
@end
