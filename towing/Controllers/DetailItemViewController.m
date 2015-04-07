//
//  DetailViewController.m
//  towing
//
//  Created by Kris Vandermast on 26/01/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "DetailItemViewController.h"
#import "AppDelegate.h"

#define SCROLL_MARGIN 150

@interface DetailItemViewController () {
    id assignedTextField;
    UIEdgeInsets originalScrollInsets;
    UIEdgeInsets originalScrollIndicatorInsets;
}

@property (strong, nonatomic) UIPopoverController *popover;
@end

@implementation DetailItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
}


- (void) presentPopOverViewController:(id)viewController fromSender:(id) sender withDelegate:(id) delegate
{
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.delegate = delegate;
    self.popover.popoverContentSize = CGSizeMake(650, 450); //your custom size.
    
    [self.popover presentPopoverFromRect:((UIButton *) sender).frame
                                  inView:self.view
                permittedArrowDirections:UIPopoverArrowDirectionUp
                                animated:YES];
}

- (void) dismissPopOverViewController
{
    if(self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
    }
}

#pragma mark - scrolling stuff
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    DLog(@" --> Keyboard size (w/h): %f/%f", kbSize.width, kbSize.height);
    
    if(UIEdgeInsetsEqualToEdgeInsets(originalScrollInsets, UIEdgeInsetsZero)) {
        originalScrollIndicatorInsets = self.currentScrollView.scrollIndicatorInsets;
        originalScrollInsets = self.currentScrollView.contentInset;
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.currentScrollView.contentInset = contentInsets;
    self.currentScrollView.scrollIndicatorInsets = contentInsets;

    CGRect aRect = self.view.frame;
    
    DLog(@" --> Current view is (w/h): %f/%f", aRect.size.width, aRect.size.height);
    
    //aRect.size.height -= kbSize.height;
    aRect.size.height = aRect.size.height - kbSize.height;

    self.currentScrollView.contentSize = CGSizeMake(aRect.size.height, aRect.size.width);
    
    DLog(@" --> Setting height/width to: %f/%f", aRect.size.height, aRect.size.width);
    
    
    CGPoint origin;
    
    if([assignedTextField isKindOfClass:[UITextView class]]) {
        origin = ((UITextView *) assignedTextField).frame.origin;
    } else {
        origin = ((UITextField *) assignedTextField).frame.origin;
    }
    
    DLog(@" --> Origin offset: %f", origin.y);
    
    origin.y -= (self.currentScrollView.contentOffset.y);
    
    DLog(@" --> Setting Origin offset: %f", origin.y);
    
//    if (!CGRectContainsPoint(aRect, origin) ) {
        DLog(@" --> Seems that the Point is not in the defined Rect");
        
        CGPoint scrollPoint = CGPointMake(0.0, origin.y-(aRect.size.height) + SCROLL_MARGIN);
        
        DLog(@" --> Created scrollpoint (x/y): %f/%f", scrollPoint.x, scrollPoint.y);
        
        [self.currentScrollView setContentOffset:scrollPoint animated:YES];
        
//    } 
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    //    self.currentScrollView.contentInset = contentInsets;
    //    self.currentScrollView.scrollIndicatorInsets = contentInsets;
    self.currentScrollView.contentInset = originalScrollInsets;
    self.currentScrollView.scrollIndicatorInsets = originalScrollIndicatorInsets;
    
    originalScrollInsets = UIEdgeInsetsZero;
    originalScrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    assignedTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    assignedTextField = nil;
}

- (void) textViewDidBeginEditing:(UITextView *)textView;
{
    assignedTextField = textView;
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    assignedTextField = nil;
}




@end
