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

- (void)showErrorIcon {
    //TODO: this
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupHeaderWithBackButton:YES doneButton:NO addItemButton:YES];

    [_contentDisplayCollectionView registerClass:[ItemViewCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];
    [_contentDisplayCollectionView registerClass:[ProfileHeaderViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_CELL_REUSE_IDENTIFIER];
    
    userData = nil;
    
    //add infinite scrolling
    [_contentDisplayCollectionView addInfiniteScrollingWithActionHandler:^{
        [itemDataSource getNextPageAndReturnWithCallback:^(NSError *error) {  }];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [_contentDisplayCollectionView reloadData];
}

- (void)setupViewWithUserID:(NSString*)profileUserID {
    
    userObject = [[UserCache getInstance] getCachedUserForId:profileUserID];
    [self readUserDataFromFacebook];
}

- (void)readUserDataFromFacebook {
    
    NSString *userFacebookID = [userObject objectForKey:DB_FIELD_USER_FACEBOOK_ID];
    NSString *facebookGraphPath = [NSString stringWithFormat:@"%@/?fields=name,location,picture,email", userFacebookID];
    FBRequest *request = [FBRequest requestForGraphPath:facebookGraphPath];
    [request startWithCompletionHandler:^(FBRequestConnection *connection,
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
    [itemDataSource getNextPageAndReturnWithCallback:^(NSError *error) {}];
    
    [_contentDisplayCollectionView registerClass:[ItemViewCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];
    [_contentDisplayCollectionView registerClass:[ProfileHeaderViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_CELL_REUSE_IDENTIFIER];
   
}



#pragma mark ItemDataSourceDelegate

- (void)populateCollectionView {
    
    NSLog(@"Populating list with %lu items", (unsigned long)itemDataSource.items.count);
    [[UserCache getInstance] updateUserNameCacheDictionaryForItems:itemDataSource.items];
    [_contentDisplayCollectionView reloadData];
}

- (void)addItemsToCollectionView {
    
    NSLog(@"Addind items to list, new total is %lu", (unsigned long)itemDataSource.items.count);
    [[UserCache getInstance] updateUserNameCacheDictionaryForItems:itemDataSource.items];
    [_contentDisplayCollectionView reloadData];
    [_contentDisplayCollectionView.infiniteScrollingView stopAnimating];
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
    [itemViewCell setParentController:self];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:itemViewCell action:@selector(openItemDetailsPage)];
    singleTap.numberOfTapsRequired = 1;
    [itemViewCell addGestureRecognizer:singleTap];
        
    return itemViewCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{

    ProfileHeaderViewCell *profileHeaderViewCell = [collectionView dequeueReusableSupplementaryViewOfKind:
                                         UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_CELL_REUSE_IDENTIFIER forIndexPath:indexPath];

    if(userData != nil) {
        [profileHeaderViewCell setupProfileHeaderViewCellWithUser:userObject UserData:userData];
        [profileHeaderViewCell setParentViewController:self];
    }


    return profileHeaderViewCell;
}



#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(97, 97);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 7, 0, 7);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 7;
}

//header size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(320, 261);
}


@end
