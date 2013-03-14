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

@interface ViewProfileViewController : BaseViewController <ItemDataSourceDelegate,
                                                            UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {

    PFUser *userObject;
    ItemDataSource *itemDataSource;
    NSDictionary *userData;
    NSMutableDictionary *totalCommentsForItemsDictionary;
}

@property (weak, nonatomic) IBOutlet UICollectionView *contentDisplayCollectionView;

- (void)setupViewWithUserID:(NSString*)profileUserID;
- (void)readUserDataFromFacebook;
- (void)facebookLoggedInWithResult:(id)result;

@end
