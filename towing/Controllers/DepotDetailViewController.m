//
//  DepotDetailViewController.m
//  towing
//
//  Created by Kris Vandermast on 15/10/14.
//  Copyright (c) 2014 Depannage La France. All rights reserved.
//

#import "DepotDetailViewController.h"
#import "AppDelegate.h"

#import "User+Model.h"
#import "Dossier+Model.h"

#import "JsonUtil.h"

#import "GeneralActionButton.h"
#import "GeneralTextField.h"
#import "DisruptiveActionButton.h"

#define DEFAULT_DEPOT @"default_depot"

@interface DepotDetailViewController ()
@property (weak, nonatomic) IBOutlet GeneralTextField *nameTextField;
@property (weak, nonatomic) IBOutlet GeneralTextField *streetTextField;
@property (weak, nonatomic) IBOutlet GeneralTextField *numberTextField;
@property (weak, nonatomic) IBOutlet GeneralTextField *poboxTextField;
@property (weak, nonatomic) IBOutlet GeneralTextField *zipTextField;
@property (weak, nonatomic) IBOutlet GeneralTextField *cityTextField;

@property (weak, nonatomic) IBOutlet GeneralActionButton *depotButton;
@property (weak, nonatomic) IBOutlet DisruptiveActionButton *updateDepotButton;

@property (readonly, strong, nonatomic) TowingVoucher *towingVoucher;
@end


@implementation DepotDetailViewController
#pragma mark - getters
- (TowingVoucher *) towingVoucher
{
    return self.delegate.towingVoucher;
}

#pragma mark - View Cycle stuff
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *json = [self.towingVoucher jsonObjectForKey:DEPOT];
    
    self.nameTextField.text         = [JsonUtil asString:[json valueForKey:NAME]];
    self.streetTextField.text       = [JsonUtil asString:[json valueForKey:STREET]];
    self.numberTextField.text       = [JsonUtil asString:[json valueForKey:NUMBER]];
    self.poboxTextField.text        = [JsonUtil asString:[json valueForKey:POBOX]];
    self.zipTextField.text          = [JsonUtil asString:[json valueForKey:ZIP]];
    self.cityTextField.text         = [JsonUtil asString:[json valueForKey:CITY]];
    
    
    self.navigationItem.title = @"Depot/Afvoerlocatie";
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(performSave)];
    self.navigationItem.rightBarButtonItem = done;
    
    [self setupGui];
    
}

- (void) setupGui {
    bool isDefaultDepot = false;
    
    NSDictionary *depot = [self.towingVoucher jsonObjectForKey:DEPOT];
    
    DLog(@"Default depot? %@", [depot objectForKey:DEFAULT_DEPOT]);
    
    
    NSNumber *defaultDepot = [JsonUtil asNumber:[depot objectForKey:DEFAULT_DEPOT]];
    
    if(depot && [defaultDepot isEqualToNumber:@1]) {
        isDefaultDepot = true;
    }
    
    self.nameTextField.enabled = !isDefaultDepot;
    self.streetTextField.enabled = !isDefaultDepot;
    self.numberTextField.enabled = !isDefaultDepot;
    self.poboxTextField.enabled = !isDefaultDepot;
    self.zipTextField.enabled = !isDefaultDepot;
    self.cityTextField.enabled = !isDefaultDepot;
    
    self.updateDepotButton.hidden = !isDefaultDepot;
    self.depotButton.hidden = isDefaultDepot;
}

#pragma mark - IBActions
- (IBAction)companyDepotAction:(id)sender {
    User *user = self.delegate.authenticatedUser;
    
    
    NSString *companyName = [user.jsonObject valueForKeyPath:@"company.name"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Afvoerlocatie" message:@"Selecteer de afvoerlocatie" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Annuleren" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //do nothing
    }];
    
    UIAlertAction *defaultDepot = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Depot %@", companyName] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSDictionary *json = user.jsonObject;
        
        [self setValuesFromDictionary:json withDefaultDepot:YES];
        
        [self setupGui];
    }];
    
    UIAlertAction *agency = [UIAlertAction actionWithTitle:@"Agentschap Wegen & Verkeer" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        Dossier *dossier = self.towingVoucher.dossier;
        
        NSDictionary *json = [dossier jsonObjectForKey:@"allotment_agency"];
        
        [self setValuesFromDictionary:json withDefaultDepot:NO];
    }];
    
    UIAlertAction *customer = [UIAlertAction actionWithTitle:@"Thuisadres Klant" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSDictionary *json = [self.towingVoucher jsonObjectForKey:@"customer"];
        
        [self setValuesFromDictionary:json withDefaultDepot:NO];
        
        
        [self performSave];
    }];
    
    UIAlertAction *causer = [UIAlertAction actionWithTitle:@"Thuisadres Hinderverwekker" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSDictionary *json = [self.towingVoucher jsonObjectForKey:@"causer"];
        
        [self setValuesFromDictionary:json withDefaultDepot:NO];
        
        
        [self performSave];
    }];
    
    
    [alertController addAction:defaultDepot];
    [alertController addAction:customer];
    [alertController addAction:causer];
    [alertController addAction:agency];
    
    [alertController addAction:cancel];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    
    if(popover)
    {
        popover.sourceView = sender;
        popover.sourceRect = ((UIButton *) sender).bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)unlockDepotAction:(id)sender
{
    NSMutableDictionary *data = [self.towingVoucher jsonObjectForKey:DEPOT];
    [data setValue:@0 forKey:DEFAULT_DEPOT];
    
    [self.towingVoucher jsonObject:data forKey:DEPOT];
    
    [self setupGui];
}

- (void) setValuesFromDictionary:(NSDictionary *) json withDefaultDepot:(BOOL)withDefaultDepot
{
    if(json)
    {
        if(withDefaultDepot) {
            self.nameTextField.text     = [JsonUtil asString:[json valueForKeyPath:@"company_depot.name"]];
            self.streetTextField.text   = [JsonUtil asString:[json valueForKeyPath:@"company_depot.street"]];
            self.numberTextField.text   = [JsonUtil asString:[json valueForKeyPath:@"company_depot.street_number"]];
            self.poboxTextField.text    = [JsonUtil asString:[json valueForKeyPath:@"company_depot.street_pobox"]];
            self.zipTextField.text      = [JsonUtil asString:[json valueForKeyPath:@"company_depot.zip"]];
            self.cityTextField.text     = [JsonUtil asString:[json valueForKeyPath:@"company_depot.city"]];
            
            
            NSMutableDictionary *data = [self.towingVoucher jsonObjectForKey:DEPOT];
            [data setValue:@1 forKey:@"default_depot"];
            
            [self.towingVoucher jsonObject:data forKey:DEPOT];
        } else {
            if([json objectForKey:@"last_name"] && ![[JsonUtil asString:[json valueForKey:@"last_name"]] isEqualToString:@""])
            {
                self.nameTextField.text = [NSString stringWithFormat:@"%@ %@",
                                           [JsonUtil asString:[json valueForKey:@"last_name"]],
                                           [JsonUtil asString:[json valueForKey:@"first_name"]]];
            }
            else
            {
                self.nameTextField.text     = [JsonUtil asString:[json valueForKeyPath:@"company_name"]];
            }
            
            self.streetTextField.text   = [JsonUtil asString:[json valueForKeyPath:@"street"]];
            self.numberTextField.text   = [JsonUtil asString:[json valueForKeyPath:@"street_number"]];
            self.poboxTextField.text    = [JsonUtil asString:[json valueForKeyPath:@"street_pobox"]];
            self.zipTextField.text      = [JsonUtil asString:[json valueForKeyPath:@"zip"]];
            self.cityTextField.text     = [JsonUtil asString:[json valueForKeyPath:@"city"]];
        }
    }
}


#pragma mark - DetailViewProtocol implementation
- (void) performSave {
    
    NSDictionary *data = [self.towingVoucher jsonObjectForKey:DEPOT];
    
    if(!data)
    {
        data = @{NAME     : self.nameTextField.text,
                 STREET   : self.streetTextField.text,
                 NUMBER   : self.numberTextField.text,
                 POBOX    : self.poboxTextField.text,
                 ZIP      : self.zipTextField.text,
                 CITY     : self.cityTextField.text,
                 @"default_depot": @0
                 };
    }
    else
    {
        [data setValuesForKeysWithDictionary:@{NAME     : self.nameTextField.text,
                                               STREET   : self.streetTextField.text,
                                               NUMBER   : self.numberTextField.text,
                                               POBOX    : self.poboxTextField.text,
                                               ZIP      : self.zipTextField.text,
                                               CITY     : self.cityTextField.text
                                               }];
    }
    
    
    NSLog(@"Setting voucher depot to : %@", data);
    
    [self.towingVoucher jsonObject:data forKey:DEPOT];
    
    [((Dossier *) self.towingVoucher.dossier) performSaveToBackoffice];
}
@end
