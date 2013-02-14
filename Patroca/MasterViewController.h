//
//  MasterViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "BaseViewController.h"
#import "ItemDataSourceDelegate.h"

@class ItemDataSource;
@class ItemViewCell;

@interface MasterViewController : BaseViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ItemDataSourceDelegate> {
    
    ItemDataSource *itemDataSource;
    NSMutableDictionary *totalCommentsForItemsDictionary;
    
    UIColor *labelSelectedColor;
    UIColor *labelUnselectedColor;
    
}

@property (weak, nonatomic) IBOutlet UILabel *featuredLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *nearbyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *menuArrowImage;
@property (weak, nonatomic) IBOutlet UIView *menuBarView;
@property (weak, nonatomic) IBOutlet UICollectionView *contentDisplayCollectionView;


- (void)userTappedOnFeatured;
- (void)userTappedOnFriends;
- (void)userTappedOnNearby;
- (void)moveMenuArrowTo:(float)xPosition;
- (void)loadFeaturedItems;
- (void)loadFriendsItems;
- (void)loadNearbyItems;

@end
