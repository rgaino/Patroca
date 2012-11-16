//
//  MasterViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "BaseViewController.h"

@interface MasterViewController : BaseViewController {
    
}

@property (weak, nonatomic) IBOutlet UILabel *featuredLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *nearbyLabel;

- (void)userTappedOnFeatured:(UIGestureRecognizer*)gestureRecognizer;
- (void)userTappedOnFriends:(UIGestureRecognizer*)gestureRecognizer;
- (void)userTappedOnNearby:(UIGestureRecognizer*)gestureRecognizer;

@end
