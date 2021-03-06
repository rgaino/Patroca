//
//  MasterViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "BaseViewController.h"
#import "ItemDataSourceDelegate.h"

@class ItemViewCell;

@interface MasterViewController : BaseViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ItemDataSourceDelegate> {
    
    UIRefreshControl *refreshControl;
    
    UIColor *labelSelectedColor;
    UIColor *labelUnselectedColor;
    UIView *errorMessageView;
}

@property (weak, nonatomic) IBOutlet UIImageView *menuArrowImage;
@property (weak, nonatomic) IBOutlet UIView *menuBarView;
@property (weak, nonatomic) IBOutlet UICollectionView *contentDisplayCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *featuredButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;
@property (weak, nonatomic) IBOutlet UIButton *nearbyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowHorizontalSpacingConstraint;


- (void)moveMenuArrowTo:(float)xPosition;
- (void)loadFeaturedItems;
- (void)loadFriendsItems;
- (void)loadNearbyItems;
- (void)inviteFriendsButtonPressed;
- (IBAction)menuButtonPressed:(id)sender;

@end
