//
//  SignatureView.m
//  towing
//
//  Created by Kris Vandermast on 13/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "SignatureView.h"

@implementation SignatureView
#pragma mark - DrawableViewProtcol
- (UIColor *) backgroundColor {
    return [UIColor whiteColor];
}

- (UIColor *) lineColor {
    return [UIColor blackColor];
}

@end
