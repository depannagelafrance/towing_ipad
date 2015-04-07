//
//  AttachmentDetailViewController.m
//  towing
//
//  Created by Kris Vandermast on 04/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "AttachmentDetailViewController.h"
#import "DetailItemViewController.h"
#import "DetailViewProtocol.h"

#import "GeneralActionButton.h"

#import "Dossier+Model.h"
#import "TowingVoucher+Model.h"

#define ALERT_TITLE_REQUEST_PDF_VOUCHER     @"PDF Takelbon aanmaken"
#define ALERT_MESSAGE_REQUEST_PDF_VOUCHER   @"U staat op het punt om de PDF takelbon aan te maken. Bent u zeker?"
#define ALERT_BUTTON_OK                     @"OK"
#define ALERT_BUTTON_CANCEL                 @"Annuleren"

#define NAVIGATION_TITLE_ATTACHMENTS        @"Bijlagen"

#define REPORT_DATA @"data"
#define REPORT_FILENAME @"filename"


//return $this->CI->rest->get(sprintf('/report/towing_voucher/%s/%s/%s/%s', $type, $dossier_id, $voucher_id, $token));
#define API_VOUCHER  @"/report/towing_voucher/%@/%@/%@/%@"

@interface AttachmentDetailViewController()
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (weak, nonatomic) IBOutlet GeneralActionButton *generateTowingVoucherButton;
@end

@implementation AttachmentDetailViewController
#pragma mark - getters

#pragma mark - Lifecycle
- (void) viewDidLoad
{
    //configuring navigation bar
    self.navigationItem.title = NAVIGATION_TITLE_ATTACHMENTS;
}

#pragma mark - IBActions
- (IBAction)requestTowingVoucherPDFAction:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT_TITLE_REQUEST_PDF_VOUCHER
                                                                   message:ALERT_MESSAGE_REQUEST_PDF_VOUCHER
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ALERT_BUTTON_CANCEL
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             DLog(@"%s -- CANCEL", __PRETTY_FUNCTION__);
                                                         }];
    
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:ALERT_BUTTON_OK
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             DLog(@"%s -- OK", __PRETTY_FUNCTION__);
                                                             [self showWaitMessage];
                                                             
                                                             [self.delegate.towingVoucher.dossier performSaveToBackoffice];
                                                             
                                                             NSString *type = @"customer";
                                                             NSString *dossier_id = self.delegate.towingVoucher.dossier.id;
                                                             NSString *voucher_id = self.delegate.towingVoucher.id;
                                                             NSString *token = self.delegate.authenticatedUser.token;
                                                             
                                                             NSString *api = [NSString stringWithFormat:API_VOUCHER, type, dossier_id, voucher_id, token];
                                                             
                                                             [self.restService get:api withParameters:nil onCompleteBlock:^(NSDictionary *json) {
                                                                 [self hideWaitMessage];
                                                                 
                                                                 
                                                                 if(json && [json objectForKey:REPORT_DATA])
                                                                 {
                                                                     NSData *data = [[NSData alloc] initWithBase64EncodedData:[json objectForKey:REPORT_DATA] options:0];
                                                                     //NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                                     
                                                                     NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                                                                     NSString *path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [json objectForKey:REPORT_FILENAME]];
                                                                     
                                                                     [data writeToFile:path atomically:YES];
                                                                     
                                                                     DLog(@"Writing file to : %@", path);
                                                                     
                                                                     [self performSelectorOnMainThread:@selector(openDocument:) withObject:path waitUntilDone:NO];
                                                                 }
                                                             } onFailBlock:^(NSError *error) {
                                                                 [self hideWaitMessage];
                                                             }];
                                                         }];
    
    [alert addAction:cancelAction];
    [alert addAction:createAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) openDocument:(NSString *) path
{
    //open document
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
    self.documentInteractionController.delegate = self;
    
    [self.documentInteractionController presentOpenInMenuFromRect:self.generateTowingVoucherButton.frame inView:self.view animated:YES];
}

#pragma mark - DetailViewProtocol
- (void) performSave
{
    //we don't need to trigger anything?
}

@end
