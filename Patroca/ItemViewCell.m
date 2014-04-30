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
    [_ownerProfilePic setImageWithURL:facebookProfilePicURL placeholderImage:[UIImage imageNamed:@"avatar_default.png"]];

    NSNumber *tradedNumber =  [itemObject objectForKey:DB_FIELD_ITEM_TRADED];
    BOOL traded = [tradedNumber boolValue];
    [_tradedLabel setText:NSLocalizedString(@"traded", nil)];
    [_tradedLabel setHidden:!traded];
    [_tradedImageView setHidden:!traded];
    
    //don't ask for CLLocation permissions for this yet... defer to when the user chooses Nearby items
    if(locationManager == nil && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager setDistanceFilter:kCLDistanceFilterNone];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        if([[[_cellItemObject objectForKey:DB_FIELD_USER_ID] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            [_likeButton setHidden:YES];
        } else {
            [_likeButton setHidden:NO];
            [_likeButton setImage:[UIImage imageNamed:@"star-off.png"] forState:UIControlStateNormal];
            for(PFObject *likedItem in [[UserCache getInstance] likedItemsArray]) {
                if([likedItem.objectId isEqualToString:itemObject.objectId]) {
                    [_likeButton setImage:[UIImage imageNamed:@"star-on.png"] forState:UIControlStateNormal];
                    [_likeButton setTag:1];
                    break;
                }
            }
        }
    }
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [locationManager startUpdatingLocation];
    }
}

- (void)updateTotalComments:(int)totalComments {
    [_totalCommentsLabel setText:[NSString stringWithFormat:@"%d", totalComments]];
}

- (IBAction)likeButtonPressed:(id)sender {
    
    PFRelation *relation = [_cellItemObject relationForKey:DB_RELATION_USER_LIKES_ITEMS];
    
    if(_likeButton.tag == 0) {
        //Likes item
        [relation addObject:[PFUser currentUser]];
        [[[UserCache getInstance] likedItemsArray] addObject:_cellItemObject];
        [_likeButton setImage:[UIImage imageNamed:@"star-on.png"] forState:UIControlStateNormal];
        [_likeButton setTag:1];
        
        // Notify owner that Item was liked
        NSString *notificationMessage = [NSString stringWithFormat:NSLocalizedString(@"user_liked_item", nil),
                                         [[PFUser currentUser] objectForKey:DB_FIELD_USER_NAME ],
                                         [_cellItemObject objectForKey:DB_FIELD_ITEM_NAME]];

        NSDictionary *pushData = [NSDictionary dictionaryWithObjectsAndKeys:_cellItemObject.objectId,@"item_id",
                                                                            notificationMessage, @"alert",
                                  nil];
        
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:DB_FIELD_USER_ID equalTo:[_cellItemObject objectForKey:DB_FIELD_USER_ID]];
        
        PFPush *pushNotification = [[PFPush alloc] init];
        [pushNotification setQuery:pushQuery];
        [pushNotification setData:pushData];
        [pushNotification sendPushInBackground];
        
    } else {
        //Removes like on item
        [relation removeObject:[PFUser currentUser]];
        [_likeButton setImage:[UIImage imageNamed:@"star-off.png"] forState:UIControlStateNormal];
        [_likeButton setTag:0];
        for(PFObject *likedItem in [[UserCache getInstance] likedItemsArray]) {
            if([[likedItem objectId] isEqualToString:[_cellItemObject objectId]]) {
                [[[UserCache getInstance] likedItemsArray] removeObject:likedItem];
                break;
            }
        }
    }
    
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
}

@end
