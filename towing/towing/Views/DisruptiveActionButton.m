//
//  DisruptiveActionButton.m
//  towing
//
//  Created by Kris Vandermast on 27/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "DisruptiveActionButton.h"
#define MY_CORNER_RADIUS  5.0

#define MY_WHITE_COLOR  [UIColor whiteColor]

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define ACTION_BUTTON_COLOR [UIColor colorWithRed:233.0/255.0 green:30.0/255.0 blue:99.0/255.0 alpha:1.0]
#define ACTION_BUTTON_DISABLED_COLOR [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0]



@implementation DisruptiveActionButton
-(void)setLayout
{
    [self setButtonStandards];
    [self setButtonLayout];
}

-(void)setButtonLayout
{
    self.layer.cornerRadius = MY_CORNER_RADIUS;
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.layer.borderWidth = 0.6f;
    self.layer.borderColor = ACTION_BUTTON_COLOR.CGColor;
    self.layer.backgroundColor = ACTION_BUTTON_COLOR.CGColor;
}

- (void)setButtonStandards
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = ACTION_BUTTON_COLOR.CGColor;
        self.layer.cornerRadius = MY_CORNER_RADIUS;
        self.backgroundColor = MY_WHITE_COLOR;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
}

- (void) setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if(!enabled)
    {
        self.layer.cornerRadius = MY_CORNER_RADIUS;
        
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
        
        self.layer.borderWidth = 0.6f;
        self.layer.borderColor = ACTION_BUTTON_DISABLED_COLOR.CGColor;
        self.layer.backgroundColor = ACTION_BUTTON_DISABLED_COLOR.CGColor;
    }
    else
    {
        [self setButtonLayout];
    }
}

#pragma mark - Initialisation

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setLayout];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setLayout];
        // Initialization code
    }
    return self;
}
@end
