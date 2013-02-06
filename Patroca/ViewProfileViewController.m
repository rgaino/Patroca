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
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ViewProfileViewController
@synthesize profileImageView;
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize logoutButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupHeaderWithBackButton:YES doneButton:NO addItemButton:YES];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                // This block will be executed asynchronously on the main thread.
                //because UI elements must be updated on the main thread
                [self facebookLoggedInWithResult:result];
                [self loadFriendsProfilePictures];
            });
            
        } else {
            //TODO: error handling
            NSLog(@"Failed to login to Facebook with error: %@", [error localizedDescription]);
        }
     
    }];
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
    [profileImageView setImageWithURL:profilePictureURL];
}

- (IBAction)logoutButtonPressed:(id)sender {
    
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)loadFriendsProfilePictures {

    // Issue a Facebook Graph API request to get your user's friend list
    PF_FBRequest *request = [PF_FBRequest requestForMyFriends];
    [request startWithCompletionHandler:^(PF_FBRequestConnection *connection,
                                          id result,
                                          NSError *error) {

        if (!error) {
            
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            //generate 10 random unique numbers between 0 and how many friends there are
            int numberOfFriends = 10;
            NSMutableArray *randomFriendIds = [NSMutableArray arrayWithCapacity:numberOfFriends];
            
            int randomId = arc4random_uniform(friendObjects.count);
            [randomFriendIds addObject:[NSNumber numberWithInteger:randomId]];
            
            for(int i=1; i<numberOfFriends; i++) {
                while( [randomFriendIds indexOfObject:[NSNumber numberWithInteger:randomId]] != NSNotFound) {
                    randomId = arc4random_uniform(friendObjects.count);
                }
                [randomFriendIds addObject:[NSNumber numberWithInteger:randomId]];
            }
            
            //now having the 10 random friend IDs, load their profile pics async
            xProfileImageView = 0;
            sizeProfileImageView = 40;
            
            for(NSNumber *randomFriendId in randomFriendIds) {
                //load friends' profile pics
                NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [friendIds objectAtIndex:randomFriendId.integerValue]]];
                UIImageView *profilePictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xProfileImageView, 0, sizeProfileImageView, sizeProfileImageView)];
                [profilePictureImageView setImageWithURL:profilePictureURL];
                [_friendsPicturesView addSubview:profilePictureImageView];

                 xProfileImageView+=sizeProfileImageView;
            }
        }
    }];
}


- (void)viewDidUnload {
    [self setProfileImageView:nil];
    [self setNameLabel:nil];
    [self setLocationLabel:nil];
    [self setLogoutButton:nil];
    [super viewDidUnload];
}


@end
