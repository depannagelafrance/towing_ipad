//
//  SignatureViewController.m
//  towing
//
//  Created by Kris Vandermast on 21/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "SignatureViewController.h"
#import "SignatureView.h"
#import "TowingVoucher+Model.h"

@interface SignatureViewController ()
@property (weak, nonatomic) IBOutlet SignatureView *signatureView;

@end

@implementation SignatureViewController


#pragma mark - IBActions

- (IBAction)doneAction:(id)sender {
    NSData *signaturePNG = [self.signatureView signatureAsPNG];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
    
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
    
    if([signaturePNG writeToFile:path atomically:YES]) {
        self.signatureBlock(path);
        [self setSignatureImage:path];
    } else {
        NSLog(@"Failed to save it to the directory: %@", path);
    };
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) setSignatureImage:(NSString *) path
{
    [self.signatureImageView setImage:[UIImage imageWithContentsOfFile:path]];
    
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    TowingVoucher *voucher = delegate.towingVoucher;
    
    [voucher addTowingSignatureWithCategory:self.category inLocation:path];
}

- (IBAction)erasAction:(id)sender {
    [self.signatureView clearCanvas];
}
@end
