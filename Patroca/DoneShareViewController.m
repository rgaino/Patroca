//
//  DoneShareViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 2/28/13.
//  Copyright (c) 2013 Punk Opera. All rights reserved.
//

#import "DoneShareViewController.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"

@implementation DoneShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localizeStrings];

    [self setupHeaderWithBackButton:YES doneButton:YES addItemButton:NO];
    [_shareButton setBackgroundImage:[UIImage imageNamed:@"yellow_button.png"] forState:UIControlStateNormal];
    [_itemTitleLabel setText:[_itemObject objectForKey:DB_FIELD_ITEM_NAME]];
}
- (void)localizeStrings {
    [_shareButton setTitle:NSLocalizedString(@"share", nil) forState:UIControlStateNormal];
    [_shareMessageLabel setText:NSLocalizedString(@"share item message", nil)];
}

- (void)backButtonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)doneButtonPressed {    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)shareButtonPressed:(id)sender {
}
@end
