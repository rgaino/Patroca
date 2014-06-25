//
//  BaseViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ItemDataSource.h"
#import "GAITrackedViewController.h"


@interface BaseViewController : GAITrackedViewController <MBProgressHUDDelegate> {
    
    ItemDataSource *itemDataSource;
    MBProgressHUD *HUD;
    UIView *headerView;
    CGFloat headerOffset; //the pixel offset for the header for iOS7 due to its translucent bar
    UIButton *doneButton;
    UIButton *_loginProfileButton;
    UIActivityIndicatorView *_loginActivityIndicator;
    UIButton *_addNewItemButton;
}

@property (strong, nonatomic) UIButton *loginProfileButton;
@property (strong, nonatomic) UIButton *addNewItemButton;
@property (strong, nonatomic) UIActivityIndicatorView *loginActivityIndicator;


- (void)setupHeaderWithBackButton:(BOOL)hasBackButton doneButton:(BOOL)hasDoneButton addItemButton:(BOOL)hasAddItemButton;
- (void)userLoggedInSuccessfully;
- (void)addNewItemButtonPressed;
- (void)loginProfileButtonPressed;
- (IBAction)backButtonPressed;
- (void)doneButtonPressed;
- (void)localizeStrings;
- (void)sendNewUserPushNotifications;

@end
