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

- (void)setupProfileHeaderViewCellWithUser:(PFUser*)user UserData:(NSDictionary*)userData {
    
    userObject = user;
    
    //Making sure we don't use nulls but blank strings instead
    NSString *facebookId = ([userData objectForKey:@"id"] == nil ? @"" : [userData objectForKey:@"id"]);
    NSString *name       = ([userData objectForKey:@"name"] == nil ? @"" : [userData objectForKey:@"name"]);
    NSString *location   = ([[userData objectForKey:@"location"] objectForKey:@"name"]==nil ? @"?" : [[userData objectForKey:@"location"] objectForKey:@"name"]);
    
    
    //display basic info on screen
    [_nameLabel setText: name];

    //pull profile picture (type=normal means 100px wide)
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=170&height=200", facebookId]];
    [_profileImageView setImageWithURL:profilePictureURL];
    

    //create the location icon and label
    UIImageView *locationIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_location.png"]];

    UILabel *locationLabel = [[UILabel alloc] init];
    [locationLabel setText:location];
    [locationLabel setFont:[UIFont systemFontOfSize:14]];

    CGFloat spacing = 10.0f;
    CGFloat locationTextWidth = [[locationLabel text] sizeWithFont:[locationLabel font]].width;
    CGFloat locationIconWidth = locationIconImageView.frame.size.width;
    CGFloat totalWidth = locationTextWidth + spacing + locationIconWidth;
    CGFloat locationIconX = (320/2 - totalWidth/2);
    CGFloat locationTextX = locationIconX + locationIconWidth + spacing;

    [locationLabel setFrame:CGRectMake(locationTextX, 123, locationTextWidth, 21)];
    [locationLabel setTextColor:[UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f]];
    [locationLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:locationLabel];
    
    [locationIconImageView setFrame:CGRectMake(locationIconX, 128, locationIconImageView.frame.size.width, locationIconImageView.frame.size.height)];
    [self addSubview:locationIconImageView];

    
    //Query for how many comments this user has ever made
    PFQuery *totalCommentsQuery = [PFQuery queryWithClassName:DB_TABLE_ITEM_COMMENTS];
    [totalCommentsQuery whereKey:DB_FIELD_USER_ID equalTo:user];
    [totalCommentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            NSUInteger totalComments = [objects count];
            [_totalCommentsLabel setText: [NSString stringWithFormat: @"%d", totalComments] ];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

    
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


- (IBAction)tellYourFriendsButtonPressed:(id)sender {
}

- (IBAction)openUserProfileOnFacebookButtonPressed:(id)sender {

    NSString *facebookNativeProfileURLString = [NSString stringWithFormat:FB_NATIVE_PROFILE_URL, [userObject objectForKey:DB_FIELD_USER_FACEBOOK_ID]];

    // Check to make sure URL can be opened on device (whether the user has the Facebook app installed)
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:facebookNativeProfileURLString]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facebookNativeProfileURLString]];
    }
    // Otherwise, just open it in the browser
    {
        NSString *facebookBrowserProfileURLString = [NSString stringWithFormat:FB_BROWSER_PROFILE_URL, [userObject objectForKey:DB_FIELD_USER_FACEBOOK_ID]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facebookBrowserProfileURLString]];
    }
}

@end
