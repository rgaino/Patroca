//
//  ViewProfileViewController.h
//  Patroca
//
//  Created by Rafael Gaino on 8/23/12.
//  Copyright (c) 2012 Punk Opera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ItemDataSourceDelegate.h"
#import <Parse/Parse.h>

@class ItemDataSource;
@class PFObject;

@interface ViewProfileViewController : BaseViewController <PF_FBRequestDelegate, ItemDataSourceDelegate,
                                                            UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {

    ItemDataSource *itemDataSource;
    NSDictionary *userData;
    NSMutableDictionary *totalCommentsForItemsDictionary;
}

@property (weak, nonatomic) IBOutlet UICollectionView *contentDisplayCollectionView;

- (IBAction)logoutButtonPressed:(id)sender;
- (void)setupViewWithUserID:(NSString*)profileUserID;
- (void)readUserDataFromFacebookForUser:(PFObject*)userObject;
- (void)facebookLoggedInWithResult:(id)result;

@end
