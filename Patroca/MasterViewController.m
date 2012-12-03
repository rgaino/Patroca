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
#import <SDWebImage/UIImageView+WebCache.h>

#define CELL_REUSE_IDENTIFIER @"Item_Cell"

@implementation MasterViewController

//@synthesize featuredLabel, friendsLabel, nearbyLabel, menuBarView;
//@synthesize menuArrowImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
                
        //Colors and patterns
        labelSelectedColor = [UIColor colorWithRed:36/255.0 green:190/255.0 blue:212/255.0 alpha:1.0f];
        labelUnselectedColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0f];

        UIColor *backgroundPattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_repeat.png"]];
        [[self view] setBackgroundColor:backgroundPattern];
        
        //making menu bar labels tappable
        UITapGestureRecognizer *featuredTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnFeatured)];
        [_featuredLabel addGestureRecognizer:featuredTap];

        UITapGestureRecognizer *friendsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnFriends)];
        [_friendsLabel addGestureRecognizer:friendsTap];

        UITapGestureRecognizer *nearbyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnNearby)];
        [_nearbyLabel addGestureRecognizer:nearbyTap];
        
        itemDataSource = [[ItemDataSource alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad {

    [self.contentDisplayCollectionView registerClass:[ItemViewCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];

}

- (void)viewDidAppear:(BOOL)animated {
    CGRect arrowFrame = _menuArrowImage.frame;
    [_menuArrowImage setFrame:CGRectMake(-100, arrowFrame.origin.y, arrowFrame.size.width, arrowFrame.size.height)];
    [self performSelector:@selector(userTappedOnFeatured) withObject:nil afterDelay:1.0f];


    //see if user is already logged in on Facebook and display the profile picture
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self userLoggedInSuccessfully];
    }

}

- (IBAction)addNewItemButtonPressed:(id)sender {
    
    AddNewItemViewController *addNewItemViewController = [[AddNewItemViewController alloc] initWithNibName:@"AddNewItemViewController" bundle:nil];
    [self.navigationController pushViewController:addNewItemViewController animated:YES];
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
        [itemDataSource getItemsAndReturnTo:self];
    } else {
        LogInViewController *logInViewController = [[LogInViewController alloc] initWithNibName:@"LogInViewController" bundle:nil];
        [self.navigationController pushViewController:logInViewController animated:YES];
    }

    
}

- (void)populateCollectionView {
    
    NSLog(@"Populating list with %d items", itemDataSource.items.count);

    [[UserCache getInstance] updateUserNameCacheDictionaryForItems:itemDataSource.items];

    [_contentDisplayCollectionView reloadData];

}

- (IBAction)loginProfileButtonPressed:(id)sender {

    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        ViewProfileViewController *viewProfileViewController = [[ViewProfileViewController alloc] initWithNibName:@"ViewProfileViewController" bundle:nil];
        [self.navigationController pushViewController:viewProfileViewController animated:YES];
    } else {
//        LogInViewController *logInViewController = [[LogInViewController alloc] initWithNibName:@"LogInViewController" bundle:nil];
//        [self.navigationController pushViewController:logInViewController animated:YES];

    
        // The permissions requested from the user
        NSArray *permissionsArray = [NSArray arrayWithObjects:
                                     @"user_about_me",
                                     @"user_relationships",
                                     @"user_location",
                                     //                                     @"offline_access",
                                     @"email",
                                     nil];
        
        // Log in
        [PFFacebookUtils logInWithPermissions:permissionsArray
                                        block:^(PFUser *user, NSError *error) {
                                            if (!user) {
                                                if (!error) { // The user cancelled the login
                                                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                                                } else { // An error occurred
                                                    NSLog(@"Uh oh. An error occurred: %@", error);
                                                }
                                            } else if (user.isNew) { // Success - a new user was created
                                                NSLog(@"User with facebook signed up and logged in!");
                                                [self userLoggedInSuccessfully];
                                            } else { // Success - an existing user logged in
                                                NSLog(@"User with facebook logged in!");
                                                [self userLoggedInSuccessfully];
                                            }
                                        }];
    
    
    }
}

-(void) userLoggedInSuccessfully {

    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[PFUser currentUser] objectForKey:DB_FIELD_USER_FACEBOOK_ID]]];
    [_loginProfileButton.imageView setImageWithURL:profilePictureURL placeholderImage:nil];
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
    
    return itemViewCell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}


#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(147, 205);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 10, 5, 10);
}

@end
