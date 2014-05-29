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
#import "HelpView.h"
#import "FacebookUtilsCache.h"

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
    
    //adjust view positions for iOS7 status bar
    [_menuBarView setFrame:CGRectMake(_menuBarView.frame.origin.x, _menuBarView.frame.origin.y + headerOffset,_menuBarView.frame.size.width, _menuBarView.frame.size.height)];
    [_contentDisplayCollectionView setFrame:CGRectMake(0, _menuBarView.frame.origin.y + 44, _contentDisplayCollectionView.frame.size.width, self.view.frame.size.height - (_menuBarView.frame.origin.y + 44))];

    totalCommentsForItemsDictionary = [[NSMutableDictionary alloc] init];
    [self.contentDisplayCollectionView registerClass:[ItemViewCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];
    [self setupHeaderWithBackButton:NO doneButton:NO addItemButton:YES];
    
    //add pull to refresh control
    refreshControl = UIRefreshControl.alloc.init;
    [refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [_contentDisplayCollectionView addSubview:refreshControl];
    
    //add infinite scrolling
    [_contentDisplayCollectionView addInfiniteScrollingWithActionHandler:^{
        [itemDataSource getNextPageAndReturnWithCallback:^(NSError *error) {}];
    }];
    
    
    //create the error message view
    [self createErrorMessageView];
    
    //make sure the content view is always at the top
    [self.view bringSubviewToFront:_contentDisplayCollectionView];
    
    [super viewDidLoad];
    
    //if user is logged in, load friends, otherwise load nearby
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//        [self performSelector:@selector(menuButtonPressed:) withObject:_friendsButton afterDelay:1.0f];
    } else {
        HelpView *loginHelpView = [[HelpView alloc] initWithStyle:HelpViewTypeLogin];
        [self.view addSubview:loginHelpView];
    }

}

- (void)localizeStrings {
    [_featuredButton setTitle:NSLocalizedString(@"featured", nil) forState:UIControlStateNormal];
    [_friendsButton setTitle:NSLocalizedString(@"friends", nil) forState:UIControlStateNormal];
    [_nearbyButton setTitle:NSLocalizedString(@"nearby", nil) forState:UIControlStateNormal];
}


-(void) userLoggedInSuccessfully {
    
    [_addNewItemButton setEnabled:YES];
    
    // Create request for user's Facebook data
    NSString *requestPath = @"me/?fields=name,email";
    
    FBRequest *request = [FBRequest requestForGraphPath:requestPath];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
            NSString *facebookId = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *email      = ([userData objectForKey:@"email"] == nil ? @"" : [userData objectForKey:@"email"]);
            
            //store info on Parse User table
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:facebookId forKey:DB_FIELD_USER_FACEBOOK_ID];
            [currentUser setObject:name forKey:DB_FIELD_USER_NAME];
            [currentUser setEmail:email];
            
            __unsafe_unretained typeof(self) weakSelf = self;
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", facebookId]];
                
                [_loginProfileButton.imageView setImageWithURL:profilePictureURL placeholderImage:[UIImage imageNamed:@"avatar_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    //TODO: check for error and do something about it
                    [weakSelf.loginActivityIndicator stopAnimating];
                    
                    if(!error) {
                        [weakSelf.loginProfileButton setImage:weakSelf.loginProfileButton.imageView.image forState:UIControlStateNormal];
                    } else {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        [weakSelf.loginProfileButton setImage:[UIImage imageNamed:@"login_with_fb.png"] forState:UIControlStateNormal];
                    }
                }];
                
                PFInstallation *myInstallation = [PFInstallation currentInstallation];
                [myInstallation setObject:[PFUser currentUser] forKey:DB_FIELD_USER_ID];
                
                [myInstallation saveInBackground];

                [self menuButtonPressed:_friendsButton];
                
            }];
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            //probably token expired or user logged out
            [PFUser logOut];
            [_loginActivityIndicator stopAnimating];
            [_loginProfileButton setImage:[UIImage imageNamed:@"login_with_fb.png"] forState:UIControlStateNormal];
        }
    }];
    
}

- (void)createErrorMessageView {
    //create the error message view but it's empty for now
    errorMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, _contentDisplayCollectionView.frame.origin.y, self.view.frame.size.width, 250)];
    [errorMessageView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:errorMessageView];
}

- (void)showErrorIcon {
    [_contentDisplayCollectionView setHidden:YES];
    [_loadingActivityIndicator stopAnimating];
    [self createErrorMessageView];
    UIImageView *errorIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
    float centerX = (errorMessageView.frame.size.width/2) - (errorIconImageView.frame.size.width/2);
    [errorIconImageView setFrame:CGRectMake(centerX, 40, errorIconImageView.frame.size.width, errorIconImageView.frame.size.height)];
    [errorMessageView addSubview:errorIconImageView];
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
            [self loadNearbyItems];
            break;
        case 1:
            [self loadFriendsItems];
            break;
        case 2:
            [self loadFeaturedItems];
            break;
        default:
            break;
    }
}


- (void)moveMenuArrowTo:(float)xPosition {
    
    //change the arrow image leading space constraint...
//    [_arrowHorizontalSpacingConstraint setConstant:xPosition];
    
    //... then animate it
    [UIView animateWithDuration:1.0f
            delay:0
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
//                [_menuBarView layoutSubviews];
                [_menuArrowImage setFrame:CGRectMake(xPosition, _menuArrowImage.frame.origin.y, _menuArrowImage.frame.size.width, _menuArrowImage.frame.size.height)];
            } completion:nil
     ];
}

- (void)loadFeaturedItems {

    // Check if a user is cached and if user is linked to Facebook
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {

        [itemDataSource setItemDataSourceMode:ItemDataSourceModeFeatured];
        [itemDataSource getNextPageAndReturnWithCallback:^(NSError *error) {
            [_loadingActivityIndicator stopAnimating];
            if (error) {
                [self showErrorIcon];
            }
        }];
    } else {
        //user not logged in yet
        [self showErrorIcon];
    }
}

- (void)loadFriendsItems {
    
    // Check if a user is cached and if user is linked to Facebook
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        [itemDataSource setItemDataSourceMode:ItemDataSourceModeFriends];
        [itemDataSource getNextPageAndReturnWithCallback:^(NSError *error) {
            if(!error && itemDataSource.items.count==0) {
                //list empty, show invite message
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
            if (error) {
                [self showErrorIcon];
            }
        }];
    } else {
        //user not logged in yet
        [self showErrorIcon];
    }
}

- (void)loadNearbyItems {
    
    [itemDataSource setItemDataSourceMode:ItemDataSourceModeNearby];
    [itemDataSource getNextPageAndReturnWithCallback:^(NSError *error) {
        [_loadingActivityIndicator stopAnimating];
        if (error) {
            [self showErrorIcon];
        }
    }];
}


- (void)inviteFriendsButtonPressed {
    [[FacebookUtilsCache getInstance] tellYourFriends];
}

#pragma mark ItemDataSourceDelegate

- (void)populateCollectionView {
    
    NSLog(@"Populating list with %lu items", (unsigned long)itemDataSource.items.count);
    [[UserCache getInstance] updateUserNameCacheDictionaryForItems:itemDataSource.items];
    [_contentDisplayCollectionView reloadData];
    [refreshControl endRefreshing];
    [_loadingActivityIndicator stopAnimating];
}

- (void)addItemsToCollectionView {

    NSLog(@"Addind items to list, new total is %lu", (unsigned long)itemDataSource.items.count);
    [[UserCache getInstance] updateUserNameCacheDictionaryForItems:itemDataSource.items];
    [_contentDisplayCollectionView reloadData];
    [_contentDisplayCollectionView.infiniteScrollingView stopAnimating];
}



- (void)populateTotalCommentsWithDictionary:(NSDictionary*)tempTotalCommentsForItemsDictionary {
    
    //updating the dictionary with items and their total comments...
    NSArray *itemIDs = [tempTotalCommentsForItemsDictionary objectForKey:@"item_ids"];
    NSArray *itemTotalComments = [tempTotalCommentsForItemsDictionary objectForKey:@"item_comments"];
    for(int i=0; i<itemIDs.count; i++) {
        [totalCommentsForItemsDictionary setObject:[itemTotalComments objectAtIndex:i] forKey:[itemIDs objectAtIndex:i]];
    }
    
    //...then update all visible cells
    for(ItemViewCell *itemViewCell in [_contentDisplayCollectionView visibleCells]) {
        [self updateTotalCommentsForItemViewCell:itemViewCell];
    }
}

- (void)updateTotalCommentsForItemViewCell:(ItemViewCell*)itemViewCell {
    
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
    
    [self updateTotalCommentsForItemViewCell:itemViewCell];
    
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
    return CGSizeMake(97, 97);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 2, 5, 2);
}

@end
