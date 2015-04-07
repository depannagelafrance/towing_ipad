//
//  GeneralTextField.m
//  towing
//
//  Created by Kris Vandermast on 16/03/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "GeneralTextField.h"

@implementation GeneralTextField
- (void) setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if(!enabled)
    {
        self.backgroundColor = [UIColor lightGrayColor];
     }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}
@end
