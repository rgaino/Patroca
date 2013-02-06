//
//  ViewProfileViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 8/23/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <Parse/Parse.h>

@interface ViewProfileViewController : BaseViewController <PF_FBRequestDelegate, NSURLConnectionDelegate> {

    float xProfileImageView;
    float sizeProfileImageView;

}

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIView *friendsPicturesView;

- (IBAction)logoutButtonPressed:(id)sender;

- (void)logWithFacebook;
- (void)facebookLoggedInWithResult:(id)result;
- (void)loadFriendsProfilePictures;

@end
