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
#import "FacebookUtilsCache.h"
#import "UserCache.h"

@implementation ItemDataSource

- (id)init {
    
    self = [super init];
    
    //custom initialization code
    currentResultsLimit = 0; //the current page count
    resultsPerPage = 20 ; //constant
    return self;
}

- (void)setItemDataSourceMode:(ItemDataSourceMode)var {
    itemDataSourceMode = var;
    currentResultsLimit = 0;
}

- (void)refresh {
    currentResultsLimit = 0;
    [self getNextPageAndReturnWithCallback:^(NSError *error) {
        
    }];
}


- (void)getNextPageAndReturnWithCallback:(GetItemsCompletionBlock)callback {
    
    if(itemDataSourceMode == ItemDataSourceModeFeatured) {
        [self getFeaturedItemsAndReturnWithCallback:^(NSError *error) {
            callback(error);
        }];
    }
    else if(itemDataSourceMode == ItemDataSourceModeFriends) {
            [self getFriendsItemsAndReturnWithCallback:^(NSError *error) {
                callback(error);
            }];
    } else if(itemDataSourceMode ==  ItemDataSourceModeNearby) {
            [self getNearbyItemsAndReturnWithCallback:^(NSError *error) {
                callback(error);
            }];
    } else if(itemDataSourceMode == ItemDataSourceModeUser) {
            [self getUserItemsAndReturnWithCallback:^(NSError *error) {
                callback(error);
            }];
    }
}

- (void)clearAndReturn {
    _items = [NSArray array];
    [_delegate populateCollectionView];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error on 'locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error': %@ %@", error, [error userInfo]);
    [_delegate showErrorIcon];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"Location updated to is %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    myLocationPoint = [PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    [locationManager stopUpdatingLocation];
    [self getNearbyItemsAndReturnWithCallback:^(NSError *error) {}];
}


#pragma mark Private or Hidden methods (undeclared on .h file, but must be at the end of this file)

- (void)getFeaturedItemsAndReturnWithCallback:(GetItemsCompletionBlock)callback {
    
    if(itemDataSourceMode!=ItemDataSourceModeFeatured) {
        currentResultsLimit=0;
    }
    
    FacebookUtilsCache *facebookUtilsCache = [FacebookUtilsCache getInstance];
    [facebookUtilsCache getFacebookFriendsPFUserArrayInBackgroundWithCallback:^(NSArray *friendPFUserArray, NSError *error) {
        if(!error) {
            PFQuery *itemsQuery = [PFQuery queryWithClassName:DB_TABLE_ITEMS];
            [itemsQuery whereKey:DB_FIELD_ITEM_DELETED equalTo:[NSNumber numberWithBool:NO]];
            [itemsQuery whereKey:DB_RELATION_USER_LIKES_ITEMS containedIn:friendPFUserArray];
            [itemsQuery whereKey:DB_FIELD_USER_ID notEqualTo:[PFUser currentUser]];
            [itemsQuery orderByDescending:DB_FIELD_CREATED_AT];
            
            [itemsQuery setSkip:currentResultsLimit];
            [itemsQuery setLimit:resultsPerPage];
            
            [itemsQuery findObjectsInBackgroundWithBlock:^(NSArray *itemObjects, NSError *error) {
                
                //TODO: this code is repeated in the 3 functions, we should make a single method
                if (!error) {
                    myLocationPoint = nil;
                    
                    if(currentResultsLimit == 0) {
                        //first page of results
                        _items = [NSArray arrayWithArray:itemObjects];
                        [_delegate populateCollectionView];
                    } else {
                        NSMutableArray *tempReturnArray = [NSMutableArray arrayWithArray:_items];
                        [tempReturnArray addObjectsFromArray:itemObjects];
                        _items = tempReturnArray;
                        [_delegate addItemsToCollectionView];
                    }
                    
                    currentResultsLimit += resultsPerPage;
                    callback(nil);
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    _items = [NSArray array];
                    callback(error);
                }
            }];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            _items = [NSArray array];
            callback(error);
        }
    }];
}

- (void)getFriendsItemsAndReturnWithCallback:(GetItemsCompletionBlock)callback {
    
    if(itemDataSourceMode!=ItemDataSourceModeFriends) {
        currentResultsLimit=0;
    }
    
    itemDataSourceMode = ItemDataSourceModeFriends;
    
    if([PFUser currentUser] == nil) {
        NSLog(@"Can't get current user");
    }
    
    FacebookUtilsCache *facebookUtilsCache = [FacebookUtilsCache getInstance];
    
    [facebookUtilsCache getFacebookFriendsPFUserArrayInBackgroundWithCallback:^(NSArray *friendPFUserArray, NSError *error) {

        if(!error) {
            PFQuery *query = [PFQuery queryWithClassName:DB_TABLE_ITEMS];
            [query whereKey:DB_FIELD_ITEM_DELETED equalTo:[NSNumber numberWithBool:NO]];
            [query whereKey:DB_FIELD_USER_ID notEqualTo:[PFUser currentUser]];
            [query whereKey:DB_FIELD_USER_ID containedIn:friendPFUserArray];
            
            [query setSkip:currentResultsLimit];
            [query setLimit:resultsPerPage];
            
            [query orderByDescending:DB_FIELD_CREATED_AT];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *itemObjects, NSError *error) {
                
                [[UserCache getInstance] getLikedItemsArrayWithCallback:^(NSMutableArray *likedItemsArray, NSError *error) {
                
                    if (!error) {
                        
                        if(currentResultsLimit == 0) {
                            //first page of results
                            _items = [NSArray arrayWithArray:itemObjects];
                            [_delegate populateCollectionView];
                        } else {
                            NSMutableArray *tempReturnArray = [NSMutableArray arrayWithArray:_items];
                            [tempReturnArray addObjectsFromArray:itemObjects];
                            _items = tempReturnArray;
                            [_delegate addItemsToCollectionView];
                        }
                        
                        currentResultsLimit += resultsPerPage;
                        callback(nil);
                    } else {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        _items = [NSArray array];
                        callback(error);
                    }
                }];
            }];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            _items = [NSArray array];
            callback(error);
        }
    }];

}

- (void)getNearbyItemsAndReturnWithCallback:(GetItemsCompletionBlock)callback {
    
    if(itemDataSourceMode!=ItemDataSourceModeNearby) {
        currentResultsLimit=0;
    }
    
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
    [query whereKey:DB_FIELD_ITEM_DELETED equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:DB_FIELD_ITEM_LOCATION nearGeoPoint:myLocationPoint];
    if([PFUser currentUser] != nil) {
        [query whereKey:DB_FIELD_USER_ID notEqualTo:[PFUser currentUser]];
    }
    
    [query setSkip:currentResultsLimit];
    [query setLimit:resultsPerPage];

    [query findObjectsInBackgroundWithBlock:^(NSArray *itemObjects, NSError *error) {
        if (!error) {
            myLocationPoint = nil;
            
            if(currentResultsLimit == 0) {
                //first page of results
                _items = [NSArray arrayWithArray:itemObjects];
                [_delegate populateCollectionView];
            } else {
                NSMutableArray *tempReturnArray = [NSMutableArray arrayWithArray:_items];
                [tempReturnArray addObjectsFromArray:itemObjects];
                _items = tempReturnArray;
                [_delegate addItemsToCollectionView];
            }
            
            currentResultsLimit += resultsPerPage;
            callback(nil);
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            _items = [NSArray array];
            callback(error);
        }
    }];
}


- (void)getUserItemsAndReturnWithCallback:(GetItemsCompletionBlock)callback {
    
    if(itemDataSourceMode!=ItemDataSourceModeUser) {
        currentResultsLimit=0;
    }

    if(_userObject == nil) {
        NSLog(@"Can't get current user");
        //TODO: show a nice error message
    }
    
    PFQuery *query = [PFQuery queryWithClassName:DB_TABLE_ITEMS];
    [query whereKey:DB_FIELD_ITEM_DELETED equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:DB_FIELD_USER_ID equalTo:_userObject];

    [query setSkip:currentResultsLimit];
    [query setLimit:resultsPerPage];

    [query orderByDescending:DB_FIELD_CREATED_AT];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *itemObjects, NSError *error) {
        if (!error) {
            
            if(currentResultsLimit == 0) {
                //first page of results
                _items = [NSArray arrayWithArray:itemObjects];
                [_delegate populateCollectionView];
            } else {
                NSMutableArray *tempReturnArray = [NSMutableArray arrayWithArray:_items];
                [tempReturnArray addObjectsFromArray:itemObjects];
                _items = tempReturnArray;
                [_delegate addItemsToCollectionView];
            }
            
            currentResultsLimit += resultsPerPage;
            callback(nil);
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            _items = [NSArray array];
            callback(error);
        }
    }];
}


@end
