//
//  TrafficPostDetailViewController.m
//  towing
//
//  Created by Kris Vandermast on 28/01/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "TrafficPostDetailViewController.h"
#import "Dossier+Model.h"
#import "TowingVoucher+Model.h"
#import "TowingVoucherSignature.h"
#import "TrafficPost+Model.h"
#import "SignatureViewController.h"

#define FORMAT_DATETIME_READABLE @"dd/MM/yyyy HH:mm"

#import "JsonUtil.h"

@interface TrafficPostDetailViewController () {
    UIDatePicker *datePicker;
}
@property (strong, nonatomic) NSArray *trafficPosts;
@property (strong, nonatomic) UIPopoverController *popover;

@property (weak, nonatomic) IBOutlet UIButton *cicTimeButton;

@property (weak, nonatomic) IBOutlet UILabel *callNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *trafficPostButton;
@property (weak, nonatomic) IBOutlet UIImageView *signatureView;

@end

@implementation TrafficPostDetailViewController
#pragma mark - getters
- (NSArray *) trafficPosts
{
    if(!_trafficPosts) {
        _trafficPosts = [TrafficPost findAllTrafficPosts:self.delegate.managedObjectContext];
        
        _trafficPosts = [_trafficPosts sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            TrafficPost *t1 = (TrafficPost *) obj1;
            TrafficPost *t2 = (TrafficPost *) obj2;
            
            return [t1.name compare:t2.name];
        }];
    }
    
    return _trafficPosts;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    TowingVoucher *voucher = self.delegate.towingVoucher;
    Dossier *dossier = (Dossier *)voucher.dossier;
    
    self.callNumberLabel.text = [NSString stringWithFormat:@"Takelbon: %@", voucher.voucher_number];
    
    
    if([dossier jsonObjectForKey:TRAFFIC_POST_ID])
    {
        [self.trafficPostButton setTitle:[dossier jsonObjectForKey:TRAFFIC_POST_NAME] forState:UIControlStateNormal];
    }
    else
    {
        [self.trafficPostButton setTitle:@"Geen ploeg" forState:UIControlStateNormal];
    }
    
    
    if(voucher.signature_traffic_post) {
        NSString *path = voucher.signature_traffic_post.path;
        [self.signatureView setImage:[UIImage imageWithContentsOfFile:path]];
    }
    
    
    NSString *cic = [JsonUtil asString:[voucher jsonObjectForKey:CIC ]];
    
    if(cic && ![cic isEqualToString:@""]) {
        NSDate *cicDate = [NSDate dateWithTimeIntervalSince1970:[cic integerValue]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:FORMAT_DATETIME_READABLE];
        
        [self.cicTimeButton setTitle:[formatter stringFromDate:cicDate] forState:UIControlStateNormal];
    }
    
    //configuring navigation bar
    self.navigationItem.title = @"Federale Wegpolitie";
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(performSave)];
    self.navigationItem.rightBarButtonItem = done;
    
    [self resignFirstResponder];
}

#pragma mark - DetailViewProtocol implementation

- (void) performSave
{
    NSLog(@"Triggering %s", __PRETTY_FUNCTION__);
    TowingVoucher *voucher = self.delegate.towingVoucher;
    
//    [voucher jsonValue:self.cicTextField.text forKey:CIC];
    
    [((Dossier *) voucher.dossier) performSaveToBackoffice];
}

#pragma mark - IBActions
- (IBAction)selectTrafficPostAction:(id)sender
{
    TrafficPostsTableViewController *viewController = [[TrafficPostsTableViewController alloc] init];
    viewController.availableTrafficPosts = self.trafficPosts;
    viewController.delegate = self;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.delegate = self;
    self.popover.popoverContentSize = CGSizeMake(650, 450); //your custom size.
    
    [self.popover presentPopoverFromRect:((UIButton *) sender).frame
                                  inView:self.view
                permittedArrowDirections: UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionUp | UIPopoverArrowDirectionRight
                                animated:YES];
}

- (IBAction)captureSignatureAction:(id)sender
{
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    SignatureViewController *viewController = [[SignatureViewController alloc] initWithNibName:@"SignatureView" bundle:nil];
    viewController.token = delegate.authenticatedUser.token;
    viewController.category = @"signature_police";
    viewController.signatureImageView = self.signatureView;
    
    __block NSString *token = delegate.authenticatedUser.token;
    __block NSString *voucherId = delegate.towingVoucher.id;
    
    [viewController setSignatureBlock:^(NSString *path) {
        NSLog(@"Wrote image to directory: %@", path);
        
        NSData *signaturePNG = [NSData dataWithContentsOfFile:path];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        
        NSString *api = [NSString stringWithFormat:@"/dossier/voucher/attachment/signature_police/%@/%@", voucherId, token];
        NSDictionary *params = @{@"content_type": @"image/png",
                                 @"file_size" : fileSizeNumber,
                                 @"content" : [signaturePNG base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]};
        
        
        [self.popover dismissPopoverAnimated:YES];
        
        RestService *restService = [[RestService alloc] init];
        
        [restService post:api withParameters:params onCompleteBlock:^(NSDictionary *result) {
            NSLog(@"Added the attachment in the back-end: %@", result);
        } onFailBlock:^(NSError *error, int statusCode) {
            NSLog(@"Failed to send signature to back-end: %ul - %@", statusCode, error);
        }];
    }];
    
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.delegate = self;
    self.popover.popoverContentSize = CGSizeMake(self.view.frame.size.width+320, self.view.frame.size.height);
    self.popover.passthroughViews = [NSArray arrayWithObject:self.view];
    
    [self.popover presentPopoverFromRect:CGRectMake(0, 0, self.view.frame.size.width+320, self.view.frame.size.height)
                                  inView:self.view
                permittedArrowDirections: 0
                                animated:YES];
    
}


- (IBAction)selectCicTime:(id)sender
{
    UIViewController *popoverContent = [[UIViewController alloc] init];
    
    UIView *popoverView = [[UIView alloc] init];
    
    datePicker = [[UIDatePicker alloc] init];
    datePicker.frame = CGRectMake(0, 44, 320, 216);
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [datePicker addTarget:self action:@selector(updateCicTime:) forControlEvents:UIControlEventValueChanged];
    
    [popoverView addSubview:datePicker];
    

    popoverContent.view = popoverView;
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    popoverController.delegate = self;
    
    [popoverController setPopoverContentSize:CGSizeMake(320, 264) animated:NO];
    [popoverController presentPopoverFromRect:self.cicTimeButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    NSString *cic = [JsonUtil asString:[self.delegate.towingVoucher jsonObjectForKey:CIC ]];
    
    if(!cic || [cic isEqualToString:@""])
    {
        [self setCIcTime:[NSDate date]];
    }
}

- (void) updateCicTime:(UIDatePicker *) sender
{
    [self setCIcTime:sender.date];
}

- (void) setCIcTime:(NSDate *) date
{
    TowingVoucher *voucher = self.delegate.towingVoucher;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:FORMAT_DATETIME_READABLE];
    NSString *timeInterval = [NSString stringWithFormat:@"%f", date.timeIntervalSince1970];
    
    DLog(@"Setting timestamp to: %@", timeInterval);
    [voucher jsonValue:timeInterval forKey:CIC];
    
    [[voucher managedObjectContext] save:nil];
    
    [self.cicTimeButton setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

#pragma mark - List Picker Delegate
- (void) wasSelected:(id)selectedItem
{
    if(selectedItem)
    {
        TowingVoucher *voucher = self.delegate.towingVoucher;
        Dossier *dossier = (Dossier *)voucher.dossier;
        
        if([selectedItem isKindOfClass:[TrafficPost class]])
        {
            TrafficPost *trafficPost = (TrafficPost *) selectedItem;
            
            [dossier jsonValue:trafficPost.name forKey:TRAFFIC_POST_NAME];
            [dossier jsonValue:trafficPost.id forKey:TRAFFIC_POST_ID];
            
            [self.trafficPostButton setTitle:trafficPost.name forState:UIControlStateNormal];
        }
        
        [dossier.managedObjectContext save:nil];
    }
    
    
    [self.popover dismissPopoverAnimated:YES];
}


@end
