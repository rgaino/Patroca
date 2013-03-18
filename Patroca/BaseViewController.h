//
//  BaseViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface BaseViewController : UIViewController <MBProgressHUDDelegate> {
    
    MBProgressHUD *HUD;
    UIView *headerView;
}

@property (weak, nonatomic) IBOutlet UIButton *loginProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *addNewItemButton;

- (void)setupHeaderWithBackButton:(BOOL)hasBackButton doneButton:(BOOL)hasDoneButton addItemButton:(BOOL)hasAddItemButton;
- (void)userLoggedInSuccessfully;
- (void)addNewItemButtonPressed;
- (void)loginProfileButtonPressed;
- (IBAction)backButtonPressed;
- (void)doneButtonPressed;
- (void)localizeStrings;

@end
