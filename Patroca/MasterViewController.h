//
//  MasterViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "BaseViewController.h"

@interface MasterViewController : BaseViewController {
    
    UIColor *labelSelectedColor;
    UIColor *labelUnselectedColor;
}

@property (weak, nonatomic) IBOutlet UILabel *featuredLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *nearbyLabel;

- (void)userTappedOnFeatured;
- (void)userTappedOnFriends;
- (void)userTappedOnNearby;

@end
