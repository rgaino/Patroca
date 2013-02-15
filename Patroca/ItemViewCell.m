//
//  ItemViewCell.m
//  Patroca
//
//  Created by Rafael Gaino on 11/22/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "ItemViewCell.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"
#import "UserCache.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ViewProfileViewController.h"

@implementation ItemViewCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame]; if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ItemViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] > 1) { return nil; }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) { return nil; }
        
        self = [arrayOfViews objectAtIndex:0];
        
    }
    
    return self;
}

- (void)setupCellWithItem:(PFObject*)itemObject {
    
    [self setCellItemObject:itemObject];
    
    [self.itemNameLabel setText:[itemObject objectForKey:DB_FIELD_ITEM_NAME]];
    
    PFUser *itemUser = [itemObject objectForKey:DB_FIELD_USER_ID];
    NSString *userId = [itemUser objectId];
    
    PFUser *userObject = [[UserCache getInstance] getCachedUserForId:userId];
    [self.ownerNameLabel setText:[userObject objectForKey:DB_FIELD_USER_NAME]];
    
    
    PFFile *itemImageFile = [itemObject objectForKey:DB_FIELD_ITEM_MAIN_IMAGE];
    NSURL *itemImageURL = [NSURL URLWithString:[itemImageFile url]];
    [_itemImageView setImageWithURL:itemImageURL placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    NSString *facebookProfilePicString = [NSString stringWithFormat:FB_PROFILE_PICTURE_URL, [userObject objectForKey:DB_FIELD_USER_FACEBOOK_ID]];
    NSURL *facebookProfilePicURL = [NSURL URLWithString:facebookProfilePicString];
    [_ownerProfilePic setImageWithURL:facebookProfilePicURL];

}

- (void)updateTotalComments:(int)totalComments {
    [_totalCommentsLabel setText:[NSString stringWithFormat:@"%d", totalComments]];
}



@end
