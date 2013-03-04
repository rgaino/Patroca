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
    ItemDataSourceModeUser
} ItemDataSourceMode;

@interface ItemDataSource : NSObject <CLLocationManagerDelegate> {
    
    NSInteger currentResultsLimit;
    NSInteger resultsPerPage;
    CLLocationManager *locationManager;
    PFGeoPoint *myLocationPoint;
    ItemDataSourceMode itemDataSourceMode;
}

@property (readonly) NSArray* items;
@property (readwrite) NSObject<ItemDataSourceDelegate> *delegate;
@property (readwrite) PFObject *userObject;

//- (void)getFriendsItemsAndReturn;
//- (void)getNearbyItemsAndReturn;
//- (void)getFeaturedItemsAndReturn;
//- (void)getUserItemsAndReturn;

- (void)setItemDataSourceMode:(ItemDataSourceMode)var;
- (void)getTotalCommentsForItems:(NSArray*)objects;
- (void)refresh;
- (void)getNextPageAndReturn;
- (void)clearAndReturn;

@end
