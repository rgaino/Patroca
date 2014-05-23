//
//  FacebookUtilsCache.h
//  Patroca
//
//  Created by Rafael Gaino on 4/10/14.
//  Copyright (c) 2014 Punk Opera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookUtilsCache : NSObject {
    NSMutableArray *friendIdsArray;
    NSDate *lastCacheForFriendIdsArray;

    NSArray *friendPFUsersArray;
    NSDate *lastCacheForFriendPFUsersArray;
}

typedef void (^FacebookFriendIDsArrayCacheCompletionBlock)(NSArray *friendIdsArray, NSError *error);
typedef void (^FacebookFriendsPFUserArrayCacheCompletionBlock)(NSArray *friendPFUserArray, NSError *error);

+(FacebookUtilsCache *) getInstance;
- (void)getFacebookFriendIDsInBackgroundWithCallback:(FacebookFriendIDsArrayCacheCompletionBlock)callback;
- (void)getFacebookFriendsPFUserArrayInBackgroundWithCallback:(FacebookFriendsPFUserArrayCacheCompletionBlock)callback;
- (void)tellYourFriends;

@end
