//
//  ItemViewCell.h
//  Patroca
//
//  Created by Rafael Gaino on 11/22/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <CoreLocation/CoreLocation.h>

@class PFObject;
@class PFGeoPoint;

@interface ItemViewCell : UICollectionViewCell { //<CLLocationManagerDelegate> {

//    CLLocationManager *locationManager;
}

@property (weak, nonatomic) PFObject *cellItemObject;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ownerProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *totalCommentsLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *tradedLabel;
@property (weak, nonatomic) IBOutlet UIView *tradedView;

- (void)setupCellWithItem:(PFObject*)itemObject;
- (void)updateTotalComments:(int)totalComments;
- (IBAction)likeButtonPressed:(id)sender;

@end
