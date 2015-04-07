//
//  ImpactDrawableView.m
//  towing
//
//  Created by Kris Vandermast on 08/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "ImpactDrawableView.h"

@implementation ImpactDrawableView

- (UIColor *) backgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"carbg.png"]];
//    return [UIColor whiteColor];
}

- (UIColor *) lineColor {
    return [UIColor redColor];
}
@end
