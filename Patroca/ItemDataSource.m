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

- (void)getItemsAndReturnTo:(MasterViewController*)masterViewController {
    
    //    NSArray *friendsItems = [[NSMutableArray alloc] init];
    //    return friendsItems;
    
    if([PFUser currentUser] == nil) {
        NSLog(@"Can't get current user");
        //TODO: show a nice error message
        //        return friendsItems;
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
            NSArray *friendUsers = [friendQuery findObjects];
            
            PFQuery *query = [PFQuery queryWithClassName:DB_TABLE_ITEMS];
            [query whereKey:DB_FIELD_USER_ID notEqualTo:[PFUser currentUser]];
            [query whereKey:DB_FIELD_USER_ID containedIn:friendUsers];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    //                    [self loadFetchedItems:objects];
                    [masterViewController populateWithItems:objects];
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    //TODO: show error message
                    //                    self.itemsArray = [NSArray array];
                }
            }];
            
        }
    }];
    
}


@end
