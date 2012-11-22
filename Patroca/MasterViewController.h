//
//  MasterViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "BaseViewController.h"

@class ItemDataSource;

@interface MasterViewController : BaseViewController <UIScrollViewDelegate> {
    
    ItemDataSource *itemDataSource;
    
    UIColor *labelSelectedColor;
    UIColor *labelUnselectedColor;
    
}

@property (weak, nonatomic) IBOutlet UILabel *featuredLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *nearbyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *menuArrowImage;
@property (weak, nonatomic) IBOutlet UIView *menuBarView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

- (void)userTappedOnFeatured;
- (void)userTappedOnFriends;
- (void)userTappedOnNearby;
- (void)moveMenuArrowTo:(float)xPosition;
- (void)loadFeaturedItems;
- (void)loadFriendsItems;
- (void)populateWithItems:(NSArray*)items;

@end
