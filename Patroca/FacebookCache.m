//
//  FacebookCache.m
//  Patroca
//
//  Created by Rafael Gaino on 4/10/14.
//  Copyright (c) 2014 Punk Opera. All rights reserved.
//

#import "FacebookCache.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"

@implementation FacebookCache

static FacebookCache *_facebookCacheInstance = nil;
void(^getServerResponseForUrlCallback)(BOOL success, NSDictionary *response, NSError *error);

+(FacebookCache *) getInstance
{
	@synchronized([FacebookCache class])
	{
		if (!_facebookCacheInstance)
			_facebookCacheInstance = [[FacebookCache alloc] init];
        
		return _facebookCacheInstance;
	}
    
	return nil;
}


+(id)alloc
{
	@synchronized([FacebookCache class])
	{
		NSAssert(_facebookCacheInstance == nil, @"Attempted to allocate a second instance of a singleton.");
		_facebookCacheInstance = [super alloc];
		return _facebookCacheInstance;
	}
    
	return nil;
}

-(id)init
{
	self = [super init];
	return self;
}


- (void)getFacebookFriendIDsInBackgroundWithCallback:(FacebookFriendIDsArrayCacheCompletionBlock)callback {
    
    //check if friends list is already here, and return it if so (cache expires in 30 minutes)
    if(friendIdsArray!=nil && lastCacheForFriendIdsArray!=nil && [[NSDate date] timeIntervalSinceDate:lastCacheForFriendIdsArray] < 1800) {
        NSLog(@"FacebookCache for friends is up to date, returning it.");
        callback(friendIdsArray, nil);
    } else {

        NSLog(@"FacebookCache for friends IDs is out of date, fetching it...");

        // Issue a Facebook Graph API request to get your user's friend list
        FBRequest *request = [FBRequest requestForGraphPath:@"me/friends"];
        [request setSession:[PFFacebookUtils session]];
        [request startWithCompletionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            if (!error) {
                lastCacheForFriendIdsArray = [NSDate date];
                // result will contain an array with your user's friends in the "data" key
                NSArray *friendObjects = [result objectForKey:@"data"];
                friendIdsArray = [NSMutableArray arrayWithCapacity:friendObjects.count];
                // Create a list of friends' Facebook IDs
                for (NSDictionary *friendObject in friendObjects) {
                    [friendIdsArray addObject:[friendObject objectForKey:@"id"]];
                }
                
                NSLog(@"FacebookCache for friends updated, returning it.");

                callback(friendIdsArray, nil);

            } else {
                NSLog(@"FacebookCache for friends fetch failed with error %@ %@.", error, [error userInfo]);
                callback(nil, error);
            }
        }];
        }
}

- (void)getFacebookFriendsPFUserArrayInBackgroundWithCallback:(FacebookFriendsPFUserArrayCacheCompletionBlock)callback {
    
    //check if friends PFUser array is already here, and return it if so (cache expires in 30 minutes)
    if(friendPFUsersArray!=nil && lastCacheForFriendPFUsersArray!=nil && [[NSDate date] timeIntervalSinceDate:lastCacheForFriendPFUsersArray] < 1800) {
        NSLog(@"FacebookCache for friends PFUser array is up to date, returning it.");
        callback(friendPFUsersArray , nil);
    } else {
        
        NSLog(@"FacebookCache for friends PFUser array is out of date, fetching it...");
        
        [self getFacebookFriendIDsInBackgroundWithCallback:^(NSArray *friendIds, NSError *error) {
            
            if(!error) {
                
                lastCacheForFriendPFUsersArray = [NSDate date];
                
                // Construct a PFUser query that will find friends whose facebook ids
                // are contained in the current user's friend list.
                PFQuery *friendQuery = [PFUser query];
                [friendQuery whereKey:DB_FIELD_USER_FACEBOOK_ID containedIn:friendIdsArray];
                [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *userObjects, NSError *error) {
                    friendPFUsersArray = userObjects;
                    callback(userObjects, nil);
                }];
                 
            } else {
                NSLog(@"FacebookCache for friends fetch failed with error %@ %@.", error, [error userInfo]);
                callback(nil, error);
            }

        }];
    }
}


@end
