//
//  ViewProfileViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 8/23/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "ViewProfileViewController.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ItemDataSource.h"
#import "ItemViewCell.h"
#import "UserCache.h"
#import "ItemDetailsViewController.h"
#import "ProfileHeaderViewCell.h"
#import "SVPullToRefresh.h"

#define CELL_REUSE_IDENTIFIER @"Item_Profile_Cell"
#define HEADER_CELL_REUSE_IDENTIFIER @"Header_Profile_Cell"

@implementation ViewProfileViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        itemDataSource = [[ItemDataSource alloc] init];
        [itemDataSource setItemDataSourceMode:ItemDataSourceModeUser];
        [itemDataSource setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupHeaderWithBackButton:YES doneButton:NO addItemButton:YES];

    totalCommentsForItemsDictionary = [[NSMutableDictionary alloc] init];
    [_contentDisplayCollectionView registerClass:[ItemViewCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];
    [_contentDisplayCollectionView registerClass:[ProfileHeaderViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_CELL_REUSE_IDENTIFIER];
    
    userData = nil;
    
    //add infinite scrolling
    [_contentDisplayCollectionView addInfiniteScrollingWithActionHandler:^{
        [itemDataSource getNextPageAndReturn];
    }];

}


- (void)setupViewWithUserID:(NSString*)profileUserID {
    
    userObject = [[UserCache getInstance] getCachedUserForId:profileUserID];
    [self readUserDataFromFacebook];
}

- (void)readUserDataFromFacebook {
    
    NSString *userFacebookID = [userObject objectForKey:DB_FIELD_USER_FACEBOOK_ID];
    NSString *facebookGraphPath = [NSString stringWithFormat:@"%@/?fields=name,location,picture,email", userFacebookID];
    PF_FBRequest *request = [PF_FBRequest requestForGraphPath:facebookGraphPath];
    [request startWithCompletionHandler:^(PF_FBRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            NSLog(@"Logged in to Facebook with success");
            dispatch_async(dispatch_get_main_queue(), ^{
                // This block will be executed asynchronously on the main thread.
                //because UI elements must be updated on the main thread
                [self facebookLoggedInWithResult:result];
            });
            
        } else {
            //TODO: error handling
            NSLog(@"Failed to login to Facebook with error: %@", [error localizedDescription]);
        }
     
    }];
}


- (void)facebookLoggedInWithResult:(id)result {
 
    //read Facebook profile information
    userData = (NSDictionary *)result;
    [itemDataSource setUserObject:userObject];
    [itemDataSource getNextPageAndReturn];
}



#pragma mark ItemDataSourceDelegate

- (void)populateCollectionView {
    
    NSLog(@"Populating list with %d items", itemDataSource.items.count);
    [[UserCache getInstance] updateUserNameCacheDictionaryForItems:itemDataSource.items];
    [_contentDisplayCollectionView reloadData];
}

- (void)addItemsToColletionView {
    
    NSLog(@"Addind items to list, new total is %d", itemDataSource.items.count);
    [[UserCache getInstance] updateUserNameCacheDictionaryForItems:itemDataSource.items];
    [_contentDisplayCollectionView reloadData];
    [_contentDisplayCollectionView.infiniteScrollingView stopAnimating];
}

- (void)populateTotalLikesWithDictionary:(NSDictionary*)tempTotalCommentsForItemsDictionary {
    
    //updating the dictionary with items and their total comments...
    NSArray *itemIDs = [tempTotalCommentsForItemsDictionary objectForKey:@"item_ids"];
    NSArray *itemTotalComments = [tempTotalCommentsForItemsDictionary objectForKey:@"item_comments"];
    for(int i=0; i<itemIDs.count; i++) {
        [totalCommentsForItemsDictionary setObject:[itemTotalComments objectAtIndex:i] forKey:[itemIDs objectAtIndex:i]];
    }
    
    //...then update all visible cells
    for(ItemViewCell *itemViewCell in [_contentDisplayCollectionView visibleCells]) {
        [self updateTotalLikesForItemViewCell:itemViewCell];
    }
}

- (void)updateTotalLikesForItemViewCell:(ItemViewCell*)itemViewCell {
    
    //lookup item on totalCommentsForItemsDictionary and update its cell
    PFObject *cellItemObject = [itemViewCell cellItemObject];
    NSString *itemId = [cellItemObject objectId];
    
    int totalComments = 0;
    
    NSString *totalCommentsString = [totalCommentsForItemsDictionary objectForKey:itemId];
    if(totalCommentsString != nil) {
        totalComments = [totalCommentsString intValue];
    }
    [itemViewCell updateTotalComments:totalComments];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return itemDataSource.items.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ItemViewCell *itemViewCell = (ItemViewCell *)[self.contentDisplayCollectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    PFObject *item = [[itemDataSource items] objectAtIndex:indexPath.row];
    [itemViewCell setupCellWithItem:item];
    
    [self updateTotalLikesForItemViewCell:itemViewCell];
    
    return itemViewCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if(userData == nil) {
        //don't display the header until we have user data information from Facebook
        return nil;
    }

    ProfileHeaderViewCell *profileHeaderViewCell = [collectionView dequeueReusableSupplementaryViewOfKind:
                                         UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_CELL_REUSE_IDENTIFIER forIndexPath:indexPath];

    [profileHeaderViewCell setupProfileHeaderViewCellWithUser:userObject UserData:userData];
    [profileHeaderViewCell setParentViewController:self];
    return profileHeaderViewCell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *item = [[itemDataSource items] objectAtIndex:indexPath.row];
    
    ItemDetailsViewController *itemDetailsViewController = [[ItemDetailsViewController alloc] initWithNibName:@"ItemDetailsViewController" bundle:nil];
    [itemDetailsViewController setItemObject:item];
    [self.navigationController pushViewController:itemDetailsViewController animated:YES];
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}


#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(147, 162);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

//header size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(320, 360);
}

#pragma mark Memory Management

- (void)viewDidUnload {
    [super viewDidUnload];
}


@end
