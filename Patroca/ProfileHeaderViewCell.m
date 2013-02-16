//
//  ProfileHeaderViewCell.m
//  Patroca
//
//  Created by Rafael Gaino on 2/14/13.
//  Copyright (c) 2013 Punk Opera. All rights reserved.
//

#import "ProfileHeaderViewCell.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "UIUnderlinedButton.h"

@implementation ProfileHeaderViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ProfileHeaderViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] > 1) { return nil; }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) { return nil; }
        
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

- (void)setupProfileHeaderViewCellWithUserData:(NSDictionary*)userData {
    
    //Making sure we don't use nulls but blank strings instead
    NSString *facebookId = ([userData objectForKey:@"id"] == nil ? @"" : [userData objectForKey:@"id"]);
    NSString *name       = ([userData objectForKey:@"name"] == nil ? @"" : [userData objectForKey:@"name"]);
    NSString *location   = ([[userData objectForKey:@"location"] objectForKey:@"name"]==nil ? @"?" : [[userData objectForKey:@"location"] objectForKey:@"name"]);
    
    
    //display basic info on screen
    [_nameLabel setText: name];
    [_locationLabel setText:location];

    //pull profile picture (type=normal means 100px wide)
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=170&height=200", facebookId]];
    [_profileImageView setImageWithURL:profilePictureURL];
    
    
    //center together the location icon and location label
    dispatch_async(dispatch_get_main_queue(), ^{
        // This block will be executed asynchronously on the main thread.
        //because UI elements must be updated on the main thread
        CGFloat spacing = 10.0f;
        CGFloat locationTextWidth = [[_locationLabel text] sizeWithFont:[_locationLabel font]].width;
        CGFloat locationIconWidth = _locationIconImageView.frame.size.width;
        CGFloat totalWidth = locationTextWidth + spacing + locationIconWidth;

        CGFloat locationIconX = (320/2 - totalWidth/2);
        [_locationIconImageView setFrame:CGRectMake(locationIconX, _locationIconImageView.frame.origin.y, _locationIconImageView.frame.size.width, _locationIconImageView.frame.size.height)];
        
        CGFloat locationTextX = locationIconX + locationIconWidth + spacing;
        [_locationLabel setFrame:CGRectMake(locationTextX, _locationLabel.frame.origin.y, locationTextWidth, _locationLabel.frame.size.height)];
    });

    
    //is this the logged user?
    NSString *loggedUserFacebookID = [[PFUser currentUser] objectForKey:DB_FIELD_USER_FACEBOOK_ID];
    if( [facebookId isEqualToString:loggedUserFacebookID] ) {
        //show friends picture and leave all elements as default
        [self loadFriendsProfilePictures];
    } else {
        //displaying someone else's profile, so format screen accordingly
        [_logoutButton setHidden:YES];
        [_shareOnFacebookButton setHidden:NO];
        [_moreFriendsMoreStuffLabel setHidden:YES];
        [_tellYourFriendsButton setHidden:YES];
    }
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

- (IBAction)logoutButtonPressed:(id)sender {
    
    [PFUser logOut];
    [_parentViewController.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareOnFacebookButtonPressed:(id)sender {
}

- (IBAction)tellYourFriendsButtonPressed:(id)sender {
}

@end
