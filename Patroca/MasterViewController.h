//
//  MasterViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "BaseViewController.h"

@interface MasterViewController : BaseViewController <UIScrollViewDelegate> {
    
    UIColor *labelSelectedColor;
    UIColor *labelUnselectedColor;
    float itemListYOffsetPosition;
}

@property (weak, nonatomic) IBOutlet UILabel *featuredLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *nearbyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *menuArrowImage;
@property (weak, nonatomic) IBOutlet UIView *menuBarView;
@property (weak, nonatomic) IBOutlet UIWebView *welcomeMessageWebView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

- (void)userTappedOnFeatured;
- (void)userTappedOnFriends;
- (void)userTappedOnNearby;
- (void)moveMenuArrowTo:(float)xPosition;
- (void)loadFeaturedItems;

@end
