//
//  ImpactViewController.h
//  towing
//
//  Created by Kris Vandermast on 08/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "DrawableView.h"
#import "BaseViewController.h"

typedef void(^ProcessSignatureBlock)(NSString *);

@interface ImpactViewController : BaseViewController

@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) UIImageView *impactView;
@property (copy, nonatomic) ProcessSignatureBlock signatureBlock;

@end
