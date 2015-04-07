//
//  ImpactViewController.m
//  towing
//
//  Created by Kris Vandermast on 08/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import "ImpactViewController.h"
#import "ImpactDrawableView.h"

@interface ImpactViewController()
@property (weak, nonatomic) IBOutlet ImpactDrawableView *drawableView;
@end


@implementation ImpactViewController
#pragma mark - IBActions

- (IBAction)doneAction:(id)sender {
    NSData *signaturePNG = [self.drawableView signatureAsPNG];
    
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
    [self.impactView setImage:[UIImage imageWithContentsOfFile:path]];

    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    TowingVoucher *voucher = delegate.towingVoucher;
    
    voucher.impact_image_path = path;
    [delegate.managedObjectContext save:nil];
}

- (IBAction)erasAction:(id)sender {
    [self.drawableView clearCanvas];
}

@end
