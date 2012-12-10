//
//  ViewProfileViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 8/23/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "ViewProfileViewController.h"
#import <Parse/Parse.h>
#import "LogInViewController.h"
#import "DatabaseConstants.h"
#import "MBProgressHUD.h"

@interface ViewProfileViewController () {
    MBProgressHUD *HUD;
}

@end

@implementation ViewProfileViewController
@synthesize profileImageView;
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize logoutButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Profile", nil);
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localizeStrings];

    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[HUD setDimBackground:YES];
	[HUD setLabelText: NSLocalizedString(@"Logging in...", nil)];
    [HUD setDelegate:self];
    [self.view addSubview:HUD];
    [HUD show:YES];
    [self logWithFacebook];
}

- (void)logWithFacebook {
    
    NSLog(@"Logging in to Facebook");
    
    PF_FBRequest *request = [PF_FBRequest requestForGraphPath:@"me/?fields=name,location,picture,email"];
    [request startWithCompletionHandler:^(PF_FBRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            NSLog(@"Logged in to Facebook with success");
            [self facebookLoggedInWithResult:result];
            
        } else {
            //TODO: error handling
            NSLog(@"Failed to login to Facebook with error: %@", [error localizedDescription]);
        }
        
        [HUD hide:YES];
        
    }];
}

- (void)localizeStrings {
    
    [logoutButton setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
}

- (void)facebookLoggedInWithResult:(id)result {
 
    //read Facebook profile information
    NSDictionary *userData = (NSDictionary *)result;
    NSLog(@"userData received is:\n%@", userData);
    
    //Making sure we don't use nulls but blank strings instead
    NSString *facebookId = ([userData objectForKey:@"id"] == nil ? @"" : [userData objectForKey:@"id"]);
    NSString *name       = ([userData objectForKey:@"name"] == nil ? @"" : [userData objectForKey:@"name"]);
    NSString *email      = ([userData objectForKey:@"email"] == nil ? @"" : [userData objectForKey:@"email"]);
    NSString *location   = ([[userData objectForKey:@"location"] objectForKey:@"name"]==nil ? @"" : [[userData objectForKey:@"location"] objectForKey:@"name"]);
    

    //display basic info on screen
    [nameLabel setText: name];
    [locationLabel setText:location];

    //store info on Parse User table
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:facebookId forKey:DB_FIELD_USER_FACEBOOK_ID];
    [currentUser setEmail:email];
    [currentUser setObject:name forKey:DB_FIELD_USER_NAME];
    [currentUser saveInBackground];
     

    //pull profile picture (type=normal means 100px wide)
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", facebookId]];
    NSData * imageData = [NSData dataWithContentsOfURL:profilePictureURL];
    UIImage * image = [UIImage imageWithData:imageData];
    [profileImageView setImage:image];
    
}

- (IBAction)logoutButtonPressed:(id)sender {
    
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];

}




- (void)viewDidUnload {
    [self setProfileImageView:nil];
    [self setNameLabel:nil];
    [self setLocationLabel:nil];
    [self setLogoutButton:nil];
    [super viewDidUnload];
}


@end
