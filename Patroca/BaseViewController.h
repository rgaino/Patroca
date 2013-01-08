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
}

@property (weak, nonatomic) IBOutlet UIButton *loginProfileButton;

- (void)setupHeaderWithBackButton:(BOOL)hasBackButton doneButton:(BOOL)hasDoneButton addItemButton:(BOOL)hasAddItemButton;
- (void)userLoggedInSuccessfully;
- (void)addNewItemButtonPressed;
- (void)loginProfileButtonPressed;
- (void)backButtonPressed;
- (void)doneButtonPressed;

@end
