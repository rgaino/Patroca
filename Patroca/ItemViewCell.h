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
@class BaseViewController;

@interface ItemViewCell : UICollectionViewCell { //<CLLocationManagerDelegate> {

//    CLLocationManager *locationManager;
}

@property (weak, nonatomic) PFObject *cellItemObject;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *tradedLabel;
@property (weak, nonatomic) IBOutlet UIView *tradedView;
@property (strong, nonatomic) BaseViewController *parentController;

- (void)setupCellWithItem:(PFObject*)itemObject;
- (IBAction)likeButtonPressed:(id)sender;
- (void)openItemDetailsPage;

@end
