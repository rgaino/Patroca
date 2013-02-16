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
    NSString *location   = ([[userData objectForKey:@"location"] objectForKey:@"name"]==nil ? @"" : [[userData objectForKey:@"location"] objectForKey:@"name"]);
    
    
    //display basic info on screen
    [_nameLabel setText: name];
    [_locationLabel setText:location];

    //pull profile picture (type=normal means 100px wide)
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=170&height=200", facebookId]];
    [_profileImageView setImageWithURL:profilePictureURL];
    
    [self loadFriendsProfilePictures];
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


@end
