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
#import "ItemDetailsViewController.h"

@implementation ItemViewCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame]; if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ItemViewCell" owner:self options:nil];
        if ([arrayOfViews count] > 1) { return nil; }
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) { return nil; }
        self = [arrayOfViews objectAtIndex:0];
    }
    
    return self;
}

- (void)setupCellWithItem:(PFObject*)itemObject {

    [self setCellItemObject:itemObject];
    
    PFFile *itemImageFile = [itemObject objectForKey:DB_FIELD_ITEM_MAIN_IMAGE];
    NSURL *itemImageURL = [NSURL URLWithString:[itemImageFile url]];
    [_itemImageView setImageWithURL:itemImageURL placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    

    NSNumber *tradedNumber =  [itemObject objectForKey:DB_FIELD_ITEM_TRADED];
    BOOL traded = [tradedNumber boolValue];
    [_tradedLabel setText:NSLocalizedString(@"traded", nil)];
    [_tradedLabel setHidden:!traded];
    [_tradedView setHidden:!traded];
    
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeButtonPressed:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGestureRecognizer];
    

    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        if([[[_cellItemObject objectForKey:DB_FIELD_USER_ID] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            [_likeButton setHidden:YES];
        } else {
            [_likeButton setHidden:NO];
            [_likeButton setImage:[UIImage imageNamed:@"star_off.png"] forState:UIControlStateNormal];
            for(PFObject *likedItem in [[UserCache getInstance] likedItemsArray]) {
                if([likedItem.objectId isEqualToString:itemObject.objectId]) {
                    [_likeButton setImage:[UIImage imageNamed:@"star_on.png"] forState:UIControlStateNormal];
                    [_likeButton setTag:1];
                    break;
                }
            }
        }
    }
}

- (void)openItemDetailsPage {
    
    ItemDetailsViewController *itemDetailsViewController = [[ItemDetailsViewController alloc] initWithNibName:@"ItemDetailsViewController" bundle:nil];
    [itemDetailsViewController setItemObject:_cellItemObject];
    [_parentController.navigationController pushViewController:itemDetailsViewController animated:YES];
}

- (IBAction)likeButtonPressed:(id)sender {
    
    PFRelation *relation = [_cellItemObject relationForKey:DB_RELATION_USER_LIKES_ITEMS];
    
    if(_likeButton.tag == 0) {
        //Likes item
        [relation addObject:[PFUser currentUser]];
        [[[UserCache getInstance] likedItemsArray] addObject:_cellItemObject];
        [_likeButton setImage:[UIImage imageNamed:@"star_on.png"] forState:UIControlStateNormal];
        [_likeButton setTag:1];
        
        // Notify owner that Item was liked
        NSString *notificationMessage = [NSString stringWithFormat:NSLocalizedString(@"user_liked_item", nil),
                                         [[PFUser currentUser] objectForKey:DB_FIELD_USER_NAME ],
                                         [_cellItemObject objectForKey:DB_FIELD_ITEM_NAME]];

        NSDictionary *pushData = [NSDictionary dictionaryWithObjectsAndKeys:_cellItemObject.objectId,@"item_id",
                                                                            notificationMessage, @"alert",
                                  nil];
        
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:DB_FIELD_USER_ID equalTo:[_cellItemObject objectForKey:DB_FIELD_USER_ID]];
        
        PFPush *pushNotification = [[PFPush alloc] init];
        [pushNotification setQuery:pushQuery];
        [pushNotification setData:pushData];
        [pushNotification sendPushInBackground];
        
    } else {
        //Removes like on item
        [relation removeObject:[PFUser currentUser]];
        [_likeButton setImage:[UIImage imageNamed:@"star_off.png"] forState:UIControlStateNormal];
        [_likeButton setTag:0];
        for(PFObject *likedItem in [[UserCache getInstance] likedItemsArray]) {
            if([[likedItem objectId] isEqualToString:[_cellItemObject objectId]]) {
                [[[UserCache getInstance] likedItemsArray] removeObject:likedItem];
                break;
            }
        }
    }
    
    [_cellItemObject saveEventually];
}


@end
