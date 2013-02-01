//
//  LogInViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 8/23/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "ViewProfileViewController.h"

@interface LogInViewController ()

@end

@implementation LogInViewController
@synthesize connectMessage;
@synthesize connectWithFacebookButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Log In", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localizeStrings];
}

-(void) localizeStrings {
    
    [connectMessage setText:NSLocalizedString(@"ConnectMessage", nil)];
    [connectWithFacebookButton setTitle:NSLocalizedString(@"Connect with Facebook", nil) forState:UIControlStateNormal];
}



- (IBAction)loginButtonTouchHandler:(id)sender
{
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


-(void) userLoggedInSuccessfully {
    //call the userLoggedInSuccessfully method on the Master VC
    NSArray *viewControllers = self.navigationController.viewControllers;
    BaseViewController *rootViewController = (BaseViewController*)[viewControllers objectAtIndex:0];
    [rootViewController userLoggedInSuccessfully];
    
    //pop out
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setConnectMessage:nil];
    [self setConnectWithFacebookButton:nil];
    [super viewDidUnload];
}
@end
