//
//  ItemDataSource.m
//  Patroca
//
//  Created by Rafael Gaino on 11/22/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "ItemDataSource.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"
#import "MasterViewController.h"

@implementation ItemDataSource


- (void)refresh {
    
    switch(itemDataSourceMode) {
        case ItemDataSourceModeFeatured:
            [self getFeaturedItemsAndReturn];
            break;
        case ItemDataSourceModeFriends:
            [self getFriendsItemsAndReturn];
            break;
        case ItemDataSourceModeNearby:
            [self getNearbyItemsAndReturn];
            break;
    }
    
}

- (void)clearAndReturn {
    _items = [NSArray array];
    [_delegate populateCollectionView];
}

- (void)getFeaturedItemsAndReturn {
    itemDataSourceMode = ItemDataSourceModeFeatured;
    _items = [NSArray array];
    [_delegate populateCollectionView];
}

- (void)getFriendsItemsAndReturn {
    
    itemDataSourceMode = ItemDataSourceModeFriends;
    
    if([PFUser currentUser] == nil) {
        NSLog(@"Can't get current user");
        //TODO: show a nice error message
    }
    
    
    // Issue a Facebook Graph API request to get your user's friend list
    PF_FBRequest *request = [PF_FBRequest requestForGraphPath:@"me/friends"];
    [request setSession:[PFFacebookUtils session]];
    [request startWithCompletionHandler:^(PF_FBRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            // Construct a PFUser query that will find friends whose facebook ids
            // are contained in the current user's friend list.
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:DB_FIELD_USER_FACEBOOK_ID containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
            [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friendUsers, NSError *error) {
                PFQuery *query = [PFQuery queryWithClassName:DB_TABLE_ITEMS];
                [query whereKey:DB_FIELD_USER_ID notEqualTo:[PFUser currentUser]];
                [query whereKey:DB_FIELD_USER_ID containedIn:friendUsers];
                
                [query orderByDescending:DB_FIELD_UPDATED_AT];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        
                        _items = [NSArray arrayWithArray:objects];
                        [_delegate populateCollectionView];
                        
                        [self getTotalCommentsForItems:objects];

                    } else {
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        _items = [NSArray array];
                        //TODO: show error message
                    }
                }];

            }];
            
            
        }
    }];
}

- (void)getNearbyItemsAndReturn {

    itemDataSourceMode = ItemDataSourceModeNearby;

    if(locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager setDistanceFilter:kCLDistanceFilterNone];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    
    if(myLocationPoint == nil) {
        [locationManager startUpdatingLocation];
        return;
    }

    
    PFQuery *query = [PFQuery queryWithClassName:DB_TABLE_ITEMS];
    [query whereKey:DB_FIELD_ITEM_LOCATION nearGeoPoint:myLocationPoint];
    if([PFUser currentUser] != nil) {
        [query whereKey:DB_FIELD_USER_ID notEqualTo:[PFUser currentUser]];
    }

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            myLocationPoint = nil;

            _items = [NSArray arrayWithArray:objects];
            [_delegate populateCollectionView];
            
            [self getTotalCommentsForItems:objects];

        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            _items = [NSArray array];
        }
    }];
}


- (void)getItemsAndReturnForUser:(PFObject*)userObject; {
    
    if(userObject == nil) {
        NSLog(@"Can't get current user");
        //TODO: show a nice error message
    }
    
    PFQuery *query = [PFQuery queryWithClassName:DB_TABLE_ITEMS];
    [query whereKey:DB_FIELD_USER_ID equalTo:userObject];
    
    [query orderByDescending:DB_FIELD_UPDATED_AT];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            _items = [NSArray arrayWithArray:objects];
            [_delegate populateCollectionView];
            
            [self getTotalCommentsForItems:objects];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            _items = [NSArray array];
            //TODO: show error message
        }
    }];
}


- (void)getTotalCommentsForItems:(NSArray*)objects {
    
    //calling CloudCode function to get a count of comments for each item
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    for(PFObject *oneItem in objects) {
        [ids addObject:oneItem.objectId];
    }
    NSDictionary *params = [NSDictionary dictionaryWithObject:ids forKey:@"item_ids_array"];
    
    [PFCloud callFunctionInBackground:@"totalCommentsForItems" withParameters:params block:^(id object, NSError *error) {
        
        NSDictionary *totalCommentsForItemsDictionary = (NSDictionary*) object;
        [_delegate populateTotalLikesWithDictionary:totalCommentsForItemsDictionary];
        
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"Location updated to is %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    myLocationPoint = [PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    [locationManager stopUpdatingLocation];
    [self getNearbyItemsAndReturn];
}

@end
