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
#import "ViewProfileViewController.h"
#import "UserCache.h"
#import "AddNewItemViewController.h"
#import "ItemDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVPullToRefresh.h"

#define CELL_REUSE_IDENTIFIER @"Item_Cell_Master"

@implementation MasterViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
                
        //Colors and patterns
        labelSelectedColor = [UIColor colorWithRed:36/255.0 green:190/255.0 blue:212/255.0 alpha:1.0f];
        labelUnselectedColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0f];
        
        itemDataSource = [[ItemDataSource alloc] init];
        [itemDataSource setDelegate:self];
        
    }
    return self;
}

- (void)viewDidLoad {

    totalCommentsForItemsDictionary = [[NSMutableDictionary alloc] init];
    [self.contentDisplayCollectionView registerClass:[ItemViewCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];
    [self setupHeaderWithBackButton:NO doneButton:NO addItemButton:YES];
    
    //add pull to refresh control
    refreshControl = UIRefreshControl.alloc.init;
    [refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [_contentDisplayCollectionView addSubview:refreshControl];
    
    //add infinite scrolling
    [_contentDisplayCollectionView addInfiniteScrollingWithActionHandler:^{
        [itemDataSource getNextPageAndReturn];
    }];
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    CGRect arrowFrame = _menuArrowImage.frame;
    [_menuArrowImage setFrame:CGRectMake(-100, arrowFrame.origin.y, arrowFrame.size.width, arrowFrame.size.height)];
    [self performSelector:@selector(friendsButtonPressed:) withObject:nil afterDelay:1.0f];
    [super viewDidAppear:animated];
}

- (void)startRefresh:(id)sender {
    [itemDataSource refresh];
}

- (IBAction)featuredButtonPressed:(id)sender {
    [_featuredButton setTitleColor:labelSelectedColor forState:UIControlStateNormal];
    [_friendsButton setTitleColor:labelUnselectedColor forState:UIControlStateNormal];
    [_nearbyButton setTitleColor:labelUnselectedColor forState:UIControlStateNormal];
    [self moveMenuArrowTo:49];
    [itemDataSource clearAndReturn];
    [_loadingActivityIndicator startAnimating];
    [self loadFeaturedItems];
}

- (IBAction)friendsButtonPressed:(id)sender {
    [_featuredButton setTitleColor:labelUnselectedColor forState:UIControlStateNormal];
    [_friendsButton setTitleColor:labelSelectedColor forState:UIControlStateNormal];
    [_nearbyButton setTitleColor:labelUnselectedColor forState:UIControlStateNormal];
    [self moveMenuArrowTo:153];
    [itemDataSource clearAndReturn];
    [_loadingActivityIndicator startAnimating];
    [self loadFriendsItems];
}

- (IBAction)nearbyButtonPressed:(id)sender {
    [_featuredButton setTitleColor:labelUnselectedColor forState:UIControlStateNormal];
    [_friendsButton setTitleColor:labelUnselectedColor forState:UIControlStateNormal];
    [_nearbyButton setTitleColor:labelSelectedColor forState:UIControlStateNormal];
    [self moveMenuArrowTo:264];
    [itemDataSource clearAndReturn];
    [_loadingActivityIndicator startAnimating];
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
    
    ////
//    PFQuery *originalQuery = [PFQuery queryWithClassName:DB_TABLE_ITEMS];
//    PFObject *originalItem = [originalQuery getObjectWithId:@"ziyuLZHZba"];
//    
//    for(int i=1; i<=500; i++) {
//        NSLog(@"Duplicating item, step %d", i);
//        
//        NSString *title = [NSString stringWithFormat:@"Teste %d", i];
//        
//        PFObject *cloneItem = [PFObject objectWithClassName:DB_TABLE_ITEMS];
//        [cloneItem setObject:title forKey:DB_FIELD_ITEM_NAME];
//        [cloneItem setObject:[originalItem objectForKey:DB_FIELD_ITEM_DESCRIPTION] forKey:DB_FIELD_ITEM_DESCRIPTION];
//        [cloneItem setObject:[originalItem objectForKey:DB_FIELD_ITEM_LOCATION] forKey:DB_FIELD_ITEM_LOCATION];
//        [cloneItem setObject:[originalItem objectForKey:DB_FIELD_ITEM_MAIN_IMAGE] forKey:DB_FIELD_ITEM_MAIN_IMAGE];
//        [cloneItem setObject:[originalItem objectForKey:DB_FIELD_USER_ID] forKey:DB_FIELD_USER_ID];
//        [cloneItem save];
//    }
//    
//    
//    return;
    /////
    
    [itemDataSource setItemDataSourceMode:ItemDataSourceModeFeatured];
    [itemDataSource getNextPageAndReturn];
}

- (void)loadFriendsItems {
    
    // Check if a user is cached and if user is linked to Facebook
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        [itemDataSource setItemDataSourceMode:ItemDataSourceModeFriends];
        [itemDataSource getNextPageAndReturn];
    } else {
        [self nearbyButtonPressed:nil];
    }
}

- (void)loadNearbyItems {
    
    [itemDataSource setItemDataSourceMode:ItemDataSourceModeNearby];
    [itemDataSource getNextPageAndReturn];
}


#pragma mark ItemDataSourceDelegate

- (void)populateCollectionView {
    
    NSLog(@"Populating list with %d items", itemDataSource.items.count);
    [[UserCache getInstance] updateUserNameCacheDictionaryForItems:itemDataSource.items];
    [_contentDisplayCollectionView reloadData];
    [refreshControl endRefreshing];
    [_loadingActivityIndicator stopAnimating];
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
