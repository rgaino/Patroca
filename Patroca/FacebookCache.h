//
//  FacebookCache.h
//  Patroca
//
//  Created by Rafael Gaino on 4/10/14.
//  Copyright (c) 2014 Punk Opera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookCache : NSObject {
    NSMutableArray *friendIdsArray;
    NSDate *lastCache;
}

typedef void (^FacebookCacheCompletionBlock)(NSArray *friendIdsArray, NSError *error);

+(FacebookCache *) getInstance;
- (void)getFacebookFriendsInBackgroundWithCallback:(FacebookCacheCompletionBlock)callback;

@end
