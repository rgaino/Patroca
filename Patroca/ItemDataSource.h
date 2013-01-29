//
//  ItemDataSource.h
//  Patroca
//
//  Created by Rafael Gaino on 11/22/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class MasterViewController;
@class PFGeoPoint;

@interface ItemDataSource : NSObject <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    PFGeoPoint *myLocationPoint;
}

@property (readonly) NSArray* items;
@property (readwrite) MasterViewController *masterViewController;

- (void)getFriendsItemsAndReturn;
- (void)getNearbyItemsAndReturn;
- (void)getTotalCommentsForItems:(NSArray*)objects;

@end
