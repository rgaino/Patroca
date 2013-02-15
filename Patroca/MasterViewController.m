//
//  MasterViewController.m
//  Patroca
//
//  Created by Rafael Gaino on 11/16/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import "MasterViewController.h"
#import <Parse/Parse.h>
#import "DatabaseConstants.h"
#import "ItemViewCell.h"
#import "ItemDataSource.h"
#import "LogInViewController.h"
#import "ViewProfileViewController.h"
#import "UserCache.h"
#import "AddNewItemViewController.h"
#import "ItemDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define CELL_REUSE_IDENTIFIER @"Item_Cell_Master"

@implementation MasterViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
                
        //Colors and patterns
        labelSelectedColor = [UIColor colorWithRed:36/255.0 green:190/255.0 blue:212/255.0 alpha:1.0f];
        labelUnselectedColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0f];

        //making menu bar labels tappable
        UITapGestureRecognizer *featuredTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnFeatured)];
        [_featuredLabel addGestureRecognizer:featuredTap];

        UITapGestureRecognizer *friendsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnFriends)];
        [_friendsLabel addGestureRecognizer:friendsTap];

        UITapGestureRecognizer *nearbyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnNearby)];
        [_nearbyLabel addGestureRecognizer:nearbyTap];
        
        itemDataSource = [[ItemDataSource alloc] init];
        [itemDataSource setDelegate:self];
        
    }
    return self;
}

- (void)viewDidLoad {

    totalCommentsForItemsDictionary = [[NSMutableDictionary alloc] init];
    [self.contentDisplayCollectionView registerClass:[ItemViewCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];
    [self setupHeaderWithBackButton:NO doneButton:NO addItemButton:YES];
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    CGRect arrowFrame = _menuArrowImage.frame;
    [_menuArrowImage setFrame:CGRectMake(-100, arrowFrame.origin.y, arrowFrame.size.width, arrowFrame.size.height)];
    [self performSelector:@selector(userTappedOnFriends) withObject:nil afterDelay:1.0f];
    [super viewDidAppear:animated];
}

- (void)userTappedOnFeatured {
    [_featuredLabel setTextColor:labelSelectedColor];
    [_friendsLabel setTextColor:labelUnselectedColor];
    [_nearbyLabel setTextColor:labelUnselectedColor];
    [self moveMenuArrowTo:49];
    [self loadFeaturedItems];
}

- (void)userTappedOnFriends {
    [_featuredLabel setTextColor:labelUnselectedColor];
    [_friendsLabel setTextColor:labelSelectedColor];
    [_nearbyLabel setTextColor:labelUnselectedColor];
    [self moveMenuArrowTo:153];
    [self loadFriendsItems];
}

- (void)userTappedOnNearby {
    [_featuredLabel setTextColor:labelUnselectedColor];
    [_friendsLabel setTextColor:labelUnselectedColor];
    [_nearbyLabel setTextColor:labelSelectedColor];
    [self moveMenuArrowTo:264];
    [self loadNearbyItems];
}

- (void)moveMenuArrowTo:(float)xPosition {
    
    [UIView animateWithDuration:1.0f
            delay:0
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
                CGRect arrowFrame = _menuArrowImage.frame;
                [_menuArrowImage setFrame:CGRectMake(xPosition, arrowFrame.origin.y, arrowFrame.size.width, arrowFrame.size.height)];
            } completion:nil
     ];
}

- (void)loadFeaturedItems {
    
}

- (void)loadFriendsItems {
    
    // Check if a user is cached and if user is linked to Facebook
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        [itemDataSource getFriendsItemsAndReturn];
    } else {
        LogInViewController *logInViewController = [[LogInViewController alloc] initWithNibName:@"LogInViewController" bundle:nil];
        [self.navigationController pushViewController:logInViewController animated:YES];
    }
}

- (void)loadNearbyItems {
    
    [itemDataSource getNearbyItemsAndReturn];
}

#pragma mark ItemDataSourceDelegate

- (void)populateCollectionView {
    
    NSLog(@"Populating list with %d items", itemDataSource.items.count);
    [[UserCache getInstance] updateUserNameCacheDictionaryForItems:itemDataSource.items];
    [_contentDisplayCollectionView reloadData];

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


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *item = [[itemDataSource items] objectAtIndex:indexPath.row];
    
    ItemDetailsViewController *itemDetailsViewController = [[ItemDetailsViewController alloc] initWithNibName:@"ItemDetailsViewController" bundle:nil];
    [itemDetailsViewController setItemObject:item];
    [self.navigationController pushViewController:itemDetailsViewController animated:YES];
    
}


#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(147, 162);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

@end
