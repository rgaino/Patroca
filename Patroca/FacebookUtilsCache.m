//
//  FacebookUtilsCache.m
//  Patroca
//
//  Created by Rafael Gaino on 4/10/14.
//  Copyright (c) 2014 Punk Opera. All rights reserved.
//

#import "FacebookUtilsCache.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"

@implementation FacebookUtilsCache

static FacebookUtilsCache *_facebookUtilsCacheInstance = nil;
void(^getServerResponseForUrlCallback)(BOOL success, NSDictionary *response, NSError *error);

+(FacebookUtilsCache *) getInstance
{
	@synchronized([FacebookUtilsCache class])
	{
		if (!_facebookUtilsCacheInstance)
			_facebookUtilsCacheInstance = [[FacebookUtilsCache alloc] init];
        
		return _facebookUtilsCacheInstance;
	}
    
	return nil;
}


+(id)alloc
{
	@synchronized([FacebookUtilsCache class])
	{
		NSAssert(_facebookUtilsCacheInstance == nil, @"Attempted to allocate a second instance of a singleton.");
		_facebookUtilsCacheInstance = [super alloc];
		return _facebookUtilsCacheInstance;
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
        NSLog(@"FacebookUtilsCache for friends is up to date, returning it.");
        callback(friendIdsArray, nil);
    } else {

        NSLog(@"FacebookUtilsCache for friends IDs is out of date, fetching it...");

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
                
                NSLog(@"FacebookUtilsCache for friends updated, returning it.");

                callback(friendIdsArray, nil);

            } else {
                NSLog(@"FacebookUtilsCache for friends fetch failed with error %@ %@.", error, [error userInfo]);
                callback(nil, error);
            }
        }];
        }
}

- (void)getFacebookFriendsPFUserArrayInBackgroundWithCallback:(FacebookFriendsPFUserArrayCacheCompletionBlock)callback {
    
    //check if friends PFUser array is already here, and return it if so (cache expires in 30 minutes)
    if(friendPFUsersArray!=nil && lastCacheForFriendPFUsersArray!=nil && [[NSDate date] timeIntervalSinceDate:lastCacheForFriendPFUsersArray] < 1800) {
        NSLog(@"FacebookUtilsCache for friends PFUser array is up to date, returning it.");
        callback(friendPFUsersArray , nil);
    } else {
        
        NSLog(@"FacebookUtilsCache for friends PFUser array is out of date, fetching it...");
        
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
                NSLog(@"FacebookUtilsCache for friends fetch failed with error %@ %@.", error, [error userInfo]);
                callback(nil, error);
            }

        }];
    }
}

- (void)tellYourFriends {
    NSString *shareURL = @"http://patroca.com";
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:shareURL];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
    } else {
        // Present the feed dialog
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Patroca", @"name",
                                       @"Social bartering.", @"caption",
                                       @"Come join Patroca and let's trade stuff.", @"description",
                                       shareURL, @"link",
                                       @"http://patroca.com/images/45e22924.logo.png", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }

}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

@end
