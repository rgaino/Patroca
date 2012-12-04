//
//  DatabaseConstants.h
//  Patroca
//
//  Created by Rafael Gaino on 8/27/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <Foundation/Foundation.h>

//Generic ID (each table has its own with the same name)
extern NSString* const DB_FIELD_ID;
extern NSString* const DB_FIELD_CREATED_AT;
extern NSString* const DB_FIELD_UPDATED_AT;

//User table
extern NSString* const DB_TABLE_USERS;
extern NSString* const DB_FIELD_USER_NAME;
extern NSString* const DB_FIELD_USER_ID;
extern NSString* const DB_FIELD_USER_FACEBOOK_ID;
extern NSString* const FB_PROFILE_PICTURE_URL;

//Item table
extern NSString* const DB_TABLE_ITEMS;
extern NSString* const DB_FIELD_ITEM_NAME;
extern NSString* const DB_FIELD_ITEM_MAIN_IMAGE;
extern NSString* const DB_FIELD_ITEM_LOCATION;

//Item_Images table
extern NSString* const DB_TABLE_ITEM_IMAGES;
extern NSString* const DB_FIELD_ITEM_ID;
extern NSString* const DB_FIELD_ITEM_IMAGE;
extern NSString* const DB_FIELD_ITEM_THUMBNAIL;

//Item_Comments table
extern NSString* const DB_TABLE_ITEM_COMMENTS;
extern NSString* const DB_FIELD_ITEM_COMMENT_TEXT;


//Item_Likes table
extern NSString* const DB_TABLE_ITEM_LIKES;


@interface DatabaseConstants : NSObject {

}

@end
