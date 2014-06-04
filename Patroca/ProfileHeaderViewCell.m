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
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookUtilsCache.h"
#import "AboutViewController.h"

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


- (void)localizeStrings {
    [_tellYourFriendsButton setTitle:NSLocalizedString(@"tell your friends", nil) forState:UIControlStateNormal];
    [_moreFriendsMoreStuffLabel setText:NSLocalizedString(@"the more the merrier", nil)];
    [_tellYourFriendsButton setHidden:NO];
    [_moreFriendsMoreStuffLabel setHidden:NO];
    [_aboutButton setTitle:NSLocalizedString(@"about", nil) forState:UIControlStateNormal];
    [_logoutButton setTitle:NSLocalizedString(@"logout", nil) forState:UIControlStateNormal];
}

- (void)setupProfileHeaderViewCellWithUser:(PFUser*)user UserData:(NSDictionary*)userData {
    
    [self localizeStrings];

    userObject = user;
    
    //Making sure we don't use nulls but blank strings instead
    NSString *facebookId = ([userData objectForKey:@"id"] == nil ? @"" : [userData objectForKey:@"id"]);
    NSString *name       = ([userData objectForKey:@"name"] == nil ? @"" : [userData objectForKey:@"name"]);
    NSString *location   = ([[userData objectForKey:@"location"] objectForKey:@"name"]==nil ? @"?" : [[userData objectForKey:@"location"] objectForKey:@"name"]);
    
    
    //display basic info on screen
    [_nameLabel setText: name];

    //pull profile picture (type=normal means 100px wide)
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=170&height=200", facebookId]];
    [_profileImageView setImageWithURL:profilePictureURL placeholderImage:[UIImage imageNamed:@"avatar_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [_activityIndicator stopAnimating];
    }];

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
    
    //is this the logged user?
    NSString *loggedUserFacebookID = [[PFUser currentUser] objectForKey:DB_FIELD_USER_FACEBOOK_ID];
    if( ![facebookId isEqualToString:loggedUserFacebookID] ) {
        //displaying someone else's profile, so format screen accordingly
        [_logoutButton setHidden:YES];
        [_shareOnFacebookButton setHidden:NO];
        [_moreFriendsMoreStuffLabel setHidden:YES];
        [_tellYourFriendsButton setHidden:YES];
    }
}

- (IBAction)logoutButtonPressed:(id)sender {
    
    [PFUser logOut];
    [_parentViewController.navigationController popViewControllerAnimated:YES];
}

- (IBAction)aboutButtonPressed:(id)sender {
    AboutViewController *aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    [self.parentViewController.navigationController pushViewController:aboutViewController animated:YES];
}


- (IBAction)tellYourFriendsButtonPressed:(id)sender {
    [[FacebookUtilsCache getInstance] tellYourFriends];
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
