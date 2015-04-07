//
//  CollectorSignatureViewController.m
//  towing
//
//  Created by Kris Vandermast on 24/11/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "CollectorSignatureViewController.h"
#import "SignatureView.h"
#import "RestService.h"

@interface CollectorSignatureViewController () {
    NSString *voucherId;
    NSString *dossierId;
    NSString *type;
}
@property (weak, nonatomic) IBOutlet SignatureView *signatureView;

@end

@implementation CollectorSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *erase = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                           target:self
                                                                           action:@selector(eraseSignatureAction:)];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(saveSignatureAction:)];
    
    self.navigationItem.rightBarButtonItem = done;
    self.navigationItem.leftBarButtonItem = erase;
    
    voucherId = [self.bundleInformation objectForKey:VOUCHER_ID];
    dossierId = [self.bundleInformation objectForKey:DOSSIER_ID];
    type = [self.bundleInformation objectForKey:TYPE];
    
    if([type isEqualToString:META_NOTIFICATION_TYPE_COLLECTOR]) {
        self.navigationItem.title = VIEW_TITLE_SIGNATURE_COLLECTOR;
    } else if ([type isEqualToString:META_NOTIFICATION_TYPE_CAUSER]) {
        self.navigationItem.title = VIEW_TITLE_SIGNATURE_CAUSER;
    } else if ([type isEqualToString:META_NOTIFICATION_TYPE_POLICE]) {
        self.navigationItem.title = VIEW_TITLE_SIGNATURE_POLICE;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)eraseSignatureAction:(id)sender
{
    [self.signatureView clearCanvas];
}

- (IBAction)saveSignatureAction:(id)sender
{
    NSData *signaturePNG = [self.signatureView signatureAsPNG];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
    
    NSString *token = self.delegate.authenticatedUser.token;
    
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
    
    if([signaturePNG writeToFile:path atomically:YES]) {
        NSLog(@"Wrote image to directory: %@", path);
        
        NSData *signaturePNG = [NSData dataWithContentsOfFile:path];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        
        NSString *api = [NSString stringWithFormat:@"/dossier/voucher/attachment/signature_%@/%@/%@", type, voucherId, token];
        NSDictionary *params = @{@"content_type": @"image/png",
                                 @"file_size" : fileSizeNumber,
                                 @"content" : [signaturePNG base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]};
        
        [self.restService post:api withParameters:params onCompleteBlock:^(NSDictionary *result) {
            NSLog(@"Added the attachment in the back-end: %@", result);
            
            [self dismissViewControllerAnimated:YES completion:nil];
        } onFailBlock:^(NSError *error, int statusCode) {
            NSLog(@"Failed to send signature to back-end: %ul - %@", statusCode, error);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_ERROR_TITLE
                                                            message:[NSString stringWithFormat:@"Er is een fout opgetreden bij het verwerken van de handtekening: %d - %@", statusCode, error]
                                                           delegate:self
                                                  cancelButtonTitle:ALERT_BUTTON_OK
                                                  otherButtonTitles:nil];
            
            [alert show];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } else {
        NSLog(@"Failed to save it to the directory: %@", path);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_ERROR_TITLE
                                                        message:[NSString stringWithFormat:@"Er is een fout opgetreden bij het wegschrijven van de handtekening. Probeer opnieuw."]
                                                       delegate:self
                                              cancelButtonTitle:ALERT_BUTTON_OK
                                              otherButtonTitles:nil];
        
        [alert show];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    };
}


@end
