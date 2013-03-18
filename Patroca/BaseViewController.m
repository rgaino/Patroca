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

- (void)viewDidLoad {
    
    UIColor *backgroundPattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_repeat.png"]];
    [[self view] setBackgroundColor:backgroundPattern];
    
    [super viewDidLoad];
}

- (void)localizeStrings {}

- (void)viewDidAppear:(BOOL)animated {

    //hide profile picture if user logged out
    if (![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [_loginProfileButton setImage:[UIImage imageNamed:@"login_with_fb.png"] forState:UIControlStateNormal];
        [_addNewItemButton setEnabled:NO];
    } else {
        [_addNewItemButton setEnabled:YES];
    }

    [super viewDidAppear:animated];
}

- (void)setupHeaderWithBackButton:(BOOL)hasBackButton doneButton:(BOOL)hasDoneButton addItemButton:(BOOL)hasAddItemButton {
    
    headerView = [[UIView alloc] init];
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
    [avatarMaskImageView setImage:[UIImage imageNamed:@"mask_fb_avatar.png"]];
    [headerView addSubview:avatarMaskImageView];

    //the logo
    UIImageView *logoImageView = [[UIImageView alloc] init];
    [logoImageView setFrame:CGRectMake(99, 12, 122, 22)];
    [logoImageView setImage:[UIImage imageNamed:@"patroca_logo.png"]];
    [headerView addSubview:logoImageView];
    
    
    if(hasAddItemButton) {
        //the Add Item button
        _addNewItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addNewItemButton setFrame:CGRectMake(270, 0, 51, 44)];
        [_addNewItemButton setImage:[UIImage imageNamed:@"add_new_item_button.png"] forState:UIControlStateNormal];
        [_addNewItemButton addTarget:self action:@selector(addNewItemButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            [_addNewItemButton setEnabled:YES];
        } else {
            [_addNewItemButton setEnabled:NO];
        }
        
        [headerView addSubview:_addNewItemButton];
    } if (hasDoneButton) {
        //the Done button
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setFrame:CGRectMake(270, 0, 51, 44)];
        [doneButton setImage:[UIImage imageNamed:@"done_button.png"] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:doneButton];
    }
    
    UIImageView *headerShadeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header_shade.png"]];
    [headerShadeImageView setFrame:CGRectMake(0, 44, headerShadeImageView.image.size.width, headerShadeImageView.image.size.height)];
    [headerView addSubview:headerShadeImageView];

    [self.view insertSubview:headerView atIndex:999];
}



- (IBAction)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed {
    //this method should always be overwritten.
    //Default behavior is to simply pop the viewcontroller (calling [super doneButtonPressed] is acceptable
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) userLoggedInSuccessfully {
    
    [_addNewItemButton setEnabled:YES];
    
    // Create request for user's Facebook data
    NSString *requestPath = @"me/?fields=name,email";
    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForGraphPath:requestPath];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
            NSString *facebookId = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *email      = ([userData objectForKey:@"email"] == nil ? @"" : [userData objectForKey:@"email"]);
            
            //store info on Parse User table
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:facebookId forKey:DB_FIELD_USER_FACEBOOK_ID];
            [currentUser setObject:name forKey:DB_FIELD_USER_NAME];
            [currentUser setEmail:email];
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [[PFUser currentUser] objectForKey:DB_FIELD_USER_FACEBOOK_ID]]];
                [_loginProfileButton.imageView setImageWithURL:profilePictureURL placeholderImage:nil success:^(UIImage *image, BOOL cached) {
                    [_loginProfileButton setImage:_loginProfileButton.imageView.image forState:UIControlStateNormal];
                } failure:^(NSError *error) {
                    NSLog(@"");
                }];
                
                PFInstallation *myInstallation = [PFInstallation currentInstallation];
                [myInstallation setObject:[PFUser currentUser] forKey:DB_FIELD_USER_ID];
                [myInstallation saveEventually];
            }];

        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    

}

- (void)loginProfileButtonPressed {

    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        ViewProfileViewController *viewProfileViewController = [[ViewProfileViewController alloc] initWithNibName:@"ViewProfileViewController" bundle:nil];
        [viewProfileViewController setupViewWithUserID:[[PFUser currentUser] objectId] ];
        [self.navigationController pushViewController:viewProfileViewController animated:YES];
        
    } else {
        
        //First time user (on this device at least) so log in
        
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
