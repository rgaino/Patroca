//
//  UserCache.h
//  Patroca
//
//  Created by Rafael Gaino on 9/4/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFUser;

@interface UserCache : NSObject {

    NSMutableDictionary *userNameCacheDictionary;
    NSDate *lastCacheForLikedItems;

}

typedef void (^LikedItemsCacheCompletionBlock)(NSMutableArray *likedItemsArray, NSError *error);

+(UserCache*) getInstance;
- (void)updateUserNameCacheDictionaryForItems:(NSArray*) items;
- (PFUser*)getCachedUserForId:(NSString*)userid;
- (void)getLikedItemsArrayWithCallback:(LikedItemsCacheCompletionBlock)callback;

@property (readwrite) NSMutableArray *likedItemsArray;

@end
