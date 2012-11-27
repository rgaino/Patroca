//
//  UserCache.m
//  Patroca
//
//  Created by Rafael Gaino on 9/4/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "UserCache.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"

@implementation UserCache 

static UserCache *_userCacheInstance = nil;


+(UserCache *) getInstance
{
	@synchronized([UserCache class])
	{
		if (!_userCacheInstance)
			_userCacheInstance = [[UserCache alloc] init];
        
		return _userCacheInstance;
	}
    
	return nil;
}


+(id)alloc
{
	@synchronized([UserCache class])
	{
		NSAssert(_userCacheInstance == nil, @"Attempted to allocate a second instance of a singleton.");
		_userCacheInstance = [super alloc];
		return _userCacheInstance;
	}
    
	return nil;
}

-(id)init
{
	self = [super init];
    
	if (self != nil) {
	    if(userNameCacheDictionary==nil) {
            //initialize user cache dictionary if necessary
            userNameCacheDictionary = [NSMutableDictionary dictionary];
        }
    }
    
	return self;
}



//Update the userName cache dictionary to avoid fetching Parse repeatedly for user names
- (void)updateUserNameCacheDictionaryForItems:(NSArray*) items {
    
    NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:items.count];
    
    //create an array with all user ids to be fetched
    for (PFObject *itemObject in items) {
        PFUser *user = [itemObject objectForKey:DB_FIELD_USER_ID];
        [userIds addObject:[user objectId]];
    }
    
    //check if the cache is up to date
    BOOL isCacheUpToDate = YES;
    for(NSString *uid in userIds) {
        if( [userNameCacheDictionary objectForKey:uid] == nil ) {
            //at least one id is not on the cache so let's fetch it
            NSLog(@"userNameCacheDictionary is outdated, updating...");
            isCacheUpToDate = NO;
            break;
        }
    }
    
    if(isCacheUpToDate) {
        NSLog(@"userNameCacheDictionary is up to date.");
        return;
    }
    
    // Fetch user names
    PFQuery *userNameQuery = [PFUser query];
    [userNameQuery whereKey:DB_FIELD_ID containedIn:userIds];
    
    NSArray *userNameResults = [userNameQuery findObjects];
    
    //update cache dictionary
    for(PFUser *userObject in userNameResults) {
        [userNameCacheDictionary setObject:userObject forKey:[userObject objectId]];
    }
    
    
}


- (PFUser*) getCachedUserForId:(NSString*)userid {
    
    if( [userNameCacheDictionary objectForKey:userid] == nil ) {
        //cache doesn't have this user, fetch it and add to the cache
        NSLog(@"User id %@ not in cache, fetching it...", userid);
        
        PFQuery *userQuery = [PFUser query];
        PFUser *userObject = (PFUser*)[userQuery getObjectWithId:userid];
        [userNameCacheDictionary setObject:userObject forKey:userid];
    }
    
    return [userNameCacheDictionary objectForKey:userid];
}


@end
