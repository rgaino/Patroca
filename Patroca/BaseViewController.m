//
//  BaseViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "BaseViewController.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"
#import "ViewProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AddNewItemViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController


- (void)setupHeaderWithBackButton:(BOOL)hasBackButton {
    
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [headerView setFrame:CGRectMake(0, 0, 320, 44)];
    

    
    if(hasBackButton) {
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setFrame:CGRectMake(0, 0, 51, 45)];
        [backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:backButton];

    } else {
        //the Login/Profile button
        _loginProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginProfileButton setFrame:CGRectMake(0, 0, 51, 44)];
        
        //see if user is already logged in on Facebook and display the profile picture
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            [self userLoggedInSuccessfully];
        }else {
            
            [_loginProfileButton setImage:[UIImage imageNamed:@"login_with_fb.png"] forState:UIControlStateNormal];
        }
        [_loginProfileButton addTarget:self action:@selector(loginProfileButtonPressed) forControlEvents:UIControlEventTouchUpInside];

        [headerView addSubview:_loginProfileButton];
    }
    
    //the Avatar mask image
    UIImageView *avatarMaskImageView = [[UIImageView alloc] init];
    [avatarMaskImageView setFrame:CGRectMake(0, 0, 82, 44)];
    [avatarMaskImageView setImage:[UIImage imageNamed:@"mask_fb_avatar"]];
    [headerView addSubview:avatarMaskImageView];

    //the logo
    UIImageView *logoImageView = [[UIImageView alloc] init];
    [logoImageView setFrame:CGRectMake(99, 12, 122, 22)];
    [logoImageView setImage:[UIImage imageNamed:@"patroca_logo"]];
    [headerView addSubview:logoImageView];
    
    
    //the Add Item button
    UIButton *addNewItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addNewItemButton setFrame:CGRectMake(270, 0, 51, 44)];
    [addNewItemButton setImage:[UIImage imageNamed:@"add_new_item_button"] forState:UIControlStateNormal];
    [addNewItemButton addTarget:self action:@selector(addNewItemButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:addNewItemButton];
    

    [self.view insertSubview:headerView atIndex:0];
}

- (void)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) userLoggedInSuccessfully {
    
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [[PFUser currentUser] objectForKey:DB_FIELD_USER_FACEBOOK_ID]]];
    [_loginProfileButton.imageView setImageWithURL:profilePictureURL placeholderImage:nil success:^(UIImage *image, BOOL cached) {
        [_loginProfileButton setImage:_loginProfileButton.imageView.image forState:UIControlStateNormal];
    } failure:^(NSError *error) {
        
    }];
}

- (void)loginProfileButtonPressed {

    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        ViewProfileViewController *viewProfileViewController = [[ViewProfileViewController alloc] initWithNibName:@"ViewProfileViewController" bundle:nil];
        [self.navigationController pushViewController:viewProfileViewController animated:YES];
    } else {
        //        LogInViewController *logInViewController = [[LogInViewController alloc] initWithNibName:@"LogInViewController" bundle:nil];
        //        [self.navigationController pushViewController:logInViewController animated:YES];
        
        
        // The permissions requested from the user
        NSArray *permissionsArray = [NSArray arrayWithObjects:
                                     @"user_about_me",
                                     @"user_relationships",
                                     @"user_location",
                                     //                                     @"offline_access",
                                     @"email",
                                     nil];
        
        // Log in
        [PFFacebookUtils logInWithPermissions:permissionsArray
                                        block:^(PFUser *user, NSError *error) {
                                            if (!user) {
                                                if (!error) { // The user cancelled the login
                                                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                                                } else { // An error occurred
                                                    NSLog(@"Uh oh. An error occurred: %@", error);
                                                }
                                            } else if (user.isNew) { // Success - a new user was created
                                                NSLog(@"User with facebook signed up and logged in!");
                                                [self userLoggedInSuccessfully];
                                            } else { // Success - an existing user logged in
                                                NSLog(@"User with facebook logged in!");
                                                [self userLoggedInSuccessfully];
                                            }
                                        }];
        
        
    }
}


- (void)addNewItemButtonPressed {
    
    AddNewItemViewController *addNewItemViewController = [[AddNewItemViewController alloc] initWithNibName:@"AddNewItemViewController" bundle:nil];
    [self.navigationController pushViewController:addNewItemViewController animated:YES];
}


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}


@end
