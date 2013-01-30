//
//  DatabaseConstants.m
//  Patroca
//
//  Created by Rafael Gaino on 8/27/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "DatabaseConstants.h"

@implementation DatabaseConstants


//Generic ID (each table has its own with the same name)
NSString* const DB_FIELD_ID = @"objectId";
NSString* const DB_FIELD_CREATED_AT = @"createdAt";
NSString* const DB_FIELD_UPDATED_AT = @"updatedAt";

//User table
NSString* const DB_TABLE_USERS = @"User";
NSString* const DB_FIELD_USER_NAME = @"name";
NSString* const DB_FIELD_USER_ID = @"user_id";
NSString* const DB_FIELD_USER_FACEBOOK_ID = @"user_facebook_id";
NSString* const FB_PROFILE_PICTURE_URL = @"https://graph.facebook.com/%@/picture?type=square";

//Item table
NSString* const DB_TABLE_ITEMS = @"Item";
NSString* const DB_FIELD_ITEM_NAME = @"item_name";
NSString* const DB_FIELD_ITEM_DESCRIPTION = @"item_description";
NSString* const DB_FIELD_ITEM_MAIN_IMAGE = @"item_main_image";
NSString* const DB_FIELD_ITEM_LOCATION = @"item_location";


//Item_Images table
NSString* const DB_TABLE_ITEM_IMAGES = @"Item_Images";
NSString* const DB_FIELD_ITEM_ID = @"item_id";
NSString* const DB_FIELD_ITEM_IMAGE = @"full_image";


//Item_Comments table
NSString* const DB_TABLE_ITEM_COMMENTS = @"Item_Comments";
NSString* const DB_FIELD_ITEM_COMMENT_TEXT = @"comment_text";


//Item_Likes table
NSString* const DB_TABLE_ITEM_LIKES = @"Item_Likes";

//Push Notifications channel names
NSString* const NOTIFICATIONS_COMMENTS_ON_ITEM = @"comments_on_item_%@";


@end
