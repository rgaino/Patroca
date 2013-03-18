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
#import "UILabel+UILabel_Resize.h"

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

    [self localizeStrings];

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
    
    //if user is logged in, load friends, otherwise load nearby
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self performSelector:@selector(menuButtonPressed:) withObject:_friendsButton afterDelay:1.0f];
    } else {
        [self performSelector:@selector(menuButtonPressed:) withObject:_nearbyButton afterDelay:1.0f];
    }
    
    //create the error message view
    [self createErrorMessageView];
    
    //make sure the content view is always at the top
    [self.view bringSubviewToFront:_contentDisplayCollectionView];
    
    [super viewDidLoad];
}

- (void)localizeStrings {
    [_featuredButton setTitle:NSLocalizedString(@"featured", nil) forState:UIControlStateNormal];
    [_friendsButton setTitle:NSLocalizedString(@"friends", nil) forState:UIControlStateNormal];
    [_nearbyButton setTitle:NSLocalizedString(@"nearby", nil) forState:UIControlStateNormal];
}


- (void)createErrorMessageView {
    //create the error message view but it's empty for now
    errorMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, _contentDisplayCollectionView.frame.origin.y, self.view.frame.size.width, 250)];
    [errorMessageView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:errorMessageView];
}

- (void)startRefresh:(id)sender {
    [itemDataSource refresh];
}

- (IBAction)menuButtonPressed:(id)sender {

    UIButton *menuButton = (UIButton*)sender;
    
    //remove any error message and show the collection view in case it's hidden
    [[errorMessageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_contentDisplayCollectionView setHidden:NO];

    //highlight the selected menu button
    [_featuredButton setTitleColor:labelUnselectedColor forState:UIControlStateNormal];
    [_friendsButton setTitleColor:labelUnselectedColor forState:UIControlStateNormal];
    [_nearbyButton setTitleColor:labelUnselectedColor forState:UIControlStateNormal];
    [menuButton setTitleColor:labelSelectedColor forState:UIControlStateNormal];
    
    //animate the arrow to the center of the button
    float arrowPosition = menuButton.frame.origin.x + (menuButton.frame.size.width/2) - (_menuArrowImage.frame.size.width/2);
    [self moveMenuArrowTo:arrowPosition];

    //load data
    [itemDataSource clearAndReturn];
    [_loadingActivityIndicator startAnimating];
    
    switch (menuButton.tag) {
        case 0:
            [self loadFeaturedItems];
            break;
        case 1:
            [self loadFriendsItems];
            break;
        case 2:
            [self loadNearbyItems];
            break;
        default:
            break;
    }
    
    
}



- (void)moveMenuArrowTo:(float)xPosition {
    
    //change the arrow image leading space constraint...
    [_arrowHorizontalSpacingConstraint setConstant:xPosition];
    
    //... then animate it
    [UIView animateWithDuration:1.0f
            delay:0
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
                [_menuBarView layoutSubviews];
            } completion:nil
     ];
}

- (void)loadFeaturedItems {
    
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

        //build the error message for a user with no friends on Patroca
        [_contentDisplayCollectionView setHidden:YES];
        
        UILabel *oopsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, errorMessageView.frame.size.width-120, 100)];
        [oopsLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [oopsLabel setTextAlignment:NSTextAlignmentCenter];
        [oopsLabel setNumberOfLines:0];
        [oopsLabel setBackgroundColor:[UIColor clearColor]];
        [oopsLabel setText:NSLocalizedString(@"oops_friends", nil)];
        [oopsLabel sizeToFit];
        [oopsLabel setFrame:CGRectMake(errorMessageView.frame.size.width/2 - oopsLabel.frame.size.width/2, oopsLabel.frame.origin.y, oopsLabel.frame.size.width, oopsLabel.frame.size.height)];
        [errorMessageView addSubview:oopsLabel];
        
        NSShadow *dropShadow = [[NSShadow alloc] init];
        [dropShadow setShadowColor:[UIColor whiteColor]];
        [dropShadow setShadowBlurRadius:0];
        [dropShadow setShadowOffset:CGSizeMake(-1, 0)];
        
        NSMutableAttributedString *fullInviteString = [[NSMutableAttributedString alloc] init];
        NSString *inviteString = NSLocalizedString(@"invite_them", nil);
        NSMutableAttributedString *inviteAttributedString = [[NSMutableAttributedString alloc] initWithString:inviteString];
        [inviteAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:197/255.0f green:18/255.0f blue:67/255.0f alpha:1.0f] range:NSMakeRange(0, inviteString.length)];
        [inviteAttributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, inviteString.length)];
        [inviteAttributedString addAttribute:NSShadowAttributeName value:dropShadow range:NSMakeRange(0, inviteString.length)];
        [fullInviteString appendAttributedString:inviteAttributedString];
        
        NSString *searchForPeopleString = NSLocalizedString(@"or_search_for_people_around_you", nil);
        NSMutableAttributedString *searchForPeopleAttributedString = [[NSMutableAttributedString alloc] initWithString:searchForPeopleString];
        [searchForPeopleAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:89/255.0f green:89/255.0f blue:89/255.0f alpha:1.0f] range:NSMakeRange(0, searchForPeopleString.length)];
        [fullInviteString appendAttributedString:searchForPeopleAttributedString];
        
        UILabel *inviteFriendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, oopsLabel.frame.origin.y+oopsLabel.frame.size.height+5, errorMessageView.frame.size.width-120, 100)];
        [inviteFriendsLabel setAttributedText:fullInviteString];
        [inviteFriendsLabel setBackgroundColor:[UIColor clearColor]];
        [inviteFriendsLabel setTextAlignment:NSTextAlignmentCenter];
        [inviteFriendsLabel setNumberOfLines:0];
        [inviteFriendsLabel sizeToFit];
        [inviteFriendsLabel setFrame:CGRectMake(errorMessageView.frame.size.width/2 - inviteFriendsLabel.frame.size.width/2, inviteFriendsLabel.frame.origin.y, inviteFriendsLabel.frame.size.width, inviteFriendsLabel.frame.size.height)];
        
        UIButton *inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [inviteFriendsButton setFrame:inviteFriendsLabel.frame];
        [inviteFriendsButton.titleLabel setNumberOfLines:0];
        [inviteFriendsButton.titleLabel setTextAlignment:0];
        [inviteFriendsButton setAttributedTitle:fullInviteString forState:UIControlStateNormal];
        [inviteFriendsButton addTarget:self action:@selector(inviteFriendsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [errorMessageView addSubview:inviteFriendsButton];

        [_loadingActivityIndicator stopAnimating];
    }
}

- (void)loadNearbyItems {
    
    [itemDataSource setItemDataSourceMode:ItemDataSourceModeNearby];
    [itemDataSource getNextPageAndReturn];
}

- (void)inviteFriendsButtonPressed {
    //    [FBNativeDialogs presentShareDialogModallyFrom:self initialText:@"initialText" image:nil url:[NSURL URLWithString:@"http://joystiq.com"] handler:^(FBNativeDialogResult result, NSError *error) {
    //
    //    }     ];
    
    //    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    //                                   @"Nome do Patroca", @"name",
    //                                   @"Patroca.", @"caption",
    //                                   @"Texto para instigar os amigos.", @"description",
    //                                   @"http://www.patroca.com/", @"link",
    ////                                   @"http://www.facebookmobileweb.com/hackbook/img/facebook_icon_large.png", @"picture",
    ////                                   actionLinksStr, @"actions",
    //                                   nil];
    
    //    [FBNativeDialogs presentShareDialogModallyFrom:self initialText:nil image:nil url:[NSURL URLWithString:@"http://www.patroca.com/"] handler:^(FBNativeDialogResult result, NSError *error) {
    //        NSLog(@"");
    //    }];
    
    //    [FBWebDialogs presentFeedDialogModallyWithSession:[PFFacebookUtils session] parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
    //        NSLog(@"");
    //    }];
    
    /*
     currentAPICall = kDialogFeedUser;
     FBSBJSON *jsonWriter = [[FBSBJSON new] autorelease];
     
     // The action links to be shown with the post in the feed
     NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
     @"Get Started",@"name",@"http://m.facebook.com/apps/hackbookios/",@"link", nil], nil];
     NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
     // Dialog parameters
     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"I'm using the Hackbook for iOS app", @"name",
     @"Hackbook for iOS.", @"caption",
     @"Check out Hackbook for iOS to learn how you can make your iOS apps social using Facebook Platform.", @"description",
     @"http://m.facebook.com/apps/hackbookios/", @"link",
     @"http://www.facebookmobileweb.com/hackbook/img/facebook_icon_large.png", @"picture",
     actionLinksStr, @"actions",
     nil];
     
     HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
     [[delegate facebook] dialog:@"feed"
     andParams:params
     andDelegate:self];
     */

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
