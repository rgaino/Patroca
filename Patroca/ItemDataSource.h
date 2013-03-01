//
//  ItemDataSource.h
//  Patroca
//
//  Created by Rafael Gaino on 11/22/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ItemDataSourceDelegate.h"

@class BaseViewController;
@class PFGeoPoint;
@class PFObject;

//the current data mode
typedef enum {
    ItemDataSourceModeFeatured,
    ItemDataSourceModeFriends,
    ItemDataSourceModeNearby,
} ItemDataSourceMode;

@interface ItemDataSource : NSObject <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    PFGeoPoint *myLocationPoint;
    ItemDataSourceMode itemDataSourceMode;
}

@property (readonly) NSArray* items;
@property (readwrite) NSObject<ItemDataSourceDelegate> *delegate;

- (void)getFriendsItemsAndReturn;
- (void)getNearbyItemsAndReturn;
- (void)getFeaturedItemsAndReturn;
- (void)getItemsAndReturnForUser:(PFObject*)userObject;
- (void)getTotalCommentsForItems:(NSArray*)objects;
- (void)refresh;
- (void)clearAndReturn;

@end
