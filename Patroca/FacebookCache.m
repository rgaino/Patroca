//
//  FacebookCache.m
//  Patroca
//
//  Created by Rafael Gaino on 4/10/14.
//  Copyright (c) 2014 Punk Opera. All rights reserved.
//

#import "FacebookCache.h"
#import <Parse/Parse.h>

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

- (void)getFacebookFriendsInBackgroundWithCallback:(FacebookCacheCompletionBlock)callback {
    
    //check if friends list is already here, and return it if so (cache expires in 30 minutes
    NSLog(@"cache:%f", [[NSDate date] timeIntervalSinceDate:lastCache]);
    if(friendIdsArray!=nil && lastCache!=nil && [[NSDate date] timeIntervalSinceDate:lastCache] < 1800) {
        NSLog(@"FacebookCache for friends is up to date, returning it.");
        callback(friendIdsArray, nil);
    } else {

        NSLog(@"FacebookCache for friends is out of date, fetching it...");
    
        // Issue a Facebook Graph API request to get your user's friend list
        FBRequest *request = [FBRequest requestForGraphPath:@"me/friends"];
        [request setSession:[PFFacebookUtils session]];
        [request startWithCompletionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            if (!error) {
                lastCache = [NSDate date];
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


@end
