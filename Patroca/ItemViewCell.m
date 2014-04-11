//
//  ItemViewCell.m
//  Patroca
//
//  Created by Rafael Gaino on 11/22/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "ItemViewCell.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"
#import "UserCache.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ViewProfileViewController.h"

@implementation ItemViewCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame]; if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ItemViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] > 1) { return nil; }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) { return nil; }
        
        self = [arrayOfViews objectAtIndex:0];
        
    }
    
    return self;
}

- (void)setupCellWithItem:(PFObject*)itemObject {

    [self setCellItemObject:itemObject];
    
    [self.itemNameLabel setText:[itemObject objectForKey:DB_FIELD_ITEM_NAME]];
    
    PFUser *itemUser = [itemObject objectForKey:DB_FIELD_USER_ID];
    NSString *userId = [itemUser objectId];
    
    
    PFUser *userObject = [[UserCache getInstance] getCachedUserForId:userId];
//    [_ownerNameLabel setText:[userObject objectForKey:DB_FIELD_USER_NAME]];
    [_ownerNameLabel setHidden:YES];
    
    
    PFFile *itemImageFile = [itemObject objectForKey:DB_FIELD_ITEM_MAIN_IMAGE];
    NSURL *itemImageURL = [NSURL URLWithString:[itemImageFile url]];
    [_itemImageView setImageWithURL:itemImageURL placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    NSString *facebookProfilePicString = [NSString stringWithFormat:FB_PROFILE_PICTURE_URL, [userObject objectForKey:DB_FIELD_USER_FACEBOOK_ID]];
    NSURL *facebookProfilePicURL = [NSURL URLWithString:facebookProfilePicString];
    [_ownerProfilePic setImageWithURL:facebookProfilePicURL];

    if(locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager setDistanceFilter:kCLDistanceFilterNone];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    [locationManager startUpdatingLocation];
}

- (void)updateTotalComments:(int)totalComments {
    [_totalCommentsLabel setText:[NSString stringWithFormat:@"%d", totalComments]];
}

- (IBAction)likeButtonPressed:(id)sender {
    PFRelation *relation = [_cellItemObject relationForKey:DB_RELATION_USER_LIKES_ITEMS];
    [relation addObject:[PFUser currentUser]];
    [_cellItemObject saveEventually];
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    PFGeoPoint *myLocationPoint = [PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    [locationManager stopUpdatingLocation];

    PFObject *itemObject = [self cellItemObject];
    PFGeoPoint *itemLocation = [itemObject  objectForKey:DB_FIELD_ITEM_LOCATION];

    NSLocale *locale = [NSLocale currentLocale];
    BOOL usesMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
    NSString *distanceText;

    if(usesMetric) {
        distanceText = [NSString stringWithFormat:@"%.2lf", [itemLocation distanceInKilometersTo:myLocationPoint]];
        [_ownerNameLabel setText:[NSString stringWithFormat:@"%@ %@", distanceText, NSLocalizedString(@"KMs", nil)]];
    } else {
        distanceText = [NSString stringWithFormat:@"%.2lf", [itemLocation distanceInMilesTo:myLocationPoint]];
        [_ownerNameLabel setText:[NSString stringWithFormat:@"%@ %@", distanceText, NSLocalizedString(@"Miles", nil)]];
    }
    [_ownerNameLabel setHidden:NO];
    
    NSLog(@"%@ - %@", [itemObject objectForKey:DB_FIELD_ITEM_NAME], _ownerNameLabel.text);
}

@end
