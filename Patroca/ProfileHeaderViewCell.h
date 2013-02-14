//
//  ProfileHeaderViewCell.h
//  Patroca
//
//  Created by Rafael Gaino on 2/14/13.
//  Copyright (c) 2013 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeaderViewCell : UICollectionViewCell {
    
    float xProfileImageView;
    float sizeProfileImageView;
}


@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIView *friendsPicturesView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

- (void)setupProfileHeaderViewCellWithUserData:(NSDictionary*)userData;
- (void)loadFriendsProfilePictures;

@end
