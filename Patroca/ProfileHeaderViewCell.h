//
//  ProfileHeaderViewCell.h
//  Patroca
//
//  Created by Rafael Gaino on 2/14/13.
//  Copyright (c) 2013 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIUnderlinedButton;
@class PFUser;

@interface ProfileHeaderViewCell : UICollectionViewCell {
    
    float xProfileImageView;
    float sizeProfileImageView;
}


@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIView *friendsPicturesView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIUnderlinedButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *shareOnFacebookButton;
@property (weak, nonatomic) IBOutlet UILabel *moreFriendsMoreStuffLabel;
@property (weak, nonatomic) IBOutlet UIButton *tellYourFriendsButton;
@property (weak, nonatomic) IBOutlet UIImageView *locationIconImageView;
@property (strong, nonatomic) UIViewController *parentViewController;
@property (weak, nonatomic) IBOutlet UILabel *totalOffersLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCommentsLabel;

- (void)setupProfileHeaderViewCellWithUser:(PFUser*)user UserData:(NSDictionary*)userData;
- (void)loadFriendsProfilePictures;
- (IBAction)logoutButtonPressed:(id)sender;
- (IBAction)shareOnFacebookButtonPressed:(id)sender;
- (IBAction)tellYourFriendsButtonPressed:(id)sender;

@end
