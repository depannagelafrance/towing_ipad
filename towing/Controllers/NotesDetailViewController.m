//
//  NotesDetailViewController.m
//  towing
//
//  Created by Kris Vandermast on 24/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "NotesDetailViewController.h"
#import "Dossier+Model.h"
#import "TowingMessage.h"

@interface NotesDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@property (weak, nonatomic) IBOutlet UITableView *messagesTableView;

@end

@implementation NotesDetailViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CALayer *imageLayer = self.messageTextView.layer;
    [imageLayer setCornerRadius:10];
    [imageLayer setBorderWidth:1];
    imageLayer.borderColor=[[UIColor lightGrayColor] CGColor];
    
    [self showTowingMessagesInScrollView];
    
    self.navigationItem.title = @"Interne nota's";
}

- (void) showTowingMessagesInScrollView
{
    NSSet *messages = self.delegate.towingVoucher.towing_messages;
    
    for(TowingMessage *message in messages)
    {
        UILabel *label = [[UILabel alloc] init];
        
        label.text = message.message;
    }
}


#pragma mark - IBActions
- (IBAction)saveAction:(id)sender
{
    [self performSave];
}

#pragma mark - DetailViewProtocol implementation
- (void) performSave {
    if(![self.messageTextView.text isEqualToString:@""]) {
        NSString *token = self.delegate.authenticatedUser.token;
        NSString *voucherId = self.delegate.towingVoucher.id;
        NSString *dossierId = self.delegate.towingVoucher.dossier.id;
        
        NSString *api = [NSString stringWithFormat:@"/dossier/communication/internal/%@", token];
        
        NSDictionary *params = @{@"dossier_id": dossierId,
                                 @"voucher_id": voucherId,
                                 @"message": self.messageTextView.text};

        [self.delegate.towingVoucher addTowingMessage:self.messageTextView.text];
        [self.messagesTableView reloadData];
        
        self.messageTextView.text = @"";
        
        [self.restService post:api withParameters:params onCompleteBlock:^(NSDictionary *json) {
            //happy that it works, don't do anything
        } onFailBlock:^(NSError *error, int statusCode) {
            NSLog(@"Received error: %@", error);
            NSLog(@"Statuscode: %d", statusCode);
        }];
    }
}

#pragma mark - UITableViewData source implementation
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSArray *messages = [self.delegate.towingVoucher.towing_messages allObjects];
    TowingMessage *message =  ((TowingMessage *)[messages objectAtIndex:indexPath.row]);
    cell.textLabel.numberOfLines = 30;
    cell.textLabel.text = message.message;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.delegate.towingVoucher.towing_messages.count;
}
@end
